@testset "Construct" begin
    g = Game()
    @test all(g.board .== 0)
    @test all(x in 1:9 for x in g.up_next)
end

@testset "make_move!" begin
    g = Game()
    @test_throws BoundsError make_move!(g, 0, 1)
    @test_throws BoundsError make_move!(g, 2, -1)
    @test_throws BoundsError make_move!(g, 2, 6)
    @test_throws BoundsError make_move!(g, 6, 1)

    # Make a valid move, then try to place on top
    make_move!(g, 1, 1)
    @test_throws AssertionError make_move!(g, 1, 1)
end
