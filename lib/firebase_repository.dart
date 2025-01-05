import 'package:celebrate_assignment/canvas_change_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class FirebaseRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  Future<List<CanvasChangeNotifier>> getCanvases() async {
    List<CanvasChangeNotifier> canvasesList = [];
    try {
      final canvases = await _fireStore
          .collection('canvases')
          .get(GetOptions(source: Source.server));
      for (var canvasDoc in canvases.docs) {
        canvasesList.add(
            CanvasChangeNotifier.fromFirestore(canvasDoc.id, canvasDoc.data()));
      }
      return canvasesList.toList();
    } on Exception catch (e) {
      dev.log(e.toString());
      return [];
    }
  }

  Future<void> updateCanvases(List<CanvasChangeNotifier> canvases) async {
    try {
      for (var canvas in canvases) {
        await _fireStore
            .collection('canvases')
            .doc(canvas.id)
            .set(canvas.toFireStore());
      }
    } on Exception catch (e) {
      dev.log(e.toString());
    }
  }
}
