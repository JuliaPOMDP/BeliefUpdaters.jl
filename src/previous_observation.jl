# a belief that just stores the previous observation
# maintained by @zsunberg

# policies based on the previous observation only are often pretty good
# e.g. for the crying baby problem
"""
Updater that stores the most recent observation as the belief, missing if none is available.
"""
struct PreviousObservationUpdater <: Updater end

initialize_belief(u::PreviousObservationUpdater, d::Any) = missing

update(bu::PreviousObservationUpdater, old_b, action, obs) = obs
