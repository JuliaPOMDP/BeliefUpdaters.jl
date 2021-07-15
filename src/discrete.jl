# Goals: minimize calls to ordered_states (allocates memory)

# needs pomdp for stateindex in pdf(b, s)
# needs list of ordered_states for rand(b)

"""
    DiscreteBelief

A belief specified by a probability vector.

Normalization of `b` is assumed in some calculations (e.g. pdf), but it is only automatically enforced in `update(...)`, and a warning is given if normalized incorrectly in `DiscreteBelief(pomdp, b)`.

# Constructor
    DiscreteBelief(pomdp, b::Vector{Float64}; check::Bool=true)

# Fields 
- `pomdp` : the POMDP problem  
- `state_list` : a vector of ordered states
- `b` : the probability vector 
"""
struct DiscreteBelief{P<:POMDP, S}
    pomdp::P
    state_list::Vector{S}       # vector of ordered states
    b::Vector{Float64}
end


function DiscreteBelief(pomdp, b; check::Bool=true)
    DiscreteBelief(HorizonLength(pomdp), pomdp, b, check)
end


function DiscreteBelief(::InfiniteHorizon, pomdp, b::Vector{Float64}, check::Bool)
    if check
        if !isapprox(sum(b), 1.0, atol=0.001)
            @warn """
                  b in DiscreteBelief(pomdp, b) does not sum to 1.
 
                  To suppress this warning use `DiscreteBelief(pomdp, b, check=false)`
                  """
        end
        if !all(0.0 <= p <= 1.0 for p in b)
            @warn """
                  b in DiscreteBelief(pomdp, b) contains entries outside [0,1].
 
                  To suppress this warning use `DiscreteBelief(pomdp, b, check=false)`
                  """
        end
    end
    return DiscreteBelief(pomdp, ordered_states(pomdp), b)
end


function DiscreteBelief(::FiniteHorizon, pomdp, d::InStageDistribution, check::Bool)
    b = distribution(d).probs
    if check
        if !isapprox(sum(b), 1.0, atol=0.001)
            @warn """
                  b in DiscreteBelief(pomdp, b) does not sum to 1.

                  To suppress this warning use `DiscreteBelief(pomdp, b, check=false)`
                  """
        end
        if !all(0.0 <= p <= 1.0 for p in b)
            @warn """
                  b in DiscreteBelief(pomdp, b) contains entries outside [0,1].

                  To suppress this warning use `DiscreteBelief(pomdp, b, check=false)`
                  """
        end
    end
    return DiscreteBelief(pomdp, ordered_stage_states(pomdp, stage(d)), b)
end


"""
     uniform_belief(pomdp)

Return a DiscreteBelief with equal probability for each state.
"""
function uniform_belief(pomdp)
    state_list = ordered_states(pomdp)
    ns = length(state_list)
    return DiscreteBelief(pomdp, state_list, ones(ns) / ns)
end

# TODO suggestion: If we find that uniform_belief is necessarry for staged DiscreteBeliefs,
# we can add uniform_belief(pomdp) which creates DiscreteBelief for first stage
# or define new uniform_bleief(pomdp, stage) for a given stage
# Something like:
# uniform_belief(::FiniteHorizon, pomdp, stage) {...}
# uniform_belief(::FiniteHorizon, pomdp) = uniform_belief(::FiniteHorizon, pomdp, 1)
# uniform_belief(pomdp) = uniform_belief(HorizonLength(pomdp), pomdp, 1)
# uniform_belief(pomdp, stage) = uniform_belief(HorizonLength(pomdp), pomdp, stage)

pdf(b::DiscreteBelief, s) = pdf(HorizonLength(b.pomdp), b, s)
pdf(::FiniteHorizon, b::DiscreteBelief, s) = b.b[stage_stateindex(b.pomdp, s)]
pdf(::InfiniteHorizon, b::DiscreteBelief, s) = b.b[stateindex(b.pomdp, s)]

function Random.rand(rng::Random.AbstractRNG, b::DiscreteBelief)
    i = sample(rng, Weights(b.b))
    return b.state_list[i]
end

function Base.fill!(b::DiscreteBelief, x::Float64)
    fill!(b.b, x)
    return b
end

Base.length(b::DiscreteBelief) = length(b.b)

support(b::DiscreteBelief) = b.state_list

Statistics.mean(b::DiscreteBelief) = sum(b.state_list.*b.b)/sum(b.b)
StatsBase.mode(b::DiscreteBelief) = b.state_list[argmax(b.b)]

==(b1::DiscreteBelief, b2::DiscreteBelief) = b1.state_list == b2.state_list && b1.b == b2.b

Base.hash(b::DiscreteBelief, h::UInt) = hash(b.b, hash(b.state_list, h))

"""
    DiscreteUpdater

An updater type to update discrete belief using the discrete Bayesian filter.

# Constructor
    DiscreteUpdater(pomdp::POMDP)

# Fields
- `pomdp <: POMDP`
"""
mutable struct DiscreteUpdater{P<:POMDP} <: Updater
    pomdp::P
end

uniform_belief(bu::DiscreteUpdater) = uniform_belief(bu.pomdp)

initialize_belief(bu::DiscreteUpdater, d) = initialize_belief(HorizonLength(bu.pomdp), bu, d)

function initialize_belief(::InfiniteHorizon, bu::DiscreteUpdater, d)
    state_list = ordered_states(bu.pomdp)
    ns = length(state_list)
    b = zeros(ns)
    belief = DiscreteBelief(bu.pomdp, state_list, b)
    for s in support(d)
        sidx = stateindex(bu.pomdp, s)
        belief.b[sidx] = pdf(d, s)
    end
    return belief
end

# StageDiscreteBelief(#=construct this with whatever stage the states in d have=#)
# No reason to distinguish between Staged and not stage DiscreteBelief
# Generates belief vector for a given stage
function initialize_belief(::FiniteHorizon, bu::DiscreteUpdater, d::InStageDistribution)
    state_list = ordered_stage_states(bu.pomdp, stage(d))
    ns = length(state_list)
    b = zeros(ns)
    belief = DiscreteBelief(bu.pomdp, state_list, b)
    for s in support(d)
        sidx = stage_stateindex(bu.pomdp, s)
        belief.b[sidx] = pdf(d, s)
    end
    return belief
end

update(bu::DiscreteUpdater, b::Any, a, o) = update(bu, initialize_belief(bu, b), a, o)

function update(bu::DiscreteUpdater, b::DiscreteBelief, a, o)
    update(HorizonLength(bu.pomdp), bu::DiscreteUpdater, b::DiscreteBelief, a, o)
end

function update(::InfiniteHorizon, bu::DiscreteUpdater, b::DiscreteBelief, a, o)
    pomdp = bu.pomdp
    state_space = b.state_list
    bp = zeros(length(state_space))

    for (si, s) in enumerate(state_space)

        if pdf(b, s) > 0.0
            td = transition(pomdp, s, a)

            for (sp, tp) in weighted_iterator(td)
                spi = stateindex(pomdp, sp)
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

    return DiscreteBelief(pomdp, b.state_list, bp)
end

function update(::FiniteHorizon, bu::DiscreteUpdater, b::DiscreteBelief, a, o)
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

    return DiscreteBelief(pomdp, ordered_stage_states(pomdp, stage(pomdp, o)+1), bp)
end
