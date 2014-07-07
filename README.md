# Droneshare

Build Status:

[![Codeship Status for diydrones/droneshare](https://codeship.io/projects/1d6b0730-e382-0131-36da-0e6774a12e5d/status)](https://codeship.io/projects/25456)

The new version of droneshare - built upon the DroneAPI.  Please see our [welcome letter](WELCOME.md).

## Developers guide

This application is built using AngularJS and [coffeescript](http://coffeescript.org/).


### Requirements

Before we continue make sure your system is running with the latest stable versions of the following packages

- [Nodejs](http://nodejs.org/)
- [npm](https://www.npmjs.org/)
- [grunt](http://gruntjs.com/) (Install globaly: ```npm install -g grunt-cli```)

### Getting the source
you either want to download the latest version or use git to get either our own or your fork of the project.

to get our repository

```
git clone https://github.com/diydrones/droneshare.git
```

to get your fork

```
git clone git@github.com:YOUR-USERNAME/droneshare.git
```

or finally theres a zip download of the latest version available.

[Download Zip](https://github.com/diydrones/droneshare/archive/master.zip)



### Installing

To install the app you need to install the packages required for this project, the app has Node package requirements and Bower library packages.

You can find the list of npm packages inside the [packages.js](https://github.com/diydrones/droneshare/blob/master/package.json) file.

The bower list can be found inside the [bower.json](https://github.com/diydrones/droneshare/blob/master/bower.json)

to install just do

```
npm install
grunt bower:install
```

### Running the app

Configure your web server to the ```dist``` folder on the app and run the **build**, **prod** or **dev** tasks

```
grunt build
```

this will generate the files your web server needs to launch the app


### Tests

To run tests you need to run the test grunt task which builds the app then runs the tests


```
grunt test
```

If you are planning on debugging tests we recommend you use either the **test** or **karma** grunt tasks with the **--watch** option

```
grunt test --watch
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

Notice the url from Karma **http://localhost:9876/** open that on your browser so you can set debug breakpoints to help you debug your tests.


### Compiling

There are 3 ways of compiling the app depending on your needs

1. `grunt build` - will compile the app preserving individual files (when run, files will be loaded on-demand)
2. `grunt` or `grunt dev` - same as `grunt` but will watch for file changes and recompile on-the-fly
3. `grunt prod` - will compile using optimizations.  This will create one JavaScript file and one CSS file to demonstrate the power of [r.js](http://requirejs.org/docs/optimization.html), the build optimization tool for RequireJS.  And take a look at the index.html file.  Yep - it's minified too.
4. `grunt test` - will compile the app and run all unit tests


### What is Coffeescript?

Coffeescript is like javascript but with much less boilerplate code.  It compiles down to javascript (trivially).  If you've never used coffeescript,
please see this [five page user guide](http://arcturo.github.io/library/coffeescript/).  If you _still_ prefer javascript: We've got ya covered.
Simply run the following grunt task.

`grunt jslove` - will transpile all of the CoffeeScript files to JavaScript and throw out the Coffee.


### A note on tabs, spaces and line-endings

This project uses a [http://editorconfig.org/](.editorconfig) file to specify source formatting conventions.  We encourage you to install a suitable
plug-in into your text-editor of choice.

