App.GfListPostsComponent = Ember.Component.extend({
  /* PROPERTIES */
  layoutName: "components/gf-list-posts",
  gifPosts: null,
  classNames: ["list-posts-component"],
  persistedGifPosts: Ember.computed.filterBy("gifPosts", "isNew", false),
  sortedPosts: function() {
    // well this is a neat trick
    return this.get("persistedGifPosts").sortBy("id:desc");
  }.property("persistedGifPosts.@each"),

  /* ACTIONS */
  actions: {
    delete: function(gifPost) {
      if (confirm("Really delete this lovely gif?")) {
        gifPost.destroyRecord();
      }
    }
  }
});

/* INITIALIZATION */
$(document).ready(function() {
  App.store.find("gifPost").then(function(result) {
    $("#gif-posts-container").each(function(){
      var component = App.GfListPostsComponent.create({
        gifPosts: result
      });
      component.replaceIn(this);
    });
  });
});
