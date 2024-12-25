import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:stack/stack.dart' as StackDS;

class CanvasChangeNotifier extends ChangeNotifier {
  List<TextItem?> textItems = [];
  int selected = -1;
  StackDS.Stack<Operation> undoStack = StackDS.Stack();
  StackDS.Stack<Operation> redoQueue = StackDS.Stack();

  void onAddText(TextItem item) {
    textItems.add(item);
    undoStack.push(Operation(
        idx: textItems.isEmpty ? 0 : textItems.length - 1, item: null));
    notifyListeners();
  }

  void removeText(int itemIdx) {
    textItems[itemIdx] = null;
    undoStack.push(Operation(idx: itemIdx, item: null));
    notifyListeners();
  }

  void onDrag(int itemIdx, double dx, double dy) {
    //undoStack.push(Operation(idx: itemIdx, item: textItems[itemIdx]));
    textItems[itemIdx]!.left += dx;
    textItems[itemIdx]!.top += dy;

    notifyListeners();
  }

  void onSelect(int itemIdx) {
    selected = itemIdx;
    notifyListeners();
  }

  void clearSelect() {
    selected = -1;
    notifyListeners();
  }

  void increaseSize() {
    if (selected != -1 && textItems[selected]!.size < 32) {
      undoStack.push(
          Operation(idx: selected, item: textItems[selected]!.copyWith()));
      textItems[selected]!.size += 2;
    }
    notifyListeners();
  }

  void decreaseSize() {
    if (selected != -1 && textItems[selected]!.size > 8) {
      undoStack.push(
          Operation(idx: selected, item: textItems[selected]!.copyWith()));
      textItems[selected]!.size -= 2;
    }
    notifyListeners();
  }

  void setFont(String font) {
    if (selected == -1) return;
    undoStack
        .push(Operation(idx: selected, item: textItems[selected]!.copyWith()));
    textItems[selected]!.fontFamily = font;
    notifyListeners();
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
        isFocused: textItems[selected]!.isFocused);
    item.text = text;
    undoStack.push(Operation(idx: selected, item: item));
    textItems[selected]!.text = newText;
    notifyListeners();
  }

  void undo() {
    if (undoStack.isNotEmpty) {
      final operation = undoStack.pop();
      redoQueue.push(Operation(
          idx: operation.idx, item: textItems[operation.idx]!.copyWith()));
      textItems[operation.idx] = operation.item;
      notifyListeners();
    }
  }

  void redo() {
    if (redoQueue.isEmpty) return;
    final operation = redoQueue.pop();
    undoStack.push(Operation(
        idx: operation.idx, item: textItems[operation.idx]?.copyWith()));
    textItems[operation.idx] = operation.item;
    notifyListeners();
  }
}

class TextItem {
  String text;
  String fontFamily;
  int size;
  double left;
  double top;
  bool isFocused;

  TextItem(
      {required this.text,
      required this.fontFamily,
      required this.size,
      required this.left,
      required this.top,
      required this.isFocused});

  TextItem copyWith(
      {String? text,
      String? fontFamily,
      int? size,
      double? left,
      double? top,
      bool? isFocused}) {
    return TextItem(
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
