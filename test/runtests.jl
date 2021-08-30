using Test
using POMDPs
using POMDPModelTools
using BeliefUpdaters
using POMDPModels
using Random
using FiniteHorizonPOMDPs
import FiniteHorizonPOMDPs: distribution, InStageDistribution, FixedHorizonPOMDPWrapper
# using FiVI
using POMDPSimulators

@testset "belief" begin
    include("test_belief.jl")
end

@testset "staged_belief" begin
    include("test_staged_belief.jl")
end

@testset "kprevobs" begin
    include("test_k_previous_observations_belief.jl")
end
