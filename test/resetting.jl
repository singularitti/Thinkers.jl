@testset "Define a pure function to be used in the tests" begin
    add(x, y) = x + y
    @testset "Test a `Thunk` (with a pure function) can be run multiple times and consistently produce the correct result" begin
        t = Thunk(add, 1, 2)
        @test unwrapresult(reify!(t)) == 3
        @test unwrapresult(reify!(t)) == 3
        @test unwrapresult(reify!(t)) == 3
    end
    @testset "Test resetting a `Thunk` (with a pure function) makes it ready for reevaluation" begin
        t = Thunk(add, 1, 2)
        reify!(t)
        @test isreified(t)
        @test unwrapresult(t) == 3
        reset!(t)
        @test !isreified(t)
        @test unwrapresult(reify!(t)) == 3
    end
    @testset "Test resetting a `Thunk` (with a pure function) multiple times doesn't affect its functionality" begin
        t = Thunk(add, 1, 2)
        @test unwrapresult(reify!(t)) == 3
        reset!(t)
        @test unwrapresult(reify!(t)) == 3
        reset!(t)
        @test unwrapresult(reify!(t)) == 3
    end
end

@testset "Define a non-pure function that increments an array's elements in-place" begin
    increment!(a) = a .+= 1
    @testset "Test a `Thunk` with a non-pure function gives different results on multiple runs" begin
        a = [1, 2, 3]
        t = Thunk(increment!, a)
        @test unwrapresult(reify!(t)) == [2, 3, 4]
        @test unwrapresult(reify!(t)) == [3, 4, 5]  # Changes on subsequent run due to mutation
    end
    @testset "Test that resetting a thunk with a non-pure function does not 'reset' the mutated state" begin
        a = [1, 2, 3]
        t = Thunk(increment!, a)
        reify!(t)
        @test isreified(t)
        @test unwrapresult(t) == [2, 3, 4]
        reset!(t)
        @test !isreified(t)
        @test unwrapresult(reify!(t)) == [3, 4, 5]  # Input was mutated and remains changed
    end
end
