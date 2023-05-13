using StaticArrays

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

@testset "get_score" begin
    board = @MMatrix [
        3 6 6 6 5
        3 9 9 3 5
        9 9 9 9 8
        2 4 9 7 2
        1 4 7 7 2
    ]
    g = Game(board, @MVector [1, 2])
    want = 164
    got = get_score(g)
    @test want == got

    board = @MMatrix [
        3 9 4 8 1
        6 3 4 5 9
        6 3 1 2 6
        6 2 3 9 1
        8 4 6 4 4
    ]
    g = Game(board, @MVector [1, 2])
    want = 29
    got = get_score(g)
    @test want == got

    board = @MMatrix [
        5 2 2 2 2
        5 5 9 2 4
        7 2 9 9 4
        7 8 8 4 1
        4 8 8 1 1
    ]
    g = Game(board, @MVector [1, 2])
    want = 120
    got = get_score(g)
    @test want == got
end

@testset "how_many_empties" begin
    g = Game()
    want = 3
    got = how_many_empties(g, CartesianIndex(1, 1))
    @test want == got

    want = 8
    got = how_many_empties(g, CartesianIndex(3, 3))
    @test want == got

    make_move!(g, 1, 1)
    want = 4
    got = how_many_empties(g, CartesianIndex(1, 2))
    @test want == got

    g = Game()
    for idx in eachindex(g.board)
        make_move!(g, idx)
    end

    for idx in eachindex(IndexCartesian(), g.board)
        @test 0 == how_many_empties(g, idx)
    end
end
