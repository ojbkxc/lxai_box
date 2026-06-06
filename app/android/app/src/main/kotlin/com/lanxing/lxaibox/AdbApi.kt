package com.lanxing.lxaibox

import android.content.Context
import android.os.IBinder
import android.os.Parcel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import rikka.shizuku.Shizuku
import java.io.BufferedReader
import java.io.InputStreamReader

/**
 * ADB API 实现
 * 通过 Shizuku 执行 Shell 命令
 */
class AdbApi(private val context: Context) {
    
    companion object {
        private const val TAG = "AdbApi"
        
        /**
         * 注册 Flutter 方法通道
         */
        fun register(context: Context, messenger: BinaryMessenger): AdbApi {
            val api = AdbApi(context)
            val channel = MethodChannel(messenger, "com.lanxing.lxaibox/adb")
            
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "executeCommand" -> {
                        val command = call.argument<String>("command")
                        if (command != null) {
                            api.executeCommand(command) { output, error ->
                                if (error != null) {
                                    result.error("ADB_ERROR", error, null)
                                } else {
                                    result.success(output)
                                }
                            }
                        } else {
                            result.error("INVALID_ARGS", "Command is required", null)
                        }
                    }
                    "executeShellCommand" -> {
                        val command = call.argument<String>("command")
                        val timeoutMs = call.argument<Int>("timeoutMs") ?: 30000
                        if (command != null) {
                            api.executeShellCommand(command, timeoutMs) { output, error ->
                                if (error != null) {
                                    result.error("ADB_ERROR", error, null)
                                } else {
                                    result.success(output)
                                }
                            }
                        } else {
                            result.error("INVALID_ARGS", "Command is required", null)
                        }
                    }
                    "isShizukuAvailable" -> {
                        result.success(api.isShizukuAvailable())
                    }
                    "hasPermission" -> {
                        result.success(api.hasPermission())
                    }
                    "requestPermission" -> {
                        api.requestPermission { granted ->
                            result.success(granted)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
            
            return api
        }
    }
    
    /**
     * 检查 Shizuku 是否可用
     */
    fun isShizukuAvailable(): Boolean {
        return try {
            Shizuku.pingBinder()
        } catch (e: Exception) {
            false
        }
    }
    
    /**
     * 检查是否已获得权限
     */
    fun hasPermission(): Boolean {
        return try {
            Shizuku.checkSelfPermission() == 0
        } catch (e: Exception) {
            false
        }
    }
    
    /**
     * 请求权限
     */
    fun requestPermission(callback: (Boolean) -> Unit) {
        try {
            if (hasPermission()) {
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
    
    /**
     * 执行 ADB 命令（通过 Shizuku 的 newProcess）
     */
    fun executeCommand(command: String, callback: (String?, String?) -> Unit) {
        if (!isShizukuAvailable()) {
            callback(null, "Shizuku 不可用，请检查 Shizuku 服务是否运行")
            return
        }
        
        if (!hasPermission()) {
            callback(null, "未获得 Shizuku 权限，请授权后重试")
            return
        }
        
        try {
            val process = Shizuku.newProcess(arrayOf("sh", "-c", command), null, null)
            val output = BufferedReader(InputStreamReader(process.inputStream)).use { it.readText() }
            val error = BufferedReader(InputStreamReader(process.errorStream)).use { it.readText() }
            val exitCode = process.waitFor()
            
            if (exitCode == 0) {
                callback(output.trim(), null)
            } else {
                callback(output.trim(), error.trim().ifEmpty { "命令执行失败，退出码: $exitCode" })
            }
        } catch (e: Exception) {
            callback(null, "执行命令异常: ${e.message}")
        }
    }
    
    /**
     * 执行带超时的 Shell 命令
     */
    fun executeShellCommand(command: String, timeoutMs: Int, callback: (String?, String?) -> Unit) {
        if (!isShizukuAvailable()) {
            callback(null, "Shizuku 不可用，请检查 Shizuku 服务是否运行")
            return
        }
        
        if (!hasPermission()) {
            callback(null, "未获得 Shizuku 权限，请授权后重试")
            return
        }
        
        try {
            val process = Shizuku.newProcess(arrayOf("sh", "-c", command), null, null)
            
            // 等待命令完成或超时
            val completed = process.waitFor()
            
            val output = BufferedReader(InputStreamReader(process.inputStream)).use { it.readText() }
            val error = BufferedReader(InputStreamReader(process.errorStream)).use { it.readText() }
            
            if (completed == 0) {
                callback(output.trim(), null)
            } else {
                callback(output.trim(), error.trim().ifEmpty { "命令执行失败，退出码: $completed" })
            }
        } catch (e: Exception) {
            callback(null, "执行命令异常: ${e.message}")
        }
    }
    
    /**
     * 获取设备信息
     */
    fun getDeviceInfo(): Map<String, String> {
        val info = mutableMapOf<String, String>()
        
        try {
            val process = Shizuku.newProcess(arrayOf("sh", "-c", "getprop ro.product.model"), null, null)
            info["model"] = BufferedReader(InputStreamReader(process.inputStream)).use { it.readText().trim() }
            process.waitFor()
            
            val process2 = Shizuku.newProcess(arrayOf("sh", "-c", "getprop ro.build.version.release"), null, null)
            info["androidVersion"] = BufferedReader(InputStreamReader(process2.inputStream)).use { it.readText().trim() }
            process2.waitFor()
            
            val process3 = Shizuku.newProcess(arrayOf("sh", "-c", "getprop ro.build.version.sdk"), null, null)
            info["sdkVersion"] = BufferedReader(InputStreamReader(process3.inputStream)).use { it.readText().trim() }
            process3.waitFor()
        } catch (e: Exception) {
            // 忽略错误，返回空信息
        }
        
        return info
    }
}
