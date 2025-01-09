import 'package:flutter/material.dart';

Widget myTransactionTile({
  required String amount,
  required String description,
  required String date,
  required Color color,
}) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: color.withAlpha(20),
      child: Icon(
        color == Colors.red ? Icons.arrow_downward : Icons.arrow_upward,
        color: color,
      ),
    ),
    title: Text(
      description,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text(date),
    trailing: Text(
      amount,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
