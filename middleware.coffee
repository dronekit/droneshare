module.exports = (connect, options) ->
  express = require 'express'
  routes = require './routes'
  cors = require 'express-cors'
  app = express()

  app.configure ->
    app.use cors
      allowedOrigins: [ '*' ]
    app.use express.logger 'dev'
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.errorHandler()
    app.use express.static String(options.base)
    app.use app.router
    routes app, options

  app.get '*', (req, res) ->
    res.sendfile('dist/index.html')

  [connect(app)]
