using DigitParty

game = Game()
engine = Naive1(vec(CartesianIndices(game.board)))

score = play!(game, engine)
pct_max = get_pct_of_max(g)
@show pct_max
