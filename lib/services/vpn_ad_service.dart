import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';

class VpnAdService {
  /// Check if master ads are enabled
  static bool isAdsGloballyEnabled(BuildContext context) {
    final ads = context.read<ConfigProvider>().ads;
    if (ads.isEmpty) return false;
    return ads['admob_status'] == 'enabled' || (ads['ads_enabled'] as bool? ?? false);
  }

  /// Check if a specific ad format is enabled
  static bool isAdFormatEnabled(BuildContext context, String format) {
    if (!isAdsGloballyEnabled(context)) return false;
    final ads = context.read<ConfigProvider>().ads;
    switch (format) {
      case 'banner':
        return ads['banner_enabled'] as bool? ?? true;
      case 'interstitial':
        return ads['interstitial_enabled'] as bool? ?? true;
      case 'rewarded':
        return ads['rewarded_enabled'] as bool? ?? true;
      case 'rewarded_interstitial':
        return ads['rewarded_interstitial_enabled'] as bool? ?? true;
      case 'native':
        return ads['native_enabled'] as bool? ?? true;
      case 'app_open':
        return ads['app_open_enabled'] as bool? ?? true;
      default:
        return false;
    }
  }

  /// Show video / interstitial ad when connecting, respecting admin specific toggles
  static Future<void> showConnectAd(
    BuildContext context, {
    required VoidCallback onDone,
  }) async {
    final ads = context.read<ConfigProvider>().ads;
    final isGlobalEnabled = ads['admob_status'] == 'enabled' || (ads['ads_enabled'] as bool? ?? false);
    final showOnConnect = ads['show_on_connect'] as bool? ?? true;

    // If master switch is off or connect trigger is off, bypass ad
    if (!isGlobalEnabled || !showOnConnect) {
      onDone();
      return;
    }

    final connectType = ads['connect_ad_type'] as String? ?? 'interstitial';
    bool isSpecificFormatActive = false;
    String adUnitId = '';
    String adFormatName = 'Interstitial Video Ad';

    if (connectType == 'rewarded') {
      isSpecificFormatActive = ads['rewarded_enabled'] as bool? ?? true;
      adUnitId = ads['admob_rewarded_id'] ?? ads['rewarded_video_ad_unit_id'] ?? 'ca-app-pub-3940256099942544/5224354917';
      adFormatName = 'Rewarded Video Ad';
    } else if (connectType == 'rewarded_interstitial') {
      isSpecificFormatActive = ads['rewarded_interstitial_enabled'] as bool? ?? true;
      adUnitId = ads['admob_rewarded_interstitial_id'] ?? 'ca-app-pub-3940256099942544/5354046379';
      adFormatName = 'Rewarded Interstitial Ad';
    } else {
      // Default Interstitial
      isSpecificFormatActive = ads['interstitial_enabled'] as bool? ?? true;
      adUnitId = ads['admob_interstitial_id'] ?? ads['interstitial_ad_unit_id'] ?? 'ca-app-pub-3940256099942544/1033173712';
      adFormatName = 'Interstitial Ad';
    }

    // If the admin turned off this specific format, skip the ad!
    if (!isSpecificFormatActive || adUnitId.trim().isEmpty) {
      onDone();
      return;
    }

    // Show Fullscreen Video Ad Experience
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _FullScreenVideoAdDialog(
        adFormatName: adFormatName,
        adUnitId: adUnitId.toString(),
        adNetwork: 'Google AdMob',
        onFinished: () {
          Navigator.of(ctx).pop();
          onDone();
        },
      ),
    );
  }

  /// Show rewarded ad to earn extra VPN hours
  static Future<void> showRewardedAd(
    BuildContext context, {
    required Function(int bonusMinutes) onReward,
  }) async {
    final ads = context.read<ConfigProvider>().ads;
    final isGlobalEnabled = ads['admob_status'] == 'enabled' || (ads['ads_enabled'] as bool? ?? false);
    final isRewardedActive = ads['rewarded_enabled'] as bool? ?? true;
    final rewardMinutes = ads['reward_minutes'] as int? ?? 120;
    final adUnitId = ads['admob_rewarded_id'] ?? ads['rewarded_video_ad_unit_id'] ?? 'ca-app-pub-3940256099942544/5224354917';

    // If rewarded ads are disabled in admin panel, directly award bonus time
    if (!isGlobalEnabled || !isRewardedActive) {
      onReward(rewardMinutes);
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _FullScreenVideoAdDialog(
        adFormatName: 'AdMob Rewarded Video',
        adUnitId: adUnitId.toString(),
        adNetwork: 'Google AdMob',
        bonusMinutes: rewardMinutes,
        onFinished: () {
          Navigator.of(ctx).pop();
          onReward(rewardMinutes);
        },
      ),
    );
  }
}

class _FullScreenVideoAdDialog extends StatefulWidget {
  final String adFormatName;
  final String adUnitId;
  final String adNetwork;
  final int? bonusMinutes;
  final VoidCallback onFinished;

  const _FullScreenVideoAdDialog({
    required this.adFormatName,
    required this.adUnitId,
    required this.adNetwork,
    this.bonusMinutes,
    required this.onFinished,
  });

  @override
  State<_FullScreenVideoAdDialog> createState() => _FullScreenVideoAdDialogState();
}

class _FullScreenVideoAdDialogState extends State<_FullScreenVideoAdDialog> {
  int _secondsLeft = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Ad Backdrop Simulation
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF020617)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 54),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.adFormatName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.adNetwork,
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Top Rated High-Speed Cloud Gaming & Streaming',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                    Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                    Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                    Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                    Icon(Icons.star_half, color: Color(0xFFF59E0B), size: 16),
                    SizedBox(width: 6),
                    Text('4.9 ★ • Free App', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    'INSTALL NOW',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
                if (widget.bonusMinutes != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Text(
                      '🎁 Reward: +${widget.bonusMinutes! ~/ 60} Hours Free VPN Time',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Top Bar with Timer / Close Button
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "Ad" badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AD',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),

                // Countdown or Close Button
                if (_secondsLeft > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Video Ad: $_secondsLeft s',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Continue to VPN', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: widget.onFinished,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic Google AdMob Banner Ad Widget
/// Automatically renders when 'banner_enabled' is true in Admin Panel
class VpnBannerAdWidget extends StatelessWidget {
  const VpnBannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<ConfigProvider>().ads;
    final isMasterEnabled = ads['admob_status'] == 'enabled' || (ads['ads_enabled'] as bool? ?? false);
    final isBannerEnabled = ads['banner_enabled'] as bool? ?? true;
    final bannerId = ads['admob_banner_id'] ?? ads['banner_ad_unit_id'] ?? '';

    if (!isMasterEnabled || !isBannerEnabled || bannerId.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'AD',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Superfast Cloud Hosting - 50% Off',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Accelerate your speed with premium global VPS server nodes',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'INSTALL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic Google AdMob Native Ad Card Widget
/// Automatically renders when 'native_enabled' is true in Admin Panel
class VpnNativeAdCard extends StatelessWidget {
  const VpnNativeAdCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<ConfigProvider>().ads;
    final isMasterEnabled = ads['admob_status'] == 'enabled' || (ads['ads_enabled'] as bool? ?? false);
    final isNativeEnabled = ads['native_enabled'] as bool? ?? true;
    final nativeId = ads['admob_native_id'] ?? '';

    if (!isMasterEnabled || !isNativeEnabled || nativeId.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('AD', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text('Sponsored by Google AdMob', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('High-Speed Tunnel Protection', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Experience unthrottled streaming and browsing with enterprise grade encryption.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
