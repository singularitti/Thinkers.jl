module Thinkers

using Dates: Period

struct ErrorInfo{T}
    thrown::T
    stacktrace::Base.StackTraces.StackTrace
end

# See https://github.com/goropikari/Timeout.jl/blob/c7df3cd/src/Timeout.jl#L4
struct TimeoutException <: Exception end

abstract type Think end
abstract type WrappedThink <: Think end
mutable struct Thunk <: Think
    callable
    args::Tuple
    kwargs::Iterators.Pairs
    result::Union{Some,Nothing}
    Thunk(callable, args::Tuple, kwargs::Iterators.Pairs) =
        new(callable, args, kwargs, nothing)
end
Thunk(f, args...; kwargs...) = Thunk(f, args, kwargs)
mutable struct TimeLimitedThunk <: WrappedThink
    time_limit::Period
    wrapped::Thunk
end
TimeLimitedThunk(time_limit, callable, args::Tuple, kwargs::Iterators.Pairs) =
    TimeLimitedThunk(time_limit, Thunk(callable, args, kwargs, nothing))
TimeLimitedThunk(time_limit, callable, args...; kwargs...) =
    TimeLimitedThunk(time_limit, callable, args, kwargs)

function reify!(thunk::Thunk)
    try
        thunk.result = Some(thunk.callable(thunk.args...; thunk.kwargs...))
    catch e
        s = stacktrace(catch_backtrace())
        thunk.result = Some(ErrorInfo(e, s))
    end
    return thunk
end
# See https://github.com/goropikari/Timeout.jl/blob/c7df3cd/src/Timeout.jl#L18-L45
function reify!(thunk::TimeLimitedThunk)
    istimedout = Channel{Bool}(1)
    main = @async begin
        reify!(thunk.wrapped)
        put!(istimedout, false)
    end
    timer = @async begin
        sleep(thunk.time_limit)
        put!(istimedout, true)
        Base.throwto(main, TimeoutException())
    end
    fetch(istimedout)  # You do not know which of `main` and `timer` finishes first, so you need `istimedout`.
    close(istimedout)
    _kill(main)  # Kill all `Task`s after done.
    _kill(timer)
    return thunk
end

isevaluated(thunk::Thunk) = thunk.result !== nothing

haserred(thunk::Thunk) = isevaluated(thunk) && something(thunk.result) isa ErrorInfo

getresult(thunk::Thunk) = thunk.result
getresult(think::WrappedThink) = getresult(think.wrapped)

function Base.setproperty!(thunk::Thunk, name::Symbol, x)
    if name in (:callable, :args, :kwargs)
        error("you cannot redefine a `Thunk` after it has been constructed!")
    else
        setfield!(thunk, name, x)
    end
end
function Base.setproperty!(think::WrappedThink, name::Symbol, x)
    if name in (:callable, :args, :kwargs)
        error("you cannot redefine a `Thunk` after it has been constructed!")
    elseif name == :result
        setfield!(think.wrapped, name, x)
    else
        setfield!(think, name, x)
    end
end

# See https://github.com/goropikari/Timeout.jl/blob/c7df3cd/src/Timeout.jl#L6-L11
function _kill(task)
    try
        schedule(task, InterruptException(); error=true)
    catch
    end
end

end
