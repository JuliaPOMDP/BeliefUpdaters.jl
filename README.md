# BeliefUpdaters.jl

[![Build Status](https://travis-ci.org/JuliaPOMDP/BeliefUpdaters.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/BeliefUpdaters.jl)

[![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/BeliefUpdaters.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/BeliefUpdaters.jl?branch=master)

Support tools for POMDPs.jl. This is a supported [JuliaPOMDP](https://github.com/JuliaPOMDP) package that provides tools
for problem modeling.

## Installation

This package requires [POMDPs.jl](https://github.com/JuliaPOMDP). To install this module run the following command:

**TODO**


## Code structure

Within src each file contains one tool. Each file should clearly indicate who is the maintainer of that file.

## Tools


#### [`discrete.jl`](src/beliefs/discrete.jl)
Dense discrete probability distribution and updater.

Create an updater with `DiscreteUpdater(pomdp)`; create a belief with `DiscreteBelief(pomdp, b)`, where `b` is a vector of probabilities; create a uniform belief with `uniform_belief(pomdp)`.

States sampled from a `DiscreteBelief` will be actual states (of type `statetype(pomdp)`) instead of integer indices as in previous versions, and actual states instead of indices should be used in `pdf(b::DiscreteBelief, s)`. `DiscreteBelief` uses `state_index(pomdp, s)` to keep track of the states internally.

#### [`previous_observation.jl`](src/beliefs/previous_observation.jl)
Beliefs (and updaters) that only deal with the most recent observation

- `PreviousObservationUpdater` maintains a "belief" that is a `Nullable{O}` where `O` is the observation type. The "belief" is null if there is no observation available, and contains the previous observation if there is one.

#### [`k_previous_observation.jl`](src/beliefs/k_previous_observation.jl)
`KMarkovUpdater` maintains a "belief" that is a `Vector{O}` where `O` is the observation type. It consists of the last k observations where k is an integer to pass to the constructor of `KMarkovUpdater`. The last observation is at the end of the vector and the oldest one is at the beginning.
Example:
```julia
using POMDPSimulators
up = KMarkovUpdater(5)
s0 = initialstate(pomdp, rng)
initialobservation = generate_o(pomdp, s0, rng)
initialobs_vec = fill(initialobservation, 5)
hr = HistoryRecorder(rng=rng, max_steps=100)
hist = simulate(hr, pomdp, policy, up, initialobs_vec, s0)
```

#### [`void.jl`](src/beliefs/void.jl)
An updater useful for when a belief is not necessary (i.e. for a random policy). `update` always returns `nothing`.
