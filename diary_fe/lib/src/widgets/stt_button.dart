import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stt_provider.dart';

class STTButton extends StatelessWidget {
  final TextEditingController textController;

  const STTButton({super.key, required this.textController});

  @override
  Widget build(BuildContext context) {
    final sttProvider = Provider.of<STTProvider>(context);
    return IconButton(
      icon: Icon(sttProvider.isRecording ? Icons.mic_off : Icons.mic,
      color: sttProvider.isRecording? const Color.fromRGBO(100, 100, 100, 100):null,),
      onPressed: () => sttProvider.toggleRecording(textController),
    );
  }
}