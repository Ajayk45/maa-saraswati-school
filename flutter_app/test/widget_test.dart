import 'package:flutter_test/flutter_test.dart';

import 'package:maa_saraswati_school/main.dart';

void main() {
  testWidgets('School app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MaaSaraswatiApp());

    expect(find.text('Maa Saraswati School'), findsWidgets);
  });
}
