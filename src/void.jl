# maintained by @zsunberg
# an empty belief
# for use with e.g. a random policy
mutable struct NothingUpdater <: Updater end

initialize_belief(::NothingUpdater, ::Any) = nothing
initialize_belief(::NothingUpdater, ::Any, ::Any) = nothing
create_belief(::NothingUpdater) = nothing

update(::NothingUpdater, ::B, ::Any, ::Any, b=nothing) where B = nothing
