module DigitParty
using Random

abstract type AbstractEngine end

include("game.jl")
include("naive1.jl")

export AbstractEngine, play

"""
    play([rng=default_rng()], e::AbstractEngine)

Play a single game with a given engine. Optionally, specify a random number generator.
This can be useful in cases where you want two or more engines to play the exact same
game.

The score is returned.
"""
function play(g::Game, e::AbstractEngine)
    while !game_is_over(g)
        next_spot = pick_next_spot(g, e)
        make_move!(g, next_spot)
    end
    get_score(g)
end

end # module DigitParty
