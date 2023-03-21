using Dates: Second
using Thinkers: ErrorInfo

@testset "Test reifying `Think`s" begin
    function f₁()
        println("Start job `i`!")
        return sleep(5)
    end
    function f₂(n)
        println("Start job `j`!")
        sleep(n)
        return exp(2)
    end
    function f₃(n)
        println("Start job `k`!")
        return sleep(n)
    end
    function f₄()
        println("Start job `l`!")
        return run(`sleep 3`)
    end
    function f₅(n, x)
        println("Start job `m`!")
        sleep(n)
        return sin(x)
    end
    function f₆(n; x=1)
        println("Start job `n`!")
        sleep(n)
        cos(x)
        return run(`pwd` & `ls`)
    end
    @testset "Test reifying `Thunk`s" begin
        i = Thunk(f₁)
        j = Thunk(f₂, 3)
        k = Thunk(f₃, 6)
        l = Thunk(f₄)
        m = Thunk(f₅, 3, 1)
        n = Thunk(f₆, 1; x=3)
        for thunk in (i, j, k, l, m, n)
            @test !isevaluated(thunk)
            @test getresult(thunk) === nothing
            reify!(thunk)
            @test isevaluated(thunk)
            @test !haserred(thunk)
        end
        @test getresult(i) == Some(nothing)
        @test getresult(j) == Some(exp(2))
        @test getresult(k) == Some(nothing)
        @test something(getresult(l)) isa Base.Process
        @test getresult(m) == Some(sin(1))
        @test something(getresult(n)) isa Base.ProcessChain
    end
    @testset "Test reifying `TimeLimitedThunk`s" begin
        i = TimeLimitedThunk(Second(4), f₁)
        k = TimeLimitedThunk(Second(4), f₃, 6)
        m = TimeLimitedThunk(Second(5), f₅, 1, 1)
        n = TimeLimitedThunk(Second(2), f₆, 5; x=3)
        for thunk in (i, k, n)
            @test !isevaluated(thunk)
            @test getresult(thunk) === nothing
            reify!(thunk)
            @test isevaluated(thunk)
            @test haserred(thunk)
        end
        @test !isevaluated(m)
        @test getresult(m) === nothing
        reify!(m)
        @test isevaluated(m)
        @test !haserred(m)
        @test something(getresult(i)) isa ErrorInfo
        @test something(getresult(k)) isa ErrorInfo
        @test getresult(m) == Some(sin(1))
        @test something(getresult(n)) isa ErrorInfo
    end
end
