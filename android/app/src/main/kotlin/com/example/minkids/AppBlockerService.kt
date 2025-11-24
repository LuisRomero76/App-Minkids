package com.example.minkids

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast
import android.os.Handler
import android.os.Looper

class AppBlockerService : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())
    private var lastCheckedPackage = ""
    private var lastCheckTime = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.packageName == null) return

        // Solo procesar eventos de cambio de ventana
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName.toString()
        
        // Evitar procesar el mismo paquete múltiples veces en poco tiempo
        val currentTime = System.currentTimeMillis()
        if (packageName == lastCheckedPackage && currentTime - lastCheckTime < 2000) {
            return
        }
        
        lastCheckedPackage = packageName
        lastCheckTime = currentTime

        // No bloquear MinKids ni el launcher del sistema
        if (packageName == "com.example.minkids" || 
            packageName.contains("launcher") ||
            packageName.contains("systemui")) {
            return
        }

        // Verificar si la app está bloqueada
        val prefs = getSharedPreferences("minkids_limits", Context.MODE_PRIVATE)
        val blockedApps = prefs.getStringSet("blocked_apps", setOf()) ?: setOf()
        
        if (blockedApps.contains(packageName)) {
            // Obtener el nombre de la app
            val appName = prefs.getString("app_name_$packageName", "esta aplicación") ?: "esta aplicación"
            
            // Bloquear: volver al home
            performGlobalAction(GLOBAL_ACTION_HOME)
            
            // Mostrar mensaje
            handler.post {
                Toast.makeText(
                    this,
                    "⏰ $appName está bloqueada. Has alcanzado tu límite diario.",
                    Toast.LENGTH_LONG
                ).show()
            }
            
            // Opcional: Abrir MinKids para mostrar la pantalla de bloqueo
            handler.postDelayed({
                val intent = packageManager.getLaunchIntentForPackage("com.example.minkids")
                intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                intent?.putExtra("show_blocked_message", true)
                intent?.putExtra("blocked_app", appName)
                try {
                    startActivity(intent)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }, 500)
        }
    }

    override fun onInterrupt() {
        // No hacer nada
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Toast.makeText(this, "✅ Control parental activado", Toast.LENGTH_SHORT).show()
    }

    companion object {
        /**
         * Actualiza la lista de apps bloqueadas desde Flutter
         */
        fun updateBlockedApps(context: Context, blockedAppsMap: Map<String, String>) {
            val prefs = context.getSharedPreferences("minkids_limits", Context.MODE_PRIVATE)
            val editor = prefs.edit()
            
            // Guardar lista de package names bloqueados
            editor.putStringSet("blocked_apps", blockedAppsMap.keys)
            
            // Guardar nombres de apps para mostrar en mensajes
            blockedAppsMap.forEach { (packageName, appName) ->
                editor.putString("app_name_$packageName", appName)
            }
            
            editor.apply()
        }

        /**
         * Limpia la lista de apps bloqueadas
         */
        fun clearBlockedApps(context: Context) {
            val prefs = context.getSharedPreferences("minkids_limits", Context.MODE_PRIVATE)
            prefs.edit().clear().apply()
        }
    }
}
