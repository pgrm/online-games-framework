// Client-side JavaScript, bundled and sent to client.
// Define Minimongo collections to match server/publish.js.

Games = new Meteor.Collection("games");

Template.game_field.game = function () {
  return Games.findOne();
};

// ID of currently selected game
Session.setDefault('game_id', null);

// Subscribe to 'lists' collection on startup.
// Select a list once data has arrived.
var gamesHandle = Meteor.subscribe('games', function () {
  if (!Session.get('game_id')) {
    var game = Games.findOne();
    if (game) {
      Router.setGame(game._id);
    }
  }
});

var gameHandle = null;
// Always be subscribed to the todos for the selected list.
Deps.autorun(function () {
  var game_id = Session.get('game_id');
  if (game_id) {
    gameHandle = Meteor.subscribe('game', game_id);
  } else {
    gameHandle = null;
  }
});

////////// Games - List //////////

Template.games.loading = function () {
  return !gamesHandle.ready();
};

Template.games.games = function () {
  return Games.find();
};

Template.games.events({
  'mousedown .game': function (evt) { // select game
    Router.setGame(this._id);
  },
  'click .game': function (evt) {
    // prevent clicks on <a> from refreshing the page.
    evt.preventDefault();
  },
});

Template.games.selected = function () {
  return Session.equals('game_id', this._id) ? 'selected' : '';
};

////////// Selected Game //////////

Template.game.loading = function () {
  return gameHandle && !gameHandle.ready();
};

Template.game.any_game_selected = function () {
  return !Session.equals('game_id', null);
};

Template.game_field.rows = function () {
  return _.map(this.field || [], function (row, index) {
    var row_index = index;
    return {index: index, cells: _.map(row || [], function (cell, index) {
      return {value: cell, row: row_index, column: index};
    })};
  });
};

////////// Tracking selected list in URL //////////

var GamesRouter = Backbone.Router.extend({
  routes: {
    ":game_id": "main"
  },
  main: function (game_id) {
    var oldList = Session.get("game_id");
    if (oldList !== list_id) {
      Session.set("game_id", game_id);
    }
  },
  setGame: function (game_id) {
    this.navigate(game_id, true);
  }
});

Router = new GamesRouter;

Meteor.startup(function () {
  Backbone.history.start({pushState: true});
});

