import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border:
                isSelected ? Border.all(color: Colors.orange, width: 2) : null,
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: color.withAlpha(60),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
