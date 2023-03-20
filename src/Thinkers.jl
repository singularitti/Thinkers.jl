module Thinkers

struct ErredResult{T}
    thrown::T
    stacktrace::Base.StackTraces.StackTrace
end

end
