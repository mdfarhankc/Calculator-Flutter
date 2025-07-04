import 'package:calculator/controllers/calculator_controller.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final bool isDarkMode;
  final CalculatorController controller;
  final ScrollController scrollController;

  const HistoryScreen({
    super.key,
    required this.isDarkMode,
    required this.controller,
    required this.scrollController,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final history = widget.controller.history.reversed.toList();

    return SafeArea(
      child: Material(
        child: Column(
          children: [
            // ------------------ Header -------------------------
            Padding(
              padding: const EdgeInsets.all(20),
              child: historyHeader(context),
            ),
            const Divider(height: 1),
            // ------------------ List -------------------------
            Expanded(child: historyBody(history)),
          ],
        ),
      ),
    );
  }

  // ------------------ Header -------------------------
  Widget historyHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "History",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        IconButton(
          color: widget.isDarkMode ? Colors.white : Colors.black,
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor:
                widget.isDarkMode ? Colors.grey[900] : Colors.white,
                title: Text(
                  "Clear History?",
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                content: Text(
                  "Are you sure you want to delete all history?",
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await widget.controller.clearHistory();
              setState(() {});
            }
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  // ------------------ Body -------------------------
  Widget historyBody(List<Map<String, String>> history) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text("No history yet."),
      );
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return ListTile(
          title: Text(
            item['expression'] ?? "",
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            item['result'] ?? "",
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          onTap: () {
            Navigator.pop(context, item['expression']);
          },
        );
      },
    );
  }
}
