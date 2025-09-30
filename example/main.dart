import 'package:flutter/material.dart';
import 'package:quicktoast/quicktoast.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuickToastDemoPage(), // 👈 yahan () lagana zaroori hai
    ),
  );
}

// apna package import karo

class QuickToastDemoPage extends StatefulWidget {
  const QuickToastDemoPage({super.key});

  @override
  State<QuickToastDemoPage> createState() => _QuickToastDemoPageState();
}

class _QuickToastDemoPageState extends State<QuickToastDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QuickToast Example 🚀")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            QuickToast.show(
              context: context,
              message: "Hello! This is QuickToast 😍",
              backgroundColor: Colors.green,
              textColor: Colors.white,
              durationInSeconds: 3,
            );
          },
          child: const Text("Show QuickToast"),
        ),
      ),
    );
  }
}
