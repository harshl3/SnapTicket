import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../providers/event_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/state_views.dart';
import 'digital_ticket_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _selectedTabIndex = 0; // 0: Upcoming, 1: Past, 2: Cancelled, 3: All

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  void _loadBookings() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      bookingProvider.fetchUserBookings(userProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final currentUser = userProvider.currentUser;

    // Categorize bookings
    final allBookings = bookingProvider.bookings;
    final now = DateTime.now();

    final upcomingBookings = allBookings.where((b) {
      return b.isConfirmed;
    }).toList();

    final pastBookings = allBookings.where((b) {
      return b.isConfirmed && b.bookedAt.isBefore(now.subtract(const Duration(days: 7)));
    }).toList();

    final cancelledBookings = allBookings.where((b) => b.isCancelled).toList();

    List<Booking> displayedBookings;
    if (_selectedTabIndex == 0) {
      displayedBookings = upcomingBookings;
    } else if (_selectedTabIndex == 1) {
      displayedBookings = pastBookings;
    } else if (_selectedTabIndex == 2) {
      displayedBookings = cancelledBookings;
    } else {
      displayedBookings = allBookings;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Tickets & Passes',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Passes for ${currentUser?.name ?? "Guest"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  GlassContainer(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(8),
                    onTap: _loadBookings,
                    child: const Icon(Icons.refresh_rounded, size: 20),
                  ),
                ],
              ),
            ),

            // Tab Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTab(0, 'Upcoming (${upcomingBookings.length})'),
                    _buildTab(1, 'Past (${pastBookings.length})'),
                    _buildTab(2, 'Cancelled (${cancelledBookings.length})'),
                    _buildTab(3, 'All (${allBookings.length})'),
                  ],
                ),
              ),
            ),

            // Bookings List Area
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primaryViolet,
                onRefresh: () async => _loadBookings(),
                child: _buildBookingsBody(
                  context,
                  bookingProvider,
                  eventProvider,
                  currentUser,
                  displayedBookings,
                  isDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryViolet : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryViolet.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsBody(
    BuildContext context,
    BookingProvider bookingProvider,
    EventProvider eventProvider,
    currentUser,
    List<Booking> bookings,
    bool isDark,
  ) {
    if (bookingProvider.isLoading) {
      return const LoadingStateView(message: 'Loading your tickets...');
    }

    if (bookingProvider.errorMessage != null) {
      return ErrorStateView(
        message: bookingProvider.errorMessage!,
        onRetry: _loadBookings,
      );
    }

    if (bookings.isEmpty) {
      return EmptyStateView(
        title: _selectedTabIndex == 0
            ? 'No Upcoming Tickets'
            : (_selectedTabIndex == 1
                ? 'No Past Event History'
                : (_selectedTabIndex == 2 ? 'No Cancelled Bookings' : 'No Tickets Reserved')),
        subtitle: 'Explore our event directory to reserve your passes.',
        icon: Icons.confirmation_number_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildEnhancedBookingCard(
          context,
          booking,
          currentUser,
          bookingProvider,
          eventProvider,
          isDark,
        );
      },
    );
  }

  Widget _buildEnhancedBookingCard(
    BuildContext context,
    Booking booking,
    currentUser,
    BookingProvider bookingProvider,
    EventProvider eventProvider,
    bool isDark,
  ) {
    final event = booking.event;
    final isConfirmed = booking.isConfirmed;
    final statusColor = isConfirmed ? AppTheme.successEmerald : AppTheme.dangerRose;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Ref + Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryViolet.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryViolet.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 14, color: AppTheme.primaryViolet),
                      const SizedBox(width: 6),
                      Text(
                        booking.bookingReference,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryViolet,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConfirmed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.status.value,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Event Title
            Text(
              event?.name ?? 'Event #${booking.eventId}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),

            // Date & Venue Details
            if (event != null) ...[
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${event.date} • ${event.time}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.accentPink),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            Divider(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
              height: 18,
            ),

            // Bottom Actions: View Digital Ticket Pass & Cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.ticketsCount} ${booking.ticketsCount == 1 ? "Ticket" : "Tickets"}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      AppConstants.formatCurrency(booking.totalPrice),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isConfirmed ? Theme.of(context).colorScheme.primary : AppTheme.dangerRose,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isConfirmed) ...[
                      // "View Pass" Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DigitalTicketScreen(
                                booking: booking,
                                user: currentUser,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_rounded, size: 15),
                        label: const Text('View Pass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Cancel Button
                      IconButton(
                        onPressed: () => _confirmAndCancelBooking(context, booking, bookingProvider, eventProvider),
                        tooltip: 'Cancel Booking',
                        icon: const Icon(Icons.cancel_outlined, size: 20, color: AppTheme.dangerRose),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Seats Restored',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.dangerRose),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndCancelBooking(
    BuildContext context,
    Booking booking,
    BookingProvider bookingProvider,
    EventProvider eventProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkSurface
              : AppTheme.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.dangerRose, size: 24),
              SizedBox(width: 10),
              Text('Cancel Ticket Pass?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel booking ${booking.bookingReference}?',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '${booking.ticketsCount} seat(s) will be released back to the event capacity.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Ticket'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await bookingProvider.cancelBooking(
                    bookingId: booking.id,
                    eventProvider: eventProvider,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking ${booking.bookingReference} cancelled. Seats restored!'),
                      backgroundColor: AppTheme.warningAmber,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppTheme.dangerRose,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRose),
              child: const Text('Confirm Cancel'),
            ),
          ],
        );
      },
    );
  }
}
