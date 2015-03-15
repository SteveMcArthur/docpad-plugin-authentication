/* global require, process*/
console.log("Compiling...");
var path = require('path');
var fs = require('fs');
var spawn = require('child_process').spawn;

var WINDOWS = (process.platform.indexOf('win') > -1) ? true : false;
var EXT = (WINDOWS) ? '.cmd' : '';
var APP_PATH = process.cwd();
var MODULES_PATH = path.join(APP_PATH, "node_modules");
var BIN_PATH = path.join(MODULES_PATH, ".bin");
var COFFEE = path.join(BIN_PATH, "coffee" + EXT);
var COFFEE_SRC_PATH = path.join("..", "src");
var COFFEE_OUT_PATH = path.join("..", "out");

function copyFile(source, target){

    function done(err){
        console.log(err);
	}

    var rd = fs.createReadStream(source);
    rd.on("error", function(err){
        done(err);
	});

    var wr = fs.createWriteStream(target)
    wr.on("error",function(err){
        done(err)
	});
    rd.pipe(wr)

}



spawn(COFFEE, ['-co', COFFEE_OUT_PATH, COFFEE_SRC_PATH], {
	stdio: 'inherit',
	cwd: APP_PATH
});


