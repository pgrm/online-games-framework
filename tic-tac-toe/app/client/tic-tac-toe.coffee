# Client-side JavaScript, bundled and sent to client.
# Define Minimongo collections to match server/publish.coffee.

Games = new Meteor.Collection("games")

Template.game_field.game = () -> Games.findOne()

# ID of currently selected game
Session.setDefault('game_id', null)
Session.setDefault('selected_field', null)

gamesHandle = Meteor.subscribe('games_list', () ->
  if (!Session.get('game_id'))
    game = Games.findOne({playerIDs: {$in: [Meteor.userId()]}})
    if (game)
      Router.setGame(game._id)
)

gameHandle = null
Deps.autorun(() ->
  game_id = Session.get('game_id')
  if (game_id)
    gameHandle = Meteor.subscribe('game', game_id, () ->
        if (!currentGame())
          Meteor.call('join_game', game_id)
    )
  else
    gameHandle = null
);

#////////// Games - List //////////

Template.games.loading_games = () -> !gamesHandle.ready()

Template.games.active_games = () -> allPlayersGames('active')
Template.games.won_games = () -> allPlayersGames('won')
Template.games.lost_games = () -> allPlayersGames('lost')

Template.games.description = () -> this._id

Template.games.events({
  'mousedown .game': ((evt) -> Router.setGame(this._id)),
  'click .game': ((evt) -> evt.preventDefault()),
  'click #newGame': ((evt) ->
    newGameId = Meteor.call('create_new_game', (error, newGameId) -> Router.setGame(newGameId))
  )
})

Template.games.selected = () -> if Session.equals('game_id', this._id) then 'selected' else ''

allPlayersGames = (state) ->
  currentPlayer = {playerIDs: {$in: [Meteor.userId()]}}
  switch state
    when 'active' then conditions = {$and: [{state: state}, currentPlayer]}
    when 'won' then conditions = {$and: [{state: 'finnished'}, {winner: Meteor.userId()}]}
    else conditions = {$and: [{state: 'finnished'}, currentPlayer]}
  Games.find(conditions)

#////////// Selected Game //////////

Template.game.loading_game = () -> (gameHandle && !gameHandle.ready()) || !currentGame()
Template.game.any_game_selected = () -> !Session.equals('game_id', null)

Template.game_field.rows = () ->
  selectedField = Session.get('selected_field')

  _.map(currentGame().field || [], (row, index) ->
    row_index = index
    {index: index, cells: _.map(row || [], (cell, index) ->
      cellObject = {value: cell, row: row_index, column: index}

      if (selectedField)
        if (row_index == selectedField.row && index == selectedField.column)
          cellObject.value = currentPlayer()

      return cellObject
    )}
  )

Template.cell_info.events({
  'click button': (evt) ->
    move = {row: this.row, column: this.column}
    Session.set('selected_field', move)
    Meteor.call('play_move', Session.get('game_id'), move, (error, data) ->
        console.log(error)
        console.log(data)
        Session.set('selected_field', null))
})

currentGame = () ->
  Games.findOne({_id: Session.get('game_id')})

currentPlayer = () ->
  game = currentGame()
  game.availablePlayers[game.playerIDs.indexOf(Meteor.userId())]

#////////// Tracking selected list in URL //////////

GamesRouter = Backbone.Router.extend({
  routes: {
    ":game_id": "main"
  },
  main: ((game_id) ->
    oldList = Session.get("game_id")
    if (oldList != game_id)
      Session.set("game_id", game_id)
  ),
  setGame: (game_id) -> this.navigate(game_id, true)
})

Router = new GamesRouter()

Meteor.startup(() -> Backbone.history.start({pushState: true}))

