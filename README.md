# Skin Monitor Pro (Flutter + TFLite)

A modern, on-device **skin monitoring** app with camera capture, TFLite inference, history, and a sleek UI.

> ⚠️ **Medical Disclaimer**: This app is for **educational and research** purposes only and is **not** a medical device. Do not use it for diagnosis. Seek a qualified clinician for care.

## Features
- On-device inference (TensorFlow Lite).
- Camera capture or pick from gallery.
- Modern UI (glassmorphism, floating sidebar, doctor login modal).
- Local prediction history.
- Safe fallback when model asset is missing.
- Easily swappable labels and model.

## Quick Start
1. Ensure Flutter SDK is installed.
2. Create a Flutter project and replace files:
   ```bash
   flutter create skin_monitor_pro
   cd skin_monitor_pro
   ```
3. Replace the generated `lib/`, `assets/`, and `pubspec.yaml` with the ones from this zip.
4. Add required Android permissions to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA"/>
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   <uses-feature android:name="android.hardware.camera" android:required="false"/>
   ```
5. iOS: Add camera permission to `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We use the camera to analyze skin images.</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We use the photo library to pick images.</string>
   ```
6. Get dependencies & run:
   ```bash
   flutter pub get
   flutter run
   ```

## Model
- Put your TFLite model at: `assets/models/skin_classifier_quant.tflite`
- Edit classes in `assets/labels.txt` (one per line).
- Example two-class setup:
  ```
  Benign
  Malignant
  ```

## Notes
- If the model file is absent, the app **falls back** to a calibrated mock to let you verify the UX.
- Replace the placeholder model with a real TFLite exported from your training pipeline.
