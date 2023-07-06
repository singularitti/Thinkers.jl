abstract type WrappedThink <: Think end

isreified(think::WrappedThink) = isreified(think.wrapped)

haserred(think::WrappedThink) = haserred(think.wrapped)

getresult(think::WrappedThink) = getresult(think.wrapped)

function setargs!(think::WrappedThink, args...; kwargs...)
    if isreified(think)
        @warn "you are changing the arguments of a `$(typeof(think))` after it has been reified!"
    end
    think.wrapped.args = args
    think.wrapped.kwargs = kwargs
    return think
end

function Base.getproperty(think::WrappedThink, name::Symbol)
    if name in (:callable, :args, :kwargs, :result)
        return getfield(think.wrapped, name)
    else
        return getfield(think, name)
    end
end
