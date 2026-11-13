package com.pravinelectricals.shop_app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

// FlutterFragmentActivity is needed so the phone's screen-lock prompt
// (local_auth) can be shown, used to recover a forgotten owner PIN.
class MainActivity : FlutterFragmentActivity() {
    // The screen uses the app's one engine, which keeps running after the app is
    // closed so Wi-Fi sync goes on (A12, see ShopEngine).
    override fun onCreate(savedInstanceState: Bundle?) {
        ShopEngine.ensure(this)
        super.onCreate(savedInstanceState)
    }

    override fun getCachedEngineId(): String = ShopEngine.ID

    override fun shouldDestroyEngineWithHost(): Boolean = false

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
                            val mime = call.argument<String>("mime") ?: "application/pdf"
                            result.success(sendToWhatsApp(bytes, filename, number, text, mime))
                        }
                        "whatsAppText" -> {
                            result.success(
                                whatsAppText(call.argument<String>("number")!!, call.argument<String>("text")!!),
                            )
                        }
                        "saveToDownloads" -> {
                            result.success(
                                saveToDownloads(
                                    call.argument<ByteArray>("bytes")!!,
                                    call.argument<String>("filename")!!,
                                    call.argument<String>("mime")!!,
                                ),
                            )
                        }
                        "openDownload" -> {
                            openDownload(call.argument<String>("uri")!!, call.argument<String>("mime")!!)
                            result.success(null)
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
    private fun sendToWhatsApp(bytes: ByteArray, filename: String, number: String, text: String?, mime: String): Boolean {
        val dir = File(cacheDir, "shared_bills").apply { mkdirs() }
        val cutoff = System.currentTimeMillis() - 24L * 60 * 60 * 1000
        dir.listFiles()?.filter { it.lastModified() < cutoff }?.forEach { it.delete() }

        val safeName = filename.replace(Regex("[^A-Za-z0-9._-]"), "_")
        val file = File(dir, safeName)
        file.writeBytes(bytes)
        val uri = FileProvider.getUriForFile(this, "$packageName.shareprovider", file)

        for (pkg in listOf("com.whatsapp", "com.whatsapp.w4b")) {
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = mime
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
     * Opens WhatsApp (or WhatsApp Business) on the chat with [number] with
     * [text] typed in, ready to send (A11 payment reminders). The person still
     * presses Send. Returns false when WhatsApp is not installed.
     */
    private fun whatsAppText(number: String, text: String): Boolean {
        val uri = android.net.Uri.parse("https://api.whatsapp.com/send?phone=$number&text=" + android.net.Uri.encode(text))
        for (pkg in listOf("com.whatsapp", "com.whatsapp.w4b")) {
            try {
                startActivity(Intent(Intent.ACTION_VIEW, uri).setPackage(pkg))
                return true
            } catch (e: ActivityNotFoundException) {
                // Try the next WhatsApp variant.
            }
        }
        return false
    }

    /**
     * Saves a file into the phone's Downloads folder (A13), where Files and
     * other apps can see it. Android 10 and later need no permission for this.
     * Returns the saved file's address, or null on older Android (the app then
     * shares the file instead).
     */
    private fun saveToDownloads(bytes: ByteArray, filename: String, mime: String): String? {
        if (android.os.Build.VERSION.SDK_INT < 29) return null
        val safeName = filename.replace(Regex("[^A-Za-z0-9._ -]"), "_")
        val values = android.content.ContentValues().apply {
            put(android.provider.MediaStore.Downloads.DISPLAY_NAME, safeName)
            put(android.provider.MediaStore.Downloads.MIME_TYPE, mime)
            put(android.provider.MediaStore.Downloads.IS_PENDING, 1)
        }
        val resolver = contentResolver
        val uri = resolver.insert(android.provider.MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("Could not create the file in Downloads")
        try {
            resolver.openOutputStream(uri).use { out ->
                requireNotNull(out) { "Could not write the file" }.write(bytes)
            }
            values.clear()
            values.put(android.provider.MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }
        return uri.toString()
    }

    /** Opens a file saved by [saveToDownloads] in a viewer app. */
    private fun openDownload(uri: String, mime: String) {
        val view = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(android.net.Uri.parse(uri), mime)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(view, null).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
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
