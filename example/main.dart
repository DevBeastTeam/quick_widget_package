import 'package:flutter/material.dart';
import 'package:quick_widgets/quicktoast.dart';
import 'package:quick_widgets/widgets/DotLoader.dart';
import 'package:quick_widgets/widgets/camera.dart';
import 'package:quick_widgets/widgets/mainbutton.dart';
import 'package:quick_widgets/widgets/tiktok.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: quick_widgetsDemoPage(), // 👈 yahan () lagana zaroori hai
    ),
  );
}

// apna package import karo

class quick_widgetsDemoPage extends StatefulWidget {
  const quick_widgetsDemoPage({super.key});

  @override
  State<quick_widgetsDemoPage> createState() => _quick_widgetsDemoPageState();
}

class _quick_widgetsDemoPageState extends State<quick_widgetsDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("quick_widgets Example 🚀")),
      body: Column(
        children: [
          // 1. tiktok loader
          const QuickTikTokLoader(),

          // 2. dot loader
          const QuickDotLoader(),

          // 3. open camera image capture, video recorder

          Center(
            child: ElevatedButton(
              onPressed: () async {
                var fileType = "";
                var filePath = "";
                // Open QuickCamera as a full-screen dialog instead of navigation
                await showDialog(
                  context: context,
                  builder: (context) => QuickCamera(
                    autoBackOnCapture: true, // will close automatically
                    onCaptured: (capturedType, file) async {
                      fileType = capturedType;
                      filePath = file.path;
                    },
                  ),
                );
                if (filePath.isEmpty) {
                  print('not captured');
                } else {
                  print("fileType:$fileType");
                  print("filePath:$filePath");
                }
              },
              child: const Text("Open Camera"),
            ),
          ),

          // 4. show toast
          Center(
            child: ElevatedButton(
              onPressed: () {
                Quick.toast(
                  context: context,
                  message: "Hello! This is quick_widgets 😍",
                  backgroundColor: Colors.green,
                  durationInSeconds: 2,
                );
              },
              child: const Text("Show quick_widgets"),
            ),
          ),

// 5. quick button
          QuickButton(
            onPressed: () {},
            text: "Quick Button",
          ),
        ],
      ),
    );
  }
}
