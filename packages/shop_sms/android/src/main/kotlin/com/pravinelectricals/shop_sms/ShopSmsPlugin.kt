package com.pravinelectricals.shop_sms

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** Sends plain SMS for the shop app's payment reminders. It only sends. */
class ShopSmsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null
  private var pending: MethodChannel.Result? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "com.pravinelectricals.shop_sms")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun granted() =
      ContextCompat.checkSelfPermission(context, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "hasPermission" -> result.success(granted())
      "requestPermission" -> {
        val a = activity
        if (granted()) {
          result.success(true)
        } else if (a == null || pending != null) {
          result.success(false)
        } else {
          pending = result
          ActivityCompat.requestPermissions(a, arrayOf(Manifest.permission.SEND_SMS), REQUEST)
        }
      }
      "send" -> {
        if (!granted()) {
          result.success(false)
          return
        }
        try {
          val number = call.argument<String>("number")!!
          val text = call.argument<String>("text")!!
          val sms: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(SmsManager::class.java)
          } else {
            @Suppress("DEPRECATION") SmsManager.getDefault()
          }
          val parts = sms.divideMessage(text)
          if (parts.size > 1) {
            sms.sendMultipartTextMessage("+$number", null, parts, null, null)
          } else {
            sms.sendTextMessage("+$number", null, text, null, null)
          }
          result.success(true)
        } catch (e: Exception) {
          result.success(false)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
    if (requestCode != REQUEST) return false
    pending?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
    pending = null
    return true
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() { activity = null }
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)
  override fun onDetachedFromActivity() { activity = null }

  companion object {
    private const val REQUEST = 4711
  }
}
