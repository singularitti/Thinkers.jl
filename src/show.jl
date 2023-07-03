function Base.show(io::IO, ::MIME"text/plain", info::ErrorInfo)
    Base.println(io, "the error and the stacktrace were:")
    Base.showerror(io, info.thrown, info.stacktrace)
    return nothing
end
