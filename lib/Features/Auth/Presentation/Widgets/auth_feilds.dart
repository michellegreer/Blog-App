import 'package:flutter/material.dart';

class AuthFeilds extends StatelessWidget {
  final String? hint;
  final bool isVisible;
  final IconData? visibilityIcon;
  final VoidCallback? callback;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const AuthFeilds({
    super.key,
    this.hint,
    required this.controller,
    this.isVisible = false,
    this.visibilityIcon,
    this.callback,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(
            onPressed: callback,
            icon: Icon(visibilityIcon),
          ),
        ),
        validator: validator ?? (value) {
          if (value!.isEmpty) return '$hint is missing';
          return null;
        },
        obscureText: isVisible,
      ),
    );
  }
}
