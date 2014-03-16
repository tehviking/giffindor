describe 'new post component', ->
  beforeEach ->
    @component = App.__container__.lookup("component:gfNewPost")
    @component.set "gifPost", App.store.createRecord("gifPost")
    @component.set "defer", (callback, delay) =>
      @deferredCallback = callback
    @component.appendTo("body")
  afterEach ->
    @component.destroy()
  it "exists", ->
    expect(@component.get('element')).to.exist
    expect(@component.$('#gif-post-dialog')).to.exist
  it "doesn't show the dialog", ->
    expect(@component.$()).to.have.class "initial"
    # TODO: Enable after SCSS is included in test
    # expect(@component.$('.share-dialog-container'))

  describe "clicking the show dialog button", ->
    beforeEach ->
      click "#toggle-post-dialog"
      @component.send "showDialog"
    it "shows the dialog", ->
      expect(@component.$('#gif-post-dialog')).to.be.visible
      expect(@component.$()).to.have.class "editing"

    describe 'entering bad text into the gif box', ->
      beforeEach ->
        # FIXME: This input is not binding back to the component model.
        # The model is binding into the input. This only happens in test.
        # fillIn "textarea#new-gif-body", "thing: notagif.jpg"
        @component.get("gifPost").set("body", "thing: notagif.jpg")
      it "binds to the model", ->
        expect(@component.$("textarea#new-gif-body").val()).to.equal "thing: notagif.jpg"
        expect(@component.get("gifPost.body")).to.equal "thing: notagif.jpg"
      it "leaves the save button disabled", ->
        expect(@component.$()).to.have.class "is-invalid"
        # TODO: Enable after CSS is included in test
        # expect(@component.$("a.gif-submit")).to.have.attr("cursor", "not-allowed")
      it "counts the characters", ->
        expect(@component.$(".character-count-number").text()).to.equal "18"
      it "displays a client-side validation error", ->
        expect(@component.$(".message")).to.be.visible
        expect(@component.$()).to.have.class("is-invalid")
        expect(@component.$(".message").text()).to.match /Please add a valid gif/
      it "does not display a preview section", ->
        expect(@component.$(".gif-preview")).not.to.exist

      describe 'putting too much text in the box', ->
        beforeEach ->
          fillIn @component.$("textarea#new-gif-body"), "thing: http://blah.com/cool-gif.gif This is a thing which is pretty cool except the text is too long. Maybe this is going to display a nice error message for people to enjoy"
          @component.get("gifPost").set("body", "thing: http://blah.com/cool-gif.gif This is a thing which is pretty cool except the text is too long. Maybe this is going to display a nice error message for people to enjoy")
          @component.$("textarea#new-gif-body").trigger("input")
        it "disables the save button", ->
          expect(@component.$()).to.have.class "is-invalid"
          # TODO: Enable after CSS is included in test
          # expect(@component.$("a.gif-submit")).to.have.attr("cursor", "not-allowed")
        it "counts the characters", ->
          expect(@component.$(".character-count-number").text()).to.equal "145"
        it "displays a client-side validation error", ->
          expect(@component.$(".message")).to.be.visible
          expect(@component.$(".message").text()).to.match /too long/
        it "continues to display a preview section", ->
          #expect(@component.$(".gif-preview")).to.exist

        describe 'entering good text into the gif box', ->
          beforeEach ->
            fillIn @component.$("textarea#new-gif-body"), "thing: http://blah.com/cool-gif.gif"
            @component.$("textarea#new-gif-body").trigger("input")
            @component.get("gifPost").set("body", "thing: http://blah.com/cool-gif.gif")
          it "enables the save button", ->
            expect(@component.$("a.gif-submit")).not.to.have.attr("disabled")
          it "counts characters, minus the gif input", ->
            expect(@component.$(".character-count-number").text()).to.equal "7"
          it "does not display an error message", ->
            expect(@component.$()).not.to.have.class "is-invalid"
            # TODO: Enable after CSS is included in test
            #expect(@component.$(".message")).not.to.be.visible
            expect(@component.$(".message").text()).to.be.empty
          it "displays a preview image", ->
            expect(@component.$(".gif-preview")).to.exist
            expect(@component.$(".gif-preview img").attr("src")).to.equal "http://blah.com/cool-gif.gif"
          describe "clicking submit with good response", ->
            beforeEach ->
              @listComponent = App.__container__.lookup("component:gfListPosts").appendTo("body")
              ic.ajax.defineFixture '/gif_posts',
                response:
                  gif_post:
                    id: "1"
                    url: "http://blah.com/cool-gif.gif"
                    username: "fakeuser"
                    body: "thing: http://blah.com/cool-gif.gif"
                jqXHR: {}
                textStatus: 'success'
              # FIXME: Still no bindings from template to component
              #click "a.gif-submit"
              @component.send "submit"
            afterEach ->
              @listComponent.destroy()

            it "shows success message", ->
              expect(@component.$("#gif-post-dialog .message")).to.be.visible
              expect(@component.$()).to.have.class "success"
              expect(@component.$("#gif-post-dialog .message").text()).to.equal "New gif posted: http://blah.com/cool-gif.gif"
            describe "after 5 seconds", ->
              beforeEach ->
                @deferredCallback()
              it "resets to initial state", ->
                expect(@component.$()).to.have.class "initial"

          describe "clicking submit with validation error", ->
            beforeEach ->
              ic.ajax.defineFixture '/gif_posts',
                jqXHR:
                  responseText: "Validation fail"
                  responseJSON:
                    errors:
                      url: ["LOL NOPE VALIDATION FAILZ"]
                  status: 422
                textStatus: 'unprocessable entity'
              # FIXME: Still no bindings from template to component
              # click "a.gif-submit"
              @component.send "submit"
            it "shows an error message", ->
              expect(@component.$()).not.to.have.class "success"
              expect(@component.$()).to.have.class "failure"
              expect(@component.$("#gif-post-dialog .message").text()).to.equal "LOL NOPE VALIDATION FAILZ"
            describe "after 5 seconds", ->
              beforeEach ->
                @deferredCallback.call()
              it "resets to editing state", ->
                expect(@component.$()).to.have.class "editing"
                expect(@component.$("#gif-post-dialog .message").text()).to.equal ""

          describe "clicking submit with bad response", ->
            beforeEach ->
              ic.ajax.defineFixture '/gif_posts',
                response: "BARF"
              # FIXME: Still no bindings from template to component
              # click "a.gif-submit"
              @component.send "submit"
            it "shows an error message", ->
              expect(@component.$()).not.to.have.class "success"
              expect(@component.$()).to.have.class "failure"
              expect(@component.$("#gif-post-dialog .message").text()).to.match /error posting/

      describe "clicking cancel", ->
        beforeEach ->
          click @component.$("a.cancel-post")
          @component.send("cancel")
        it "closes the dialog", ->
          expect(@component.$()).to.have.class "initial"
          # TODO: Enable after CSS is included in test
          # expect(@component.$('#gif-post-dialog')).not.to.be.visible
        it "clears the text input", ->
          expect(@component.$('textarea').val()).to.equal ""

describe "list posts component", ->
  beforeEach ->
    ic.ajax.defineFixture '/gif_posts',
      response:
        favorites: [
          id: 1
          user_id: 1
          gif_post_id: 1
        ]
        gif_posts: [
          id: 1,
          url: "http://cool-gifs.com/cool.gif"
          body: "Cool gif http://cool-gifs.com/cool.gif"
          username: "tehviking"
          current_user_favorite_id: 1
          created_at: "2014-03-12T21:57:55.017Z"
          favorite_ids: [1]
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
      @component.send("toggleFavorite", @gifPost)
    it "favorites the post", ->
      wait()
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
