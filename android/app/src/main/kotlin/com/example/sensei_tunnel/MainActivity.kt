package com.example.sensei_tunnel

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.VpnService
import android.os.Build
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mktunnel.vpn/service"
    private val VPN_REQUEST_CODE = 2048
    private var pendingVpnResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "prepareVpn" -> {
                    try {
                        val intent = VpnService.prepare(this)
                        if (intent != null) {
                            pendingVpnResult = result
                            startActivityForResult(intent, VPN_REQUEST_CODE)
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.success(true)
                    }
                }
                "startVpn" -> {
                    try {
                        val intent = Intent(this, MKVpnService::class.java).apply {
                            action = MKVpnService.ACTION_START
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.success(false)
                    }
                }
                "stopVpn" -> {
                    try {
                        val intent = Intent(this, MKVpnService::class.java).apply {
                            action = MKVpnService.ACTION_STOP
                        }
                        startService(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.success(false)
                    }
                }
                "isVpnRunning" -> {
                    result.success(MKVpnService.isRunning)
                }
                "getNetworkInfo" -> {
                    val info = getCarrierNetworkInfo(this)
                    result.success(info)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_REQUEST_CODE) {
            val success = (resultCode == Activity.RESULT_OK)
            pendingVpnResult?.success(success)
            pendingVpnResult = null
        }
    }

    private fun getCarrierNetworkInfo(context: Context): String {
        try {
            val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            var operator = tm?.simOperatorName?.trim()
            if (operator.isNullOrEmpty()) {
                operator = tm?.networkOperatorName?.trim()
            }
            var country = tm?.simCountryIso?.uppercase()?.trim()
            if (country.isNullOrEmpty()) {
                country = tm?.networkCountryIso?.uppercase()?.trim()
            }
            if (country.isNullOrEmpty()) {
                country = Locale.getDefault().country.uppercase()
            }
            if (country.isEmpty()) country = "BD"

            if (!operator.isNullOrEmpty()) {
                val fullName = resolveFullOperatorName(operator, country)
                return "$fullName [$country]"
            }

            // Check if wifi is active
            val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            val active = cm?.activeNetwork
            val caps = cm?.getNetworkCapabilities(active)
            if (caps != null && caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                return "WiFi [$country]"
            }

            return "Grameenphone [$country]"
        } catch (_: Exception) {
            return "Grameenphone [BD]"
        }
    }

    private fun resolveFullOperatorName(raw: String, country: String): String {
        val lower = raw.lowercase().trim()

        // Bangladesh Operators
        if (lower == "gp" || lower.contains("grameen") || lower == "47001") return "Grameenphone"
        if (lower == "bl" || lower.contains("banglalink") || lower == "47003") return "Banglalink"
        if (lower == "robi" || lower == "aktel" || lower == "47002") return "Robi"
        if (lower.contains("airtel") || lower == "47007") return "Airtel"
        if (lower.contains("teletalk") || lower == "47004") return "Teletalk"

        // Saudi Arabia Operators
        if (lower.contains("mobily") || lower == "42003") return "Mobily"
        if (lower.contains("stc") || lower.contains("jawwy") || lower.contains("aljawal") || lower == "42001") return "STC"
        if (lower.contains("zain") || lower == "42004") return "Zain"
        if (lower.contains("salam") || lower == "42006") return "Salam"
        if (lower.contains("virgin") || lower.contains("red bull")) return "Virgin Mobile"

        // India Operators
        if (lower.contains("jio") || lower.contains("reliance")) return "Jio"
        if (lower.contains("airtel") || lower.contains("bharti")) return "Airtel"
        if (lower.contains("vodafone") || lower.contains("idea") || lower == "vi") return "Vi"
        if (lower.contains("bsnl")) return "BSNL"

        // Middle East & Others
        if (lower.contains("etisalat")) return "Etisalat"
        if (lower.contains("du")) return "du"
        if (lower.contains("ooredoo")) return "Ooredoo"

        // Fallback: title case the name
        return raw.split(" ")
            .filter { it.isNotEmpty() }
            .joinToString(" ") { word ->
                word.lowercase().replaceFirstChar { if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString() }
            }
    }
}
