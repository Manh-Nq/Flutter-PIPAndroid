package com.example.tub_app_overlays

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


const val OVER_LAY_CHANNEL = "com.example.tub_app_overlays/overlayChannel"
const val FLAGS_CHANNEL = "com.example.tub_app_overlays/flag_channel"
const val MESSAGE_CHANNEL = "com.example.tub_app_overlays/overlay_messenger"
const val CACHE_TAG = "myCachedEngine"

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler,
    BasicMessageChannel.MessageHandler<Any?> {
    lateinit var overlayChannel: MethodChannel
    lateinit var messageChannel: BasicMessageChannel<Any?>
    lateinit var result: MethodChannel.Result
    val REQUEST_CODE_FOR_OVERLAY_PERMISSION = 1009

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        overlayChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVER_LAY_CHANNEL)
        messageChannel = BasicMessageChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MESSAGE_CHANNEL,
            JSONMessageCodec.INSTANCE
        )

        overlayChannel.setMethodCallHandler(this)
        messageChannel.setMessageHandler(this)

        WindowConfig.messenger = messageChannel
        WindowConfig.messenger.setMessageHandler(this)

    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val enn = FlutterEngineGroup(context)
        val dEntry = DartEntrypoint(
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            "showPIPScreen"
        )
        val engine = enn.createAndRunEngine(context, dEntry)
        FlutterEngineCache.getInstance().put(CACHE_TAG, engine)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        this.result = result
        when (call.method) {
            "show" -> {
                if (WindowConfig.serviceIsRunning) {
                    result.success(null)
                    return
                } else {
                    Log.d("ManhNQ", "onMethodCall: showFunction")
                    if (!checkValidPermission()) {
                        result.error("PERMISSION", "overlay permission is not enabled", null)
                        return
                    }

                    val height = call.argument("height") as Int? ?: -1
                    val width = call.argument("width") as Int? ?: -1
                    val alignment = call.argument("alignment") as String? ?: ""
                    val flag = call.argument("flag") as String? ?: "flagNotFocusable"
                    val overlayTitle = call.argument("overlayTitle") as String? ?: ""
                    val overlayContent = call.argument("overlayContent") as String? ?: ""
                    val notificationVisibility =
                        call.argument("notificationVisibility") as String? ?: "visibilityPrivate"
                    val enableDrag = call.argument("enableDrag") as Boolean? ?: false
                    val positionGravity = call.argument("positionGravity") as String? ?: ""

                    WindowConfig.width = width
                    WindowConfig.height = height
                    WindowConfig.enableDrag = enableDrag

                    WindowConfig.setGravityFromAlignment(alignment)
                    WindowConfig.setFlag(flag)
                    WindowConfig.overlayTitle = overlayTitle
                    WindowConfig.overlayContent = overlayContent
                    WindowConfig.positionGravity = positionGravity
                    WindowConfig.setNotificationVisibility(notificationVisibility)

                    val intent = Intent(context, OverlayService::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.O)
                        startForegroundService(intent)
                    else
                        startService(intent)

                    result.success(null)
                }

            }
            "close" -> {
                Log.d("ManhNQ", "onMethodCall: close")
                if (WindowConfig.serviceIsRunning) {
                    Log.d("ManhNQ", "close: ${WindowConfig.serviceIsRunning}")

                    val i = Intent(context, OverlayService::class.java)
                    i.putExtra(INTENT_EXTRA_IS_CLOSE_WINDOW, true)
                    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.O)
                        startForegroundService(i)
                    else
                        startService(i)
                    result.success(true)
                }
                return
            }
            "putArguments" -> {
                Log.d("ManhNQ", "onMethodCall: putArguments")
            }
            "requestP" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                    intent.data = Uri.parse("package:$packageName")
                    startActivityForResult(intent, REQUEST_CODE_FOR_OVERLAY_PERMISSION)
                } else {
                    result.success(true)
                }
            }
            "isActive"->{
               result.success(WindowConfig.serviceIsRunning)
            }
        }
    }


    private fun checkValidPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            Settings.canDrawOverlays(context)
        else true
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_FOR_OVERLAY_PERMISSION) {
            if (requestCode == RESULT_OK) {
                result.success(true)
            } else {
                result.success(false)
            }
        }
    }

    override fun onMessage(message: Any?, reply: BasicMessageChannel.Reply<Any?>) {
        Log.d("ManhNQ", "onMessage UI NATIVE: ${message.toString()}")
        val engine = FlutterEngineCache.getInstance()[CACHE_TAG]
        if (engine != null) {
            val overlayMessageChannel: BasicMessageChannel<Any> = BasicMessageChannel(
                engine.dartExecutor.binaryMessenger,
                MESSAGE_CHANNEL, JSONMessageCodec.INSTANCE
            )
            overlayMessageChannel.send(message, reply);
        }

    }
}
