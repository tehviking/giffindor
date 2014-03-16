chai.Assertion.includeStack = true
Ember.testing = true
App.setupForTesting()
App.injectTestHelpers()

#window.start = ->
#window.stop = ->

beforeEachWithoutEmberRun = this.beforeEach
this.beforeEach = (fn)->
  beforeEachWithoutEmberRun -> Ember.run.join => fn.call(this)

afterEachWithoutEmberRun = this.afterEach
this.afterEach = (fn)->
  afterEachWithoutEmberRun -> Ember.run.join => fn.call(this)

beforeEach ->
  App.reset()
