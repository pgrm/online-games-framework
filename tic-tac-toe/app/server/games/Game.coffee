class @Game extends SecuredObject
  constructor: (playerId, gameId = null) ->
    super(playerId)
    @playerId = playerId
    @gameId = gameId
    if (gameId)
      @game = @load_game()


  create_new_game: -> @games().insert(@get_empty_game())


  join_game: ->
    if (@can_join_game())
      return @update_game(
        {$push: {playerIDs: @playerId, playersQueue: @playerId}})
    else
      throw new Meteor.Error(403, "The game is already full.")


  play_move: (move) ->
    @check_if_move_is_valid(move)
    @perform_move(move)
    @check_if_game_is_finnished()


  get_empty_game: ->
    state: 'active'
    nextPlayer: @playerId
    playersQueue: []
    playerIDs: [@playerId]
    when: new Date()


  load_game: ->
    if (@game)
      return @game

    @game = @games().findOne({_id: @gameId})
    if (!@game)
      throw new Meteor.Error(404, "The game does not exist.")
    else
      return @game


  update_game: (updateCommand) ->
    updateCommand.$set ||= {}
    updateCommand.$set.when = new Date()

    @games().update({_id: @gameId}, updateCommand)


  can_join_game: -> false

  check_if_move_is_valid: (move) -> false

  perform_move: (move) -> false

  check_if_game_is_finnished: -> false

  games: -> share.Games