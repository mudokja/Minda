import 'package:flutter/material.dart';

// 감정 색상 설명을 토글하는 위젯
class ColorLegendToggle extends StatefulWidget {
  const ColorLegendToggle({super.key});

  @override
  _ColorLegendToggleState createState() => _ColorLegendToggleState();
}

class _ColorLegendToggleState extends State<ColorLegendToggle> {
  bool _showLegend = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _showLegend = !_showLegend; // 토글 상태 변경
            });
          },
          child: Text(
            _showLegend ? '감정 색상 설명 숨기기' : '감정 색상 설명 보기',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_showLegend)
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFF5AC25), // 기쁨에 노랑
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 기쁨       ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFBC7FCD), // 슬픔에 연보라
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 슬픔       ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    // color: Color(0xFFB3B4B4), // 불안에 회색
                    color: Color(0xFF86469C), // 불안에 진보라
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 불안\n",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFDF1E1E), // 분노에 빨강
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 분노       ",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
                // TextSpan(
                //   text: "●",
                //   style: TextStyle(
                //     color: Color(0xFF86469C), // 상처에 진보라
                //     fontSize: 24,
                //   ),
                // ),
                // TextSpan(
                //   text: " : 상처       ",
                //   style: TextStyle(
                //     color: Color.fromARGB(255, 122, 122, 122),
                //     fontSize: 16,
                //   ),
                // ),
                TextSpan(
                  text: "●",
                  style: TextStyle(
                    color: Color(0xFFFC819E), // 놀람에 핑크
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: " : 놀람",
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}