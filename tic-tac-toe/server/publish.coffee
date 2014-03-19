Games = new Meteor.Collection("games")

share.Games = Games
Y = share.Y
TicTacToe = share.TicTacToe
t = new TicTacToe()

# Publish complete set of lists to all clients.
Meteor.publish('games_list', -> Games.find({playerIDs: {$in: [this.userId]}}))
Meteor.publish('game', (game_id) -> Games.find({$and: [{_id: game_id}, {playerIDs: {$in: [this.userId]}}]}))

Meteor.methods({
  create_new_game: -> t.create_new_game(this.userId)
  join_game: (gameId) -> t.join_game(this.userId, gameId)
  play_move: (gameId, move) -> t.play_move(this.userId, gameId, move)
})


check_user = (userId) ->
  if (userId)
    return true
  else
    throw new Meteor.Error(401, "You must be logged in")


Y(TicTacToe).when
  create_new_game: (userId) -> check_user(userId)
  join_game: (userId) -> check_user(userId)
  play_move: (userId) -> check_user(userId)