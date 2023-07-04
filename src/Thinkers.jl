module Thinkers

export setargs!, isreified, haserred, getresult

"Capture errors and stack traces from a running `Thunk`."
struct ErrorInfo{T}
    thrown::T
    stacktrace::Base.StackTraces.StackTrace
end

abstract type Think end
abstract type WrappedThink <: Think end
# TODO: CachedThunk
# which does not allow `setargs!`

isreified(think::WrappedThink) = isreified(think.wrapped)

haserred(think::WrappedThink) = haserred(think.wrapped)

getresult(think::WrappedThink) = getresult(think.wrapped)

function setargs!(think::WrappedThink, args...; kwargs...)
    if isreified(think)
        error(
            "you cannot change the arguments of a `$(typeof(think))` after it has been evaluated!",
        )
    else
        think.wrapped.args = args
        think.wrapped.kwargs = kwargs
    end
    return think
end

"""
    reset!(think::Think)

Reset the computation result of the `think` object.

!!! warning
    Please be aware that `reset!` does not guarantee that a `Think` object will behave
    exactly as if it has never been evaluated. Some functions that the `Think` object
    wraps may modify their arguments or depend on external state (i.e., they are not
    pure functions), which could lead to different results upon re-evaluation.
"""
function reset!(think::Think)
    think.result = nothing
    return think
end

function Base.getproperty(think::WrappedThink, name::Symbol)
    if name in (:callable, :args, :kwargs, :result)
        return getfield(think.wrapped, name)
    else
        return getfield(think, name)
    end
end

include("Thunk.jl")
include("TimeLimitedThunk.jl")
include("show.jl")

end
