import 'package:diary_fe/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextForm extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const TextForm({
    super.key,
    required this.title,
    required this.controller,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: TextStyle(
          color: themeColors.color1,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 10.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: suffix,
      ),
      obscureText: title == '비밀번호' || title == '비밀번호 확인',
      inputFormatters: title == '비밀번호'
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^[\x00-\x7F]+$')),
            ]
          : [],
      validator: validator, // validator 적용
    );
  }
}
