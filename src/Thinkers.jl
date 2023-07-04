module Thinkers

export unwrapresult, reset!

"Capture errors and stack traces from a running `Thunk`."
struct ErrorInfo{T}
    thrown::T
    stacktrace::Base.StackTraces.StackTrace
end

abstract type Think end
# TODO: CachedThunk
# which does not allow `setargs!`

"""
    unwrapresult(think::Think)

Unwrap the retrieved result of a `think` object.

This function extracts the result of a `Think` object from its `Some` container.
If the `Think` object has not been reified (i.e., `reify!` has not been called) or is
still running, it throws an error.
"""
unwrapresult(think::Think) = something(getresult(think))

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

include("Thunk.jl")
include("WrappedThink.jl")
include("TimeLimitedThunk.jl")
include("show.jl")

end
