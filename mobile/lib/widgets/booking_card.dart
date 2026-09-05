import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'glass_container.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onCancel;
  final bool isCancelling;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConfirmed = booking.isConfirmed;
    final statusColor = isConfirmed ? AppTheme.successEmerald : AppTheme.dangerRose;
    final event = booking.event;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Reference + Status
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
                      const Icon(Icons.qr_code_rounded, size: 14, color: AppTheme.primaryViolet),
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
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
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
                    '${event.date} • ${event.time.split(' - ').first}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Divider line with perforated feel
            Divider(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
              height: 20,
            ),

            // Bottom summary: Ticket count, Price, and Cancel action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.ticketsCount} ${booking.ticketsCount == 1 ? "Ticket" : "Tickets"}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppConstants.formatCurrency(booking.totalPrice),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isConfirmed ? Theme.of(context).colorScheme.primary : AppTheme.dangerRose,
                          ),
                    ),
                  ],
                ),
                if (isConfirmed)
                  OutlinedButton.icon(
                    onPressed: isCancelling ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dangerRose,
                      side: BorderSide(color: AppTheme.dangerRose.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: isCancelling
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.dangerRose),
                          )
                        : const Icon(Icons.cancel_outlined, size: 16),
                    label: Text(
                      isCancelling ? 'Cancelling...' : 'Cancel Booking',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRose.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Seats Restored',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dangerRose,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
