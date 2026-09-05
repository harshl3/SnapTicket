import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/booking_provider.dart';
import '../providers/event_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/quantity_selector.dart';
import 'booking_success_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProvider = Provider.of<EventProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Get live event state in case seats updated in provider
    final liveEvent = eventProvider.events.firstWhere(
      (e) => e.id == widget.event.id,
      orElse: () => widget.event,
    );

    final catColor = AppConstants.getCategoryColor(liveEvent.category, isDark: isDark);
    final isSoldOut = liveEvent.isSoldOut;
    final maxAvailable = isSoldOut ? 1 : liveEvent.availableSeats;

    if (_selectedQuantity > liveEvent.availableSeats && !isSoldOut) {
      _selectedQuantity = liveEvent.availableSeats;
    }

    final totalPrice = liveEvent.price * _selectedQuantity;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Slivers App Bar with Event Banner
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: GlassContainer(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(8),
                  customColor: Colors.black.withValues(alpha: 0.5),
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: GlassContainer(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(8),
                    customColor: Colors.black.withValues(alpha: 0.5),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event link copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    liveEvent.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            catColor.withValues(alpha: 0.8),
                            AppTheme.primaryViolet,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          AppConstants.getCategoryIcon(liveEvent.category),
                          size: 72,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          (isDark ? AppTheme.darkBg : AppTheme.lightBg).withValues(alpha: 0.95),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: catColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppConstants.getCategoryIcon(liveEvent.category), size: 14, color: catColor),
                            const SizedBox(width: 6),
                            Text(
                              liveEvent.category,
                              style: TextStyle(color: catColor, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              liveEvent.rating.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                            Text(
                              ' (450+ reviews)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                    liveEvent.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Organizer Tag
                  Row(
                    children: [
                      Icon(Icons.verified_user_rounded, size: 15, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Organized by ${liveEvent.organizer}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Cards: Date, Time & Venue
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 18,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                              const SizedBox(height: 8),
                              Text('Date & Time', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                              const SizedBox(height: 2),
                              Text(liveEvent.date, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(liveEvent.time, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 18,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppTheme.accentPink, size: 20),
                              const SizedBox(height: 8),
                              Text('Venue Location', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                              const SizedBox(height: 2),
                              Text(
                                liveEvent.venue,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Available Seats Bar
                  GlassContainer(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Seat Availability',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              isSoldOut
                                  ? 'SOLD OUT'
                                  : '${liveEvent.availableSeats} of ${liveEvent.totalSeats} seats remaining',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSoldOut ? AppTheme.dangerRose : AppTheme.successEmerald,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: liveEvent.totalSeats > 0
                                ? (liveEvent.totalSeats - liveEvent.availableSeats) / liveEvent.totalSeats
                                : 1.0,
                            minHeight: 8,
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSoldOut ? AppTheme.dangerRose : AppTheme.primaryViolet,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // About Event Section
                  Text(
                    'About This Event',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    liveEvent.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Ticket Selection Section
                  if (!isSoldOut) ...[
                    Text(
                      'Select Ticket Quantity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.formatCurrency(liveEvent.price),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const Text(
                              'per single ticket',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        QuantitySelector(
                          quantity: _selectedQuantity,
                          maxAvailable: maxAvailable,
                          onChanged: (newQty) {
                            setState(() {
                              _selectedQuantity = newQty;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Booking Summary Card
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking Summary',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tickets count', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12)),
                              Text('$_selectedQuantity', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Price per ticket', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12)),
                              Text(AppConstants.formatCurrency(liveEvent.price), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                            ],
                          ),
                          Divider(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              Text(
                                AppConstants.formatCurrency(totalPrice),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 120), // Bottom padding for sticky bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Bottom Booking Button Bar
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.darkSurface : Colors.white).withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price breakdown column
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      isSoldOut ? 'Sold Out' : AppConstants.formatCurrency(totalPrice),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isSoldOut ? AppTheme.dangerRose : Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),

              // Booking action button
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: isSoldOut || bookingProvider.isBookingInProgress
                      ? null
                      : () => _handleBookTickets(liveEvent, userProvider, bookingProvider, eventProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSoldOut ? Colors.grey : AppTheme.primaryViolet,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: bookingProvider.isBookingInProgress
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          isSoldOut ? 'SOLD OUT' : 'BOOK TICKETS',
                          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBookTickets(
    Event event,
    UserProvider userProvider,
    BookingProvider bookingProvider,
    EventProvider eventProvider,
  ) async {
    final user = userProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an active user to book tickets.')),
      );
      return;
    }

    try {
      final booking = await bookingProvider.createBooking(
        user: user,
        event: event,
        ticketsCount: _selectedQuantity,
        eventProvider: eventProvider,
      );

      if (!mounted) return;

      // Navigate to Booking Success Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(booking: booking),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.dangerRose,
        ),
      );
    }
  }
}
