App.Favorite = DS.Model.extend({
  userId: DS.attr("number"),
  gifPost: DS.belongsTo("gifPost")
});
