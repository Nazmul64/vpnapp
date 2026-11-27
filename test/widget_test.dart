import 'package:flutter_test/flutter_test.dart';
import 'package:sensei_tunnel/main.dart';
import 'package:sensei_tunnel/screens/tunnel/xj_home_screen.dart';

void main() {
  testWidgets('MK Tunnel VPN app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MkTunnelApp());
    await tester.pump();
    expect(find.byType(MkMainScreen), findsOneWidget);
    expect(find.text('MK Tunnel VPN'), findsOneWidget);
    expect(find.text('STOP'), findsOneWidget);
    expect(find.text('Config Version: 1.0.22'), findsOneWidget);
  });
}
