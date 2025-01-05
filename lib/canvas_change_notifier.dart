import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stack/stack.dart' as StackDS;
import 'package:uuid/uuid.dart';

class CanvasChangeNotifier {
  String id;
  List<TextItem?> textItems = [];
  int selected = -1;
  StackDS.Stack<Operation> undoStack = StackDS.Stack();
  StackDS.Stack<Operation> redoQueue = StackDS.Stack();

  factory CanvasChangeNotifier.fromFirestore(
      String id, Map<String, dynamic> doc) {
    return CanvasChangeNotifier(
      id: id,
      textItems: doc.isEmpty?[]:(doc['textItems'] as List)
          .map((item) => item != null ? TextItem.fromMap(item) : null)
          .toList(),
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'textItems': textItems
          .map(
            (e) => e?.toFirestore(),
          )
          .toList()
    };
  }

  CanvasChangeNotifier({required this.id, required this.textItems}) {
    textItems = textItems;
  }
  void onAddText(TextItem item) {
    textItems.add(item);
    undoStack.push(Operation(
        idx: textItems.isEmpty ? 0 : textItems.length - 1, item: null));
  }

  void changeColor(Color newColor) {
    if (selected == -1) return;
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
  final String id = Uuid().v1();
  String text;
  String fontFamily;
  int size;
  double left;
  double top;
  Color color;
  bool isFocused;

  factory TextItem.fromMap(Map<String, dynamic> map) {
    return TextItem(
      text: map['text'],
      fontFamily: map['fontFamily'],
      size: map['size'],
      left: map['left'] * 1.0,
      top: map['top'] * 1.0,
      color: Color.fromARGB((map['a']), map['r'], map['g'], map['b']),
      isFocused: false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'fontFamily': fontFamily,
      'size': size,
      'left': left,
      'top': top,
      'a': color.alpha,
      'r': color.red,
      'g': color.green,
      'b': color.blue,
    };
  }

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
        color: color ?? this.color,
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
