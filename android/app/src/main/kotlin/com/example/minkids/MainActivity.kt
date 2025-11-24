package com.example.minkids

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.minkids/app_blocker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestAccessibilityPermission" -> {
                    requestAccessibilityPermission()
                    result.success(null)
                }
                "isAccessibilityServiceEnabled" -> {
                    val isEnabled = isAccessibilityServiceEnabled(this)
                    result.success(isEnabled)
                }
                "updateBlockedApps" -> {
                    val blockedApps = call.argument<Map<String, String>>("blockedApps")
                    if (blockedApps != null) {
                        AppBlockerService.updateBlockedApps(this, blockedApps)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "blockedApps is null", null)
                    }
                }
                "clearBlockedApps" -> {
                    AppBlockerService.clearBlockedApps(this)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestAccessibilityPermission() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val service = "${context.packageName}/${AppBlockerService::class.java.canonicalName}"
        var accessibilityEnabled = 0
        
        try {
            accessibilityEnabled = Settings.Secure.getInt(
                context.contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED
            )
        } catch (e: Settings.SettingNotFoundException) {
            e.printStackTrace()
        }

        if (accessibilityEnabled == 1) {
            val settingValue = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            
            if (!settingValue.isNullOrEmpty()) {
                return settingValue.split(":").any { it.equals(service, ignoreCase = true) }
            }
        }

        return false
    }
}
