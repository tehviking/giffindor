$(document).ready(function(){
  $('#toggle-post-dialog').on("click", function(e) {
    e.preventDefault();
    $('#share-section .button-area').hide('fade');
    $('#gif-post-dialog').show('blind');
  });

  $('button.gif-submit').on("click", function(e) {
    e.preventDefault();
    var currentUserId = $('meta[name="current-user-id"]').attr("content");
    $(this).hide("fade");
    var url = $(this).attr('href');
    var body = $("#new-gif-body").val();
    $.ajax({
      type: "POST",
      dataType: "json",
      url: url,
      data: {
        gif_post: {
          body: body,
          user_id: currentUserId
        }
      }
    }).done(function(data) {
      var post = data.gif_post;
      var url = post.url || "";
      var username = (!!post.user && !!post.user.username) ? post.user.username : "";
      var body = post.body || null;
      $('.button.gif-submit').show('fade');
      $('.share-gif-form').hide('fade');
      $("#new-gif-body").val("");
      $('#gif-post-dialog').append("<p class='success-text'>New gif posted: " + post.url + "</p>");
      var newRow = '<td>' + username + '</td><td>' + url + '</td><td>' + body + '</td><td><a href="/gif_posts/' + post.id + '">Show</a></td><td><a href="/gif_posts/' + post.id + '/edit">Edit</a></td><td><a data-confirm="Are you sure?" data-method="delete" href="/gif_posts/' + post.id + '" rel="nofollow">Destroy</a></td>';
      $('table.gif-list tbody').append(newRow);
      setTimeout(function() {
        $('#share-section .button-area').show('fade');
        $('#gif-post-dialog .success-text').remove();
        $('#gif-post-dialog').hide('blind');
        $('.share-gif-form').show();
      }, 5000);
    });
  });
});
