import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/event_card.dart';
import '../widgets/glass_container.dart';
import '../widgets/state_views.dart';
import 'event_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryViolet,
          onRefresh: () => eventProvider.fetchEvents(),
          child: CustomScrollView(
            slivers: [
              // Top Title Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Events',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Find live concerts, tech summits & matches',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                      GlassContainer(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(8),
                        onTap: () => eventProvider.fetchEvents(),
                        child: const Icon(Icons.refresh_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: GlassContainer(
                    borderRadius: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => eventProvider.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search by title, category, venue...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 22),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  eventProvider.clearSearch();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // Category Pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: AppConstants.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = AppConstants.categories[index];
                      final isSelected =
                          eventProvider.selectedCategory.toLowerCase() == category.toLowerCase();
                      final catColor = AppConstants.getCategoryColor(category, isDark: isDark);

                      return GestureDetector(
                        onTap: () => eventProvider.setCategory(category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppTheme.primaryViolet, Color(0xFF8B5CF6)],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isDark ? AppTheme.darkCard.withValues(alpha: 0.6) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryViolet.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (category != 'All') ...[
                                Icon(
                                  AppConstants.getCategoryIcon(category),
                                  size: 14,
                                  color: isSelected ? Colors.white : catColor,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Section Count Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        eventProvider.selectedCategory == 'All'
                            ? (eventProvider.searchQuery.isEmpty ? 'All Events' : 'Matching Results')
                            : '${eventProvider.selectedCategory} Events',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        '${eventProvider.filteredEvents.length} available',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Events List
              _buildEventsListSection(context, eventProvider),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsListSection(BuildContext context, EventProvider provider) {
    if (provider.isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingStateView(message: 'Loading events...'),
      );
    }

    if (provider.errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateView(
          message: provider.errorMessage!,
          onRetry: () => provider.fetchEvents(),
        ),
      );
    }

    final events = provider.filteredEvents;

    if (events.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(
          title: 'No Events Found',
          subtitle: provider.searchQuery.isNotEmpty
              ? 'No matching events for "${provider.searchQuery}".'
              : 'No events found in "${provider.selectedCategory}".',
          action: ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              provider.clearSearch();
              provider.setCategory('All');
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset Filters'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(event: event),
                  ),
                );
              },
            );
          },
          childCount: events.length,
        ),
      ),
    );
  }
}
