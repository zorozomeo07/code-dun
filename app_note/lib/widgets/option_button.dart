import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  OptionButton({super.key, required this.onPressed, required this.label});
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
