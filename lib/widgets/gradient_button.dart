import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const GradientButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F8DFE), Color(0xFF6FE1E1)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,6))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: DefaultTextStyle(style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600), child: child),
        ),
      ),
    );
  }
}
