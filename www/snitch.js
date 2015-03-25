var exec = require("cordova/exec");

/**
 * This is a global variable called exposed by cordova
 */    
var Snitch = function(){};

Snitch.prototype.forcecrash = function(success, error) {
  exec(success, error, "HockeyAppPlugin", "forcecrash", []);
};

module.exports = new Snitch();
