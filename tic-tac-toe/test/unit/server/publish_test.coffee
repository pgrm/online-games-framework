describe "Players model", ->
  it "is only added once to the Meteor.Collection", ->
    # EXECUTE & VERIFY
    expect(Meteor.instantiationCounts.games).toBe(2)