export Thunk, reify!, setargs!, isreified, haserred, getresult

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
"""
    Thunk(thunk::Thunk)

Create a new `Thunk` from an existing `Thunk` by deep-copying the callable and arguments
of the `thunk`.

!!! warning
    This is just a shorthand for writing a new `Thunk` instance.
    It is not guaranteed that the new `Thunk` will behave exactly as the original one.
    If the callable, positional arguments, or keyword arguments have changed since
    creating the original `Thunk` instance, the new `Thunk` will copy them as they are.
    If this is the case, you should generate a new callable and new arguments for
    the new `Thunk` instance.
"""
Thunk(thunk::Thunk) =
    Thunk(deepcopy(thunk.callable), deepcopy(thunk.args), deepcopy(thunk.kwargs), nothing)

# See https://github.com/tbenst/Thunks.jl/blob/ff2a553/src/core.jl#L113-L123
"""
    reify!(thunk::Thunk)

Reify a `Thunk`.

Calculate the value of the expression by recursively evaluating each argument and keyword of
the `Thunk`, and then evaluating the `Thunk`'s callable with the evaluated arguments.

If called again, this function will recompute everything from scratch.

!!! warning
    Some functions that the `Think` object wraps may modify their arguments or depend on
    external state (i.e., they are not pure functions), which could lead to different
    results upon re-evaluation.
"""
function reify!(thunk::Thunk)
    try
        thunk.result = Some(thunk.callable(thunk.args...; thunk.kwargs...))
    catch e
        s = stacktrace(catch_backtrace())
        thunk.result = Some(ErrorInfo(e, s))
        @warn "caught an error when reifying `thunk`! See `getresult(thunk)` for details."
        Base.showerror(stdout, e, s)  # See https://discourse.julialang.org/t/how-to-print-a-backtrace/74164/4
    end
    return thunk
end

"""
    isreified(thunk::Thunk)

Determine whether `thunk` has been reified.
"""
isreified(thunk::Thunk) = thunk.result !== nothing

"""
    haserred(thunk::Thunk)

Check if `thunk` produced an error when reified.
"""
haserred(thunk::Thunk) = isreified(thunk) && something(thunk.result) isa ErrorInfo

"""
    getresult(thunk::Thunk)

Get the result of a `Thunk`. If `thunk` has not been reified, return `nothing`, else return a `Some`-wrapped result.
"""
getresult(thunk::Thunk) = thunk.result

"""
    setargs!(think::Think, args...; kwargs...)

Change the arguments of a `Think`, after it has been created but before it has been evaluated.
"""
function setargs!(thunk::Thunk, args...; kwargs...)
    if isreified(thunk)
        @warn "you are changing the arguments of a `Thunk` after it has been reified!"
    end
    thunk.args = args
    thunk.kwargs = kwargs
    return thunk
end
