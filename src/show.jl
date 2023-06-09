function Base.show(io::IO, ::MIME"text/plain", info::ErrorInfo)
    Base.println(io, "the error and the stacktrace were:")
    Base.showerror(io, info.thrown, info.stacktrace)
    return nothing
end
function Base.show(io::IO, ::MIME"text/plain", think::Think)
    println(io, summary(think), ':')
    print(io, " definition: ", think.callable, '(')
    args = think.args
    if length(args) > 0
        for v in args[1:(end - 1)]
            print(io, v, ", ")
        end
        print(io, args[end])
    end
    kwargs = think.kwargs
    if isempty(kwargs)
        println(io, ')')
    else
        print(io, ";")
        for (k, v) in zip(keys(kwargs)[1:(end - 1)], Tuple(kwargs)[1:(end - 1)])
            print(io, ' ', k, '=', v, ",")
        end
        print(io, ' ', last(keys(kwargs)), '=', last(values(kwargs)))
        println(io, ')')
    end
    print(io, " result: ", think.result)
    return nothing
end
