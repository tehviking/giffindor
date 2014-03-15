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

  /* OBSERVERS */
  // This computes the displayed message for all success/failure
  message: function(){
    var formState = this.get("formState")
    // On failure, delegate message to the object
    if (formState === "failure") {
      return this.get("gifPost.message");
      // On success, just scream real loud!
    } else if (formState === "success") {
      return "New gif posted: " + this.get("gifPost.parsedUrl")
      // If it's invalid but has a gif, it's too long:
    } else if (this.get("isInvalid") && !!this.get("gifPost.isGif")) {
      return "Your message is too long.";
      // Otherwise if it's not valid it's not a gif
    } else if (this.get("isInvalid")) {
      return "Please add a valid gif link to this post.";
    } else {
      return null;
    }
  }.property("formState", "isInvalid", "gifPost.isGif", "gifPost.message"),

  /* ACTIONS */
  // These actions are primarily about pushing state around.
  actions: {
    showDialog: function() {
      this.set("formState", "editing");
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
        controller.defer(function() {
          controller.set("formState", "initial")
          controller.set("gifPost", App.store.createRecord("gifPost"));
        }, 5000);
      // Failure
      }, function(data) {
        controller.set("formState", "failure");
        if (!!data.jqXHR && data.jqXHR.status == 422) {
          // 422: validation error
          controller.get("gifPost").set("message", data.jqXHR.responseJSON.errors.url[0]);
        } else {
          controller.get("gifPost").set("message", "There was an error posting your gif. Please wait and try again.")
        }
        controller.defer(function() {
          controller.set("formState", "editing")
        }, 5000);
      });
    }
  },

  /* FUNCTIONS */
  // Allow injectable setTimeout override for testing
  defer: function(callback, delay) {
    setTimeout(callback, delay);
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
