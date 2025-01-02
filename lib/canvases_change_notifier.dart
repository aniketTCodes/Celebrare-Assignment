import 'package:celebrate_assignment/canvas_change_notifier.dart';
import 'package:flutter/material.dart';

class CanvasesChangeNotifier  extends ChangeNotifier{
  List<CanvasChangeNotifier> canvases = [
    CanvasChangeNotifier(),
    CanvasChangeNotifier(),
    CanvasChangeNotifier()
  ];
  int current = 0;

  void onAddText(TextItem item) {
    canvases[current].onAddText(item);
    notifyListeners();
  }

  void changeColor(Color color){
    canvases[current].changeColor(color);
    notifyListeners();
  }

  void changePage(int idx){
    current = idx;
    notifyListeners();
  }

  void removeText(int itemIdx) {
    canvases[current].removeText(itemIdx);
    notifyListeners();
  }

  void onDrag(int itemIdx, double dx, double dy) {
    canvases[current].onDrag(itemIdx,dx,dy);

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
    canvases[current].setText(text,newText);
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