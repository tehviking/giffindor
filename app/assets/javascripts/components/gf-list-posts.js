App.GfListPostsComponent = Ember.Component.extend({
  /* PROPERTIES */
  layoutName: "components/gf-list-posts",
  gifPosts: null,
  classNames: ["list-posts-component"],
  // We only want to show posts that are saved to the server
  persistedGifPosts: Ember.computed.filterBy("gifPosts", "isNew", false),

  sortedPosts: function() {
    // well this is a neat trick, sort in reverse ID order
    return this.get("persistedGifPosts").sortBy("id:desc");
  }.property("persistedGifPosts.@each"),

  favedPosts: Ember.computed.filterBy("sortedPosts", "isFavorited", true),

  filteredPosts: function() {
    if (this.get("displayFilter") == "faved") {
      return this.get("favedPosts");
    } else {
      return this.get("persistedGifPosts");
    }
  }.property("favedPosts", "displayFilter"),

  /* ACTIONS */
  actions: {
    applyFilter: function(filter) {
      this.set("displayFilter", filter)
    },
    toggleFav: function(gifPost) {
      if (gifPost.get("isFavorited")) {
        var favId = gifPost.get("currentUserFavoriteId")
        App.store.find("favorite", favId).then(function(result){
          gifPost.set("currentUserFavoriteId", null);
          result.destroyRecord();
        });
      } else {
        fav = App.store.createRecord("favorite", {
          gifPost: gifPost
        });
        fav.save().then(function(result){
          gifPost.set("currentUserFavoriteId", result.get("id"))
        }, function(){
          gifPost.set("currentUserFavoriteId", null);
          fav.rollback();
        });
      }
    //   }
    },
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
