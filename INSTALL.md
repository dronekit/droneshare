# Installing Droneshare

This document is mostly assuming you are installing to the 3DR version of droneshare.  If you are forking droneshare for your own purposes, then some of these commands may need your personal credentials.

Droneshare is (currently) an entirely Angular client side application.  So deployment is mostly a matter of finding a suitable static file server.

# Deploying

## to Appengine

See deploy-to-appengine.sh for example.

## to Amazon S3

* ```pip install awscli```
* ```aws configure``` - and then enter your AWS credentials
* [Configure aws](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* complete -C aws_completer aws
* ```deploy-to-s3.sh```

# Running


## Requirements

- [Nodejs](http://nodejs.org/)
- [npm](https://www.npmjs.org/)
- [grunt](http://gruntjs.com/) (Install globaly: ```npm install -g grunt-cli```)

## Installing

To install the app you need to install the packages required for this project, the app has Node package requirements and Bower library packages

```
npm install
grunt bower:install
```

## Running the app

Configure your web server to the ```dist``` folder on the app and run the **build**, **prod** or **dev** tasks

```
grunt build
```

this will generate the files your web server needs to launch the app


## Tests

To run tests you need to run the test grunt task which builds the app then runs the tests


```
grunt test
```

If you are planning on debugging tests we recommend you use either the **test** or **karma** grunt tasks with the **--watch** option

```
grunt test --watch
// or
grunt karma --watch

```

this will leave a process running watching for changes on the test files, which speeds up testing.

A pro-tip is to launch your browser at the url specified when running the tests

Here is an example excerpt output from ```grunt karma```

```
Running "karma:unit" (karma) task
INFO [karma]: Karma v0.12.16 server started at http://localhost:9876/
INFO [launcher]: Starting browser PhantomJS
INFO [PhantomJS 1.9.7 (Mac OS X)]: Connected on socket tIC2TRlp_tzgnpb0U1mB with id 25791127
```

notice the url from Karma **http://localhost:9876/** run that on your browser so you can set debug breakpoints to help you debug your tests.