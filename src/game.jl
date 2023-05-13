# This file has the interface for running a game
using StaticArrays
import Base: print, show

export Game, make_move!

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
    print(io, "\nUp next: $(g.up_next[1]), $(g.up_next[2])")
end

Base.print(g::Game) = Base.print(Base.stdout, g)

function make_move!(g::Game, row::Int, col::Int; verbose::Bool = false)
    # Check validity of input
    # `row` and `col` each have to be in [1, 5]
    ((row in 1:5) && (col in 1:5)) || BoundsError(g.board, CartesianIndex(row, col))
    # They cannot place a piece where one already exists
    @assert g.board[row, col] < 1 "Number already at [$row, $col]"

    # Place the first number from `up_next` at the desired location
    g.board[row, col] = g.up_next[1]

    # Update `up_next`
    g.up_next[1] = g.up_next[2]
    g.up_next[2] = rand(1:9)

    # Print if asked
    verbose && print(g)
end
