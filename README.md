CodaLess
========

Small Coda plug-in that compiles less files on save.

#Install

You need to have node.js installed (at /usr/local/bin/node). If you haven't already installed node.js go to http://nodejs.org, download the installer and run the install. The installer will put the files in the correct location.

Then you must have installed less (at /usr/local/lib/node_modules/less/bin/lessc). The easiest way is to run the following command once you have installed node:

	sudo npm install -g less

You can download the plugin from [Panic](http://panic.com/coda/plugins.php#Plugins) (the topmost plug in) or if you want to be sure to get the latest build download the zip from the [releases page](https://github.com/idmean/CodaLess/releases).

#Usage

Whenever you save a less file (file with extension `.less`) it will be compiled.

#Preferences

Go to `Plug-ins > CodaLess Preferences` in Coda. It's currently possible to change the output path and to minify output.

![Preferences Screen Shot](preferences.png?raw=true)

## Change Log

### 2.0.0

- Plug-in rewritten in Swift (blazing fast!)
- Using installed Less, no longer contains own compiler
- Improvements by taking advantage of queues 
- Not compiling remote files
- Introducing "Jump to error"
