import 'package:flutter/material.dart';

class CarouselElement extends StatelessWidget {
  final String imagePath;
  final String displayText;

  const CarouselElement({
    super.key,
    required this.imagePath,
    required this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
