var documenterSearchIndex = {"docs": [

{
    "location": "discrete.html#",
    "page": "Discrete",
    "title": "Discrete",
    "category": "page",
    "text": ""
},

{
    "location": "discrete.html#BeliefUpdaters.DiscreteBelief",
    "page": "Discrete",
    "title": "BeliefUpdaters.DiscreteBelief",
    "category": "type",
    "text": "DiscreteBelief\n\nA belief specified by a probability vector.\n\nNormalization of b is NOT enforced at all times, but the DiscreteBeleif(pomdp, b) constructor will warn, and update(...) always returns a belief with normalized b.\n\nConstructor: \n\nDiscreteBelief(pomdp, b::Vector{Float64}; check::Bool=true)\n\nFields\n\n- `pomdp` : the POMDP problem  \n- `state_list` : a vector of ordered states\n- `b` : the probability vector\n\n\n\n\n\n"
},

{
    "location": "discrete.html#BeliefUpdaters.DiscreteUpdater",
    "page": "Discrete",
    "title": "BeliefUpdaters.DiscreteUpdater",
    "category": "type",
    "text": "DiscreteUpdater\n\nAn updater type to update discrete belief using the discrete Bayesian filter.\n\nFields\n\n- pomdp <: POMDP\n\n\n\n\n\n"
},

{
    "location": "discrete.html#BeliefUpdaters.uniform_belief-Tuple{Any}",
    "page": "Discrete",
    "title": "BeliefUpdaters.uniform_belief",
    "category": "method",
    "text": " uniform_belief(pomdp)\n\nReturn a DiscreteBelief with equal probability for each state.\n\n\n\n\n\n"
},

{
    "location": "discrete.html#Discrete-1",
    "page": "Discrete",
    "title": "Discrete",
    "category": "section",
    "text": "BeliefUpdaters contains a default implementation of a discrete bayesian filter. The updater is defined with the DiscreteUpdater type. The DiscreteBelief type is provided to represent discrete beliefs for discrete states POMDPs. A convenience function uniform_belief is probided to create a DiscreteBelief with equal probability for each state. DiscreteBeliefDiscreteUpdateruniform_belief(pomdp)"
},

{
    "location": "index.html#",
    "page": "About",
    "title": "About",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#About-1",
    "page": "About",
    "title": "About",
    "category": "section",
    "text": "BeliefUpdaters is a collection of belief updaters to be used with POMDPs.jl models and solvers. It currently provides:a discrete belief updater\na k previous observation updater\na previous observation updater \na nothing updaterFor particle filters see ParticleFilters.jl"
},

{
    "location": "k_previous_observations.html#",
    "page": "K Previous Observations",
    "title": "K Previous Observations",
    "category": "page",
    "text": ""
},

{
    "location": "k_previous_observations.html#BeliefUpdaters.KMarkovUpdater",
    "page": "K Previous Observations",
    "title": "BeliefUpdaters.KMarkovUpdater",
    "category": "type",
    "text": "KMarkovUpdater\n\nUpdater that stores the k most recent observations as the belief.\n\nExample:\n\nup = KMarkovUpdater(5)\ns0 = initialstate(pomdp, rng)\ninitial_observation = generate_o(pomdp, s0, rng)\ninitial_obs_vec = fill(initial_observation, 5)\nhr = HistoryRecorder(rng=rng, max_steps=100)\nhist = simulate(hr, pomdp, policy, up, initial_obs_vec, s0)\n\n\n\n\n\n"
},

{
    "location": "k_previous_observations.html#K-Previous-Observations-1",
    "page": "K Previous Observations",
    "title": "K Previous Observations",
    "category": "section",
    "text": "KMarkovUpdater"
},

{
    "location": "previous_observation.html#",
    "page": "Previous Observation",
    "title": "Previous Observation",
    "category": "page",
    "text": ""
},

{
    "location": "previous_observation.html#BeliefUpdaters.PreviousObservationUpdater",
    "page": "Previous Observation",
    "title": "BeliefUpdaters.PreviousObservationUpdater",
    "category": "type",
    "text": "Updater that stores the most recent observation as the belief. If an initial distribution is provided, it will pass that as the initial belief.\n\n\n\n\n\n"
},

{
    "location": "previous_observation.html#Previous-Observation-1",
    "page": "Previous Observation",
    "title": "Previous Observation",
    "category": "section",
    "text": "PreviousObservationUpdater"
},

{
    "location": "void.html#",
    "page": "Nothing",
    "title": "Nothing",
    "category": "page",
    "text": ""
},

{
    "location": "void.html#BeliefUpdaters.NothingUpdater",
    "page": "Nothing",
    "title": "BeliefUpdaters.NothingUpdater",
    "category": "type",
    "text": "An updater useful for when a belief is not necessary (i.e. for a random policy). update always returns nothing.\n\n\n\n\n\n"
},

{
    "location": "void.html#Nothing-1",
    "page": "Nothing",
    "title": "Nothing",
    "category": "section",
    "text": "NothingUpdater"
},

]}
