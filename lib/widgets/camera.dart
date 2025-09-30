import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

/// QuickCamera is the Main Application.
class QuickCamera extends StatefulWidget {
  /// Callback function that gets called when an image or video is captured
  /// Parameters: type (String) - either 'image' or 'video', file (File) - the captured file
  final Function(String type, File file)? onCaptured;

  /// Whether to automatically go back after capturing
  final bool autoBackOnCapture;

  /// Default Constructor
  const QuickCamera({
    super.key,
    this.onCaptured,
    this.autoBackOnCapture = true,
  });

  @override
  State<QuickCamera> createState() => _QuickCameraState();
}

class _QuickCameraState extends State<QuickCamera>
    with TickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  String? _errorMessage;
  int _selectedCameraIndex = 0;
  bool _isRecording = false;
  double _currentZoom = 1.0;
  double _maxZoom = 1.0;
  double _minZoom = 1.0;
  final List<String> _capturedFiles = [];
  bool _showFiles = false;
  final ImagePicker _imagePicker = ImagePicker();

  // Recording timer variables
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  String _recordingTimeDisplay = '00:00';

  // Animation controllers
  late AnimationController _recordingAnimationController;
  late Animation<double> _recordingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _recordingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device';
        });
        return;
      }

      await _initializeCameraController();
    } catch (e) {
      print('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  Future<void> _initializeCameraController() async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller!.initialize();

      if (!mounted) return;

      // Get zoom levels
      _maxZoom = await controller!.getMaxZoomLevel();
      _minZoom = await controller!.getMinZoomLevel();
      _currentZoom = _minZoom;

      // Lock orientation to portrait for better UX
      await controller!.lockCaptureOrientation();

      setState(() {
        _isInitialized = true;
        _errorMessage = null;
      });
    } catch (e) {
      print('Controller initialization error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera error: ${e.toString()}';
          _isInitialized = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) {
      _showSnackBar('Only one camera available');
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    await _initializeCameraController();
  }

  Future<void> _setZoom(double zoom) async {
    if (controller != null && _isInitialized) {
      try {
        await controller!.setZoomLevel(zoom);
        setState(() {
          _currentZoom = zoom;
        });
      } catch (e) {
        print('Zoom error: $e');
      }
    }
  }

  Future<String> _getFilePath(String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'camera_$timestamp.$extension';
    return path.join(directory.path, fileName);
  }

  Future<void> _takePicture() async {
    if (controller == null || !_isInitialized || _isRecording) return;

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      final XFile photo = await controller!.takePicture();
      final String newPath = await _getFilePath('jpg');

      // Copy file to permanent location
      final File originalFile = File(photo.path);
      final File savedFile = await originalFile.copy(newPath);

      setState(() {
        _capturedFiles.insert(0, newPath); // Add to beginning of list
      });

      // Call the callback function if provided
      if (widget.onCaptured != null) {
        widget.onCaptured!('image', savedFile);
      }

      _showSnackBar('📸 Photo saved!', isSuccess: true);

      // Auto back navigation if enabled
      if (widget.autoBackOnCapture && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Photo capture error: $e');
      _showSnackBar('❌ Error taking photo: $e', isSuccess: false);
    }
  }

  void _startRecordingTimer() {
    _recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
        final minutes = _recordingSeconds ~/ 60;
        final seconds = _recordingSeconds % 60;
        _recordingTimeDisplay =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    setState(() {
      _recordingSeconds = 0;
      _recordingTimeDisplay = '00:00';
    });
  }

  Future<void> _startVideoRecording() async {
    if (controller == null || !_isInitialized || _isRecording) return;

    try {
      // Haptic feedback
      HapticFeedback.heavyImpact();

      await controller!.startVideoRecording();

      setState(() {
        _isRecording = true;
      });

      // Start animation and timer
      _recordingAnimationController.repeat(reverse: true);
      _startRecordingTimer();

      _showSnackBar('🎥 Recording started...', isSuccess: true);
    } catch (e) {
      print('Start recording error: $e');
      _showSnackBar('❌ Failed to start recording: $e', isSuccess: false);
    }
  }

  Future<void> _stopVideoRecording() async {
    if (controller == null || !_isRecording) return;

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      final XFile video = await controller!.stopVideoRecording();
      final String newPath = await _getFilePath('mp4');

      // Copy file to permanent location
      final File originalFile = File(video.path);
      final File savedFile = await originalFile.copy(newPath);

      setState(() {
        _isRecording = false;
        _capturedFiles.insert(0, newPath); // Add to beginning of list
      });

      // Stop animation and timer
      _recordingAnimationController.stop();
      _recordingAnimationController.reset();
      _stopRecordingTimer();

      // Call the callback function if provided
      if (widget.onCaptured != null) {
        widget.onCaptured!('video', savedFile);
      }

      _showSnackBar('✅ Video saved! ($_recordingTimeDisplay)', isSuccess: true);

      // Auto back navigation if enabled
      if (widget.autoBackOnCapture && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Stop recording error: $e');
      setState(() {
        _isRecording = false;
      });
      _recordingAnimationController.stop();
      _recordingAnimationController.reset();
      _stopRecordingTimer();
      _showSnackBar('❌ Error saving video: $e', isSuccess: false);
    }
  }

  Future<void> _pickFromGallery(String mediaType) async {
    try {
      XFile? pickedFile;

      if (mediaType == 'image') {
        pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
      } else {
        pickedFile = await _imagePicker.pickVideo(
          source: ImageSource.gallery,
        );
      }

      if (pickedFile != null) {
        final File selectedFile = File(pickedFile.path);

        if (widget.onCaptured != null) {
          widget.onCaptured!(mediaType, selectedFile);
        }

        _showSnackBar(
          mediaType == 'image'
              ? '📷 Image selected from gallery!'
              : '🎥 Video selected from gallery!',
          isSuccess: true,
        );

        if (widget.autoBackOnCapture && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Gallery picker error: $e');
      _showSnackBar('❌ Error picking from gallery: $e', isSuccess: false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isSuccess ? Colors.green.shade600 : Colors.red.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      width: 40,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentZoom.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: _currentZoom,
                min: _minZoom,
                max: _maxZoom,
                divisions: 20,
                onChanged: _setZoom,
                activeColor: Colors.white,
                inactiveColor: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery Image button
          _buildControlButton(
            icon: Icons.photo,
            onPressed: () => _pickFromGallery('image'),
            backgroundColor: Colors.blue.shade600,
            size: 50,
          ),

          // Take photo button (main button)
          GestureDetector(
            onTap: _isRecording ? null : _takePicture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.grey.shade600 : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                color: _isRecording ? Colors.white54 : Colors.black,
                size: 40,
              ),
            ),
          ),

          // Video record button (start/stop)
          GestureDetector(
            onTap: _isRecording ? _stopVideoRecording : _startVideoRecording,
            child: AnimatedBuilder(
              animation: _recordingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _recordingAnimation.value : 1.0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.videocam,
                      color: _isRecording ? Colors.white : Colors.red,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),

          // Gallery Video button
          _buildControlButton(
            icon: Icons.video_library,
            onPressed: () => _pickFromGallery('video'),
            backgroundColor: Colors.red.shade600,
            size: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            _buildControlButton(
              icon: Icons.arrow_back,
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              backgroundColor: Colors.black54,
              size: 40,
            ),

            // Camera switch button
            if (_cameras.length > 1)
              _buildControlButton(
                icon: Icons.flip_camera_ios,
                onPressed: _switchCamera,
                backgroundColor: Colors.black54,
                size: 40,
              ),

            // Recording indicator with timer
            if (_isRecording)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'REC $_recordingTimeDisplay',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Flash toggle
            _buildControlButton(
              icon: Icons.flash_auto,
              onPressed: () {
                HapticFeedback.lightImpact();
                _showSnackBar('Flash control coming soon!');
              },
              backgroundColor: Colors.black54,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFiles ? 250 : 0,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Captured Files (${_capturedFiles.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _showFiles = false;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: _capturedFiles.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined,
                            color: Colors.white54, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'No files captured yet',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _capturedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _capturedFiles[index];
                      final fileName = path.basename(file);
                      final isVideo = fileName.endsWith('.mp4');

                      return Card(
                        color: Colors.white12,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isVideo
                                  ? Colors.red.shade600
                                  : Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isVideo ? Icons.video_file : Icons.photo,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            fileName,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            isVideo ? 'Video file' : 'Photo file',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _deleteFile(index, file);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                          onTap: () {
                            _showSnackBar('File: $fileName');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _deleteFile(int index, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title:
              const Text('Delete File', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete this file?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _capturedFiles.removeAt(index);
                });
                try {
                  File(filePath).deleteSync();
                  _showSnackBar('🗑️ File deleted', isSuccess: true);
                } catch (e) {
                  _showSnackBar('❌ Error deleting file', isSuccess: false);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recordingAnimationController.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCameraWidget();
  }

  Widget _buildCameraWidget() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitialized = false;
                  });
                  _initializeCamera();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Initializing camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Get camera preview size for full screen
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Stack(
      children: [
        // Full screen camera preview
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width / 3,
              height: size.width / controller!.value.aspectRatio,
              child: CameraPreview(controller!),
            ),
          ),
        ),

        // Top controls overlay
        _buildTopControls(),

        // Zoom controls on the right
        Positioned(
          right: 8,
          top: 120,
          bottom: 200,
          child: _buildZoomControls(),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: _buildControlButtons(),
          ),
        ),

        // Files list overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildFilesList(),
        ),
      ],
    );
  }
}
