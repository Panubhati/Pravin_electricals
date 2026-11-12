package com.pravinelectricals.shop_app

import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

// FlutterFragmentActivity is needed so the phone's screen-lock prompt
// (local_auth) can be shown, used to recover a forgotten owner PIN.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "sendToWhatsApp" -> {
                            val bytes = call.argument<ByteArray>("bytes")!!
                            val filename = call.argument<String>("filename")!!
                            val number = call.argument<String>("number")!!
                            val text = call.argument<String>("text")
                            result.success(sendToWhatsApp(bytes, filename, number, text))
                        }
                        "shareFile" -> {
                            shareBackup(
                                call.argument<String>("path")!!,
                                call.argument<String>("subject"),
                                call.argument<String>("text"),
                            )
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("share_failed", e.message, null)
                }
            }
    }

    /**
     * Opens WhatsApp (or WhatsApp Business) on the chat with [number] with the
     * PDF attached. Returns false when neither app is installed. The temporary
     * PDF lives in the app cache and files older than a day are deleted here.
     */
    private fun sendToWhatsApp(bytes: ByteArray, filename: String, number: String, text: String?): Boolean {
        val dir = File(cacheDir, "shared_bills").apply { mkdirs() }
        val cutoff = System.currentTimeMillis() - 24L * 60 * 60 * 1000
        dir.listFiles()?.filter { it.lastModified() < cutoff }?.forEach { it.delete() }

        val safeName = filename.replace(Regex("[^A-Za-z0-9._-]"), "_")
        val file = File(dir, safeName)
        file.writeBytes(bytes)
        val uri = FileProvider.getUriForFile(this, "$packageName.shareprovider", file)

        for (pkg in listOf("com.whatsapp", "com.whatsapp.w4b")) {
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "application/pdf"
                setPackage(pkg)
                putExtra(Intent.EXTRA_STREAM, uri)
                if (!text.isNullOrEmpty()) putExtra(Intent.EXTRA_TEXT, text)
                // Opens the chat with this person instead of asking who to send to.
                putExtra("jid", "$number@s.whatsapp.net")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            try {
                startActivity(intent)
                return true
            } catch (e: ActivityNotFoundException) {
                // Try the next WhatsApp variant.
            }
        }
        return false
    }

    /**
     * Opens the share sheet (email, Drive, WhatsApp...) with a backup file from
     * the app's private backups folder. Anything outside that folder is refused,
     * so this channel can never be used to send other app files.
     */
    private fun shareBackup(path: String, subject: String?, text: String?) {
        val file = File(path).canonicalFile
        val allowed = File(filesDir, "backups").canonicalFile
        require(file.path.startsWith(allowed.path + File.separator) && file.isFile) {
            "Not a backup file"
        }
        val uri = FileProvider.getUriForFile(this, "$packageName.shareprovider", file)
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_STREAM, uri)
            if (!subject.isNullOrEmpty()) putExtra(Intent.EXTRA_SUBJECT, subject)
            if (!text.isNullOrEmpty()) putExtra(Intent.EXTRA_TEXT, text)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(send, "Send backup").addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }

    companion object {
        const val CHANNEL = "com.pravinelectricals.shop_app/share"
    }
}
