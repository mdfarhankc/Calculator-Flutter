import 'package:calculator/screens/history_screen.dart';
import 'package:calculator/screens/settings_screen.dart';
import 'package:calculator/widgets/calculator_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:calculator/controllers/calculator_controller.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = CalculatorController();
  bool isDeleting = false;
  double slideOffset = 0;

  void handleButtonTap(String value) {
    HapticFeedback.lightImpact();

    setState(() {
      if (value == 'AC') {
        controller.clear();
      } else if (value == '=') {
        controller.calculateResult();
      } else if (value == '+/-') {
        controller.toggleSign();
      } else if (value == '%') {
        controller.applyPercentage();
      } else if (value == 'calc') {
        return;
      } else {
        controller.append(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: calculatorAppbar(),
      body: calculatorBody(),
    );
  }

  // ------------ Appbar ---------------------
  PreferredSizeWidget calculatorAppbar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.history),
        color: widget.isDarkMode ? Colors.white : Colors.black,
        onPressed: () {
          HapticFeedback.lightImpact();
          showCupertinoModalBottomSheet(
            context: context,
            backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
            expand: false,
            // Keeps draggable behavior
            topRadius: Radius.circular(30),
            builder:
                (context) => DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.3,
                  maxChildSize: 0.9,
                  expand: false,
                  snap: true,
                  // Important for snapping effect
                  snapSizes: [0.3, 0.5, 0.9],
                  // Breakpoints at 30%, 50%, 90%
                  builder: (context, scrollController) {
                    return HistoryScreen(
                      controller: controller,
                      isDarkMode: widget.isDarkMode,
                      scrollController: scrollController,
                    );
                  },
                ),
          );
        },
      ),
      title: const Text("Calculator"),
      centerTitle: true,
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          color: widget.isDarkMode ? Colors.white : Colors.black,
          onPressed: () {
            HapticFeedback.lightImpact();
            widget.onThemeToggle();
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          color: widget.isDarkMode ? Colors.white : Colors.black,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        SettingsScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  // Example: Slide from Bottom Animation
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ------------ Body ---------------------
  Widget calculatorBody() {
    final buttonRows = [
      ['AC', '+/-', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['calc', '0', '.', '='],
    ];
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // -------------------- Expression ------------------------
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < 0) {
                  // Swipe Left → Delete Last Character with Animation
                  setState(() {
                    isDeleting = true;
                    slideOffset = -0.2;
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    setState(() {
                      controller.deleteLast();
                      isDeleting = false;
                      slideOffset = 0;
                    });
                  });
                  HapticFeedback.lightImpact();
                } else if (details.primaryVelocity! > 0) {
                  // Swipe Right → All Clear with Animation
                  setState(() {
                    isDeleting = true;
                    slideOffset = 0.2;
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    setState(() {
                      controller.clear();
                      isDeleting = false;
                      slideOffset = 0;
                    });
                  });
                  HapticFeedback.lightImpact();
                }
              }
            },
            child: AnimatedSlide(
              offset: isDeleting ? Offset(slideOffset, 0) : Offset.zero,
              duration: const Duration(milliseconds: 150),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isDeleting ? 0.3 : 1,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(24),
                  child: Text(
                    controller.expression.isEmpty ? '0' : controller.expression,
                    style: TextStyle(
                      color:
                          widget.isDarkMode ? Colors.white70 : Colors.black87,
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // --------------------------------- RESULT -------------------------------------------------
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child:
                  controller.hasResult
                      ? Text(
                        controller.result,
                        key: ValueKey(controller.result),
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 10),
          // -------------------------- Buttons ----------------------------------------------------
          for (var row in buttonRows)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  row.map((btn) {
                    return CalcButton(
                      text: btn,
                      isDarkMode: widget.isDarkMode,
                      onTap: () => handleButtonTap(btn),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }
}
