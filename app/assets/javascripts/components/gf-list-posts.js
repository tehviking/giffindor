App.GfListPostsComponent = Ember.Component.extend({
  layoutName: "components/gf-list-posts",
  gifPosts: null,
  classNames: ["list-posts-component"],

  /* PROPERTIES */
  // We only want to show posts that are saved to the server
  persistedGifPosts: Ember.computed.filterBy("gifPosts", "isNew", false),

  /* ACTIONS */
  actions: {
    // Set or remove the filter for filteredPosts
    delete: function(gifPost) {
      if (confirm("Really delete this lovely gif?")) {
        gifPost.destroyRecord().then(function(result){
          //message?
        }, function(){
          gifPost.rollback();
        });
      }
    }
  }
});

/* INITIALIZATION */
$(document).ready(function() {
  if ($("#gif-posts-container").length) {
    App.store.find("gifPost").then(function(result) {
      $("#gif-posts-container").each(function(){
        var component = App.GfListPostsComponent.create({
          gifPosts: result
        });
        component.replaceIn(this);
      });
    });
  }
});
