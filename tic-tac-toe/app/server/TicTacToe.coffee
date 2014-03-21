class TicTacToe
  constructor: (playerId, gameId = null) ->
    @playerId = playerId
    @gameId = gameId
    if (gameId)
      @game = load_game()


  create_new_game: ->
    @games().insert({
      state: 'active',
      nextPlayer: @playerId,
      playersQueue: [],
      field: [['', '', ''], ['', '', ''], ['', '', '']],
      availablePlayers: ['X', 'O'],
      playerIDs: [@playerId],
      when: new Date()
    })


  join_game: ->
    if (@game.playerIDs.length < @game.availablePlayers.length)
      return @update_game(
        {$push: {playerIDs: @playerId, playersQueue: @playerId}})
    else
      throw new Meteor.Error(403, "The game is already full.")


  play_move: (move) ->
    @check_if_move_is_valid(move)
    @perform_move(move)
    @check_if_game_is_finnished()


  load_game: ->
    if (@game)
      return @game

    @game = @games().findOne({_id: @gameId})
    if (!@game)
      throw new Meteor.Error(404, "The game does not exist.")
    else
      return @game


  check_if_move_is_valid: (move) ->
    if (@game.availablePlayers.length == @game.playerIDs.length)
      if (@game.nextPlayer == @playerId)
        if (@game.field[move.row][move.column] == '')
          return true
        else
          throw new Meteor.Error(403, "The field is not free anymore")
      else
        throw new Meteor.Error(403, "It is not your turn")
    else
      throw new Meteor.Error(403, "You must wait for all the players to join")


  perform_move: (move) ->
    updateCommand = {
      $set: {nextPlayer: @game.playersQueue.shift()},
      $push: {playersQueue: @game.nextPlayer}
    }

    cellProperty = "field.#{move.row}.#{move.column}"
    updateCommand.$set[cellProperty] = @current_player_sign()
    @update_game(updateCommand)
    @update_game({$pop: {playersQueue: -1}})


  update_game: (updateCommand) ->
    updateCommand.$set ||= {}
    updateCommand.$set.when = new Date()

    @games().update({_id: @gameId}, updateCommand)


  check_if_game_is_finnished: ->
#    winner = @check_rows_and_columns(game)
#    lastRow = lastColumn = null
#    for i in [0..game.field.length]
#      for j in [0..game.field.length]

    false


  check_rows: (requiredLineLength) ->
    for i in [0..@game.field.length-1]
      lastPlayer = @game.field[i][0]
      lineLength = @calc_players_line_length(lastPlayer, 0)

      for j in [1..@game.field[i].length-1]
        if lastPlayer == @game.field[i][j]
          lineLength = @calc_players_line_length(lastPlayer, lineLength)
          if lineLength == requiredLineLength
            return lastPlayer
        else
          lastPlayer = @game.field[i][j]
          lineLength = @calc_players_line_length(lastPlayer, 0)
          if (j - lineLength) >= (@game.field[i].length - requiredLineLength)
            break

  current_player_sign: ->
    @game.availablePlayers[@game.playerIDs.indexOf(@playerId)]

  calc_players_line_length: (playerSign, oldLineLength) ->
    if playerSign == '' then 0 else oldLineLength + 1

  games: -> share.Games


share.TicTacToe = TicTacToe