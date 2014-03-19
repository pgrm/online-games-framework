Games = new Meteor.Collection("games")

# Publish complete set of lists to all clients.
Meteor.publish('games_list', () -> Games.find())
Meteor.publish('game', (game_id) -> Games.find({_id: game_id}))