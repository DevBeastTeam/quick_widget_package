import 'package:flutter/material.dart';
import 'package:quicktoast/quicktoast.dart';
import 'package:quicktoast/widgets/DotLoader.dart';
import 'package:quicktoast/widgets/camera.dart';
import 'package:quicktoast/widgets/mainbutton.dart';
import 'package:quicktoast/widgets/tiktok.dart';

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
                  message: "Hello! This is QuickToast 😍",
                  backgroundColor: Colors.green,
                  durationInSeconds: 2,
                );
              },
              child: const Text("Show QuickToast"),
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
