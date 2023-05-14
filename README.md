# DigitParty

A copy of [Digit Party](https://digit.party/) that can be programatically played. It can also be manually played, but it's a lot easier to just play on the site. The intent here is to have fun making various engines that play the game, and compare the performance.

If you create an engine, create a new file in `src/` with the name of the engine. Then export
- Your engine, e.g. `export MyEngine`. Make sure `MyEngine <: AbstractEngine`.
- The following method: `pick_next_spot(g::Game, e::MyEngine)::CartesianIndex{2}`

To run it:
```julia
g = Game()
score = play!(g, MyEngine())
pct_max = get_pct_of_max(g)
```
to run a single game with your engine; your score is returned. See [`examples/naive1.jl`](https://github.com/natemcintosh/DigitParty/blob/main/examples/naive1.jl) for a runnable example.
