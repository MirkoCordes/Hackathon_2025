import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.status,
    required this.type,
  });

  const StatusBadge.available(this.status, {super.key}) : type = StatusType.available;
  const StatusBadge.restricted(this.status, {super.key}) : type = StatusType.restricted;
  const StatusBadge.pending(this.status, {super.key}) : type = StatusType.pending;
  const StatusBadge.approved(this.status, {super.key}) : type = StatusType.approved;
  const StatusBadge.rejected(this.status, {super.key}) : type = StatusType.rejected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: type.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: theme.textTheme.labelSmall?.copyWith(
              color: type.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType {
  available(Color(0xFF16A34A)), // Grün
  restricted(Color(0xFFF59E0B)), // Orange
  pending(Color(0xFF6B7280)), // Grau
  approved(Color(0xFF16A34A)), // Grün
  rejected(Color(0xFFDC2626)); // Rot

  const StatusType(this.color);
  final Color color;
}
