module DigitParty

abstract type AbstractEngine end

include("game.jl")
include("naive1.jl")

export AbstractEngine, play!

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
