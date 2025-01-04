import 'package:celebrate_assignment/canvases_change_notifier.dart';
import 'package:celebrate_assignment/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCanvas extends StatelessWidget {
  void Function(Color widgetColor, String font) onWidgetSelect;
  MyCanvas({super.key, required this.onWidgetSelect});

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
                      onWidgetSelect(e.$2!.color, e.$2!.fontFamily);
                      //
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
      return Stack(fit: StackFit.expand, children: textWidgets);
    });
  }
}


List<String> fonts = ["roboto", "monospace", "serif", "sans-serif"];
