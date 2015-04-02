/*global cordova, module*/

module.exports = {
    onStartup: function (name, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Snitch", "onStartup", [name]);
    }
};
