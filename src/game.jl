# This file has the interface for running a game
using StaticArrays
# using JuMP
# using HiGHS
import Base: print, show

export Game,
    make_move!,
    get_empty_spots,
    game_is_over,
    get_score,
    how_many_empties,
    get_pct_of_max,
    get_max_without_board,
    get_max_score_as_calculated_on_site

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
    how_many_empties(g::Game, idx::CartesianIndex{2})

How many of the spots around `idx` are empty?
"""
function how_many_empties(g::Game, idx::CartesianIndex{2})::Int
    count(
        true for
        dir in DIRS if checkbounds(Bool, g.board, idx + dir) && (g.board[idx+dir] < 1)
    )
end

"""
    get_pct_of_max(g::Game)

Of the most possible points you could have scored, if you had perfect knowledge of the
future, how many points did you score? In the range [0.0, 1.0].

This function is intended to be called once the game is over.
"""
function get_pct_of_max(g::Game)
    game_is_over(g) || error("Cannot calculate percent before game is over")

    max_score = get_max_without_board(g)
    get_score(g) / max_score
end

"""
Calculates the max score, by simply assuming that each instance of a number could be
connected to all other instances of that number
"""
function get_max_without_board(g::Game)::Int
    game_is_over(g) || error("Cannot get max score before game is over")
    # Create an array that acts like a dictionary. The index is the number and the value
    # is how many times that number appeared on the board
    counts = @MVector zeros(Int, 9)
    for val in g.board
        counts[val] += 1
    end

    sum(val * binomial(cnt, 2) for (val, cnt) in enumerate(counts))
end

"""
The site calculates the max score for each digits. This is always correct, but it's
correct more often than `get_max_without_board`
"""
function get_max_score_as_calculated_on_site(g::Game)::Int
    game_is_over(g) || error("Cannot get max score before game is over")
    # Using a vector as a dictionary: key is the index
    # n_verts2n_connections = @SVector [0, 0, 1, 3, 6, 8, 11, 14, 17, 20, 23]
    # d = Dict(zip(0:10, n_verts2n_connections))
    d = Dict(
        0 => 0,
        1 => 0,
        2 => 1,
        3 => 3,
        4 => 6,
        5 => 8,
        6 => 11,
        7 => 14,
        8 => 17,
        9 => 20,
        10 => 23,
    )

    # Count how many of each number we have
    counts = @MVector zeros(Int, 9)
    for val in g.board
        counts[val] += 1
    end

    sum(num * d[counts[num]] for num = 1:9)
end

# function optimizing_get_max_score(g::Game)::Int
#     game_is_over(g) || error("Cannot get max score before game is over")

#     # Create an array that acts like a dictionary. The index is the number and the value
#     # is how many times that number appeared on the board
#     counts = @MVector zeros(Int, 9)
#     for val in g.board
#         counts[val] += 1
#     end

#     model = Model(HiGHS.Optimizer)
#     # Create a 7x7 matrix, where the outer rows and columns are all zeros. Makes getting
#     # neighbors easier
#     @variable(model, x[1:7, 1:7], Int)

#     # All boundaries have to be 0
#     @constraint(model, bz1, x[:, 1] .== 0)
#     @constraint(model, bz2, x[:, end] .== 0)
#     @constraint(model, bz3, x[1, :] .== 0)
#     @constraint(model, bz4, x[end, :] .== 0)

#     # Need the correct number of instances of each number
#     @constraints(
#         model,
#         begin
#             correct_numbers[i = eachindex(counts)], count(==(i), x[2:6, 2:6]) == counts[i]
#         end
#     )

#     # Hoping to use 
#     # when `x[idx+dir] >= 1`, we add `x[idx]`, otherwise add 0
#     # DIRS = CartesianIndex.([(1, 1), (1, 0), (1, -1), (0, 1), (0, -1), (-1, 1), (-1, 0), (-1, -1)])
#     @objective(
#         model,
#         Max,
#         sum(
#             x[idx] * (1 - min(x[idx+dir], 1)) for
#             idx in eachindex(IndexCartesian(), x[2:6, 2:6]) for dir in DIRS
#         )
#     )

#     optimize!(model)
#     @show termination_status(model)
#     @show x
# end
