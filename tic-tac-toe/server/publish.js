Games = new Meteor.Collection("games");

// Publish complete set of lists to all clients.
Meteor.publish('games_list', function () {
  return Games.find();
});

Meteor.publish('game', function(game_id) {
  return Games.find({_id: game_id});
});