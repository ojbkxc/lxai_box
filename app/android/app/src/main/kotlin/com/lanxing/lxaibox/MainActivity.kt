package com.lanxing.lxaibox

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * 应用主 Activity
 */
class MainActivity : FlutterActivity() {
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 注册 ADB API 方法通道
        AdbApi.register(this, flutterEngine.dartExecutor.binaryMessenger)
    }
}
