describe 'new post component', ->
  beforeEach ->
    @component = App.GfNewPostComponent.create().append()
    @component.container = App.__container__
  afterEach ->
    @component.destroy()
  it "exists", ->
    expect(@component.get('element')).to.exist
    expect(@component.$('#gif-post-dialog')).to.exist
  it "doesn't show the dialog", ->
    expect(@component.$('#gif-post-dialog')).not.to.be.visible

  describe "clicking the show dialog button", ->
    beforeEach ->
      @component.$("#toggle-post-dialog").click()
    it "shows the dialog", ->
      expect(@component.$('#gif-post-dialog')).to.be.visible

    describe 'entering bad text into the gif box', ->
      beforeEach ->
        @component.$("textarea").val("thing: notagif.jpg")
        @component.$("textarea").trigger "input"
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
            @component.$("textarea").val("thing: http://blah.com/cool-gif.gif")
            @component.$("textarea").trigger "input"
            @component.$("textarea").val("thing: http://blah.com/cool-gif.gif This is a thing which is pretty cool except the text is too long. Maybe this is going to display a nice error message for people to enjoy")
            @component.$("textarea").trigger "input"
        it "disables the save button", ->
          expect(@component.$("a.gif-submit")).to.have.attr("disabled")
        it "counts the characters", ->
          expect(@component.$(".character-count-number").text()).to.equal "145"
        it "displays a client-side validation error", ->
          expect(@component.$(".message")).to.be.visible
          expect(@component.$(".message")).to.have.class("validation-error")
          expect(@component.$(".message").text()).to.match /too long/
        it "continues to display a preview section", ->
          expect(@component.$(".gif-preview")).to.exist

        describe 'entering good text into the gif box', ->
          beforeEach ->
            @component.$("textarea").val("thing: http://blah.com/cool-gif.gif")
            @component.$("textarea").trigger "input"
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
              @clock = sinon.useFakeTimers()
              @component.$().append('<section class="gif-list"></section>')
              @component.$("a.gif-submit").attr("href", "/gif_posts").click();
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
              @component.$("a.gif-submit").click();
            afterEach ->
              @clock.restore()

            it "adds success class and shows message", ->
              expect(@component.$("#gif-post-dialog .message")).to.be.visible
              expect(@component.$("#gif-post-dialog .message")).to.have.class "success"
              expect(@component.$("#gif-post-dialog .message").text()).to.equal "New gif posted: http://blah.com/cool-gif.gif"
            it "adds the gif to the list", ->
              @newGif = @component.$("section.gif-list article.gif-entry")
              expect(@newGif).to.exist
              expect($(@newGif[0]).find(".gif-entry-user").text()).to.equal "Shared by fakeuser"
            describe "after 5 seconds", ->
              beforeEach ->
                @clock.tick(5010)
              it "resets to initial state", ->
                expect(@component.$("#gif-post-dialog .message")).not.to.be.visible
                expect(@component.$("#gif-post-dialog .message")).not.to.have.class "success"
                expect(@component.$("#gif-post-dialog .message").text()).to.equal ""

          describe "clicking submit with validation error", ->
            beforeEach ->
              @clock = sinon.useFakeTimers()
              @component.$("a.gif-submit").attr("href", "/gif_posts").click();
              ic.ajax.defineFixture '/gif_posts',
                responseText: "Validation fail"
                responseJSON:
                  errors:
                    url: ["LOL NOPE VALIDATION FAILZ"]
                jqXHR: {}
                textStatus: 'unprocessable entity'
              @component.$("a.gif-submit").click();
            it "shows an error message", ->
              expect(@component.$("#gif-post-dialog .message")).not.to.have.class "success"
              expect(@component.$("#gif-post-dialog .message")).to.have.class "error"
              expect(@component.$("#gif-post-dialog .message").text()).to.equal "LOL NOPE VALIDATION FAILZ"
            describe "after 5 seconds", ->
              beforeEach ->
                @clock.tick(5010)
              afterEach ->
                @clock.restore()
              it "resets to initial state", ->
                expect(@component.$("#gif-post-dialog .message")).not.to.be.visible
                expect(@component.$("#gif-post-dialog .message")).not.to.have.class "error"
                expect(@component.$("#gif-post-dialog .message").text()).to.equal ""

          describe "clicking submit with bad response", ->
            beforeEach ->
              @component.$("a.gif-submit").attr("href", "/gif_posts").click();
              ic.ajax.defineFixture '/gif_posts',
                response: "BARF"
              @component.$("a.gif-submit").click();
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
