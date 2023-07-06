@testset "Test `setargs!` on `Thunk`s" begin
    function f()
        println("Start job `i`!")
        return sleep(5)
    end
    i = Thunk(f)
    setargs!(i, 1)
    reify!(i)
    @test haserred(i)
    g(x=1) = cos(x)
    j = Thunk(g)
    @test j.args == ()
    reify!(j)
    @test getresult(j) == Some(cos(1))
    setargs!(j, 2)
    reify!(j)
    @test getresult(j) == Some(cos(2))
end
