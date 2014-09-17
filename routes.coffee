# GRUNT SERVER ROUTES
module.exports = (app, options) ->
  app.get '/', (req, res) ->
    res.render "#{options.base}/index.html"
