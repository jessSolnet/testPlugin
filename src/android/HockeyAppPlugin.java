package org.nypr.cordova.hockeyappplugin;

import net.hockeyapp.android.CrashManager;
import net.hockeyapp.android.Tracking;
import net.hockeyapp.android.UpdateManager;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.lang.RuntimeException;

import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;

public class HockeyAppPlugin extends CordovaPlugin {
	protected static final String LOG_TAG = "HockeyAppPlugin";
    private Activity activity;
	
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);
        activity = cordova.getActivity();
	  _checkForCrashes();
	  _checkForUpdates();
		Log.d(LOG_TAG, "HockeyApp Plugin initialized");
	}
	
	@Override
	public void onResume(boolean multitasking) {
		Log.d(LOG_TAG, "HockeyApp Plugin resuming");
	  _checkForUpdates();
		super.onResume(multitasking);
        Tracking.startUsage(activity);
	}

    @Override
    public void onPause(boolean multitasking) {
      Tracking.stopUsage(activity);
      super.onPause(multitasking);
    }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
    boolean ret=true;
    if(action.equalsIgnoreCase("forcecrash")){
      Calendar c = Calendar.getInstance();
      SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      throw new RuntimeException("Test crash at " + df.format(c.getTime())); 
    }else{
      callbackContext.error(LOG_TAG + " error: invalid action (" + action + ")");
      ret=false;
    }
    return ret;
  }
		
	@Override
	public void onDestroy() {
		Log.d(LOG_TAG, "HockeyApp Plugin destroying");
		super.onDestroy();
	}

	@Override
	public void onReset() {
		Log.d(LOG_TAG, "HockeyApp Plugin onReset--WebView has navigated to new page or refreshed.");
		super.onReset();
	}
	
	protected void _checkForCrashes() {
		Log.d(LOG_TAG, "HockeyApp Plugin checking for crashes");
		ApplicationInfo appliInfo = null;
		try {
			appliInfo = activity.getPackageManager().getApplicationInfo(activity.getPackageName(), PackageManager.GET_META_DATA);
		} catch (NameNotFoundException e) {}
		String hockeyAppId = appliInfo.metaData.getString("org.nypr.cordova.hockeyappplugin.HOCKEYAPP_APP_ID");
		if(hockeyAppId!=null && !hockeyAppId.equals("") && !hockeyAppId.contains("HOCKEY_APP_KEY")){
			CrashManager.register(cordova.getActivity(), hockeyAppId);
		}
	}

	protected void _checkForUpdates() {
		// Remove this for store builds!
		//__HOCKEY_APP_UPDATE_ACTIVE_START__
		Log.d(LOG_TAG, "HockeyApp Plugin checking for updates");
		ApplicationInfo appliInfo = null;
		try {
			appliInfo = activity.getPackageManager().getApplicationInfo(activity.getPackageName(), PackageManager.GET_META_DATA);
		} catch (NameNotFoundException e) {}
		String hockeyAppId = appliInfo.metaData.getString("org.nypr.cordova.hockeyappplugin.HOCKEYAPP_APP_ID");
		if(hockeyAppId!=null && !hockeyAppId.equals("") && !hockeyAppId.contains("HOCKEY_APP_KEY")){
			UpdateManager.register(cordova.getActivity(), hockeyAppId);
		}
		//__HOCKEY_APP_UPDATE_ACTIVE_END__
	}
}
