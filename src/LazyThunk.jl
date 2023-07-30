export LazyThunk

mutable struct LazyThunk <: Think
    callable
    args::Thunk
    kwargs::Thunk
    result::Union{Some,Nothing}
    LazyThunk(callable, args::Thunk=Thunk(() -> ()), kwargs::Thunk=Thunk(() -> (;))) =
        new(callable, args, kwargs, nothing)
end

function reify!(thunk::LazyThunk)
    try
        reify!(thunk.args)
    catch e
        s = stacktrace(catch_backtrace())
        thunk.result = Some(ErrorInfo(e, s))
        @warn "caught an error when reifying the arguments of `thunk`! Call `getresult(thunk)` for details."
        Base.showerror(stdout, e, s)  # See https://discourse.julialang.org/t/how-to-print-a-backtrace/74164/4
    end
    try
        reify!(thunk.kwargs)
    catch e
        s = stacktrace(catch_backtrace())
        thunk.result = Some(ErrorInfo(e, s))
        @warn "caught an error when reifying the keyword arguments of `thunk`! Call `getresult(thunk)` for details."
        Base.showerror(stdout, e, s)  # See https://discourse.julialang.org/t/how-to-print-a-backtrace/74164/4
    end
    args, kwargs = unwrapresult(thunk.args), unwrapresult(thunk.kwargs)
    try
        thunk.result = Some(thunk.callable(args...; kwargs...))
    catch e
        s = stacktrace(catch_backtrace())
        thunk.result = Some(ErrorInfo(e, s))
        @warn "caught an error when reifying `thunk`! Call `getresult(thunk)` for details."
        Base.showerror(stdout, e, s)  # See https://discourse.julialang.org/t/how-to-print-a-backtrace/74164/4
    end
    return thunk
end

isreified(thunk::LazyThunk) = thunk.result !== nothing

haserred(thunk::LazyThunk) = isreified(thunk) && something(thunk.result) isa ErrorInfo

getresult(thunk::LazyThunk) = thunk.result
