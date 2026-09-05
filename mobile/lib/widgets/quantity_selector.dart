import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxAvailable;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.maxAvailable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canDecrement = quantity > 1;
    final canIncrement = quantity < maxAvailable;

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button
          _buildActionButton(
            context,
            icon: Icons.remove_rounded,
            enabled: canDecrement,
            onPressed: canDecrement ? () => onChanged(quantity - 1) : null,
          ),
          // Quantity Display
          Container(
            constraints: const BoxConstraints(minWidth: 44),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
            ),
          ),
          // Increment Button
          _buildActionButton(
            context,
            icon: Icons.add_rounded,
            enabled: canIncrement,
            onPressed: canIncrement ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required bool enabled,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.primaryViolet.withValues(alpha: 0.18)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? AppTheme.primaryViolet
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
