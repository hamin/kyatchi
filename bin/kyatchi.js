#!/usr/bin/env node
var coffee = require('coffee-script'); var vm = require('vm'); var fs = require('fs')
var src = fs.readFileSync(__dirname + '/../app.coffee')
var c = {process: process, require : require}; vm.runInNewContext(coffee.compile(src), c)