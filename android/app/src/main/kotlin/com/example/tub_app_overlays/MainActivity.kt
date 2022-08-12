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
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


const val OVER_LAY_CHANNEL = "com.example.tub_app_overlays/overlayChannel"
const val MESSAGE_CHANNEL = "com.example.tub_app_overlays/overlay_messenger"
const val CACHE_TAG = "myCachedEngine"
const val REQUEST_CODE_FOR_OVERLAY_PERMISSION = 1009

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler,
    BasicMessageChannel.MessageHandler<Any?> {
    lateinit var overlayChannel: MethodChannel
    lateinit var messageChannel: BasicMessageChannel<Any?>
    lateinit var result: MethodChannel.Result

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
        GeneratedPluginRegistrant.registerWith(engine)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        Log.d("ManhNQ", "onMethodCall: ")

        this.result = result
        when (call.method) {
            "show" -> {
                if (WindowConfig.serviceIsRunning) {
                    result.success(false)
                    Log.d("ManhNQ", "showOverlays: return ${WindowConfig.serviceIsRunning}")
                    return
                } else {
                    Log.d("ManhNQ", "onMethodCall: showFunction")
                    if (!checkValidPermission()) {
                        result.error("PERMISSION", "overlay permission is not enabled", null)
                        return
                    }

                    val height = call.argument("height") as Int? ?: -1
                    val width = call.argument("width") as Int? ?: -1
                    val x = call.argument("x") as Int? ?: 0
                    val y = call.argument("y") as Int? ?: 0

                    //config arguments
                    WindowConfig.width = width
                    WindowConfig.height = height
                    WindowConfig.x = x
                    WindowConfig.y = y

                    val intent = Intent(context, OverlayService::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.O)
                        startForegroundService(intent)
                    else
                        startService(intent)

                    result.success(true)
                }

            }
            "requestPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                    intent.data = Uri.parse("package:$packageName")
                    startActivityForResult(intent, REQUEST_CODE_FOR_OVERLAY_PERMISSION)
                } else {
                    result.success(true)
                }
            }

            "isActive" -> {
                result.success(WindowConfig.serviceIsRunning)
            }

            "isPermissionGranted" -> {
                result.success(checkOverlayPermission())
            }
        }
    }


    private fun checkValidPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            Settings.canDrawOverlays(context)
        else true
    }

    private fun checkOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else true
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
            if (message == "close") {
                dismissOverlays()
            }
            overlayMessageChannel.send(message, reply);
        }
    }

    private fun dismissOverlays() {
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
    }

    override fun onResume() {
        super.onResume()
        Log.d("ManhNQ", "[NATIVE] onResume: ")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("ManhNQ", "[NATIVE] onDestroy: ")
//        WindowConfig.messenger.send("app killed")
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        Log.d("ManhNQ", "[NATIVE] onDetachedFromWindow: ")
    }

}
