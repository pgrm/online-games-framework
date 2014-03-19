class TicTacToe
  create_new_game: (playerId) ->
    @games().insert({
      state: 'active',
      nextPlayer: 'X',
      playersQueue: ['O'],
      field: [['', '', ''], ['', '', ''], ['', '', '']],
      players: ['X', 'O'],
      playerIDs: [playerId],
      when: new Date()
    })


  join_game: (playerId, gameId) ->
    game = @get_game(gameId)
    if (game.playerIDs.length < game.players.length)
      return @update_game(gameId, {$push: {playerIDs: playerId}})
    else
      throw new Meteor.Error(403, "The game is already full.")


  get_game: (gameId) ->
    game = @games().findOne({_id: gameId})
    if (!game)
      throw new Meteor.Error(404, "The game does not exist.")
    else
      return game


  update_game: (gameId, updateCommand) ->
    updateCommand.$set ||= {}
    updateCommand.$set.when = new Date()

    @games().update({_id: gameId}, updateCommand)


  games: -> share.Games


share.TicTacToe = TicTacToe