import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabatfresh/app_entry_page.dart';
import 'package:talabatfresh/data/local/cache_helper.dart';
import 'package:talabatfresh/features/auth/pages/login_page.dart';
import 'package:talabatfresh/providers/auth_provider.dart';
import 'package:talabatfresh/startup_gate.dart';

Widget entryApp() => ChangeNotifierProvider(
  create: (_) => AuthProvider(),
  child: const MaterialApp(home: AppEntryPage()),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  testWidgets('Startup displays loading then opens login', (tester) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      StartupGate(
        initialize: () => initialization.future,
        builder: (_) => entryApp(),
      ),
    );
    await tester.pump();
    expect(find.text('Starting Qotomoto…'), findsOneWidget);
    initialization.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Startup failure can recover to login with retry', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      StartupGate(
        initialize: () async {
          if (++attempts == 1) {
            throw StateError('Firebase initialization failed');
          }
        },
        builder: (_) => entryApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unable to start Qotomoto.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hung startup displays recovery after timeout', (tester) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      StartupGate(
        initialize: () => initialization.future,
        timeout: const Duration(seconds: 2),
        builder: (_) => entryApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
    initialization.complete();
  });

  testWidgets('Fresh install opens login and validates required fields', (
    tester,
  ) async {
    await tester.pumpWidget(entryApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    final button = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Enter email or phone'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
