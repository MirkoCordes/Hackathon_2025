import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final CategoryType category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? category.color : category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: category.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? Colors.white : category.color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : category.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum CategoryType {
  administration(
    color: Color(0xFF1E3A8A), // Nordsee-Blau
    icon: Icons.account_balance,
  ),
  business(
    color: Color(0xFF16A34A), // Ostfriesisches Grün
    icon: Icons.business,
  ),
  science(
    color: Color(0xFFF59E0B), // Orange
    icon: Icons.science,
  ),
  citizens(
    color: Color(0xFF7C3AED), // Lila
    icon: Icons.groups,
  ),
  environment(
    color: Color(0xFF059669), // Teal
    icon: Icons.eco,
  ),
  infrastructure(
    color: Color(0xFFDC2626), // Emden-Rot
    icon: Icons.construction,
  );

  const CategoryType({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;
}
