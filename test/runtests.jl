using Dates: Second
using Thinkers
using Test

@testset "Thinkers.jl" begin
    include("construction.jl")
    include("reifying.jl")
    include("arguments.jl")
    include("resetting.jl")
end
