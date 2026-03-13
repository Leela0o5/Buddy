import 'package:flutter_test/flutter_test.dart';
import 'package:buddy/app.dart';

void main() {
  testWidgets('App initializes without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const Buddy());
    expect(find.byType(Buddy), findsOneWidget);
  });
}