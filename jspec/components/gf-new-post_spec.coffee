describe 'new post component', ->
  beforeEach ->
    @component = App.__container__.lookup("component:gfNewPost").appendTo("body")
    @component.set "gifPost", App.store.createRecord("gifPost")
    @component.set "defer", (callback, delay) =>
      @deferredCallback = callback
  afterEach ->
    @component.destroy()
  it "exists", ->
    expect(@component.get('element')).to.exist
    expect(@component.$('#gif-post-dialog')).to.exist
  it "doesn't show the dialog", ->
    expect(@component.get("formState")).to.equal "initial"
    # TODO: Enable after CSS is included in test
    # expect(@component.$('.share-dialog-container'))

  describe "clicking the show dialog button", ->
    beforeEach ->
      click "#toggle-post-dialog"
      @component.send "showDialog"
    it "shows the dialog", ->
      expect(@component.$('#gif-post-dialog')).to.be.visible

    describe 'entering bad text into the gif box', ->
      beforeEach ->
        # FIXME: EMBER PROBLEMS
        # THIS IS AWFUL. This input is not binding back to the component model.
        fillIn @component.$("textarea#new-gif-body"), "thing: notagif.jpg"
        @component.get("gifPost").set("body", "thing: notagif.jpg")
        @component.$("textarea#new-gif-body").trigger("input")
      afterEach ->
      it "binds to the model", ->
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
              click "a.gif-submit"
              # WTF EMBER. BIND YO SHIT.
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
                expect(@component.$("#gif-post-dialog .message").text()).to.equal ""

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
              click "a.gif-submit"
              # WTF EMBER. BIND YO SHIT.
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
              click "a.gif-submit"
              # WTF EMBER. BIND YO SHIT.
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
      response: {"gif_posts":[{"id":69,"url":"http://fake.com/cool.gif","body":"Play ball http://fake.com/cool.gif","username":"tehviking"}]}
      jqXHR: {}
      textStatus: 'success'
    @component = App.__container__.lookup("component:gfListPosts").appendTo("body")
    App.store.find("gifPost").then (result) =>
      @component.set "gifPosts", result
      @gifPost = result.get("firstObject")
  afterEach ->
    @component.destroy()
  it "exists", ->
    expect(@component.get('element')).to.exist

  it "lists the gifs", ->
    expect(@component.$("article.gif-entry:first .gif-entry-user").text().trim()).to.equal "Shared by tehviking"
  # FIXME: this has async issues. It doesn't wait for the gifPost?
  # describe "deleting a gif", ->
  #   beforeEach ->
  #     sinon.stub(window, "confirm").returns(true)
  #     #@domGif = $("article.gif-entry:first")
  #     #@deleteButton = $(@domGif).find(".gif-entry-delete [data-gif-delete]")
  #     #$(@deleteButton).trigger("click")
  #     @component.send("delete", @gifPost)
  #   afterEach ->
  #     window.confirm.restore()
  #   it "removes the gif", ->
  #     expect($("article.gif-entry")).not.to.exist
