import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const PasswordField({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscure = true; // untuk menyimpan status sembunyi/tampil

  @override
  Widget build(BuildContext context) {
    final screenWidth = widget.screenWidth;
    final screenHeight = widget.screenHeight;

    return TextField(
      obscureText: _isObscure,
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(
          fontSize: screenWidth * 0.04,
          color: const Color(0xFF787A95),
        ),
        filled: true,
        fillColor: const Color(0xFF1b1e3f),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
          horizontal: screenWidth * 0.055,
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.04),
          child: IconButton(
            icon: Icon(
              _isObscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: const Color(0xFF585a74),
              size: screenWidth * 0.06,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure; // ubah status
              });
            },
          ),
        ),
      ),
      style: TextStyle(
        fontSize: screenWidth * 0.035,
        color: const Color(0xFF787A95),
      ),
    );
  }
}
