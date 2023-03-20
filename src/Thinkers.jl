module Thinkers

using Dates: Period

export Thunk, TimeLimitedThunk, reify!, isevaluated, haserred, getresult

"Capture errors and stack traces from a running `Thunk`."
struct ErrorInfo{T}
    thrown::T
    stacktrace::Base.StackTraces.StackTrace
end

# See https://github.com/goropikari/Timeout.jl/blob/c7df3cd/src/Timeout.jl#L4
struct TimeoutException <: Exception end

abstract type Think end
abstract type WrappedThink <: Think end
# Idea from https://github.com/tbenst/Thunks.jl/blob/ff2a553/src/core.jl#L11-L20
"""
    Thunk(callable, args...; kwargs...)

Hold a callable and its arguments for lazy evaluation. Use `reify!` to evaluate.

# Examples
```jldoctest
julia> using Thinkers

julia> a = Thunk(x -> 3x, 4);

julia> reify!(a);

julia> getresult(a)
Some(12)

julia> b = Thunk(+, 4, 5);

julia> reify!(b);

julia> getresult(b)
Some(9)

julia> c = Thunk(sleep, 1);

julia> getresult(c)  # `c` has not been evaluated

julia> reify!(c);  # `c` has been evaluated

julia> getresult(c)
Some(nothing)

julia> f(args...; kwargs...) = collect(kwargs);

julia> d = Thunk(f, 1, 2, 3; x=1.0, y=4, z="5");

julia> reify!(d);

julia> getresult(d)
Some(Pair{Symbol, Any}[:x => 1.0, :y => 4, :z => "5"])

julia> e = Thunk(sin, "1");  # Catch errors

julia> reify!(e);

julia> haserred(e)
true
```
"""
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
    TimeLimitedThunk(time_limit, Thunk(callable, args, kwargs))
TimeLimitedThunk(time_limit, callable::Base.Callable, args...; kwargs...) =
    TimeLimitedThunk(time_limit, Thunk(callable, args, kwargs))

# See https://github.com/tbenst/Thunks.jl/blob/ff2a553/src/core.jl#L113-L123
"""
    reify!(thunk::Thunk)

Reify a `Thunk` into a value.

Compute the value of the expression.
Walk through the `Thunk`'s arguments and keywords, recursively evaluating each one,
and then evaluating the `Thunk`'s function with the evaluated arguments.

See also [`Thunk`](@ref).
"""
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

"""
    isevaluated(thunk::Thunk)

Determine whether `thunk` has been executed before.
"""
isevaluated(thunk::Thunk) = thunk.result !== nothing
isevaluated(think::WrappedThink) = isevaluated(think.wrapped)

"""
    haserred(thunk::Thunk)

Check if thunk produced an error when executed.
"""
haserred(thunk::Thunk) = isevaluated(thunk) && something(thunk.result) isa ErrorInfo
haserred(think::WrappedThink) = haserred(think.wrapped)

"""
    getresult(thunk::Thunk)

Get the result of a `Thunk`. If `thunk` has not been evaluated, return `nothing`, else return a `Some`-wrapped result.
"""
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

function Base.getproperty(think::WrappedThink, name::Symbol)
    if name in (:callable, :args, :kwargs, :result)
        return getfield(think.wrapped, name)
    else
        return getfield(think, name)
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
