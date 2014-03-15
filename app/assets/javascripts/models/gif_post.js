App.GifPost = DS.Model.extend({
  /* PROPERTIES */
  favorites: DS.hasMany("favorite"),
  body: DS.attr("string"),
  url: DS.attr("string"),
  username: DS.attr("string"),
  currentUserFavoriteId: DS.attr("string"),
  message: null,
  isFavorited: Ember.computed.notEmpty("currentUserFavoriteId"),
  parsedUrl: function() {
    if (!!this.get("body")) {
      var matches = this.get("body").match(this.get("regex"))
      return (matches && matches.length > 0) ? matches[0] : "";
    }
  }.property("body"),
  isGif: function() {
    return /.gif$/.test(this.get("parsedUrl"))
  }.property("parsedUrl"),
  charCount: function() {
    if (this.get("isGif")) {
      return this.get("body.length") - this.get("parsedUrl.length")
    } else {
      return this.get("body.length")
    }
  }.property("body", "parsedUrl", "isGif"),
  isValid: function() {
    return !!(this.get("charCount") <= 140 && this.get("isGif"))
  }.property("charCount", "isGif"),
  permalink: function() {
    return "/gif_posts/" + this.get("id");
  }.property("id"),

  /* OBSERVERS */
  // Copy the computed parsedUrl into the canonical url to send to the server
  setUrl: function() {
    this.set("url", this.get("parsedUrl"));
  }.observes("parsedUrl"),

  /* MISC */
  // This property is at the end basically because it breaks Emacs auto-indent :/
  regex: function() {
    return /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/
   }.property()
});
