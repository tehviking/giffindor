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

    describe 'entering in bad text into the gif box', ->
      beforeEach ->
        @component.$("textarea").val("thing: notagif.jpg")
        @component.$("textarea").trigger "input propertychange"
      it "leaves the save button disabled", ->
        expect(@component.$("a.gif-submit")).to.have.attr("disabled")

      describe 'entering good text into the gif box', ->
        beforeEach ->
          @component.$("textarea").val("thing: http://blah.com/cool-gif.gif")
          @component.$("textarea").trigger "input"
        it "enables the save button", ->
          expect(@component.$("a.gif-submit")).not.to.have.attr("disabled")

      describe "clicking cancel", ->
        beforeEach ->
          @component.$("#gif-post-dialog a.cancel-post").click()
        it "closes the dialog", ->
          expect(@component.$('#gif-post-dialog')).not.to.be.visible
        it "clears the text input", ->
          expect(@component.$('textarea').val()).to.equal ""

  #   it "triggers a search on the server", ->
  #     expect(App.Search.on).to.have.been.calledWith
  #       q: "partial"
  #       type: "person"
  #       params: {extra: "bacon"}
  #   describe 'when a result is selected', ->
  #     beforeEach ->
  #       @selectThing = sinon.spy()
  #       @result =
  #         name: 'Bob',
  #         value: new Object()
  #       @typeahead.$("input.typeahead").trigger('typeahead:selected', [@result])
  #     it 'invokes the action with that result', ->
  #       expect(@selectThing).to.have.been.calledWith @result
