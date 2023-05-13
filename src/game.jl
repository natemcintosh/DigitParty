# This file has the interface for running a game
using StaticArrays
import Base: print, show

export Game, make_move!, get_empty_spots, game_is_over, get_score, how_many_empties

mutable struct Game
    board   :: MMatrix{5,5,Int8}
    up_next :: MVector{2,Int8}
end

Game() = Game(MMatrix{5,5,Int8}(zeros(5, 5)), MVector{2,Int8}(rand(1:9, 2)))
Game(rng) = Game(MMatrix{5,5,Int8}(zeros(5, 5)), MVector{2,Int8}(rand(rng, 1:9, 2)))

function Base.print(io::IO, g::Game)
    # First print a row showing column numbers
    println("   1 2 3 4 5")
    println("   - - - - -")

    for (rnum, row) in enumerate(eachrow(g.board))
        print(rnum, "| ")
        for elt in row
            if elt < 1
                print(io, ". ")
            else
                print(io, elt, " ")
            end
        end
        println(io)
    end
    print(io, "\nUp next: $(g.up_next[1]), then $(g.up_next[2])")
end

Base.print(g::Game) = Base.print(Base.stdout, g)

"""
    make_move!(g::Game, row::Int, col::Int; verbose::Bool = false)

Make a move by placing the first item from `up_next` at `[row, col]`
Optionally, print the status of the board and up_next if so desired
"""
make_move!(g::Game, row::Int, col::Int; verbose::Bool = false) =
    make_move!(g, CartesianIndex(row, col), verbose = verbose)

"""
    make_move!(g::Game, idx; verbose::Bool = false)

`idx` can be either LinearIndex or CartesianIndex
"""
function make_move!(
    g::Game,
    idx::Union{CartesianIndex{2},IndexLinear,Int};
    verbose::Bool = false,
)
    # Check validity of input
    # They cannot place a piece where one already exists
    @assert g.board[idx] < 1 "Number already at [$idx]"

    # Place the first number from `up_next` at the desired location
    g.board[idx] = g.up_next[1]

    # Update `up_next`
    g.up_next[1] = g.up_next[2]
    g.up_next[2] = rand(1:9)

    # Print if asked
    verbose && print(g)
end

"""
    get_empty_spots(g::Game)

For API use
"""
function get_empty_spots(g::Game)
    findall(==(0), g.board)
end

"""
    game_is_over(g::Game)

Check if the game is over
"""
function game_is_over(g::Game)::Bool
    all(>=(1), g.board)
end

const DIRS =
    CartesianIndex.([(1, 1), (1, 0), (1, -1), (0, 1), (0, -1), (-1, 1), (-1, 0), (-1, -1)])

"""
    get_score(g::Game)

For each neighbor, vertical, horizontal, or diagonal, add that number to the score
"""
function get_score(g::Game)
    seen = Vector{CartesianIndex{2}}()
    score = 0

    # For each spot on the board
    for idx in eachindex(IndexCartesian(), g.board)
        # For each neighborly direction
        for dir in DIRS
            # If outside array or already seen, skip
            if !(checkbounds(Bool, g.board, idx + dir) && (idx + dir ∉ seen))
                continue
            end

            # Add to score if matches
            if g.board[idx+dir] == g.board[idx]
                score += g.board[idx]
            end
        end

        # Add it to `seen`
        push!(seen, idx)
    end

    score
end

"""
How many of the spots around `idx` are empty?
"""
function how_many_empties(g::Game, idx::CartesianIndex{2})::Int
    count(
        true for
        dir in DIRS if checkbounds(Bool, g.board, idx + dir) && (g.board[idx+dir] < 1)
    )
end
