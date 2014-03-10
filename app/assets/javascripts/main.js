$(document).ready(function(){
  $('#toggle-post-dialog').on("click", function(e) {
    e.preventDefault();
    $("#new-gif-body").val("");
    $('#share-section .button-area').hide('fade');
    $('#gif-post-dialog').show('blind');
    $("#gif-post-dialog a.gif-submit").attr("disabled", "disabled");
  });

  $('#gif-post-dialog').on("click", 'a.cancel-post', function(e) {
    e.preventDefault();
    $('#share-section .button-area').show('fade');
    $("#new-gif-body").val("");
    $('#gif-post-dialog').hide('blind');
  });

  $('#new-gif-body').on("input propertychange", function(e) {
    var parsedUrl = $(this).val().match(/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/);
    var isGif = !!parsedUrl ? /.gif$/.test(parsedUrl) : null;
    var charCount
    if (!!isGif) {
      charCount = ($(this).val().length - parsedUrl[0].length)
      if (charCount <= 140) {
        $("#gif-post-dialog a.gif-submit").removeAttr("disabled");
        $('#gif-post-dialog .message').text("").removeClass("error").hide();
        $('#gif-post-dialog .gif-preview-container').html('<div class="gif-preview"><img src="' + parsedUrl[0] + '" width="90"></div>')
     } else {
       $('#gif-post-dialog .message').show().addClass("validation-error").text("Your message is too long.");
       $("#gif-post-dialog a.gif-submit").attr("disabled", "disabled");
     }
    } else {
      charCount = $(this).val().length
      $('#gif-post-dialog .message').show().addClass("validation-error").text("There is no valid gif link in this post.")
      $('#gif-post-dialog .gif-preview').remove()
      $("#gif-post-dialog a.gif-submit").attr("disabled", "disabled");
    }
    $("#gif-post-dialog .character-count-number").text(charCount);
  });

  $('section.gif-list').on("click", "article a[data-gif-delete]", function(e) {
    e.preventDefault();
    console.log(e);
    var url = $(this).attr('href');
    var id = $(this).data('gifPostId');
    if(confirm('Are you sure you want to delete this post?')){
      $.ajax({
        type: "DELETE",
        dataType: "json",
        url: url
      }).done(function(data) {
        $('section.gif-list article[data-gif-post-id=' + id.toString() + ']').remove();
      });
    }
  });

  $('#gif-post-dialog').on("click", 'a.gif-submit', function(e) {
    e.preventDefault();
    var currentUserId = $('meta[name="current-user-id"]').attr("content");
    $(this).attr("disabled", "disabled");
    var url = $(this).attr('href');
    var body = $("#new-gif-body").val();
    var parsedUrl = body.match(/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/);
    $.ajax({
      type: "POST",
      dataType: "json",
      url: url,
      data: {
        gif_post: {
          body: body,
          url: parsedUrl[0],
        }
      }
    }).done(function(data) {
      var post = data.gif_post;
      var url = post.url || "";
      var username = (!!post.user && !!post.user.username) ? post.user.username : "";
      var body = post.body || null;
      $('#gif-post-dialog .message').removeClass("error").text("");
      $('.share-gif-form').hide('fade');
      $("#gif-post-dialog .character-count-number").text("0");
      $('#gif-post-dialog .message').show().addClass("success").text("New gif posted: " + post.url);
      var newArticle = '<article class="gif-entry" data-gif-entry data-gif-post-id="' + post.id + '"><div class="gif-entry-image"><img class="framed" src="' + url + '"></div><div class="gif-entry-body">' + body + '</div><div class="gif-entry-delete"><a class="btn btn-danger"data-gif-delete data-gif-post-id="' + post.id + '" href="/gif_posts/' + post.id + '" rel="nofollow">Delete</a></div><div class="gif-entry-user">Shared by ' + username + '</div><div class="gif-entry-permalink"><a href="/gif_posts/' + post.id + '">Permalink</a></div><div style="clear:both;"></div></article>';
      $('section.gif-list').prepend(newArticle);
      setTimeout(function() {
        $('#share-section .button-area').show('fade');
        $('#gif-post-dialog .message').hide().text("");
        $('#gif-post-dialog .gif-preview').remove()
        $('#gif-post-dialog').hide('blind');
        $('.share-gif-form').show();
      }, 5000);
    }).fail(function(data) {
      if (!data.responseText) {
        $('#gif-post-dialog .message').show().addClass("error").text("There was an error posting your gif. Please wait and try again.");
      } else {
        $('#gif-post-dialog .message').show().addClass("error").text(data.responseJSON.errors.url[0]);
      }
      setTimeout(function() {
        $('#gif-post-dialog .message').removeClass("error").hide();
        $("#gif-post-dialog a.gif-submit").removeAttr("disabled");
      }, 5000);
    });
  });
});
