import 'package:celebrate_assignment/canvas_change_notifier.dart';
import 'package:celebrate_assignment/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:uuid/uuid.dart';

class CanvasesChangeNotifier extends ChangeNotifier {
  final _firebaseRepository = FirebaseRepository();
  List<CanvasChangeNotifier> canvases = [];
  int current = -1;

  void addCanvases() {
    canvases.add(CanvasChangeNotifier(id: Uuid().v1(), textItems: []));
    notifyListeners();
  }

  void loadFromFirebase() async {
    try {
      canvases = await _firebaseRepository.getCanvases();
      if (current == -1) {
        current = 0;
      }
    } on Exception catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> saveToFirestore() async {
    try {
      await _firebaseRepository.updateCanvases(canvases);
    } on Exception {
      dev.log('Exception');
      rethrow;
    }
  }

  void reorderCanvases(List<CanvasChangeNotifier> new_canvases) {
    canvases = new_canvases;
    notifyListeners();
  }

  void onAddText(TextItem item) {
    canvases[current].onAddText(item);
    notifyListeners();
  }

  void changeColor(Color color) {
    canvases[current].changeColor(color);
    notifyListeners();
  }

  void changePage(int idx) {
    current = idx;
    notifyListeners();
  }

  void removeText(int itemIdx) {
    canvases[current].removeText(itemIdx);
    notifyListeners();
  }

  void onDrag(int itemIdx, double dx, double dy) {
    canvases[current].onDrag(itemIdx, dx, dy);

    notifyListeners();
  }

  void onSelect(int itemIdx) {
    canvases[current].onSelect(itemIdx);
    notifyListeners();
  }

  void clearSelect() {
    canvases[current].clearSelect();
    notifyListeners();
  }

  void increaseSize() {
    canvases[current].increaseSize();
    notifyListeners();
  }

  void decreaseSize() {
    canvases[current].decreaseSize();
    notifyListeners();
  }

  void setFont(String font) {
    canvases[current].setFont(font);
    notifyListeners();
  }

  void recordDrag(int itemIdx) {
    canvases[current].recordDrag(itemIdx);
  }

  void setText(String text, String newText) {
    canvases[current].setText(text, newText);
    notifyListeners();
  }

  void undo() {
    canvases[current].undo();
    notifyListeners();
  }

  void redo() {
    canvases[current].redo();
    notifyListeners();
  }
}
