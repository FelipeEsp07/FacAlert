package com.example.facalert

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Registra automáticamente los plugins generados por Flutter
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
