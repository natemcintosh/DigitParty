# DigitParty

A copy of [Digit Party](https://digit.party/) that can be programatically played. It can also be manually played, but it's a lot easier to just play on the site. The intent here is to have fun making various engines that play the game, and comparing them.

The intended interface is that if you create an engine, you create a new file in `src/` with the name of the engine. The only method that you need to export is `pick_next_spot(g::Game, e::AbstractEngine)::CartesianIndex{2}`. That means your engine should be a subtype of `AbstractEngine`, which is exported by this package. Finally, call `play!(g::Game, e::YourEngine)` to run a single game with your engine; your score is returned.
