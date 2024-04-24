import 'package:diary_fe/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Write extends StatefulWidget {
  const Write({super.key});

  @override
  State<Write> createState() => _WriteState();
}

class _WriteState extends State<Write> {
  DateTime selectedDate = DateTime.now(); // 선택된 날짜를 저장하는 변수, 기본값은 오늘 날짜

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      if (picked.isAfter(DateTime.now())) {
        // 선택된 날짜가 오늘 날짜보다 미래일 경우, 오늘 날짜로 설정합니다.
        setState(() {
          selectedDate = DateTime.now();
        });
      } else if (picked != selectedDate) {
        // 선택된 날짜가 오늘 날짜보다 과거일 경우, 그 날짜로 설정합니다.
        setState(() {
          selectedDate = picked;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _selectDate(context), // 날짜 선택 메서드 호출
                      child: const Icon(Icons.calendar_month),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  '오늘은 어떤일이 있었나요?',
                  style: TextStyle(
                    fontSize: 20,
                    color: themeColors.color1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  child: SizedBox(
                    height: keyboardHeight == 0 ? 370 : 180,
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: '자유롭게 일기를 작성해보세요.',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
