package com.pravinelectricals.shop_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * The app's one Flutter engine (A12). It is kept in [FlutterEngineCache], so it
 * outlives the screen: when the app is swiped away, Wi-Fi sync keeps running in
 * it while [ShopSyncService] keeps the process alive. The screen attaches to the
 * same engine when the app is opened again, and the background service starts
 * it on its own after a phone restart.
 */
object ShopEngine {
    const val ID = "shop"
    private const val CHANNEL = "com.pravinelectricals.shop_app/background_sync"
    private const val PREFS = "background_sync"
    private const val KEY_ON = "on"

    private var channel: MethodChannel? = null

    /** Returns the running engine, starting it (and the app's Dart code) if needed. */
    @Synchronized
    fun ensure(context: Context): FlutterEngine {
        FlutterEngineCache.getInstance().get(ID)?.let { return it }
        val app = context.applicationContext
        val engine = FlutterEngine(app)
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "start" -> {
                            setOn(app, true)
                            ShopSyncService.start(app, call.argument<String>("title")!!, call.argument<String>("text")!!)
                            result.success(null)
                        }
                        "update" -> {
                            ShopSyncService.update(app, call.argument<String>("title")!!, call.argument<String>("text")!!)
                            result.success(null)
                        }
                        "stop" -> {
                            setOn(app, false)
                            ShopSyncService.stop(app)
                            result.success(null)
                        }
                        "batteryUnrestricted" -> result.success(batteryUnrestricted(app))
                        "askBattery" -> {
                            askBattery(app)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("background_sync", e.message, null)
                }
            }
        }
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(ID, engine)
        return engine
    }

    /** The 2-minute check: asks the app's Dart code to sync now. */
    fun tick() {
        channel?.invokeMethod("tick", null)
    }

    /** Whether the owner switched background sync on (read after a restart). */
    fun isOn(context: Context): Boolean =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(KEY_ON, false)

    private fun setOn(context: Context, on: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(KEY_ON, on).apply()
    }

    private fun batteryUnrestricted(context: Context): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(context.packageName)
    }

    /** Android's own question "Let the app always run in the background?". */
    private fun askBattery(context: Context) {
        val ask = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:${context.packageName}"))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            context.startActivity(ask)
        } catch (e: Exception) {
            // Some phones hide that screen: open the app's settings page instead.
            context.startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${context.packageName}"))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        }
    }

    /** True on Android versions that need a service type (14 and later). */
    val needsServiceType: Boolean get() = Build.VERSION.SDK_INT >= 34
}
