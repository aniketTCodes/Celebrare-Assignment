import 'package:celebrate_assignment/canvas.dart';
import 'package:celebrate_assignment/canvas_change_notifier.dart';
import 'package:celebrate_assignment/canvases_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final notifier1 = CanvasChangeNotifier();
  final notifier2 = CanvasChangeNotifier();
  final notifier3 = CanvasChangeNotifier();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text("Canvas"),
          ),
          body: ChangeNotifierProvider(
            create: (context) => CanvasesChangeNotifier(),
            child: Consumer<CanvasesChangeNotifier>(builder: (context, value, child) {
              return PageView(
                children: value.canvases.map<Widget>((e) => MyCanvas(),).toList(),
                onPageChanged: (pageIdx) {
                  value.changePage(pageIdx);
                },
              );
            },),
          )),
    );
  }
}
