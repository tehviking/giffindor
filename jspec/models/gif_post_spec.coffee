describe "GifPost", ->
  beforeEach ->
    @gifPost = App.store.createRecord("gifPost")
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
