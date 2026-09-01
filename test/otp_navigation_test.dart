import 'package:farm_to_home_app/app/app_router.dart';
import 'package:farm_to_home_app/app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('registration email is passed to the OTP screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.otp,
                  arguments: <String, dynamic>{
                    'phoneNumber': '+919876543210',
                    'email': 'venkata@example.com',
                    'emailVerificationSent': true,
                    'source': 'register-email-only',
                  },
                );
              },
              child: const Text('Open OTP'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open OTP'));
    await tester.pump();

    expect(find.text('Verify OTP'), findsOneWidget);
    expect(find.textContaining('ve***@example.com'), findsOneWidget);
    expect(find.text('VERIFY OTP'), findsOneWidget);
  });
}
