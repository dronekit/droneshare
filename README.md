# mega-droneshare

Build Status: [![Dependency Status](https://www.codeship.io/projects/bdded4a0-a3ed-0131-b562-3a2ddf12dbeb/status)](https://www.codeship.io/projects/18633)

The new version of droneshare - built upon the DroneAPI.

## Developers guide

This application is built using AngularFS and [coffeescript](http://coffeescript.org/).

### Installing
Enter the following commands in the terminal.

1. `git clone git://github.com/diydrones/droneshare.git`
2. `cd MegaDroneShare`
3. `npm install`
4. `grunt bower:install`

### Compiling
You have options.

1. `grunt build` - will compile the app preserving individual files (when run, files will be loaded on-demand)
2. `grunt` or `grunt dev` - same as `grunt` but will watch for file changes and recompile on-the-fly
3. `grunt prod` - will compile using optimizations.  This will create one JavaScript file and one CSS file to demonstrate the power of [r.js](http://requirejs.org/docs/optimization.html), the build optimization tool for RequireJS.  And take a look at the index.html file.  Yep - it's minified too.
4. `grunt test` - will compile the app and run all unit tests

### What is Coffeescript?

Coffeescript is like javascript but with much less boilerplate code.  It compiles down to javascript (trivially).  If you've never used coffeescript,
please see this [five page user guide](http://arcturo.github.io/library/coffeescript/).  If you _still_ prefer javascript: We've got ya covered.
Simply run the following grunt task.

`grunt jslove` - will transpile all of the CoffeeScript files to JavaScript and throw out the Coffee.


## A note on tabs, spaces and line-endings

This project uses a [http://editorconfig.org/](.editorconfig) file to specify source formatting conventions.  We encourage you to install a suitable
plug-in into your text-editor of choice.
