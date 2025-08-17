package com.example.esc_one

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.KeyEvent
import android.view.WindowManager
import android.os.Build
import android.view.View
import android.view.WindowInsetsController
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.esc_one/detox"
    private var isDetoxActive = false
    private val LOCK_TASK_REQUEST_CODE = 123

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Prevent screenshots and screen recording
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        
        // Make app always on top
        window.setFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Detox channel for controlling kiosk mode
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setDetoxActive" -> {
                    isDetoxActive = call.arguments as Boolean
                    if (isDetoxActive) {
                        enableKioskMode()
                    } else {
                        disableKioskMode()
                    }
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun enableKioskMode() {
        // Hide system UI
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.apply {
                hide(android.view.WindowInsets.Type.statusBars() or 
                     android.view.WindowInsets.Type.navigationBars())
                systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_FULLSCREEN)
        }
        
        // Try to start lock task mode
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            if (activityManager.isInLockTaskMode) {
                return
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                startLockTask()
            }
        } catch (e: Exception) {
            // Fallback if lock task fails
            try {
                val intent = Intent(this, MainActivity::class.java)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                startActivity(intent)
            } catch (e: Exception) {
                // Ignore if this fails too
            }
        }
    }
    
    private fun disableKioskMode() {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            if (activityManager.isInLockTaskMode) {
                stopLockTask()
            }
        } catch (e: Exception) {
            // Ignore exceptions
        }
        
        // Show system UI
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.apply {
                show(android.view.WindowInsets.Type.statusBars() or 
                     android.view.WindowInsets.Type.navigationBars())
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
        }
    }
    
    // Block hardware buttons during detox
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        // Allow call-related buttons even during detox
        if (keyCode == KeyEvent.KEYCODE_CALL || keyCode == KeyEvent.KEYCODE_ENDCALL) {
            return super.onKeyDown(keyCode, event)
        }
        
        return if (isDetoxActive && (
                keyCode == KeyEvent.KEYCODE_BACK || 
                keyCode == KeyEvent.KEYCODE_HOME || 
                keyCode == KeyEvent.KEYCODE_APP_SWITCH || 
                keyCode == KeyEvent.KEYCODE_MENU ||
                keyCode == KeyEvent.KEYCODE_POWER ||
                keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
                keyCode == KeyEvent.KEYCODE_VOLUME_DOWN
            )) {
            true // Consume the event
        } else {
            super.onKeyDown(keyCode, event)
        }
    }
    
    // Block hardware buttons during detox (alternative method)
    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        // Allow call-related buttons even during detox
        if (keyCode == KeyEvent.KEYCODE_CALL || keyCode == KeyEvent.KEYCODE_ENDCALL) {
            return super.onKeyUp(keyCode, event)
        }
        
        return if (isDetoxActive && (
                keyCode == KeyEvent.KEYCODE_BACK || 
                keyCode == KeyEvent.KEYCODE_HOME || 
                keyCode == KeyEvent.KEYCODE_APP_SWITCH || 
                keyCode == KeyEvent.KEYCODE_MENU ||
                keyCode == KeyEvent.KEYCODE_POWER ||
                keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
                keyCode == KeyEvent.KEYCODE_VOLUME_DOWN
            )) {
            true // Consume the event
        } else {
            super.onKeyUp(keyCode, event)
        }
    }
    
    // Prevent task switching
    override fun onPause() {
        super.onPause()
        if (isDetoxActive) {
            val intent = Intent(this, MainActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            startActivity(intent)
        }
    }
    
    // Prevent task switching
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (isDetoxActive) {
            val intent = Intent(this, MainActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            startActivity(intent)
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // No listener to clean up
    }
}
