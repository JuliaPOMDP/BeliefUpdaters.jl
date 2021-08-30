module BeliefUpdaters

using POMDPs
import POMDPs: Updater, update, initialize_belief, pdf, mode, updater, support
import Base: ==
import Statistics
using POMDPModelTools
using StatsBase
using Random
using FiniteHorizonPOMDPs
import FiniteHorizonPOMDPs: HorizonLength, FiniteHorizon, InfiniteHorizon,
                distribution, stage, stage_stateindex, ordered_stage_states,
                InStageDistribution, FHWrapper

export
    NothingUpdater
include("void.jl")

export
    DiscreteBelief,
    DiscreteUpdater,
    uniform_belief

include("discrete.jl")

export
    StagedDiscreteBelief,
    uniform_staged_belief

include("staged_discrete.jl")

export
    PreviousObservationUpdater,
    FastPreviousObservationUpdater,
    PrimedPreviousObservationUpdater

include("previous_observation.jl")

export
    KMarkovUpdater

include("k_previous_observations.jl")

end
