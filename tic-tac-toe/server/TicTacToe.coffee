class TicTacToe
  create_new_game: (playerId) ->
    @games().insert({
      state: 'active',
      nextPlayer: playerId,
      playersQueue: [],
      field: [['', '', ''], ['', '', ''], ['', '', '']],
      availablePlayers: ['X', 'O'],
      playerIDs: [playerId],
      when: new Date()
    })


  join_game: (playerId, gameId) ->
    game = @get_game(gameId)

    if (game.playerIDs.length < game.availablePlayers.length)
      return @update_game(gameId, {$push: {playerIDs: playerId, playersQueue: playerId}})
    else
      throw new Meteor.Error(403, "The game is already full.")


  play_move: (playerId, gameId, move) ->
    game = @get_game(gameId)

    if (game.availablePlayers.length == game.playerIDs.length)
      if (game.nextPlayer == playerId)
        if (game.field[move.row][move.column] == '')
          return @perform_move(playerId, game, move)
        else
          throw new Meteor.Error(403, "The field is not free anymore")
      else
        throw new Meteor.Error(403, "It is not your turn")
    else
      throw new Meteor.Error(403, "You must wait for all the players to join")


  get_game: (gameId) ->
    game = @games().findOne({_id: gameId})
    if (!game)
      throw new Meteor.Error(404, "The game does not exist.")
    else
      return game


  perform_move: (playerId, game, move) ->
    updateCommand = {
      $set: {nextPlayer: game.playersQueue.shift()},
      $push: {playersQueue: game.nextPlayer}
    }

    updateCommand.$set['field.' + move.row + '.' + move.column] = @current_player_sign(game.nextPlayer, game)
    @update_game(game._id, updateCommand)
    @update_game(game._id, {$pop: {playersQueue: -1}})


  update_game: (gameId, updateCommand) ->
    updateCommand.$set ||= {}
    updateCommand.$set.when = new Date()

    @games().update({_id: gameId}, updateCommand)


  current_player_sign: (playerId, game) -> game.availablePlayers[game.playerIDs.indexOf(playerId)]

  games: -> share.Games


share.TicTacToe = TicTacToe