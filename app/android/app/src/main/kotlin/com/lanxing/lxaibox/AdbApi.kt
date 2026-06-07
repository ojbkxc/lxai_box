package com.lanxing.lxaibox

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import rikka.shizuku.Shizuku
import java.io.BufferedReader
import java.io.InputStreamReader

/**
 * ADB 原生 API
 * 通过 Shizuku 执行 Shell 命令，注册到 Flutter MethodChannel
 */
class AdbApi(private val context: Context) {

    companion object {
        /**
         * 注册所有 Flutter 方法通道
         */
        fun register(context: Context, messenger: BinaryMessenger) {
            val api = AdbApi(context)
            api._registerAdbChannel(messenger)
            api._registerAppChannel(messenger)
            api._registerScreenChannel(messenger)
        }
    }

    // ========== ADB Native API ==========

    private fun _registerAdbChannel(messenger: BinaryMessenger) {
        val channel = MethodChannel(messenger, "dev.flutter.pigeon.AdbNativeApi.isShizukuAvailable")
        channel.setMethodCallHandler { _, result ->
            result.success(isShizukuAvailable())
        }

        val channel2 = MethodChannel(messenger, "dev.flutter.pigeon.AdbNativeApi.requestShizukuPermission")
        channel2.setMethodCallHandler { _, result ->
            requestPermission { granted -> result.success(granted) }
        }

        val channel3 = MethodChannel(messenger, "dev.flutter.pigeon.AdbNativeApi.executeCommand")
        channel3.setMethodCallHandler { call, result ->
            val command = call.argument<String>("command") ?: call.arguments?.toString() ?: ""
            executeShell(command) { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel4 = MethodChannel(messenger, "dev.flutter.pigeon.AdbNativeApi.executeShellCommand")
        channel4.setMethodCallHandler { call, result ->
            val command = call.argument<String>("command") ?: call.arguments?.toString() ?: ""
            executeShell(command) { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel5 = MethodChannel(messenger, "dev.flutter.pigeon.AdbNativeApi.getConnectedDevices")
        channel5.setMethodCallHandler { _, result ->
            result.success(getConnectedDevices())
        }

        val channel6 = MethodChannel(messenger, "dev.flutter.pigeon.AdbNativeApi.getCurrentDevice")
        channel6.setMethodCallHandler { _, result ->
            result.success(getCurrentDevice())
        }

        val channel7 = MethodChannel(messenger, "dev.flutter.pigeon.AdbNativeApi.connectDevice")
        channel7.setMethodCallHandler { call, result ->
            val deviceId = call.argument<String>("deviceId") ?: call.arguments?.toString() ?: ""
            executeShell("connect $deviceId") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel8 = MethodChannel(messenger, "dev.flutter.pigeon.AdbNativeApi.disconnectDevice")
        channel8.setMethodCallHandler { call, result ->
            val deviceId = call.argument<String>("deviceId") ?: call.arguments?.toString() ?: ""
            executeShell("disconnect $deviceId") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }
    }

    // ========== App Manager API ==========

    private fun _registerAppChannel(messenger: BinaryMessenger) {
        val channel1 = MethodChannel(messenger, "dev.flutter.pigeon.AppManagerApi.getInstalledApps")
        channel1.setMethodCallHandler { _, result ->
            result.success(getInstalledApps())
        }

        val channel2 = MethodChannel(messenger, "dev.flutter.pigeon.AppManagerApi.installApp")
        channel2.setMethodCallHandler { call, result ->
            val path = call.arguments?.toString() ?: ""
            executeShell("pm install $path") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel3 = MethodChannel(messenger, "dev.flutter.pigeon.AppManagerApi.uninstallApp")
        channel3.setMethodCallHandler { call, result ->
            val pkg = call.arguments?.toString() ?: ""
            executeShell("pm uninstall $pkg") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel4 = MethodChannel(messenger, "dev.flutter.pigeon.AppManagerApi.launchApp")
        channel4.setMethodCallHandler { call, result ->
            val pkg = call.arguments?.toString() ?: ""
            executeShell("monkey -p $pkg -c android.intent.category.LAUNCHER 1") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel5 = MethodChannel(messenger, "dev.flutter.pigeon.AppManagerApi.stopApp")
        channel5.setMethodCallHandler { call, result ->
            val pkg = call.arguments?.toString() ?: ""
            executeShell("am force-stop $pkg") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel6 = MethodChannel(messenger, "dev.flutter.pigeon.AppManagerApi.clearAppData")
        channel6.setMethodCallHandler { call, result ->
            val pkg = call.arguments?.toString() ?: ""
            executeShell("pm clear $pkg") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel7 = MethodChannel(messenger, "dev.flutter.pigeon.AppManagerApi.isAppInstalled")
        channel7.setMethodCallHandler { call, result ->
            val pkg = call.arguments?.toString() ?: ""
            executeShell("pm list packages $pkg") { output, _ ->
                result.success(output?.contains("package:$pkg") == true)
            }
        }
    }

    // ========== Screen API ==========

    private fun _registerScreenChannel(messenger: BinaryMessenger) {
        val channel1 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.takeScreenshot")
        channel1.setMethodCallHandler { call, result ->
            val path = call.arguments?.toString() ?: "/sdcard/screenshot.png"
            executeShell("screencap -p $path") { _, _ -> result.success(path) }
        }

        val channel2 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.startScreenRecording")
        channel2.setMethodCallHandler { call, result ->
            val args = call.arguments as? List<*> ?: emptyList<Any>()
            val path = args.getOrElse(0) { "/sdcard/video.mp4" }.toString()
            val duration = (args.getOrElse(1) { 30 } as? Int) ?: 30
            executeShell("screenrecord --time-limit $duration $path") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel3 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.stopScreenRecording")
        channel3.setMethodCallHandler { _, result ->
            executeShell("pkill -INT screenrecord") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel4 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.getScreenResolution")
        channel4.setMethodCallHandler { _, result ->
            executeShell("wm size") { output, _ -> result.success(output ?: "") }
        }

        val channel5 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.getScreenDensity")
        channel5.setMethodCallHandler { _, result ->
            executeShell("wm density") { output, _ -> result.success(output ?: "") }
        }

        val channel6 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.tapScreen")
        channel6.setMethodCallHandler { call, result ->
            val args = call.arguments as? List<*> ?: emptyList<Any>()
            val x = (args.getOrElse(0) { 0 } as? Int) ?: 0
            val y = (args.getOrElse(1) { 0 } as? Int) ?: 0
            executeShell("input tap $x $y") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel7 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.swipeScreen")
        channel7.setMethodCallHandler { call, result ->
            val args = call.arguments as? List<*> ?: emptyList<Any>()
            val x1 = (args.getOrElse(0) { 0 } as? Int) ?: 0
            val y1 = (args.getOrElse(1) { 0 } as? Int) ?: 0
            val x2 = (args.getOrElse(2) { 0 } as? Int) ?: 0
            val y2 = (args.getOrElse(3) { 0 } as? Int) ?: 0
            val dur = (args.getOrElse(4) { 300 } as? Int) ?: 300
            executeShell("input swipe $x1 $y1 $x2 $y2 $dur") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel8 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.inputText")
        channel8.setMethodCallHandler { call, result ->
            val text = call.arguments?.toString() ?: ""
            executeShell("input text '$text'") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }

        val channel9 = MethodChannel(messenger, "dev.flutter.pigeon.ScreenApi.pressKey")
        channel9.setMethodCallHandler { call, result ->
            val keyCode = (call.arguments as? Int) ?: 0
            executeShell("input keyevent $keyCode") { output, error ->
                if (error != null) result.success(listOf(false, "", null, error))
                else result.success(listOf(true, output ?: "", null, null))
            }
        }
    }

    // ========== 核心方法 ==========

    private fun isShizukuAvailable(): Boolean {
        return try {
            Shizuku.pingBinder()
        } catch (e: Exception) {
            false
        }
    }

    private fun requestPermission(callback: (Boolean) -> Unit) {
        try {
            if (Shizuku.checkSelfPermission() == 0) {
                callback(true)
                return
            }
            Shizuku.addRequestPermissionResultListener(object : Shizuku.OnRequestPermissionResultListener {
                override fun onRequestPermissionResult(requestCode: Int, grantResult: Int) {
                    Shizuku.removeRequestPermissionResultListener(this)
                    callback(grantResult == 0)
                }
            })
            Shizuku.requestPermission(0)
        } catch (e: Exception) {
            callback(false)
        }
    }

    private fun executeShell(command: String, callback: (String?, String?) -> Unit) {
        if (!isShizukuAvailable()) {
            callback(null, "Shizuku 不可用")
            return
        }
        try {
            val process = Shizuku.newProcess(arrayOf("sh", "-c", command), null, null)
            val output = BufferedReader(InputStreamReader(process.inputStream)).use { it.readText() }
            val error = BufferedReader(InputStreamReader(process.errorStream)).use { it.readText() }
            val exitCode = process.waitFor()
            if (exitCode == 0) callback(output.trim(), null)
            else callback(null, error.ifEmpty { "Exit code: $exitCode" })
        } catch (e: Exception) {
            callback(null, e.message ?: "Unknown error")
        }
    }

    private fun getConnectedDevices(): List<List<Any>> {
        return try {
            val model = exec("getprop ro.product.model")
            val sdk = exec("getprop ro.build.version.sdk")
            val ver = exec("getprop ro.build.version.release")
            listOf(listOf("local", model, ver, sdk.toIntOrNull() ?: 0, true))
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun getCurrentDevice(): List<Any>? {
        return getConnectedDevices().firstOrNull()
    }

    private fun getInstalledApps(): List<List<Any>> {
        return try {
            val output = exec("pm list packages -3")
            output.lines()
                .filter { it.startsWith("package:") }
                .map { line ->
                    val pkg = line.removePrefix("package:").trim()
                    listOf(pkg, pkg, "", 0, false, true)
                }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun exec(command: String): String {
        return try {
            val process = Shizuku.newProcess(arrayOf("sh", "-c", command), null, null)
            val output = BufferedReader(InputStreamReader(process.inputStream)).use { it.readText() }
            process.waitFor()
            output.trim()
        } catch (e: Exception) {
            ""
        }
    }
}
