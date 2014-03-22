class @SecuredObject
  constructor: (userId) ->
    if !userId
      throw new Meteor.Error(401, "You must be logged in")
    @userId = userId