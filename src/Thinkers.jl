module Thinkers

struct ErrorInfo{T}
    thrown::T
    stacktrace::Base.StackTraces.StackTrace
end

abstract type Think end
mutable struct Thunk <: Think
    callable
    args::Tuple
    kwargs::Iterators.Pairs
    result::Union{Some,Nothing}
    Thunk(callable, args::Tuple, kwargs::Iterators.Pairs) =
        new(callable, args, kwargs, nothing)
end
Thunk(f, args...; kwargs...) = Thunk(f, args, kwargs)

function reify!(thunk::Thunk)
    try
        thunk.result = Some(thunk.callable(thunk.args...; thunk.kwargs...))
    catch e
        s = stacktrace(catch_backtrace())
        thunk.result = Some(ErrorInfo(e, s))
    end
    return thunk
end

isevaluated(thunk::Thunk) = thunk.result === nothing

haserred(thunk::Thunk) = isevaluated(thunk) && something(thunk.result) isa ErrorInfo

getresult(thunk::Thunk) = thunk.result

function Base.setproperty!(thunk::Thunk, name::Symbol, x)
    if name in (:callable, :args, :kwargs)
        error("you cannot redefine a `Thunk` after it has been constructed!")
    else
        setfield!(thunk, name, x)
    end
end

end
