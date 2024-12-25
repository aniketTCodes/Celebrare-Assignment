import 'package:flutter/material.dart';

class MyEditableText extends StatefulWidget {
  final String initialText;
  final TextStyle? textStyle;
  final ValueChanged<String>? onTextChanged;
  final bool isSelected;
  final Function(String prevText, String newText) onTexTChange;

  const MyEditableText(
      {super.key,
      required this.initialText,
      this.textStyle,
      this.onTextChanged,
      required this.isSelected,
      required this.onTexTChange});

  @override
  State<MyEditableText> createState() => _MyEditableTextState();
}

class _MyEditableTextState extends State<MyEditableText> {
  late TextEditingController _controller;
  bool _isEditing = false;
  late String prevValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    prevValue = _controller.text;
    _controller.addListener(
      () {},
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSelected) {
      setState(() {
        _isEditing = false;
      });
    }
    _controller.text = widget.initialText;
    return IntrinsicWidth(
      child: Container(
        color: widget.isSelected
            ? Color.fromARGB(150, 128, 128, 128)
            : Colors.transparent,
        child: GestureDetector(
          onDoubleTap: () => setState(() => _isEditing = true),
          child: _isEditing
              ? TextField(
                  controller: _controller,
                  autofocus: true,
                  style: widget.textStyle,
                  onSubmitted: (value) {
                    setState(() => _isEditing = false);
                    widget.onTextChanged?.call(value);
                  },
                  onChanged: (value) {
                    _controller.text = value;
                    widget.onTexTChange(prevValue, value);
                    setState(() {
                      prevValue = value;
                    });
                  },
                  onEditingComplete: () {
                    setState(() => _isEditing = false);
                    widget.onTextChanged?.call(_controller.text);
                  },
                )
              : Text(
                  widget.initialText,
                  style: widget.textStyle,
                ),
        ),
      ),
    );
  }
}
