import 'package:flutter_test/flutter_test.dart';
import 'package:sales_man_admin/main.dart';

void main() {
  testWidgets('Admin panel renders login view when unauthenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
