# HockeyApp PhoneGap/PhoneGap Build/Cordova Plugin

### Platform Support

This plugin supports PhoneGap/PhoneGap Build/Cordova apps running on both iOS and Android.

### Version Requirements

This plugin is meant to work with Cordova 3.5.0+ and the latest version of the HockeyApp library.

SDK documentation and integration guides for IOS and Android:  
http://support.hockeyapp.net/kb/client-integration-ios-mac-os-x/hockeyapp-for-ios  
http://support.hockeyapp.net/kb/client-integration-android-other-platforms/hockeyapp-for-android-sdk  

TODO - update plugin to latest SDK versions 

## Installation

#### Phonegap Build

        <gap:plugin name="net.michaelgooden.cordova.hockeyappplugin" source="plugins.cordova.io" version="~0.1.8">
          <param name="HOCKEYAPP_APP_ID_FOR_ANDROID" value="HOCKEY_APP_KEY" />
          <param name="HOCKEYAPP_APP_ID_FOR_IOS" value="HOCKEY_APP_KEY" />
        </gap:plugin>

Make sure to change `HOCKEY_APP_KEY` for your HockeyApp application ID for each platform.

#### Automatic Installation using PhoneGap/Cordova CLI (iOS and Android)
 1. Make sure you update your projects to Cordova version 3.5.0+ before installing this plugin.

        cordova platform update ios
        cordova platform update android

 2. Install this plugin using PhoneGap/Cordova CLI:

        cordova plugin add net.michaelgooden.cordova.hockeyappplugin

 3. Add your HockeyApp application IDs to your config.xml:
     
        <preference name="HOCKEYAPP_APP_ID_FOR_ANDROID" value="HOCKEY_APP_KEY" />
        <preference name="HOCKEYAPP_APP_ID_FOR_IOS" value="HOCKEY_APP_KEY" />

Make sure to change `HOCKEY_APP_KEY` for your HockeyApp application ID for each platform.

TODO - better way to turn update check on/off (Android only) than having build script comment out code between __HOCKEY_APP_UPDATE_ACTIVE_START__ and __HOCKEY_APP_UPDATE_ACTIVE_END__ in HockeyAppPlugin.java 

### Acknowledgements

This plugin was forked from wnyc's original project at https://github.com/wnyc/cordova-plugin-hockeyapp.git
