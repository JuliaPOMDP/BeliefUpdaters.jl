"""
    StagedDiscreteBelief

A given stage's belief specified by a probability vector.

Normalization of `b` is assumed in some calculations (e.g. pdf), but it is only automatically enforced in `update(...)`, and a warning is given if normalized incorrectly in `StagedDiscreteBelief(pomdp, b)`.

# Constructor
    StagedDiscreteBelief(pomdp, b::Vector{Float64}, st::Int; check::Bool=true)

# Fields
- `pomdp` : the POMDP problem wrapped in FixedHorizon(PO)MDPWrapper struct
            from FiniteHorizonPOMDPs.jl
- `state_list` : a vector of ordered states in a given stage
                (Tuple of Infinite Horizon states and stage number)
                eg. (:StateX, 1)
- `b` : the probability vector
- `st` : number of POMDP's stage that `StagedDiscreteBelief` represents
"""
struct StagedDiscreteBelief{P<:FiniteHorizonPOMDPs.FHWrapper, S}
    pomdp::P
    state_list::Vector{S}
    b::Vector{Float64}
    st::Int
end


function StagedDiscreteBelief(pomdp::FiniteHorizonPOMDPs.FHWrapper, b::Vector{Float64}, st; check::Bool=true)
    if check
        if !isapprox(sum(b), 1.0, atol=0.001)
            @warn """
                  b in StagedDiscreteBelief(pomdp, b) does not sum to 1.

                  To suppress this warning use `StagedDiscreteBelief(pomdp, b, check=false)`
                  """
        end
        if !all(0.0 <= p <= 1.0 for p in b)
            @warn """
                  b in StagedDiscreteBelief(pomdp, b) contains entries outside [0,1].

                  To suppress this warning use `StagedDiscreteBelief(pomdp, b, check=false)`
                  """
        end
    end
    return StagedDiscreteBelief(pomdp, ordered_stage_states(pomdp, st), b, st)
end


function StagedDiscreteBelief(pomdp::FiniteHorizonPOMDPs.FHWrapper,
        d::FiniteHorizonPOMDPs.InStageDistribution; check::Bool=true)
    st = FiniteHorizonPOMDPs.stage(d)
    state_list = ordered_stage_states(pomdp, st)
    b = [pdf(d, ss) for ss in state_list]
    if check
        if !isapprox(sum(b), 1.0, atol=0.001)
            @warn """
                  b in StagedDiscreteBelief(pomdp, b) does not sum to 1.

                  To suppress this warning use `StagedDiscreteBelief(pomdp, b, check=false)`
                  """
        end
        if !all(0.0 <= p <= 1.0 for p in b)
            @warn """
                  b in StagedDiscreteBelief(pomdp, b) contains entries outside [0,1].

                  To suppress this warning use `StagedDiscreteBelief(pomdp, b, check=false)`
                  """
        end
    end
    return StagedDiscreteBelief(pomdp, state_list, b, st)
end

stage(b::StagedDiscreteBelief) = b.st

"""
     uniform_staged_belief(pomdp::FiniteHorizonPOMDPs.FHWrapper)

Return a StagedDiscreteBelief with equal probability for each state in a given stage.
"""
function uniform_staged_belief(pomdp::FiniteHorizonPOMDPs.FHWrapper; st::Int=1)
    state_list = ordered_stage_states(pomdp, st)
    ns = length(state_list)
    return StagedDiscreteBelief(pomdp, state_list, ones(ns) / ns, st)
end

function uniform_belief(pomdp::FiniteHorizonPOMDPs.FHWrapper)
    return uniform_staged_belief(pomdp, 1)
end


function POMDPs.pdf(b::StagedDiscreteBelief, ss::Tuple{<:Any, Int})
    if FiniteHorizonPOMDPs.stage(b.pomdp, ss) == stage(b)
        return b.b[stage_stateindex(b.pomdp, ss)]
    end
    return 0.
end

function Random.rand(rng::Random.AbstractRNG, b::StagedDiscreteBelief)
    i = sample(rng, Weights(b.b))
    return (b.state_list[i], stage(b))
end

function Base.fill!(b::StagedDiscreteBelief, x::Float64)
    fill!(b.b, x)
    return b
end

Base.length(b::StagedDiscreteBelief) = length(b.b)

support(b::StagedDiscreteBelief) = b.state_list

# TODO: I think this should work with state indices:
# sum(stage_stateindex.(b.pomdp, b.state_list) .*b.b)
# This would probablyu need something like ref(pomdp)
Statistics.mean(b::StagedDiscreteBelief) = sum(b.state_list.*b.b)/sum(b.b)
StatsBase.mode(b::StagedDiscreteBelief) = b.state_list[argmax(b.b)]

function ==(b1::StagedDiscreteBelief, b2::StagedDiscreteBelief)
    b1.state_list == b2.state_list && b1.b == b2.b && stage(b1) == stage(b2)
end

function Base.hash(b::StagedDiscreteBelief, h::UInt)
    hash(b.b, hash(b.state_list, hash(stage(b), h)))
end

uniform_staged_belief(bu::DiscreteUpdater, st::Int=1) = uniform_staged_belief(bu.pomdp, st)

function initialize_belief(bu::DiscreteUpdater, d::FiniteHorizonPOMDPs.InStageDistribution)
    st = FiniteHorizonPOMDPs.stage(d)
    state_list = ordered_stage_states(bu.pomdp, st)
    ns = length(state_list)
    b = zeros(ns)
    belief = StagedDiscreteBelief(bu.pomdp, state_list, b, st)
    for s in POMDPModelTools.support(d)
        sidx = FiniteHorizonPOMDPs.stage_stateindex(bu.pomdp, s)
        belief.b[sidx] = pdf(d, s)
    end
    return belief
end


function update(bu::DiscreteUpdater, b::StagedDiscreteBelief, a, o)
    pomdp = bu.pomdp
    state_space = b.state_list
    bp = zeros(length(state_space))

    for (si, s) in enumerate(state_space)
        si = stage_stateindex(pomdp, s)

        if pdf(b, s) > 0.0
            td = transition(pomdp, s, a)

            for (sp, tp) in weighted_iterator(td)
                spi = stage_stateindex(pomdp, sp)
                op = obs_weight(pomdp, s, a, sp, o) # shortcut for observation probability from POMDPModelTools

                bp[spi] += op * tp * b.b[si]
            end
        end
    end

    bp_sum = sum(bp)

    if bp_sum == 0.0
        error("""
              Failed discrete belief update: new probabilities sum to zero.

              b = $b
              a = $a
              o = $o

              Failed discrete belief update: new probabilities sum to zero.
              """)
    end

    # Normalize
    bp ./= bp_sum

    return StagedDiscreteBelief(pomdp, ordered_stage_states(pomdp, stage(b)+1), bp, stage(b)+1)
end
