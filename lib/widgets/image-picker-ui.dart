import 'package:flutter/material.dart';

Widget buildDialogOption(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onTap,
      bool isCancel = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Icon(icon,
                size: 24, color: isCancel ? Colors.red : Colors.lightBlue[600]),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isCancel ? Colors.red : Colors.lightBlue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }