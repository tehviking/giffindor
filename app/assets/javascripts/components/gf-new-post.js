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
          url: this.get("parsedUrl"),
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
    if (!!this.get("gifPost.isGif")) {
      if (this.get("gifPost.isValid")) {
        $("#gif-post-dialog a.gif-submit").removeAttr("disabled");
        $('#gif-post-dialog .message').text("").removeClass("error").removeClass("validation-error").hide();
      } else {
        $('#gif-post-dialog .message').show().addClass("validation-error").text("Your message is too long.");
        $("#gif-post-dialog a.gif-submit").attr("disabled", "disabled");
      }
    } else {
      $('#gif-post-dialog .message').show().addClass("validation-error").text("There is no valid gif link in this post.")
      $("#gif-post-dialog a.gif-submit").attr("disabled", "disabled");
    }
  }.observes("gifPost.body", "gifPost.isValid"),

  /* ACTIONS */
  actions: {
    showDialog: function() {
      $("#new-gif-body").val("");
      $('#share-section .button-area').hide('fade');
      $('#gif-post-dialog').show('blind');
      $("#gif-post-dialog a.gif-submit").attr("disabled", "disabled");
    },
    cancel: function() {
      $('#share-section .button-area').show('fade');
      $("#new-gif-body").val("");
      $('#gif-post-dialog').hide();
    },
    submit: function() {
      var gifPost = this.get("gifPost")
      this.$("a.gif-submit").attr("disabled", "disabled");
      gifPost.save().then(function(data) {
        // Success
        gifPost.set("username", data.gif_post.user.username)
        gifPost.set("id", data.gif_post.id)
        $('#gif-post-dialog .message').removeClass("error").text("");
        $('.share-gif-form').hide('fade');
        $('#gif-post-dialog .message').show().addClass("success").text("New gif posted: " + gifPost.get("parsedUrl"));
        var newArticle = '<article class="gif-entry" data-gif-entry data-gif-post-id="' + gifPost.get("id") + '"><div class="gif-entry-image"><img class="framed" src="' + gifPost.get("parsedUrl") + '"></div><div class="gif-entry-body">' + gifPost.get("body") + '</div><div class="gif-entry-delete"><a class="btn btn-danger"data-gif-delete data-gif-post-id="' + gifPost.get("id") + '" href="/gif_posts/' + gifPost.get("id") + '" rel="nofollow">Delete</a></div><div class="gif-entry-user">Shared by ' + gifPost.get("username") + '</div><div class="gif-entry-permalink"><a href="/gif_posts/' + gifPost.get("id") + '">Permalink</a></div><div style="clear:both;"></div></article>';
        $('section.gif-list').prepend(newArticle);
        setTimeout(function() {
          console.log("running set-timeout on success")
          $('#share-section .button-area').show('fade');
          $('#gif-post-dialog .message').removeClass("success").hide().text("");
          $('#gif-post-dialog').hide('blind');
          $('.share-gif-form').show();
        }, 5000);
      // Failure
      }, function(data) {
        $('#gif-post-dialog .message').removeClass("success").text("");
        if (!data.jqXHR || !data.jqXHR.responseJSON) {
          $('#gif-post-dialog .message').show().addClass("error").text("There was an error posting your gif. Please wait and try again.");
        } else {
          $('#gif-post-dialog .message').show().addClass("error").text(data.jqXHR.responseJSON.errors.url[0]);
        }
        setTimeout(function() {
          $('#gif-post-dialog .message').removeClass("error").text("").hide();
          $("#gif-post-dialog a.gif-submit").removeAttr("disabled");
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
