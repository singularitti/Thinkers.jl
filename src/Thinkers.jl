module Thinkers

struct ErredResult{T}
    thrown::T
    stacktrace::Base.StackTraces.StackTrace
end

abstract type Think end
mutable struct Thunk <: Think
    callable
    args::Tuple
    kwargs::Iterators.Pairs
    isevaluated::Bool
    haserred::Bool
    result::Union{Some,Nothing}
    Thunk(callable, args::Tuple, kwargs::Iterators.Pairs) =
        new(callable, args, kwargs, false, false, nothing)
end
Thunk(f, args...; kwargs...) = Thunk(f, args, kwargs)

function reify!(thunk::Thunk)
    try
        thunk.result = Some(thunk.callable(thunk.args...; thunk.kwargs...))
    catch e
        thunk.haserred = true
        s = stacktrace(catch_backtrace())
        thunk.result = Some(ErredResult(e, s))
    finally
        thunk.isevaluated = true
    end
end

function Base.setproperty!(thunk::Thunk, name::Symbol, x)
    if name in (:callable, :args, :kwargs)
        error("you cannot redefine a `Thunk` after it has been constructed!")
    else
        setfield!(thunk, name, x)
    end
end

end
