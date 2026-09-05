import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class EventProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Event> _events = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  EventProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    fetchEvents();
  }

  List<Event> get events => _events;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Event> get featuredEvents => _events.where((e) => e.isFeatured).toList();

  List<Event> get filteredEvents {
    return _events.where((event) {
      // 1. Category Filter
      final matchesCategory = _selectedCategory == 'All' ||
          event.category.toLowerCase() == _selectedCategory.toLowerCase();

      // 2. Search Filter (by title, category, venue)
      if (_searchQuery.trim().isEmpty) {
        return matchesCategory;
      }

      final query = _searchQuery.toLowerCase().trim();
      final matchesName = event.name.toLowerCase().contains(query);
      final matchesCat = event.category.toLowerCase().contains(query);
      final matchesVenue = event.venue.toLowerCase().contains(query);

      return matchesCategory && (matchesName || matchesCat || matchesVenue);
    }).toList();
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getEvents();
      _events = data;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Sync seat counts after booking or cancellation
  void syncEventSeats(String eventId, int availableSeats) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(availableSeats: availableSeats);
      notifyListeners();
    }
  }
}
