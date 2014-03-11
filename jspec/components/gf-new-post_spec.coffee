## UNIT TESTS
describe "GifPost", ->
  beforeEach ->
    @gifPost = App.GifPost.create()
    @clock = sinon.useFakeTimers()
  afterEach ->
    @clock.restore()
  describe "with a valid url", ->
    beforeEach ->
      @gifPost.set("body", "thing: http://blah.com/cool-gif.gif")
    it "parses the url from the body", ->
      expect(@gifPost.get("parsedUrl")).to.equal "http://blah.com/cool-gif.gif"
    it "sets isGif to true", ->
      expect(@gifPost.get("isGif")).to.be.true
    it "returns a char count minus the gif url", ->
      expect(@gifPost.get("charCount")).to.equal 7
    it "is valid", ->
      expect(@gifPost.get("isValid")).to.be.true
  describe "with a non-gif url", ->
    beforeEach ->
      @gifPost.set("body", "thing: http://blah.com/cool-gif.jpg")
    it "parses the url from the body", ->
      expect(@gifPost.get("parsedUrl")).to.equal "http://blah.com/cool-gif.jpg"
    it "sets isGif to true", ->
      expect(@gifPost.get("isGif")).to.be.false
    it "returns a char count minus the gif url", ->
      expect(@gifPost.get("charCount")).to.equal 35
    it "is not valid", ->
      expect(@gifPost.get("isValid")).to.be.false

## INTEGRATION TESTS
describe 'new post component', ->
  beforeEach ->
    @gifList = $('<section class="gif-list"></section>').appendTo("body");
    @component = App.__container__.lookup("component:gfNewPost").appendTo("body")
    @component.set "gifPost", App.GifPost.create()
  afterEach ->
    @gifList.remove()
    @component.destroy()
  it "exists", ->
    expect(@component.get('element')).to.exist
    expect(@component.$('#gif-post-dialog')).to.exist
  it "doesn't show the dialog", ->
    expect(@component.$('#gif-post-dialog')).not.to.be.visible

  describe "clicking the show dialog button", ->
    beforeEach ->
      click "#toggle-post-dialog"
      @component.send "showDialog"
    it "shows the dialog", ->
      expect(@component.$('#gif-post-dialog')).to.be.visible

    describe 'entering bad text into the gif box', ->
      beforeEach ->
        # THIS IS AWFUL. This input is not binding back to the component model.
        fillIn @component.$("textarea#new-gif-body"), "thing: notagif.jpg"
        @component.get("gifPost").set("body", "thing: notagif.jpg")
        @component.$("textarea#new-gif-body").trigger("input")
      it "binds to the model", ->
        expect(@component.get("gifPost.body")).to.equal "thing: notagif.jpg"
      it "leaves the save button disabled", ->
        expect(@component.$("a.gif-submit")).to.have.attr("disabled")
      it "counts the characters", ->
        expect(@component.$(".character-count-number").text()).to.equal "18"
      it "displays a client-side validation error", ->
        expect(@component.$(".message")).to.be.visible
        expect(@component.$(".message")).to.have.class("validation-error")
        expect(@component.$(".message").text()).to.match /no valid gif/
      it "does not display a preview section", ->
        expect(@component.$(".gif-preview")).not.to.exist

      describe 'putting too much text in the box', ->
        beforeEach ->
          fillIn @component.$("textarea#new-gif-body"), "thing: http://blah.com/cool-gif.gif This is a thing which is pretty cool except the text is too long. Maybe this is going to display a nice error message for people to enjoy"
          @component.get("gifPost").set("body", "thing: http://blah.com/cool-gif.gif This is a thing which is pretty cool except the text is too long. Maybe this is going to display a nice error message for people to enjoy")
          @component.$("textarea#new-gif-body").trigger("input")
        it "disables the save button", ->
          expect(@component.$("a.gif-submit")).to.have.attr("disabled")
        it "counts the characters", ->
          expect(@component.$(".character-count-number").text()).to.equal "145"
        it "displays a client-side validation error", ->
          expect(@component.$(".message")).to.be.visible
          expect(@component.$(".message")).to.have.class("validation-error")
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
            expect(@component.$(".message")).not.to.be.visible
            expect(@component.$(".message")).not.to.have.class("validation-error")
            expect(@component.$(".message").text()).to.be.empty
          it "displays a preview image", ->
            expect(@component.$(".gif-preview")).to.exist
            expect(@component.$(".gif-preview img").attr("src")).to.equal "http://blah.com/cool-gif.gif"
          describe "clicking submit with good response", ->
            beforeEach ->
              ic.ajax.defineFixture '/gif_posts',
                response:
                  gif_post:
                    id: "1"
                    url: "http://blah.com/cool-gif.gif"
                    user:
                      username: "fakeuser"
                    body: "thing: http://blah.com/cool-gif.gif"
                jqXHR: {}
                textStatus: 'success'
              click "a.gif-submit"
              # WTF EMBER. BIND YO SHIT.
              @component.send "submit"

            it "shows success message and adds gif", ->
              expect(@component.$("#gif-post-dialog .message")).to.be.visible
              expect(@component.$("#gif-post-dialog .message")).to.have.class "success"
              expect(@component.$("#gif-post-dialog .message").text()).to.equal "New gif posted: http://blah.com/cool-gif.gif"
              newGif = $("section.gif-list article.gif-entry")
              expect($(newGif[0]).find(".gif-entry-user").text()).to.equal "Shared by fakeuser"
            # describe "after 5 seconds", ->
            #   beforeEach ->
            #     @clock.tick(6000)
            #   it "resets to initial state", ->
            #     expect(@component.$("#gif-post-dialog .message")).not.to.be.visible
            #     expect(@component.$("#gif-post-dialog .message")).not.to.have.class "success"
            #     expect(@component.$("#gif-post-dialog .message").text()).to.equal ""

              describe "deleting the gif with success response", ->
                beforeEach ->
                  ic.ajax.defineFixture '/gif_posts/1',
                    response: "yay"
                    jqXHR: {}
                    textStatus: 'success'
                  sinon.stub(window, "confirm").returns(true)
                  @newGif = $("section.gif-list article.gif-entry")
                  @deleteButton = $(@newGif).find(".gif-entry-delete [data-gif-delete]")
                  $(@deleteButton).trigger("click")

                afterEach ->
                  window.confirm.restore()
                it "removes the gif", ->
                  expect($("section.gif-list article.gif-entry")).not.to.exist

          describe "clicking submit with validation error", ->
            beforeEach ->
              ic.ajax.defineFixture '/gif_posts',
                jqXHR:
                  responseText: "Validation fail"
                  responseJSON:
                    errors:
                      url: ["LOL NOPE VALIDATION FAILZ"]

                textStatus: 'unprocessable entity'
              click "a.gif-submit"
              # WTF EMBER. BIND YO SHIT.
              @component.send "submit"
            it "shows an error message", ->
              expect(@component.$("#gif-post-dialog .message")).not.to.have.class "success"
              expect(@component.$("#gif-post-dialog .message")).to.have.class "error"
              expect(@component.$("#gif-post-dialog .message").text()).to.equal "LOL NOPE VALIDATION FAILZ"
          #   describe "after 5 seconds", ->
          #     beforeEach ->
          #       @clock.tick(5010)
          #     afterEach ->
          #       @clock.restore()
          #     it "resets to initial state", ->
          #       expect(@component.$("#gif-post-dialog .message")).not.to.be.visible
          #       expect(@component.$("#gif-post-dialog .message")).not.to.have.class "error"
          #       expect(@component.$("#gif-post-dialog .message").text()).to.equal ""

          describe "clicking submit with bad response", ->
            beforeEach ->
              ic.ajax.defineFixture '/gif_posts',
                response: "BARF"
              click "a.gif-submit"
              # WTF EMBER. BIND YO SHIT.
              @component.send "submit"
            it "shows an error message", ->
              expect(@component.$("#gif-post-dialog .message")).not.to.have.class "success"
              expect(@component.$("#gif-post-dialog .message")).to.have.class "error"
              expect(@component.$("#gif-post-dialog .message").text()).to.match /error posting/

      describe "clicking cancel", ->
        beforeEach ->
          @component.$("#gif-post-dialog a.cancel-post").click()
        it "closes the dialog", ->
          expect(@component.$('#gif-post-dialog')).not.to.be.visible
        it "clears the text input", ->
          expect(@component.$('textarea').val()).to.equal ""
