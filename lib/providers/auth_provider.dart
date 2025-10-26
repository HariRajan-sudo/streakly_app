import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userAvatar => _currentUser?.avatarUrl;
  
  AuthProvider() {
    _checkAuthStatus();
    _setupAuthListener();
  }
  
  void _setupAuthListener() {
    SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        _handleSignIn(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _handleSignOut();
      }
    });
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      final session = SupabaseService.instance.client.auth.currentSession;
      if (session != null) {
        await _handleSignIn(session.user);
      } else {
        _handleSignOut();
      }
    } catch (e) {
      _handleSignOut();
    }
  }
  
  Future<void> _handleSignIn(User user) async {
    try {
      _isAuthenticated = true;
      _userEmail = user.email;
      _userName = user.userMetadata?['name'] ?? user.email?.split('@')[0];
      
      // Load full user profile
      _currentUser = await SupabaseService.instance.getUserProfile(user.id);
      
      // Verify avatar data is loaded
      if (_currentUser != null && _currentUser!.avatarUrl != null) {
        print('✅ Avatar loaded: ${_currentUser!.avatarUrl}');
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
      print('❌ Error loading user profile: $e');
      notifyListeners();
    }
  }
  
  void _handleSignOut() {
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await SupabaseService.instance.signIn(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Auth state change will be handled by listener
        return true;
      } else {
        _errorMessage = 'Login failed';
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await SupabaseService.instance.signUp(
        email: email,
        password: password,
        name: name,
      );
      
      if (response.user != null) {
        // Check if email confirmation is required
        if (response.session == null) {
          _errorMessage = 'Please check your email to confirm your account';
        }
        return true;
      } else {
        _errorMessage = 'Registration failed';
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateAvatar(String emoji, Color backgroundColor) async {
    try {
      if (_currentUser == null || SupabaseService.instance.currentUserId == null) {
        _errorMessage = 'User not logged in';
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Store only the emoji as the avatar_url
      await SupabaseService.instance.updateUserProfile(
        userId: SupabaseService.instance.currentUserId!,
        data: {'avatar_url': emoji},
      );
      
      // Update local user data
      _currentUser = _currentUser!.copyWith(avatarUrl: emoji);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await SupabaseService.instance.signOut();
      // Auth state change will be handled by listener
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await SupabaseService.instance.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  String _getErrorMessage(dynamic error) {
    print('Error type: ${error.runtimeType}, Error: $error'); // Debug print
    
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'Email not confirmed':
          return 'Please confirm your email address';
        case 'User already registered':
          return 'An account with this email already exists';
        case 'Password should be at least 6 characters':
          return 'Password must be at least 6 characters long';
        case 'Invalid email':
          return 'Please enter a valid email address';
        case 'Signup requires a valid password':
          return 'Please enter a valid password';
        case 'Email rate limit exceeded':
          return 'Too many attempts. Please try again later';
        case 'Weak password':
          return 'Password is too weak. Please choose a stronger password';
        default:
          return error.message.isNotEmpty ? error.message : 'Authentication failed';
      }
    }
    
    // Handle network/connection errors
    final errorString = error.toString();
    if (errorString.contains('404') || 
        errorString.contains('Failed host lookup') ||
        errorString.contains('SocketException') ||
        errorString.contains('Connection refused')) {
      return 'Cannot connect to server. Please check your internet connection or use demo mode.';
    }
    
    if (errorString.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    }
    
    if (errorString.contains('User not found')) {
      return 'No account found with this email. Please sign up first.';
    }
    
    return 'Authentication failed. Please try again.';
  }
}
