describe "list posts component", ->
  beforeEach ->
    App.advanceReadiness()
    ic.ajax.defineFixture '/gif_posts',
      response:
        gif_posts: [
          id: 1,
          url: "http://cool-gifs.com/cool.gif"
          body: "Cool gif http://cool-gifs.com/cool.gif"
          username: "tehviking"
          created_at: "2014-03-12T21:57:55.017Z"
          favorite_ids: []
        ]
      jqXHR: {}
      textStatus: 'success'
    @component = App.GfListPostsComponent.create
      container: App.__container__
    @component.appendTo("body")

    App.store.find("gifPost").then (result) =>
      Ember.run =>
        @gifPost = result.get("firstObject")
        @component.set "gifPosts", result
  afterEach ->
    @component.destroy()
  it "exists", ->
    expect(@component.get('element')).to.exist

  it "lists the gifs", ->
    expect(@component.$("article.gif-entry:first .gif-entry-user").text().trim()).to.equal "Shared by tehviking"
  describe "favoriting a post", ->
    beforeEach ->
      ic.ajax.defineFixture '/favorites',
        response:
          favorite:
            id: 1
            user_id: 1
            gif_post_id: 1
        jqXHR: {}
        textStatus: 'success'
      @entry = @component.$("article.gif-entry:first")
      click $(@entry).find(".gif-entry-fav-link")
    it "favorites the post", ->
      expect($("article.gif-entry i.fav-star")).to.have.class "is-favorited"
    it "lists the favorite count", ->
      expect($("article.gif-entry .gif-entry-fav-count").text().trim()).to.equal "1"

  # FIXME: This doesn't work unless run in isolation. Punting on a fix for now.
  # describe "deleting a gif", ->
  #   beforeEach ->
  #     ic.ajax.defineFixture '/gif_posts/1',
  #       response: "deleted yo"
  #       jqXHR: {}
  #       textStatus: 'success'

  #     sinon.stub(window, "confirm").returns(true)
  #     @component.send("delete", @gifPost)
  #   afterEach ->
  #     window.confirm.restore()
  #   it "removes the gif", ->
  #     wait()
  #     expect($("article.gif-entry")).not.to.exist
