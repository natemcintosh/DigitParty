module DigitParty

import Base: print, show
using Graphs
using GridGraphs
using JuMP
using HiGHS
using Random
using StaticArrays

abstract type AbstractEngine end

include("game.jl")
include("naive1.jl")
include("optimal_solution.jl")

export AbstractEngine, play!
export Game,
    make_move!,
    get_empty_spots,
    game_is_over,
    get_score,
    how_many_empties,
    get_pct_of_max,
    get_max_without_board,
    get_max_score_as_calculated_on_site
export Naive1, pick_next_spot
export optimal_solution

"""
    play!(g::Game, e::AbstractEngine)

Play a single game with a given engine. Optionally, specify a random number generator.
This can be useful in cases where you want two or more engines to play the exact same
game. The score is returned.

Note that the `Game` object will be filled up. If you want multiple engines to play
the same game, make copies of it with `deepcopy()`.
"""
function play!(g::Game, e::AbstractEngine)
    for _ in 1:25
        next_spot = pick_next_spot(g, e)
        make_move!(g, next_spot)
    end
    get_score(g)
end

end # module DigitParty
