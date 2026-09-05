import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_constants.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/user_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                children: [
                  GlassContainer(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(8),
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Settings & Info',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Active User Section
              _buildSectionHeader(context, 'ACTIVE USER PROFILE'),
              const SizedBox(height: 10),
              GlassContainer(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.primaryViolet.withValues(alpha: 0.2),
                      backgroundImage: currentUser?.avatarUrl != null && currentUser!.avatarUrl.isNotEmpty
                          ? NetworkImage(currentUser.avatarUrl)
                          : null,
                      child: currentUser == null || currentUser.avatarUrl.isEmpty
                          ? const Icon(Icons.person_rounded, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.name ?? 'No user selected',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${currentUser?.role ?? "Attendee"} • ${currentUser?.email ?? ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentUser?.phone ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const UserSelectorChip(),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Theme Mode Section
              _buildSectionHeader(context, 'THEME PREFERENCES'),
              const SizedBox(height: 10),
              GlassContainer(
                borderRadius: 22,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: AppThemeMode.values.map((mode) {
                    final isSelected = themeProvider.currentThemeMode == mode;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => themeProvider.setThemeMode(mode),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryViolet.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getThemeIcon(mode),
                                color: isSelected ? AppTheme.primaryViolet : (isDark ? Colors.white70 : Colors.black54),
                                size: 20,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  mode.label,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.primaryViolet
                                        : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppTheme.primaryViolet, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),

              // Backend & Architecture Configuration Section
              _buildSectionHeader(context, 'BACKEND ARCHITECTURE & STATUS'),
              const SizedBox(height: 10),
              GlassContainer(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Data Layer',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ApiConstants.useMockApi
                                ? AppTheme.warningAmber.withValues(alpha: 0.15)
                                : AppTheme.successEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ApiConstants.useMockApi ? AppTheme.warningAmber : AppTheme.successEmerald,
                            ),
                          ),
                          child: Text(
                            ApiConstants.useMockApi ? 'MOCK API MODE (ACTIVE)' : 'REAL REST API',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: ApiConstants.useMockApi ? AppTheme.warningAmber : AppTheme.successEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Configured Base URL:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 16, color: AppTheme.primaryViolet),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ApiConstants.baseUrl,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Connected to the Node.js + Express backend by default. Set API_BASE_URL when building for a deployed environment.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // About App Card
              _buildSectionHeader(context, 'ABOUT SNAPTICKET'),
              const SizedBox(height: 10),
              GlassContainer(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryViolet, Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            Text(
                              AppConstants.appTagline,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Built with Flutter, Material 3, and Glassmorphic aesthetics. Features modular ApiService abstraction layer, Provider state management, and real-time seat synchronization.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppConstants.appVersion,
                      style: const TextStyle(fontSize: 11, color: AppTheme.primaryViolet, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}
