App.GifPost = DS.Model.extend({
  /* PROPERTIES */
  body: DS.attr("string"),
  url: DS.attr("string"),
  username: DS.attr("string"),

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
  setUrl: function() {
    this.set("url", this.get("parsedUrl"));
  }.observes("parsedUrl"),

  regex: function() {
    return /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/
   }.property()
});
