import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:f11_todoapp/main.dart';

void main() {
  testWidgets('To-do app test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
  });
}
