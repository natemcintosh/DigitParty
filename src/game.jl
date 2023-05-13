# This file has the interface for running a game
using StaticArrays
import Base: print, show

export Game, make_move!, get_empty_spots, game_is_over

mutable struct Game
    board   :: MMatrix{5,5,Int8}
    up_next :: MVector{2,Int8}
end

Game() = Game(MMatrix{5,5,Int8}(zeros(5, 5)), MVector{2,Int8}(rand(1:9, 2)))

function Base.print(io::IO, g::Game)
    for row in eachrow(g.board)
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
function make_move!(g::Game, idx::Union{CartesianIndex{2}, IndexLinear, Int}; verbose::Bool = false)
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
