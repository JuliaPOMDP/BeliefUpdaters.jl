module BeliefUpdaters

Base.depwarn("""
             The functionality in BeliefUpdaters has been moved to POMDPTools.

             Please simply replace `using BeliefUpdaters` with `using POMDPTools`.
             """, :BeliefUpdaters)

using POMDPTools.BeliefUpdaters

export
    NothingUpdater,
    DiscreteBelief,
    DiscreteUpdater,
    uniform_belief,
    PreviousObservationUpdater,
    FastPreviousObservationUpdater,
    PrimedPreviousObservationUpdater,
    KMarkovUpdater

#=
using POMDPs
import POMDPs: Updater, update, initialize_belief, pdf, mode, updater, support
import Base: ==
import Statistics
using POMDPModelTools
using StatsBase
using Random


export
    NothingUpdater
include("void.jl")

export
    DiscreteBelief,
    DiscreteUpdater,
    uniform_belief

include("discrete.jl")

export
    PreviousObservationUpdater,
    FastPreviousObservationUpdater,
    PrimedPreviousObservationUpdater

include("previous_observation.jl")

export
    KMarkovUpdater

include("k_previous_observations.jl")
=#

end
