Games = new Meteor.Collection("games")

share.Games = Games
Y = share.Y
TicTacToe = share.TicTacToe

# Publish complete set of lists to all clients.
Meteor.publish('games_list', ->
  Games.find({playerIDs: {$in: [this.userId]}}))

Meteor.publish('game', (game_id) ->
  Games.find({$and: [{_id: game_id}, {playerIDs: {$in: [this.userId]}}]}))

Meteor.methods({
  create_new_game: ->
    new TicTacToe(this.userId).create_new_game()

  join_game: (gameId) ->
    new TicTacToe(this.userId, gameId).join_game()

  play_move: (gameId, move) ->
    new TicTacToe(this.userId, gameId).play_move(move)
})