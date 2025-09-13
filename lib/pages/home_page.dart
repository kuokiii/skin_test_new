import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/inference_service.dart';
import '../models/prediction.dart';
import '../services/history_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/doctor_login_dialog.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  CameraController? controller;
  final _picker = ImagePicker();
  final _inference = InferenceService();
  final _history = HistoryService();
  String _status = 'Ready';
  Prediction? _last;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final cameras = await availableCameras();
      controller = CameraController(cameras.first, ResolutionPreset.medium, enableAudio: false);
      await controller!.initialize();
      await _inference.init();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() { _status = 'Camera or model init failed: $e'; });
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (controller == null || !controller!.value.isInitialized) return;
    setState(() { _status = 'Analyzing...'; });
    final xfile = await controller!.takePicture();
    await _analyzeFile(File(xfile.path));
  }

  Future<void> _pickFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) await _analyzeFile(File(x.path));
  }

  Future<void> _analyzeFile(File file) async {
    final res = await _inference.classify(file);
    final pred = Prediction(
      label: res['label'],
      confidence: (res['confidence'] as num).toDouble(),
      imagePath: file.path,
      timestamp: DateTime.now(),
    );
    await _history.add(pred);
    if (mounted) {
      setState(() {
        _last = pred;
        _status = res['mock'] == true ? 'Mock result (replace model to enable real inference)' : 'Analysis complete';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Result: ${pred.label} (${(pred.confidence*100).toStringAsFixed(1)}%)')));
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FB),
      body: controller == null || !controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Live camera preview
                Positioned.fill(child: CameraPreview(controller!)),
                // Frosted overlay
                Positioned.fill(child: Container(color: Colors.black.withOpacity(0.35))),

                // Floating sidebar (left)
                Positioned(
                  left: 16,
                  top: size.height * 0.20,
                  child: Column(
                    children: [
                      FloatingActionButton(heroTag: 'home', onPressed: () {}, child: const Icon(Icons.home)),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: 'history',
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryPage())),
                        child: const Icon(Icons.history),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: 'doctor',
                        onPressed: () => showDialog(context: context, builder: (_) => const DoctorLoginDialog()),
                        child: const Icon(Icons.medical_services),
                      ),
                    ],
                  ),
                ),

                // Center glass card
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0,10))],
                      border: Border.all(color: Colors.white.withOpacity(0.6)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.health_and_safety, size: 64, color: Colors.blue),
                        const SizedBox(height: 6),
                        const Text('Skin Monitor Pro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.blue)),
                        const SizedBox(height: 4),
                        Text(_status, style: const TextStyle(color: Colors.black87)),
                        const SizedBox(height: 12),
                        if (_last != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text('Latest: ${_last!.label} — ${(_last!.confidence*100).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text(_last!.timestamp.toLocal().toString(), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GradientButton(onPressed: _captureAndAnalyze, child: const Row(children: [Icon(Icons.camera_alt), SizedBox(width:8), Text('Capture & Analyze')])),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(onPressed: _pickFromGallery, icon: const Icon(Icons.photo), label: const Text('Pick from gallery')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Disclaimer: This is not a medical device. For concerns, consult a clinician.', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
