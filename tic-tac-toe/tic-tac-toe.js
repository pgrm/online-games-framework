Games = new Meteor.Collection("games");
Colors = new Meteor.Collection("colors");

if (Meteor.isClient) {
  Template.game_field.game = function () {
    return Games.findOne();
  };

  Template.color_list.colors = function () {
    return Colors.find({}, {sort: {likes: -1, name: 1}});
  };
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup
  });
}
