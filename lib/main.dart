import 'dart:typed_data';

import 'package:celebrate_assignment/canvas.dart';
import 'package:celebrate_assignment/canvas_change_notifier.dart';
import 'package:celebrate_assignment/canvases_change_notifier.dart';
import 'package:celebrate_assignment/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:developer' as dev;

import 'package:screenshot/screenshot.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ChangeNotifierProvider<CanvasesChangeNotifier>(
          create: (context) => CanvasesChangeNotifier(),
          child: MyEditor(),
        ),
      ),
    );
  }
}

class MyEditor extends StatefulWidget {
  const MyEditor({super.key});

  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  late CarouselController _carouselController;
  late ScreenshotController _screenshotController;
  late List<Uint8List> _screenshots;
  late Color _color;
  late String _font;
  List<Widget> widgets = [];

  @override
  void initState() {
    _carouselController = CarouselController();
    _screenshotController = ScreenshotController();
    _color = Colors.black;
    _font = 'roboto';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 25),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () =>
                    Provider.of<CanvasesChangeNotifier>(context, listen: false)
                        .undo(),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Icon(
                    Icons.undo_sharp,
                    color: Colors.blue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Provider.of<CanvasesChangeNotifier>(context, listen: false)
                        .redo(),
                child: Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Icon(
                    Icons.redo_sharp,
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
          Expanded(
            flex: 3,
            child: Consumer<CanvasesChangeNotifier>(
                builder: (context, value, child) {
              widgets = value.canvases.map<Widget>(
                (e) {
                  return GestureDetector(
                    onTap: () {
                      Provider.of<CanvasesChangeNotifier>(context,
                              listen: false)
                          .clearSelect();
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: RepaintBoundary(
                        key: e.key,
                        child: MyCanvas(
                          onWidgetSelect: (value, selectedFont) {
                            setState(() {
                              _color = value;
                              _font = selectedFont;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ).toList();
              return PageView(
                onPageChanged: (pageIdx) {
                  value.changePage(pageIdx);
                },
                children: widgets,
              );
            }),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 50,
                width: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: fonts.map<Widget>(
                    (e) {
                      return Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              Provider.of<CanvasesChangeNotifier>(context,
                                      listen: false)
                                  .setFont(e);
                              setState(() {
                                _font = e;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 8, right: 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color:
                                      _font == e ? Colors.black : Colors.white,
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  "Aa",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: e == _font
                                        ? Colors.white
                                        : Colors.black,
                                    fontFamily: e,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          Provider.of<CanvasesChangeNotifier>(context,
                                  listen: false)
                              .onAddText(TextItem(
                                  text: "Text",
                                  fontFamily: 'roboto',
                                  size: 24,
                                  left: 0,
                                  top: 0,
                                  color: Colors.black,
                                  isFocused: false));
                        },
                        icon: Icon(Icons.add),
                      ),
                      TapRegion(
                        child: IconButton(
                          onPressed: () {
                            Provider.of<CanvasesChangeNotifier>(context,
                                    listen: false)
                                .increaseSize();
                          },
                          icon: Icon(Icons.text_increase),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Provider.of<CanvasesChangeNotifier>(context,
                                  listen: false)
                              .decreaseSize();
                        },
                        icon: Icon(Icons.text_decrease),
                      ),
                      GestureDetector(
                        onTap: () {
                          final model = Provider.of<CanvasesChangeNotifier>(
                              context,
                              listen: false);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Done"),
                                  )
                                ],
                                content: SizedBox(
                                  height: 600,
                                  width: 600,
                                  child: ColorPicker(
                                    pickerColor: _color,
                                    onColorChanged: (value) {
                                      model.changeColor(value);
                                      _color = value;
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            color: _color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final model = Provider.of<CanvasesChangeNotifier>(
                              context,
                              listen: false);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return FutureBuilder(
                                future: _captureScreenshots(model),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      return AlertDialog(
                                        title: const Text('Reorder Canvases'),
                                        content: ReorderCanvasWidget(
                                          model: model,
                                          screenshots: snapshot.data!,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Done'),
                                          )
                                        ],
                                      );
                                    }
                                  }
                                  return AlertDialog(
                                    title: Text('Reorder Canvases'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'))
                                    ],
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.reorder),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<List<Uint8List>> _captureScreenshots(
      CanvasesChangeNotifier canvasesNotifier) async {
    List<Uint8List> screenshots = [];
    for (var canvas in canvasesNotifier.canvases) {
      final textWidgets = canvas.textItems.indexed.map<Widget>(
        (e) {
          return Builder(builder: (context) {
            if (e.$2 != null) {
              return Positioned(
                left: e.$2!.left,
                top: e.$2!.top,
                child: MyEditableText(
                  initialText: e.$2!.text,
                  isSelected: false,
                  onTexTChange: (text, newText) {},
                  textStyle: TextStyle(
                      fontSize: e.$2!.size.toDouble(),
                      fontFamily: e.$2!.fontFamily,
                      color: e.$2!.color),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          });
        },
      ).toList();
      final controller = ScreenshotController();
      final widget = Screenshot(
        controller: controller,
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
          child: Stack(
            children: textWidgets,
          ),
        ),
      );
      final shot = await controller.captureFromWidget(widget);
      screenshots.add(shot);
    }
    return screenshots;
  }
}

class ReorderCanvasWidget extends StatefulWidget {
  final CanvasesChangeNotifier model;
  final List<Uint8List> screenshots;
  const ReorderCanvasWidget(
      {super.key, required this.model, required this.screenshots});

  @override
  State<ReorderCanvasWidget> createState() => _ReorderCanvasWidgetState();
}

class _ReorderCanvasWidgetState extends State<ReorderCanvasWidget> {
  late List<(int, CanvasChangeNotifier, Uint8List)> canvases = [];
  @override
  void initState() {
    canvases = widget.model.canvases.indexed
        .map(
          (e) => (e.$1, e.$2, widget.screenshots[e.$1]),
        )
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 600,
          height: 500,
          child: ReorderableListView(
            children: List.generate(
              canvases.length,
              (index) {
                return ListTile(
                  key: Key('$index'),
                  title: Row(
                    children: [
                      Text((canvases[index].$1 + 1).toString()),
                      Image(
                          width: 80,
                          height: 100,
                          image: MemoryImage(canvases[index].$3))
                    ],
                  ),
                  trailing: const Icon(Icons.drag_handle_sharp),
                );
              },
            ),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex--;
                }
                final canvas = canvases.removeAt(oldIndex);

                canvases.insert(newIndex, canvas);
                widget.model.reorderCanvases(canvases
                    .map(
                      (e) => e.$2,
                    )
                    .toList());
              });
            },
          ),
        ),
      ],
    );
  }
}
