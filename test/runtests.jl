using Dates: Second
using Thinkers
using Test

@testset "Thinkers.jl" begin
    include("construction.jl")
    include("reifying.jl")
end
