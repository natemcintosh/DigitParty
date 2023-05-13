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

@testset "get_empty_spots" begin
    g = Game()

    # Everything is empty
    want = (1:5, 1:5) |> CartesianIndices |> vec
    got  = get_empty_spots(g)
    @test want == got

    # Add a number to [1, 1]
    want = setdiff(want, [CartesianIndex(1, 1)])
    make_move!(g, 1, 1)
    got = get_empty_spots(g)
    @test want == got

    # Add a number to [3, 4]
    want = setdiff(want, [CartesianIndex(3, 4)])
    make_move!(g, 3, 4)
    got = get_empty_spots(g)
    @test want == got

    @test_broken @inferred get_empty_spots(g)
end

@testset "game_is_over" begin
    g = Game()
    @test !game_is_over(g)

    # Fill up the board
    for idx in eachindex(g.board)
        make_move!(g, idx)
    end

    @test game_is_over(g)
end
