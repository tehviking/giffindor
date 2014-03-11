App.GifPost = Ember.Object.extend({
  regex: gifRegex(),
  body: "",
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
  }.property("charCount", "isGif")
});

App.GfNewPostComponent = Ember.Component.extend({
  currentUser: null,
  layoutName: "components/gf-new-post",
  gifPost: null,
  postUrl: "/gif_posts",

  initLegacyCode: function() {
    var regex = gifRegex();
    var ajax = ic.ajax;
    var component = this;

    $('#gif-post-dialog').on("click", 'a.cancel-post', function(e) {
      e.preventDefault();
      $('#share-section .button-area').show('fade');
      $("#new-gif-body").val("");
      $('#gif-post-dialog').hide();
    });

    $('section.gif-list').on("click", "article a[data-gif-delete]", function(e) {
      e.preventDefault();
      var url = $(this).attr('href');
      var id = $(this).data('gifPostId');
      if(confirm('Are you sure you want to delete this post?')){
        ajax({
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

  actions: {
    showDialog: function() {
      $("#new-gif-body").val("");
      $('#share-section .button-area').hide('fade');
      $('#gif-post-dialog').show('blind');
      $("#gif-post-dialog a.gif-submit").attr("disabled", "disabled");
    },
    submit: function() {
      var currentUserId = $('meta[name="current-user-id"]').attr("content");
      $(this).attr("disabled", "disabled");
      ic.ajax({
        type: "POST",
        dataType: "json",
        url: this.get("postUrl"),
        data: {
          gif_post: {
            body: this.get("postUrl.body"),
            url: this.get("gifPost.parsedUrl"),
          }
        }
      }).then(function(data) {
        var post = data.gif_post;
        var url = post.url || "";
        var username = (!!post.user && !!post.user.username) ? post.user.username : "";
        var body = post.body || null;
        $('#gif-post-dialog .message').removeClass("error").text("");
        $('.share-gif-form').hide('fade');
        $('#gif-post-dialog .message').show().addClass("success").text("New gif posted: " + post.url);
        var newArticle = '<article class="gif-entry" data-gif-entry data-gif-post-id="' + post.id + '"><div class="gif-entry-image"><img class="framed" src="' + url + '"></div><div class="gif-entry-body">' + body + '</div><div class="gif-entry-delete"><a class="btn btn-danger"data-gif-delete data-gif-post-id="' + post.id + '" href="/gif_posts/' + post.id + '" rel="nofollow">Delete</a></div><div class="gif-entry-user">Shared by ' + username + '</div><div class="gif-entry-permalink"><a href="/gif_posts/' + post.id + '">Permalink</a></div><div style="clear:both;"></div></article>';
        $('section.gif-list').prepend(newArticle);
        setTimeout(function() {
          console.log("running set-timeout on success")
          $('#share-section .button-area').show('fade');
          $('#gif-post-dialog .message').removeClass("success").hide().text("");
          $('#gif-post-dialog').hide('blind');
          $('.share-gif-form').show();
        }, 5000);
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
