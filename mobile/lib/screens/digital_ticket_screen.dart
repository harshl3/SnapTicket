import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

/// Standalone Digital Ticket Pass with QR representation, tear line notches, and attendee metadata.
class DigitalTicketScreen extends StatelessWidget {
  final Booking booking;
  final User? user;

  const DigitalTicketScreen({
    super.key,
    required this.booking,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final event = booking.event;
    final isConfirmed = booking.isConfirmed;
    final catColor = event != null
        ? AppConstants.getCategoryColor(event.category, isDark: isDark)
        : AppTheme.primaryViolet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Ticket Pass'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Pass',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket pass ${booking.bookingReference} ready to share!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Digital Ticket Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryViolet.withValues(alpha: isDark ? 0.25 : 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Banner
                        Container(
                          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                catColor.withValues(alpha: 0.9),
                                AppTheme.primaryViolet,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.confirmation_number_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'SNAPTICKET PASS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      booking.status.value,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                event?.name ?? 'Event Admission',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event?.category ?? 'General Admission',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Ticket Information Body
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            children: [
                              // Attendee & Seats Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoColumn(
                                    context,
                                    label: 'ATTENDEE',
                                    value: user?.name ?? 'Ticket Holder',
                                    subvalue: user?.email,
                                  ),
                                  _buildInfoColumn(
                                    context,
                                    label: 'SEATS',
                                    value: '${booking.ticketsCount} ${booking.ticketsCount == 1 ? "Ticket" : "Tickets"}',
                                    subvalue: AppConstants.formatCurrency(booking.totalPrice),
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Date & Time Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoColumn(
                                    context,
                                    label: 'DATE',
                                    value: event?.date ?? 'TBA',
                                  ),
                                  _buildInfoColumn(
                                    context,
                                    label: 'TIME',
                                    value: event?.time ?? 'TBA',
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Venue Row
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoColumn(
                                  context,
                                  label: 'VENUE LOCATION',
                                  value: event?.venue ?? 'Venue Location TBA',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Perforated Divider with Cutout Notches
                        _buildPerforatedDivider(context, isDark),

                        // QR Code & Barcode Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                          child: Column(
                            children: [
                              Text(
                                'SCAN AT ENTRY GATE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // QR Code Container
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: isConfirmed
                                    ? QrImageView(
                                        data: booking.qrPayload,
                                        version: QrVersions.auto,
                                        size: 160.0,
                                        backgroundColor: Colors.white,
                                      )
                                    : SizedBox(
                                        width: 160,
                                        height: 160,
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.cancel_rounded, color: AppTheme.dangerRose, size: 48),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'VOID / CANCELLED',
                                                style: TextStyle(
                                                  color: AppTheme.dangerRose,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 14),

                              // Booking Reference Code
                              SelectableText(
                                booking.bookingReference,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Booked on ${AppConstants.formatShortDate(booking.bookedAt)}',
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
                  ),
                ),

                const SizedBox(height: 24),

                // Offline Notice
                GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.offline_pin_rounded, size: 16, color: AppTheme.successEmerald),
                      const SizedBox(width: 8),
                      Text(
                        'This digital pass is verified for entry check-in.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    required String label,
    required String value,
    String? subvalue,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subvalue != null) ...[
          const SizedBox(height: 2),
          Text(
            subvalue,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPerforatedDivider(BuildContext context, bool isDark) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dotted perforation line
        Row(
          children: List.generate(
            30,
            (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Container(
                  height: 1.5,
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
        ),
        // Left notch cutout
        Positioned(
          left: -12,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Right notch cutout
        Positioned(
          right: -12,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
