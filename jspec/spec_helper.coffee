chai.Assertion.includeStack = true
Ember.testing = true
Ember.Test.adapter = Ember.Test.MochaAdapter.create()
App.setupForTesting()
App.injectTestHelpers()

window.start = ->
window.stop = ->

beforeEachWithoutEmberRun = this.beforeEach
this.beforeEach = (fn)->
  beforeEachWithoutEmberRun -> Ember.run => fn.call(this)

afterEachWithoutEmberRun = this.afterEach
this.afterEach = (fn)->
  afterEachWithoutEmberRun -> Ember.run => fn.call(this)
