package com.example.robust_background_service

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class RobustBackgroundServicePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private var context: Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "robust_background_service")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "isIgnoringBatteryOptimizations") {
      result.success(isIgnoringBatteryOptimizations())
    } else if (call.method == "requestIgnoreBatteryOptimizations") {
      requestIgnoreBatteryOptimizations()
      result.success(null)
    } else if (call.method == "openOemAutostartSettings") {
      openOemAutostartSettings()
      result.success(null)
    } else if (call.method == "getManufacturer") {
      result.success(Build.MANUFACTURER)
    } else {
      result.notImplemented()
    }
  }

  private fun isIgnoringBatteryOptimizations(): Boolean {
    val pm = context?.getSystemService(Context.POWER_SERVICE) as? PowerManager
    return pm?.isIgnoringBatteryOptimizations(context?.packageName) ?: false
  }

  private fun requestIgnoreBatteryOptimizations() {
    if (isIgnoringBatteryOptimizations()) return
    try {
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
        intent.data = Uri.parse("package:${context?.packageName}")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context?.startActivity(intent)
    } catch (e: Exception) {
        try {
            val fallback = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
            fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context?.startActivity(fallback)
        } catch (ex: Exception) {}
    }
  }

  private fun openOemAutostartSettings() {
      val manufacturer = Build.MANUFACTURER.lowercase()
      val candidates = mutableListOf<Intent>()

      when {
          manufacturer.contains("honor") || manufacturer.contains("huawei") -> {
              candidates.add(componentIntent("com.hihonor.systemmanager", "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity"))
              candidates.add(componentIntent("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"))
              candidates.add(componentIntent("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"))
          }
          manufacturer.contains("xiaomi") || manufacturer.contains("redmi") || manufacturer.contains("poco") -> {
              candidates.add(componentIntent("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"))
          }
          manufacturer.contains("oppo") || manufacturer.contains("realme") -> {
              candidates.add(componentIntent("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"))
              candidates.add(componentIntent("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity"))
              candidates.add(componentIntent("com.oplus.safecenter", "com.oplus.safecenter.permission.startup.StartupAppListActivity"))
          }
          manufacturer.contains("vivo") || manufacturer.contains("iqoo") -> {
              candidates.add(componentIntent("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"))
              candidates.add(componentIntent("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"))
          }
          manufacturer.contains("samsung") -> {
              candidates.add(componentIntent("com.samsung.android.lool", "com.samsung.android.sm.battery.ui.BatteryActivity"))
              candidates.add(componentIntent("com.samsung.android.sm", "com.samsung.android.sm.ui.battery.BatteryActivity"))
          }
          manufacturer.contains("oneplus") || manufacturer.contains("nothing") -> {
              candidates.add(componentIntent("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"))
              candidates.add(componentIntent("com.oplus.safecenter", "com.oplus.safecenter.permission.startup.StartupAppListActivity"))
          }
          manufacturer.contains("tecno") || manufacturer.contains("infinix") || manufacturer.contains("itel") -> {
              candidates.add(componentIntent("com.transsion.phonemanager", "com.rlk.phonemanager.autostart.AutoStartActivity"))
              candidates.add(componentIntent("com.transsion.phonemaster", "com.rlk.phonemaster.autostart.AutoStartActivity"))
          }
          manufacturer.contains("asus") -> {
              candidates.add(componentIntent("com.asus.mobilemanager", "com.asus.mobilemanager.autostart.AutoStartActivity"))
          }
          manufacturer.contains("lenovo") -> {
              candidates.add(componentIntent("com.lenovo.security", "com.lenovo.security.purebackground.PureBackgroundActivity"))
          }
      }

      for (intent in candidates) {
          try {
              intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
              context?.startActivity(intent)
              return
          } catch (e: Exception) {
          } catch (t: Throwable) {
          }
      }
  }

  private fun componentIntent(pkg: String, cls: String): Intent {
      val intent = Intent()
      intent.component = ComponentName(pkg, cls)
      return intent
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
      // Not strictly necessary for startActivity with NEW_TASK, but good practice
  }

  override fun onDetachedFromActivityForConfigChanges() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivity() {}
}
