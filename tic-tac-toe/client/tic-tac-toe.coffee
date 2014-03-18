# Client-side JavaScript, bundled and sent to client.
# Define Minimongo collections to match server/publish.coffee.

Games = new Meteor.Collection("games")

Template.game_field.game = () -> Games.findOne()

# ID of currently selected game
Session.setDefault('game_id', null)

gamesHandle = Meteor.subscribe('games_list', () ->
  if (!Session.get('game_id'))
    game = Games.findOne()
    if (game)
      Router.setGame(game._id)
)

gameHandle = null
Deps.autorun(() ->
  game_id = Session.get('game_id')
  if (game_id)
    gameHandle = Meteor.subscribe('game', game_id)
  else
    gameHandle = null
);

#////////// Games - List //////////

Template.games.loading = () -> !gamesHandle.ready()
Template.games.games = () -> Games.find()

Template.games.events({
  'mousedown .game': ((evt) -> Router.setGame(this._id)),
  'click .game': ((evt) -> evt.preventDefault()),
  'click #newGame': (evt) ->
    newGameId = Games.insert({
      nextPlayer: 'X',
      playersQueue: ['O'],
      field: [['', '', ''], ['', '', ''], ['', '', '']],
      players: [{X: Meteor.userId()}, {Y: null}]
    })
    
    Router.setGame(newGameId)
})

Template.games.selected = () -> if Session.equals('game_id', this._id) then 'selected' else ''

#////////// Selected Game //////////

Template.game.loading = () -> gameHandle && !gameHandle.ready()
Template.game.any_game_selected = () -> !Session.equals('game_id', null)

Template.game_field.rows = () ->
  _.map(Games.findOne({_id: Session.get('game_id')}).field || [], (row, index) ->
    row_index = index
    {index: index, cells: _.map(row || [], (cell, index) ->
      {value: cell, row: row_index, column: index}
    )}
  )

Template.cell_info.events({
  'click button': (evt) ->
    game_id = Session.get('game_id')
    game = Games.findOne({_id: game_id})
    updateCommand = {
      $set: {nextPlayer: game.playersQueue.shift()},
      $push: {playersQueue: game.nextPlayer}
    }

    updateCommand.$set['field.' + this.row + '.' + this.column] = game.nextPlayer
    Games.update({_id: game_id}, updateCommand)
    Games.update({_id: game_id}, {$pop: {playersQueue: -1}})
})

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

