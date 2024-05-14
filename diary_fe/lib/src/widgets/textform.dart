import 'package:diary_fe/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextForm extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? errorText;
  final Widget? suffix;

  const TextForm({
    super.key,
    required this.title,
    required this.controller,
    this.errorText,
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
          color: ThemeColors.color1,
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
        errorText: errorText, // 에러 텍스트를 여기에 추가
      ),
      obscureText: title.contains('비밀번호'),
      inputFormatters: title.contains('비밀번호')
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^[\x00-\x7F]+$')),
            ]
          : [],
    );
  }
}
