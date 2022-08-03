package com.example.tub_app_overlays

import android.R
import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Point
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


const val INTENT_EXTRA_IS_CLOSE_WINDOW = "IsCloseWindow"
const val CHANNEL_ID = "Overlay Channel"
const val NOTIFICATION_ID = 4579

class OverlayService : Service(), View.OnTouchListener {

    private var windowManager: WindowManager? = null
    var flutterView: FlutterView? = null
    private val flutterChannel = MethodChannel(
        FlutterEngineCache.getInstance()[CACHE_TAG]!!.dartExecutor,
        FLAGS_CHANNEL
    )
    private val overlayMessageChannel = BasicMessageChannel(
        FlutterEngineCache.getInstance()[CACHE_TAG]!!.dartExecutor,
        MESSAGE_CHANNEL,
        JSONMessageCodec.INSTANCE
    )
    private val clickableFlag: Int =
        WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN

    private val mAnimationHandler: Handler = Handler()

    private var lastX = 0f
    private var lastY = 0f
    private var lastYPosition = 0
    private var dragging = false
    private val MAXIMUM_OPACITY_ALLOWED_FOR_S_AND_HIGHER = 0.8f
    private val szWindow: Point = Point()

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val isCloseWindow = intent?.getBooleanExtra(INTENT_EXTRA_IS_CLOSE_WINDOW, false)
        if (isCloseWindow != null && isCloseWindow) {
            if (windowManager != null) {
                windowManager?.removeView(flutterView)
                windowManager = null
                stopSelf()
            }
            WindowConfig.serviceIsRunning = false
            return START_STICKY
        }
        if (windowManager != null) {
            windowManager?.removeView(flutterView)
            windowManager = null
            stopSelf()
        }
        WindowConfig.serviceIsRunning = true
        val engine = FlutterEngineCache.getInstance()[CACHE_TAG]
        engine!!.lifecycleChannel.appIsResumed()
        flutterView = FlutterView(
            applicationContext, FlutterTextureView(
                applicationContext
            )
        )
        flutterView?.let { view ->
            view.attachToFlutterEngine(FlutterEngineCache.getInstance()[CACHE_TAG]!!)
            view.fitsSystemWindows = true
            view.isFocusable = true
            view.isFocusableInTouchMode = true
            view.setBackgroundColor(Color.TRANSPARENT)
            view.setOnTouchListener(this)
        }


        flutterChannel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result? ->
//            if (call.method == "updateFlag") {
//                val flag = call.argument<Any>("flag").toString()
//                updateOverlayFlag(result, flag)
//            } else if (call.method == "resizeOverlay") {
//                val width = call.argument<Int>("width")!!
//                val height = call.argument<Int>("height")!!
//                resizeOverlay(width, height, result)
//            }
        }
        overlayMessageChannel.setMessageHandler { message: Any?, reply: BasicMessageChannel.Reply<Any?>? ->
            Log.d("ManhNQ", "SERVICE -onStartCommand: ${message.toString()}")
            WindowConfig.messenger.send(message)
        }
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        val layoutType: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }
        windowManager?.defaultDisplay?.getSize(szWindow)
        val params = WindowManager.LayoutParams(
            WindowConfig.width,
            WindowConfig.height,
            layoutType,
            WindowConfig.flag or WindowManager.LayoutParams.FLAG_SECURE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && WindowConfig.flag === clickableFlag) {
            params.alpha = MAXIMUM_OPACITY_ALLOWED_FOR_S_AND_HIGHER
        }
        params.gravity = WindowConfig.gravity

        windowManager?.addView(flutterView, params)
        return START_STICKY
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0, notificationIntent, pendingFlags
        )
        val notifyIcon = getDrawableResourceId("mipmap", "launcher")
        val notification =
            NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle(WindowConfig.overlayTitle)
                .setContentText(WindowConfig.overlayContent)
                .setSmallIcon(if (notifyIcon == 0) R.drawable.arrow_up_float else notifyIcon)
                .setContentIntent(pendingIntent)
                .setVisibility(WindowConfig.notificationVisibility)
                .build()
        startForeground(NOTIFICATION_ID, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(
                NotificationManager::class.java
            )!!
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun getDrawableResourceId(resType: String, name: String): Int {
        return applicationContext.resources.getIdentifier(
            String.format("ic_%s", name),
            resType,
            applicationContext.packageName
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        WindowConfig.serviceIsRunning = false
        val notificationManager =
            applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)
    }


    override fun onTouch(v: View?, event: MotionEvent?): Boolean {
        if (windowManager != null && WindowConfig.enableDrag) {
            val params = flutterView?.layoutParams as WindowManager.LayoutParams

            when (event?.action) {
                MotionEvent.ACTION_DOWN -> {
//                    Log.d("ManhNQ", "onTouch: ACTION_DOWN")
                    dragging = false;
                    lastX = event.rawX;
                    lastY = event.rawY;
                }
                MotionEvent.ACTION_MOVE -> {
//                    Log.d("ManhNQ", "onTouch: ACTION_MOVE")
                    val dx = event.rawX - lastX
                    val dy = event.rawY - lastY
                    if (!dragging && dx * dx + dy * dy < 25) {
                        return false
                    }
                    lastX = event.rawX
                    lastY = event.rawY
                    val xx = params.x + dx.toInt()
                    val yy = params.y + dy.toInt()
                    params.x = xx
                    params.y = yy
                    windowManager?.updateViewLayout(flutterView, params)
                    dragging = true
                }
                MotionEvent.ACTION_UP -> {
//                    Log.d("ManhNQ", "onTouch: ACTION_UP")
                }
                MotionEvent.ACTION_CANCEL -> {
//                    Log.d("ManhNQ", "onTouch: ACTION_CANCEL")
                }
                else -> {
                    return false;
                }
            }
            return false;
        }
        return false;
    }

}