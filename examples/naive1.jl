using DigitParty

game = Game()
engine = Naive1(vec(CartesianIndices(game.board)))

score = play(game, engine)
@show score
