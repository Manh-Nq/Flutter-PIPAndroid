package com.example.tub_app_overlays

import android.view.WindowManager
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.BasicMessageChannel


object WindowConfig {
    var height = WindowManager.LayoutParams.MATCH_PARENT
    var width = WindowManager.LayoutParams.MATCH_PARENT
    var x = 0
    var y = 0
    lateinit var messenger: BasicMessageChannel<Any?>
    var enableDrag = false
    var serviceIsRunning = false;

}
