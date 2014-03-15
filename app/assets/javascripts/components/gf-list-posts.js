App.GfListPostsComponent = Ember.Component.extend({
  layoutName: "components/gf-list-posts",
  gifPosts: null,
  classNames: ["list-posts-component"],

  /* PROPERTIES */
  // We only want to show posts that are saved to the server
  persistedGifPosts: Ember.computed.filterBy("gifPosts", "isNew", false),

  // Then sort them in reverse createdAt order
  sortedPosts: function() {
    // Sort in reverse createdAt order
    return this.get("persistedGifPosts").sortBy("createdAt").reverseObjects()
  }.property("persistedGifPosts.@each.createdAt"),

  // Then allow filtering by whether a post is faved by current user
  favedPosts: Ember.computed.filterBy("sortedPosts", "isFavorited", true),

  // Then filter on the displayFilter property
  filteredPosts: function() {
    if (this.get("displayFilter") == "faved") {
      return this.get("favedPosts");
    } else {
      return this.get("sortedPosts");
    }
  }.property("favedPosts", "displayFilter"),

  /* ACTIONS */
  actions: {
    // Set or remove the filter for filteredPosts
    applyFilter: function(filter) {
      this.set("displayFilter", filter)
    },
    // Submit or delete a fav object for this post
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
