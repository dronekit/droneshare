(function() {
  module.exports = function(connect, options) {
    var app, cors, express, routes;
    express = require('express');
    routes = require('./routes');
    cors = require('express-cors');
    app = express();
    app.configure(function() {
      app.use(cors({
        allowedOrigins: ['*']
      }));
      app.use(express.logger('dev'));
      app.use(express.bodyParser());
      app.use(express.methodOverride());
      app.use(express.errorHandler());
      app.use(express["static"](String(options.base)));
      app.use(app.router);
      return routes(app, options);
    });
    app.get('*', function(req, res) {
      return res.sendfile('dist/index.html');
    });
    return [connect(app)];
  };

}).call(this);
