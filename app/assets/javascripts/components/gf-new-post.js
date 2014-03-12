App.GifPost = Ember.Object.extend({
  /* PROPERTIES */
  regex: gifRegex(),
  body: "",
  urlRoot: "/gif_posts",
  username: "",

  parsedUrl: function() {
    var matches = this.get("body").match(this.get("regex"))
    return (matches && matches.length > 0) ? matches[0] : "";
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

  /* FUNCTIONS */
  save: function() {
    return ic.ajax({
      type: "POST",
      dataType: "json",
      url: this.get("urlRoot"),
      data: {
        gif_post: {
          body: this.get("body"),
          url: this.get("parsedUrl")
        }
      }
    })
  }
});

App.GfNewPostComponent = Ember.Component.extend({
  /* PROPERTIES */
  currentUser: null,
  layoutName: "components/gf-new-post",
  gifPost: null,
  classNames: ["new-post-component"],
  classNameBindings: ["formState", "isInvalid"],
  formState: "initial",
  // FORM-STATES: "initial", "editing", "loading", "failure", "success"
  isValid: Ember.computed.alias("gifPost.isValid"),
  isInvalid: Ember.computed.not("isValid"),
  message: "",

  /* OBSERVERS */
  initLegacyCode: function() {
    $('section.gif-list').on("click", "article a[data-gif-delete]", function(e) {
      e.preventDefault();
      var url = $(this).attr('href');
      var id = $(this).data('gifPostId');
      if(confirm('Are you sure you want to delete this post?')){
        ic.ajax({
          type: "DELETE",
          dataType: "json",
          url: url
        }).then(function(data) {
          $('section.gif-list article[data-gif-post-id=' + id.toString() + ']').remove();
        });
      }
    });
  }.on("didInsertElement"),

  observeInputChanges: function(){
    if (this.get("gifPost.isGif")) {
      if (this.get("gifPost.isValid")) {
        $('#gif-post-dialog .message').text("");
      } else {
        $('#gif-post-dialog .message').text("Your message is too long.");
      }
    } else {
      $('#gif-post-dialog .message').text("There is no valid gif link in this post.")
    }
  }.observes("gifPost.body", "gifPost.isValid"),

  /* ACTIONS */
  actions: {
    showDialog: function() {
      this.set("formState", "editing");
      $("#new-gif-body").val("");
    },
    cancel: function() {
      this.set("formState", "initial")
      $("#new-gif-body").val("");
    },
    submit: function() {
      controller = this;
      controller.set("formState", "loading");
      var gifPost = this.get("gifPost");
      gifPost.save().then(function(data) {
        // Success
        controller.set("formState", "success");
        gifPost.set("username", data.gif_post.user.username)
        gifPost.set("id", data.gif_post.id)
        $('#gif-post-dialog .message').text("");
        $('#gif-post-dialog .message').text("New gif posted: " + gifPost.get("parsedUrl"));
        var newArticle = '<article class="gif-entry" data-gif-entry data-gif-post-id="' + gifPost.get("id") + '"><div class="gif-entry-image"><img class="framed" src="' + gifPost.get("parsedUrl") + '"></div><div class="gif-entry-body">' + gifPost.get("body") + '</div><div class="gif-entry-delete"><a class="btn btn-danger"data-gif-delete data-gif-post-id="' + gifPost.get("id") + '" href="/gif_posts/' + gifPost.get("id") + '" rel="nofollow">Delete</a></div><div class="gif-entry-user">Shared by ' + gifPost.get("username") + '</div><div class="gif-entry-permalink"><a href="/gif_posts/' + gifPost.get("id") + '">Permalink</a></div><div style="clear:both;"></div></article>';
        $('section.gif-list').prepend(newArticle);
        setTimeout(function() {
          controller.set("formState", "initial")
          $('#gif-post-dialog .message').text("");
        }, 5000);
      // Failure
      }, function(data) {
        controller.set("formState", "failure");
        if (!data.jqXHR || !data.jqXHR.responseJSON) {
          $('#gif-post-dialog .message').text("There was an error posting your gif. Please wait and try again.");
        } else {
          $('#gif-post-dialog .message').text(data.jqXHR.responseJSON.errors.url[0]);
        }
        setTimeout(function() {
          $('#gif-post-dialog .message').text("");
          controller.set("formState", "initial")
        }, 5000);
      });
    }
  }
});

/* INITIALIZATION */
$(document).ready(function() {
  $("#new-post-container").each(function(){
    var component = App.GfNewPostComponent.create({
      gifPost: App.GifPost.create()
    });
    component.replaceIn(this);
  });
});

function gifRegex() {
  return /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/
                                                                         };
