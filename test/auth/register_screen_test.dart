import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:streakly_app/providers/auth_provider.dart';
import 'package:streakly_app/screens/auth/register_screen.dart';

// Generate mocks
@GenerateMocks([AuthProvider])
import 'register_screen_test.mocks.dart';

void main() {
  group('RegisterScreen Error Handling Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const RegisterScreen(),
        ),
      );
    }

    testWidgets('should display error message when registration fails', (WidgetTester tester) async {
      // Arrange
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.errorMessage).thenReturn('An account with this email already exists');
      when(mockAuthProvider.isAuthenticated).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('An account with this email already exists'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should hide error message when no error exists', (WidgetTester tester) async {
      // Arrange
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.errorMessage).thenReturn(null);
      when(mockAuthProvider.isAuthenticated).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.text('An account with this email already exists'), findsNothing);
    });

    testWidgets('should show loading state when registration is in progress', (WidgetTester tester) async {
      // Arrange
      when(mockAuthProvider.isLoading).thenReturn(true);
      when(mockAuthProvider.errorMessage).thenReturn(null);
      when(mockAuthProvider.isAuthenticated).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Button should be disabled when loading
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should call clearError when close button is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.errorMessage).thenReturn('Registration failed');
      when(mockAuthProvider.isAuthenticated).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Assert
      verify(mockAuthProvider.clearError()).called(1);
    });

    testWidgets('should display different error messages for different error types', (WidgetTester tester) async {
      final errorMessages = [
        'Password must be at least 6 characters long',
        'Please enter a valid email address',
        'Too many attempts. Please try again later',
        'Password is too weak. Please choose a stronger password',
      ];

      for (final errorMessage in errorMessages) {
        // Arrange
        when(mockAuthProvider.isLoading).thenReturn(false);
        when(mockAuthProvider.errorMessage).thenReturn(errorMessage);
        when(mockAuthProvider.isAuthenticated).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text(errorMessage), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should validate form fields before registration', (WidgetTester tester) async {
      // Arrange
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.errorMessage).thenReturn(null);
      when(mockAuthProvider.isAuthenticated).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Try to submit without filling fields
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('should show terms agreement error when not checked', (WidgetTester tester) async {
      // Arrange
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.errorMessage).thenReturn(null);
      when(mockAuthProvider.isAuthenticated).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Fill in valid form data but don't check terms
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');
      
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Assert
      expect(find.text('Please agree to the Terms of Service'), findsOneWidget);
    });
  });
}
