App.GfNewPostComponent = Ember.Component.extend({
  /* PROPERTIES */
  layoutName: "components/gf-new-post",
  gifPost: null,
  classNames: ["new-post-component"],
  classNameBindings: ["formState", "isInvalid"],
  formState: "initial",
  // FORM-STATES: "initial", "editing", "loading", "failure", "success"
  isValid: Ember.computed.alias("gifPost.isValid"),
  isInvalid: Ember.computed.not("isValid"),
  message: "",

  /* OBSERVERS */
  observeInputChanges: function(){
    var message = ""
    if (!this.get("gifPost.body")) {
      message = ""
    } else if (!this.get("gifPost.isValid") && !!this.get("gifPost.isGif")) {
      message = "Your message is too long."
      // otherwise if it's not valid it's not a gif
    } else if (!this.get("gifPost.isValid")) {
      message = "Please add a valid gif link to this post."
    }
    this.set("message", message);
  }.observes("gifPost.body", "gifPost.isValid").on("init"),

  /* ACTIONS */
  actions: {
    showDialog: function() {
      this.set("formState", "editing");
      $("#new-gif-body").val("");
    },
    cancel: function() {
      this.set("formState", "initial");
      this.set("gifPost", App.store.createRecord("gifPost"));
    },
    submit: function() {
      controller = this;
      controller.set("formState", "loading");
      var gifPost = this.get("gifPost");
      gifPost.save().then(function(data) {
        // Success
        controller.set("formState", "success");
        controller.set("message", "New gif posted: " + gifPost.get("parsedUrl"));

        setTimeout(function() {
          controller.set("message", "");
          controller.set("formState", "initial")
        }, 5000);
      // Failure
      }, function(data) {
        controller.set("formState", "failure");
        if (!!data.jqXHR && data.jqXHR.status == 422) {
          //422: validation error
          controller.set("message", data.jqXHR.responseJSON.errors.url[0]);
        } else {
          controller.set("message", "There was an error posting your gif. Please wait and try again.")
        }
        setTimeout(function() {
          controller.set("message", "");
          controller.set("formState", "editing")
        }, 5000);
      });
    }
  }
});

/* INITIALIZATION */
$(document).ready(function() {
  $("#new-post-container").each(function(){
    var component = App.GfNewPostComponent.create({
      gifPost: App.store.createRecord("gifPost")
    });
    component.replaceIn(this);
  });
});
