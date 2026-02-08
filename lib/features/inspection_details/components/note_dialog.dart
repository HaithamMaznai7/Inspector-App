import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteInputDialog extends StatefulWidget {
  final String status;
  final String? note;

  const NoteInputDialog({super.key, required this.status, this.note});

  @override
  State<NoteInputDialog> createState() => _NoteInputDialogState();
}

class _NoteInputDialogState extends State<NoteInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.note ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.status == 'finished'
            ? 'Enter General Note'
            : 'Enter Rejection Note',
      ),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Type your note...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: _controller.text.trim()),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
