package com.pravinelectricals.shop_app

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.SystemClock
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

/**
 * Keeps the app running while it is closed so Wi-Fi sync with the shop's other
 * phone goes on (A12). It shows the "Shop sync on" notification Android needs,
 * keeps Wi-Fi awake, and every 2 minutes wakes the app's Dart code to check the
 * other phone. New changes still arrive at once: the other phone calls this one.
 */
class ShopSyncService : Service() {
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        // After a phone restart nothing else has started the app's Dart code.
        ShopEngine.ensure(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: lastTitle
        val text = intent?.getStringExtra(EXTRA_TEXT) ?: lastText
        lastTitle = title
        lastText = text
        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            notification(this, title, text),
            if (ShopEngine.needsServiceType) ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE else 0,
        )
        holdWifi()
        scheduleTick(this)
        // Android starts it again by itself if it ever has to stop it.
        return START_STICKY
    }

    override fun onDestroy() {
        cancelTick(this)
        wifiLock?.let { if (it.isHeld) it.release() }
        wifiLock = null
        super.onDestroy()
    }

    @Suppress("DEPRECATION")
    private fun holdWifi() {
        if (wifiLock?.isHeld == true) return
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        wifiLock = wifi.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "PravinElectricals:sync").apply {
            setReferenceCounted(false)
            acquire()
        }
    }

    /** The 2-minute alarm: wakes the phone briefly and asks the app to sync. */
    class Tick : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            // Long enough for one sync round; released by itself.
            pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "PravinElectricals:tick").acquire(30_000)
            ShopEngine.ensure(context)
            ShopEngine.tick()
            if (ShopEngine.isOn(context)) scheduleTick(context)
        }
    }

    companion object {
        private const val CHANNEL_ID = "shop_sync"
        private const val NOTIFICATION_ID = 4782
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_TEXT = "text"
        private const val TICK_MS = 2 * 60 * 1000L

        private var lastTitle = "Pravin Electricals"
        private var lastText = ""

        fun start(context: Context, title: String, text: String) {
            val intent = Intent(context, ShopSyncService::class.java)
                .putExtra(EXTRA_TITLE, title)
                .putExtra(EXTRA_TEXT, text)
            if (Build.VERSION.SDK_INT >= 26) context.startForegroundService(intent) else context.startService(intent)
        }

        /** Changes the notification text ("last synced 10:42") without a sound. */
        fun update(context: Context, title: String, text: String) {
            lastTitle = title
            lastText = text
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(NOTIFICATION_ID, notification(context, title, text))
        }

        fun stop(context: Context) {
            cancelTick(context)
            context.stopService(Intent(context, ShopSyncService::class.java))
        }

        private fun notification(context: Context, title: String, text: String): Notification {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (Build.VERSION.SDK_INT >= 26 && nm.getNotificationChannel(CHANNEL_ID) == null) {
                nm.createNotificationChannel(
                    NotificationChannel(CHANNEL_ID, "Shop sync", NotificationManager.IMPORTANCE_LOW).apply {
                        description = "Shown while the app syncs with the shop's other phone"
                        setShowBadge(false)
                    },
                )
            }
            val open = PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            return NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_sync)
                .setContentTitle(title)
                .setContentText(text)
                .setContentIntent(open)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setSilent(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
                .build()
        }

        private fun tickIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
            context,
            1,
            Intent(context, Tick::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        private fun scheduleTick(context: Context) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val at = SystemClock.elapsedRealtime() + TICK_MS
            // Inexact is fine: Android may group it with other wake-ups to save battery,
            // and spaces it out more in deep sleep. New changes do not wait for it.
            am.setAndAllowWhileIdle(AlarmManager.ELAPSED_REALTIME_WAKEUP, at, tickIntent(context))
        }

        private fun cancelTick(context: Context) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.cancel(tickIntent(context))
        }
    }
}
