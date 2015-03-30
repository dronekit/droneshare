(function() {
  module.exports = function(app, options) {
    return app.get('/', function(req, res) {
      return res.render("" + options.base + "/index.html");
    });
  };

}).call(this);
