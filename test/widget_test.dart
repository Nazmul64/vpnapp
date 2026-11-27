import 'package:flutter_test/flutter_test.dart';
import 'package:sensei_tunnel/main.dart';
import 'package:sensei_tunnel/screens/tunnel/xj_home_screen.dart';

void main() {
  testWidgets('XJ Tunnel VPN app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const XjTunnelApp());
    await tester.pump();
    expect(find.byType(XjMainScreen), findsOneWidget);
    expect(find.text('XJ Tunnel VPN'), findsOneWidget);
    expect(find.text('STOP'), findsOneWidget);
    expect(find.text('Config Version: 1.0.22'), findsOneWidget);
  });
}
