import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  static const String appName = 'SnapTicket';
  static const String appTagline = 'Smart Ticket Booking & Companion';
  static const String appVersion = 'v1.1.0 (Hackathon Edition)';

  // Categories supported by backend & mobile
  static const List<String> categories = [
    'All',
    'Technology',
    'Music',
    'Sports',
    'Entertainment',
    'Business',
    'Workshop',
  ];

  // Currency Formatter in INR
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return format.format(amount);
  }

  // Date Formatting helpers
  static String formatDate(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Category Icons
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.memory_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'business':
      case 'conference':
        return Icons.business_center_rounded;
      case 'sports':
        return Icons.sports_basketball_rounded;
      case 'entertainment':
        return Icons.movie_filter_rounded;
      case 'workshop':
        return Icons.handyman_rounded;
      default:
        return Icons.confirmation_number_rounded;
    }
  }

  // Category Colors
  static Color getCategoryColor(String category, {bool isDark = true}) {
    switch (category.toLowerCase()) {
      case 'technology':
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
      case 'music':
        return isDark ? const Color(0xFFF472B6) : const Color(0xFFDB2777);
      case 'business':
      case 'conference':
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
      case 'sports':
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
      case 'entertainment':
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      case 'workshop':
        return isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
      default:
        return isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
    }
  }
}
