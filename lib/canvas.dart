import 'package:celebrate_assignment/canvas_change_notifier.dart';
import 'package:celebrate_assignment/canvases_change_notifier.dart';
import 'package:celebrate_assignment/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class MyCanvas extends StatefulWidget {
  const MyCanvas({super.key});

  @override
  State<MyCanvas> createState() => _MyCanvasState();
}

class _MyCanvasState extends State<MyCanvas> {
  late String font;
  late TextEditingController _controller;
  late Color pickerColor;

  @override
  void initState() {
    font = "roboto";
    pickerColor = Colors.black;
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasesChangeNotifier>(builder: (context, model, _) {
      final textWidgets =
          model.canvases[model.current].textItems.indexed.map<Widget>(
        (e) {
          return Builder(builder: (context) {
            if (e.$2 != null) {
              return Positioned(
                left: e.$2!.left,
                top: e.$2!.top,
                child: GestureDetector(
                    onTap: () {
                      model.onSelect(e.$1);
                      setState(() {
                        pickerColor = e.$2!.color;
                        font = e.$2!.fontFamily;
                      });
                    },
                    onPanUpdate: (details) {
                      model.onDrag(e.$1, details.delta.dx, details.delta.dy);
                    },
                    onPanStart: (details) {
                      model.recordDrag(e.$1);
                    },
                    child: MyEditableText(
                      initialText: e.$2!.text,
                      isSelected:
                          model.canvases[model.current].selected == e.$1,
                      onTexTChange: (text, newText) {
                        model.setText(text, newText);
                      },
                      textStyle: TextStyle(
                          fontSize: e.$2!.size.toDouble(),
                          fontFamily: e.$2!.fontFamily,
                          color: e.$2!.color),
                    )),
              );
            } else {
              return SizedBox.shrink();
            }
          });
        },
      ).toList();
      return TapRegion(
        onTapOutside: (event) {
          model.clearSelect();
        },
        child: Stack(
          fit: StackFit.expand,
          children: textWidgets +
              [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton.extended(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.black,
                              onPressed: () {
                                model.onAddText(TextItem(
                                  text: "text",
                                  fontFamily: "roboto",
                                  size: 32,
                                  left: 0,
                                  color: Colors.black,
                                  top: 0,
                                  isFocused: true,
                                ));
                              },
                              label: Text("Add Text"),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 16.0,
                                ),
                                FloatingActionButton.extended(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.blue,
                                    onPressed: () {
                                      model.increaseSize();
                                    },
                                    label: Text("+")),
                                SizedBox(
                                  width: 2.0,
                                ),
                                FloatingActionButton.extended(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.blue,
                                    onPressed: () {
                                      model.decreaseSize();
                                    },
                                    label: Text("-")),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<String>(
                              value: font,
                              items: fonts
                                  .map<DropdownMenuItem<String>>(
                                      (String e) => DropdownMenuItem<String>(
                                            value: e,
                                            child: Text(e),
                                          ))
                                  .toList(),
                              onChanged: (value) {
                                model.setFont(value ?? 'roboto');
                                setState(() {
                                  font = value ?? 'roboto';
                                });
                              },
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 16.0,
                                ),
                                FloatingActionButton.extended(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.blue,
                                    onPressed: () {
                                      model.undo();
                                    },
                                    label: Icon(Icons.undo)),
                                SizedBox(
                                  width: 2.0,
                                ),
                                FloatingActionButton.extended(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.blue,
                                    onPressed: () {
                                      model.redo();
                                    },
                                    label: Icon(Icons.redo)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        FloatingActionButton.extended(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.black,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Pick Color"),
                                  content: ColorPicker(
                                    pickerColor: pickerColor,
                                    onColorChanged: (value) {
                                      model.changeColor(value);
                                    },
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
                              },
                            );
                          },
                          label: Row(
                            children: [Icon(Icons.brush), Text("Color")],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
        ),
      );
    });
  }
}

List<String> fonts = ["roboto", "monospace", "serif", "sans-serif"];
