import 'package:diary_fe/constants.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeColors.color1,
            ThemeColors.color2,
            ThemeColors.color3,
          ],
          stops: const [
            0.3,
            0.8,
            1.0,
          ],
        ),
      ),
    );
  }
}
