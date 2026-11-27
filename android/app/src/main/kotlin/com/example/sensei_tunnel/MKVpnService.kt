package com.example.sensei_tunnel

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat
import java.io.FileInputStream
import java.io.FileOutputStream

class MKVpnService : VpnService() {

    companion object {
        const val ACTION_START = "com.mktunnel.vpn.START"
        const val ACTION_STOP = "com.mktunnel.vpn.STOP"
        const val CHANNEL_ID = "mk_vpn_service_channel"
        const val NOTIFICATION_ID = 2026

        @Volatile
        var isRunning: Boolean = false
            private set
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private var vpnWorkerThread: Thread? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: ACTION_START
        if (action == ACTION_STOP) {
            stopVpnTunnel()
            return START_NOT_STICKY
        }

        startForeground(NOTIFICATION_ID, buildForegroundNotification("Connected • MK Tunnel VPN"))
        startVpnTunnel()
        return START_STICKY
    }

    private fun startVpnTunnel() {
        if (isRunning && vpnInterface != null) return

        try {
            val builder = Builder()
            builder.setSession("MK Tunnel VPN")
            builder.setMtu(1500)
            builder.addAddress("10.8.0.2", 24)
            builder.addDnsServer("8.8.8.8")
            builder.addDnsServer("1.1.1.1")
            builder.addRoute("0.0.0.0", 0)

            try {
                builder.addDisallowedApplication(packageName)
            } catch (_: Exception) {}

            // establish() tells the Android OS to route through TUN and displays the [VPN] key icon in the status bar
            vpnInterface = builder.establish()
            isRunning = true

            // Keep the VPN descriptor active and loop packets
            vpnWorkerThread = Thread({
                try {
                    val pfd = vpnInterface ?: return@Thread
                    val inStream = FileInputStream(pfd.fileDescriptor)
                    val buffer = ByteArray(32768)

                    while (isRunning && !Thread.currentThread().isInterrupted) {
                        val read = inStream.read(buffer)
                        if (read <= 0) {
                            Thread.sleep(100)
                        }
                    }
                } catch (_: Exception) {
                    // Closed or terminated
                }
            }, "MKVpnWorkerThread")
            vpnWorkerThread?.start()

        } catch (e: Exception) {
            e.printStackTrace()
            stopVpnTunnel()
        }
    }

    private fun stopVpnTunnel() {
        isRunning = false
        try {
            vpnWorkerThread?.interrupt()
            vpnWorkerThread = null
            vpnInterface?.close()
            vpnInterface = null
        } catch (_: Exception) {}

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    override fun onDestroy() {
        stopVpnTunnel()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN Tunnel Connection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Notifies when VPN tunnel is active"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(contentText: String): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = if (launchIntent != null) {
            PendingIntent.getActivity(
                this,
                0,
                launchIntent,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
            )
        } else null

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle("MK Tunnel VPN")
            .setContentText(contentText)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .build()
    }
}
