import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_template/main.dart';
import 'package:frontend_template/core/init/app_initializer.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await AppInitializer.init(navigatorKey);

    await tester.pumpWidget(const EnterpriseApp());
    expect(find.byType(EnterpriseApp), findsOneWidget);
  });
}
