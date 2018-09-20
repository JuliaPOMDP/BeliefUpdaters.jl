# Discrete 

BeliefUpdaters contains a default implementation of a discrete bayesian filter. The updater is defined with the `DiscreteUpdater` type. The `DiscreteBelief` type is provided to represent discrete beliefs for discrete states POMDPs. 

A convenience function `uniform_belief` is probided to create a `DiscreteBelief` with equal probability for each state. 

```@docs 
DiscreteBelief
```

```@docs
DiscreteUpdater
```

```@docs
uniform_belief(pomdp)
```