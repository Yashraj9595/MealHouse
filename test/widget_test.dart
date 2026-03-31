import 'package:flutter_test/flutter_test.dart';
import 'package:meal_house/main.dart';

void main() {
  testWidgets('App should build and show Welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MealHouseApp());

    // Verify that our Welcome screen text exists.
    expect(find.textContaining('Welcome to'), findsOneWidget);
    expect(find.textContaining('Meal House'), findsOneWidget);
  });
}
