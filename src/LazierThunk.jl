export LazierThunk

mutable struct LazierThunk <: Think
    callable
    args::Thunk
    kwargs::Thunk
    result::Union{Some,Nothing}
    LazierThunk(callable, args::Thunk, kwargs::Thunk) = new(callable, args, kwargs, nothing)
end
LazierThunk(callable, args=Thunk(() -> ()), kwargs=Thunk(() -> (;))) =
    LazierThunk(callable, args, kwargs)

function reify!(thunk::LazierThunk)
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

isreified(thunk::LazierThunk) = thunk.result !== nothing

haserred(thunk::LazierThunk) = isreified(thunk) && something(thunk.result) isa ErrorInfo

getresult(thunk::LazierThunk) = thunk.result
