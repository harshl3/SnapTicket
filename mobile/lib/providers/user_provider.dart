import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService;
  static const String _prefUserKey = 'selected_user_id';

  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    loadUsers();
  }

  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedUsers = await _apiService.getUsers();
      _users = fetchedUsers;

      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString(_prefUserKey);

      if (savedUserId != null && _users.any((u) => u.id == savedUserId)) {
        _currentUser = _users.firstWhere((u) => u.id == savedUserId);
      } else if (_users.isNotEmpty) {
        _currentUser = _users.first;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectUser(User user) async {
    _currentUser = user;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefUserKey, user.id);
    } catch (_) {}
  }
}
