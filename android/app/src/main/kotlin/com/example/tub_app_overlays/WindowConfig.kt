package com.example.tub_app_overlays

import android.view.WindowManager
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.BasicMessageChannel


object WindowConfig {
    var height = WindowManager.LayoutParams.MATCH_PARENT
    var width = WindowManager.LayoutParams.MATCH_PARENT
    lateinit var messenger: BasicMessageChannel<Any?>
    var overlayTitle = "Overlay is activated"
    var overlayContent = "Tap to edit settings or disable"
    var notificationVisibility = NotificationCompat.VISIBILITY_PRIVATE
    var enableDrag = false
    var serviceIsRunning = false;

    fun setNotificationVisibility(name: String) {
        if (name.equals("visibilityPublic", ignoreCase = true)) {
            notificationVisibility = NotificationCompat.VISIBILITY_PUBLIC
        }
        if (name.equals("visibilitySecret", ignoreCase = true)) {
            notificationVisibility = NotificationCompat.VISIBILITY_SECRET
        }
        if (name.equals("visibilityPrivate", ignoreCase = true)) {
            notificationVisibility = NotificationCompat.VISIBILITY_PRIVATE
        }
    }
}
