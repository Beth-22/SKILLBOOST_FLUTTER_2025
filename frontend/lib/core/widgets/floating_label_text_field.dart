import 'package:flutter/material.dart';

class FloatingLabelTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final double width;
  final double height;
  final bool obscureText;

  const FloatingLabelTextField({
    Key? key,
    required this.label,
    this.controller,
    this.width = 342,
    this.height = 70,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Text field container
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color.fromARGB(255, 187, 151, 236), width: 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26.withOpacity(0.2),
                    blurRadius: 4.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 16, bottom: 8),
                ),
              ),
            ),
          ),

          // Floating label
          Positioned(
            top: 0,
            left: 16,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF746868),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
