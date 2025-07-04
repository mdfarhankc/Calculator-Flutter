import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String text;
  final bool isDarkMode;
  final VoidCallback onTap;

  const CalcButton({
    super.key,
    required this.text,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isCalc = text == 'calc';
    Color bgColor = const Color(0xFFA5A5A5);
    Color textColor = Colors.white;
    if (['AC', '+/-', '%'].contains(text)) {
      bgColor =
          isDarkMode
              ? const Color.fromARGB(255, 201, 201, 201)
              : const Color.fromARGB(255, 74, 74, 74);
      textColor = isDarkMode ? Colors.black : Colors.white;
    } else if (['÷', '×', '-', '+', '='].contains(text)) {
      bgColor = const Color(0xFFFF9F0A);
    } else {
      bgColor =
          isDarkMode
              ? const Color.fromARGB(255, 74, 74, 74)
              : const Color.fromARGB(255, 201, 201, 201);
      textColor = isDarkMode ? Colors.white : Colors.black;
    }

    return GestureDetector(
      onTap: () {
        if (isCalc) {
          final RenderBox button = context.findRenderObject() as RenderBox;
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;

          final Offset position = button.localToGlobal(
            Offset.zero,
            ancestor: overlay,
          );

          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy,
              position.dx + button.size.width,
              position.dy + button.size.height,
            ),
            items: [
              PopupMenuItem(
                value: 'scientific',
                child: Text('Scientific Mode'),
              ),
              PopupMenuItem(value: 'converter', child: Text('Unit Converter')),
              PopupMenuItem(
                value: 'currency',
                child: Text('Currency Converter'),
              ),
            ],
          ).then((selected) {
            if (selected != null) {
              // Handle selected option
              print("Selected: $selected");
            }
          });
        } else {
          onTap();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child:
              isCalc
                  ? Icon(Icons.calculate, size: 36, color: textColor)
                  : Text(
                    text,
                    style: TextStyle(fontSize: 28, color: textColor),
                  ),
        ),
      ),
    );
  }
}
