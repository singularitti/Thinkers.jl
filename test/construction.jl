@testset "Test constructing `Thunk`s" begin
    @testset "`Thunk` which requires no arguments" begin
        function f()
            println("Start job `i`!")
            return sleep(5)
        end
        i = Thunk(f)
        j = Thunk(f, ())  # Do not give an empty `Tuple` to a `Thunk` which requires no arguments
        reify!(i)
        reify!(j)
        @test !haserred(i)
        @test haserred(j)
    end
    @testset "`Thunk` which optionally requires arguments" begin
        g(x=1) = cos(x)
        i = Thunk(g)
        j = Thunk(g, 2)
        reify!(i)
        reify!(j)
        @test something(getresult(i)) == cos(1)
        @test something(getresult(j)) == cos(2)
    end
    @testset "`Thunk` which optionally requires keyword arguments" begin
        h(; x=1) = cos(x)
        i = Thunk(h)
        j = Thunk(h, 2)
        k = Thunk(h; x=2)
        reify!(i)
        reify!(j)
        reify!(k)
        @test something(getresult(i)) == cos(1)
        @test haserred(j)
        @test something(getresult(k)) == cos(2)
    end
    @testset "`Thunk` which requires keyword arguments" begin
        func(; x) = cos(x)
        i = Thunk(func)
        j = Thunk(func, 2)
        k = Thunk(func; x=2)
        reify!(i)
        reify!(j)
        reify!(k)
        @test haserred(i)
        @test haserred(j)
        @test something(getresult(k)) == cos(2)
    end
end

@testset "Test constructing `TimeLimitedThunk`s" begin
    function f()
        println("Start job `i`!")
        return sleep(1)
    end
    i = Thunk(f)
    j = TimeLimitedThunk(Second(3), i)
    reify!(i)
    reify!(j)
    @test !haserred(i)
    @test !haserred(j)
    @testset "`TimeLimitedThunk` which requires no arguments" begin
        i = TimeLimitedThunk(Second(3), f)
        j = TimeLimitedThunk(Second(3), f, ())
        reify!(i)
        reify!(j)
        @test !haserred(i)
        @test haserred(j)
    end
    @testset "`Thunk` which requires one argument" begin
        g(x) = cos(x)
        i = TimeLimitedThunk(Second(3), g)
        j = TimeLimitedThunk(Second(3), g, 2)
        reify!(i)
        reify!(j)
        @test haserred(i)
        @test something(getresult(j)) == cos(2)
    end
    @testset "`Thunk` which requires at most two arguments" begin
        ff(x, y=1) = x + y
        i = TimeLimitedThunk(Second(3), ff, 3)
        j = TimeLimitedThunk(Second(3), ff, 2, 4)
        reify!(i)
        reify!(j)
        @test something(getresult(i)) == 4
        @test something(getresult(j)) == 6
    end
    @testset "`Thunk` which optionally requires keyword arguments" begin
        h(; x=1) = cos(x)
        i = TimeLimitedThunk(Second(3), h)
        j = TimeLimitedThunk(Second(3), h, 2)
        k = TimeLimitedThunk(Second(3), h; x=2)
        reify!(i)
        reify!(j)
        reify!(k)
        @test something(getresult(i)) == cos(1)
        @test haserred(j)
        @test something(getresult(k)) == cos(2)
    end
end
