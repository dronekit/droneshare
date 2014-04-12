# Heroku

This describes how to deploy this package to heroku

heroku create myappname --buildpack https://github.com/mbuchetics/heroku-buildpack-nodejs-grunt.git
heroku config:set NODE_ENV=development
