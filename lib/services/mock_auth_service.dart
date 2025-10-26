import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthService {
  // Store email -> password mapping for mock authentication
  static final Map<String, String> _registeredUsers = {
    'test@example.com': 'password123', // Default test user
    'demo@streakly.com': 'demo123', // Demo user
  };
  
  static Future<AuthResponse> mockSignUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate various error scenarios for testing
    if (email == 'test@error.com') {
      throw AuthException('User already registered');
    }
    
    if (password.length < 6) {
      throw AuthException('Password should be at least 6 characters');
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw AuthException('Invalid email');
    }
    
    if (password == 'weak') {
      throw AuthException('Weak password');
    }
    
    if (email == 'rate@limit.com') {
      throw AuthException('Email rate limit exceeded');
    }
    
    if (_registeredUsers.containsKey(email)) {
      throw AuthException('User already registered');
    }
    
    // Simulate successful registration
    _registeredUsers[email] = password;
    
    // Create mock user
    final mockUser = User(
      id: 'mock-${Random().nextInt(10000)}',
      appMetadata: {},
      userMetadata: {'name': name},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    
    return AuthResponse(
      user: mockUser,
      session: Session(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        expiresIn: 3600,
        tokenType: 'bearer',
        user: mockUser,
      ),
    );
  }
  
  static Future<AuthResponse> mockSignIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if user exists
    if (!_registeredUsers.containsKey(email)) {
      throw AuthException('Invalid login credentials');
    }
    
    // Validate password
    if (_registeredUsers[email] != password) {
      throw AuthException('Invalid login credentials');
    }
    
    // Create mock user for sign in
    final mockUser = User(
      id: 'mock-${email.hashCode}',
      appMetadata: {},
      userMetadata: {'name': email.split('@')[0]},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    
    return AuthResponse(
      user: mockUser,
      session: Session(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        expiresIn: 3600,
        tokenType: 'bearer',
        user: mockUser,
      ),
    );
  }
}
