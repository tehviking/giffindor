describe 'new post component', ->
  beforeEach ->
    @component = App.GfNewPostComponent.create().append()
    @component.container = App.__container__
  afterEach ->
    @component.destroy()
  it "exists", ->
    expect(@component.get('element')).to.exist
    expect(@component.$('#gif-post-dialog')).to.exist

  # describe 'entering in some text into the search box', ->
  #   beforeEach ->
  #     sinon.stub App.Search, "on", (params)->
  #       new Ember.RSVP.Promise (resolve, reject)=>

  #     @typeahead.$("input.typeahead").val("partial")
  #     @typeahead.$("input.typeahead").trigger "input"
  #   afterEach ->
  #     App.Search.on.restore()

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
