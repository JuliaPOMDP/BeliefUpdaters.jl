pomdp = fixhorizon(BabyPOMDP(), 2)

FiniteHorizonPOMDPs.distribution(initialstate(pomdp))

sdb = StagedDiscreteBelief(pomdp, initialstate(pomdp), false)

@test sdb == StagedDiscreteBelief(pomdp, [1., 0.], 1, false)

bu = DiscreteUpdater(pomdp)

# testing equality (== function)
@test uniform_staged_belief(bu, 1) ==
    initialize_belief(bu, FiniteHorizonPOMDPs.InStageDistribution(BoolDistribution(0.5), 1))

@test stage(sdb) == 1


sdb2 = initialize_belief(bu, FiniteHorizonPOMDPs.InStageDistribution(BoolDistribution(0.5), 1))
@test pdf(sdb2, (false, 2)) == 0.
@test pdf(sdb2, (false, 1)) == .5

# rand(sdb2)

# testing constructor
b0 = DiscreteBelief(pomdp, [0.5,0.5])

@test pdf(b0,true) == 0.5
@test pdf(b0,false) == 0.5

println("There should be a warning below:")
StagedDiscreteBelief(pomdp, [0.6, 0.5], 1)
println("There should be a warning below:")
StagedDiscreteBelief(pomdp, [-0.1, 1.1], 1)

println("There should NOT be a warning below:")
StagedDiscreteBelief(pomdp, [-0.1, 1.1], 1, check=false)

# testing iterator
@test support(sdb) == ordered_stage_states(pomdp, 1)

# TODO: fill this with another tests even from test_belief.jl

# testing hashing

# testing updater initialization

# testing update function; if we feed baby, it won't be hungry

# if we don't feed the baby and observe crying

# Some more tests with tiger problem (old tests, but still work)

# test mean and mode
