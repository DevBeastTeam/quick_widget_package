# Quick Widgets

- Can called modiefied widgets like , loaders, toast, quick button, camera widgets, 
- With just a single import, you get access to multiple utilities like loaders, toasts, camera integration, and more.


## ✨ Features

- **QuickToast** → Show simple, customizable toast/snackbar messages  
- **DotLoader** → Animated 3-dot bouncing loader  
- **CameraApp2 (QuickCamera)** → Full camera widget with photo & video capture  
- **QuickButton** → Stylish button with customizable styles and loading state  
- **TikTokProgressLoader** → Smooth animated progress bar inspired by TikTok  

---

## Getting Started

Add this package in your `pubspec.yaml`:

```yaml
dependencies:
  quick_widgets: ^0.0.1
```

## Example Widgets

```dart
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
```