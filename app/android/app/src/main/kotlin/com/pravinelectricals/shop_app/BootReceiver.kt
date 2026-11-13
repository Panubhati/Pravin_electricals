package com.pravinelectricals.shop_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Starts background sync again after the phone restarts or the app is updated
 * (A12), when it was on. The app's Dart code then starts and syncs on its own.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
                if (!ShopEngine.isOn(context)) return
                try {
                    ShopSyncService.start(context, "Pravin Electricals", "")
                } catch (e: Exception) {
                    // Android refused (rare): sync starts when the app is next opened.
                    Log.w("ShopSync", "Could not start background sync: ${e.message}")
                }
            }
        }
    }
}
