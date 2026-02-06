import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = SupabaseService.currentUser;
    if (_user != null) {
      _loadProfile();
    }

    SupabaseService.authStateChanges.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _loadProfile();
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    try {
      _profile = await SupabaseService.getProfile(_user!.id);
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      _user = response.user;
      if (_user != null) {
        await _loadProfile();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;
      if (_user != null) {
        await _loadProfile();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    if (_user == null) return;
    
    try {
      await SupabaseService.updateProfile(
        userId: _user!.id,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      await _loadProfile();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}
