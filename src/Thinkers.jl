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

end
