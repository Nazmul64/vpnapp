import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'providers/vpn_provider.dart';
import 'providers/config_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/tunnel/xj_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style matching screenshot (Green header & navigation)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.headerGreen,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bottomBarGreen,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const XjTunnelApp());
}

class XjTunnelApp extends StatelessWidget {
  const XjTunnelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VpnProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const XjMainScreen(),
      ),
    );
  }
}
