App.GfListPostsComponent = Ember.Component.extend({
  /* PROPERTIES */
  layoutName: "components/gf-list-posts",
  gifPosts: null,
  classNames: ["list-posts-component"],
  persistedGifPosts: Ember.computed.filterBy("gifPosts", "isNew", false),

  /* ACTIONS */
  actions: {
    delete: function(gifPost) {
      gifPost.destroyRecord();
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
