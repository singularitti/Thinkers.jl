using Dates: Period

export TimeLimitedThunk

# See https://github.com/goropikari/Timeout.jl/blob/c7df3cd/src/Timeout.jl#L4
struct TimeoutException <: Exception end

struct TimeLimitedThunk <: WrappedThink
    time_limit::Period
    wrapped::Thunk
    TimeLimitedThunk(time_limit::Period, callable::Thunk) = new(time_limit, callable)
    TimeLimitedThunk(time_limit, callable, args::Tuple, kwargs::Iterators.Pairs) =
        TimeLimitedThunk(time_limit, Thunk(callable, args, kwargs))
    # Distinguish between no-arg functions and the default constructor
    TimeLimitedThunk(time_limit, callable; kwargs...) =
        TimeLimitedThunk(time_limit, Thunk(callable; kwargs...))
    TimeLimitedThunk(time_limit, callable, arg, args...; kwargs...) =
        TimeLimitedThunk(time_limit, Thunk(callable, arg, args...; kwargs...))
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

# See https://github.com/goropikari/Timeout.jl/blob/c7df3cd/src/Timeout.jl#L6-L11
function _kill(task)
    try
        schedule(task, InterruptException(); error=true)
    catch
    end
end
