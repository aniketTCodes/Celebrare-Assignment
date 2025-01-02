import 'package:flutter/material.dart';
import 'package:stack/stack.dart' as StackDS;

class CanvasChangeNotifier{
  List<TextItem?> textItems = [];
  int selected = -1;
  StackDS.Stack<Operation> undoStack = StackDS.Stack();
  StackDS.Stack<Operation> redoQueue = StackDS.Stack();

  void onAddText(TextItem item) {
    textItems.add(item);
    undoStack.push(Operation(
        idx: textItems.isEmpty ? 0 : textItems.length - 1, item: null));
  }

  void changeColor(Color newColor){
    if(selected == -1) return;
    undoStack.push(Operation(idx: selected, item: textItems[selected]));
    textItems[selected] = textItems[selected]!.copyWith(color: newColor);
  }

  void removeText(int itemIdx) {
    textItems[itemIdx] = null;
    undoStack.push(Operation(idx: itemIdx, item: null));
  }

  void onDrag(int itemIdx, double dx, double dy) {
    //undoStack.push(Operation(idx: itemIdx, item: textItems[itemIdx]));
    textItems[itemIdx]!.left += dx;
    textItems[itemIdx]!.top += dy;

  }

  void onSelect(int itemIdx) {
    selected = itemIdx;
  }

  void clearSelect() {
    selected = -1;
  }

  void increaseSize() {
    if (selected != -1 && textItems[selected]!.size < 32) {
      undoStack.push(
          Operation(idx: selected, item: textItems[selected]!.copyWith()));
      textItems[selected]!.size += 2;
    }
  }

  void decreaseSize() {
    if (selected != -1 && textItems[selected]!.size > 8) {
      undoStack.push(
          Operation(idx: selected, item: textItems[selected]!.copyWith()));
      textItems[selected]!.size -= 2;
    }
  }

  void setFont(String font) {
    if (selected == -1) return;
    undoStack
        .push(Operation(idx: selected, item: textItems[selected]!.copyWith()));
    textItems[selected]!.fontFamily = font;
  }

  void recordDrag(int itemIdx) {
    undoStack
        .push(Operation(idx: itemIdx, item: textItems[itemIdx]!.copyWith()));
  }

  void setText(String text, String newText) {
    if (selected == -1) return;
    TextItem item = TextItem(
        text: text,
        fontFamily: textItems[selected]!.fontFamily,
        size: textItems[selected]!.size,
        left: textItems[selected]!.left,
        top: textItems[selected]!.top,
        color: textItems[selected]!.color,
        isFocused: textItems[selected]!.isFocused);
    item.text = text;
    undoStack.push(Operation(idx: selected, item: item));
    textItems[selected]!.text = newText;
  }

  void undo() {
    if (undoStack.isNotEmpty) {
      final operation = undoStack.pop();
      redoQueue.push(Operation(
          idx: operation.idx, item: textItems[operation.idx]!.copyWith()));
      textItems[operation.idx] = operation.item;

    }
  }

  void redo() {
    if (redoQueue.isEmpty) return;
    final operation = redoQueue.pop();
    undoStack.push(Operation(
        idx: operation.idx, item: textItems[operation.idx]?.copyWith()));
    textItems[operation.idx] = operation.item;
  }
}

class TextItem {
  String text;
  String fontFamily;
  int size;
  double left;
  double top;
  Color color;
  bool isFocused;

  TextItem(
      {required this.text,
      required this.fontFamily,
      required this.size,
      required this.left,
      required this.top,
      required this.color,
      required this.isFocused});

  TextItem copyWith(
      {String? text,
      String? fontFamily,
      int? size,
      Color? color,
      double? left,
      double? top,
      bool? isFocused}) {
    return TextItem(
      color: color??this.color,
        text: text ?? this.text,
        fontFamily: fontFamily ?? this.fontFamily,
        size: size ?? this.size,
        left: left ?? this.left,
        top: top ?? this.top,
        isFocused: isFocused ?? this.isFocused);
  }
}

class Operation {
  final int idx;
  final TextItem? item;

  Operation({required this.idx, required this.item});
}

class Position {
  final double left;
  final double top;

  Position({required this.left, required this.top});
}

enum OperationType { addText, removeText, drag, changeText }
