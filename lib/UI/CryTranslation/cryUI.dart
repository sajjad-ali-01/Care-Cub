// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:math'; // For sin, pi, floor, ceil
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// // If you find a good WAV parsing package from pub.dev, import it.
// // Example: import 'package:wav/wav.dart' as wav_parser;
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Baby Cry Analyzer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const CryCaptureScreen(),
//     );
//   }
// }
//
// class CryCaptureScreen extends StatefulWidget {
//   const CryCaptureScreen({super.key});
//
//   @override
//   State<CryCaptureScreen> createState() => _CryCaptureScreenState();
// }
//
// class _CryCaptureScreenState extends State<CryCaptureScreen> {
//   Interpreter? interpreter;
//   String? _pickedFilePath;
//   Map<String, double>? _predictionResults;
//   bool isProcessing = false;
//   String statusMessage = 'Please load a .wav audio file.';
//
//   // IMPORTANT: These must match your model's output
//   final List<String> _classNames = [
//     'Belly Pain',
//     'Burping',
//     'Discomfort',
//     'Hungry',
//     'Others',
//     'Tired'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }
//
//   Future<void> _loadModel() async {
//     setState(() {
//       statusMessage = 'Loading model...';
//     });
//     try {
//       interpreter = await Interpreter.fromAsset('assets/fmodel.tflite');
//       // Print model input/output details for debugging
//       print('Input Tensors: ${interpreter!.getInputTensors()}');
//       print('Output Tensors: ${interpreter!.getOutputTensors()}');
//       setState(() {
//         statusMessage = 'Model loaded. Ready to pick audio.';
//       });
//     } catch (e) {
//       print('Failed to load TFLite model: $e');
//       setState(() {
//         statusMessage = 'Error loading model: $e';
//       });
//       Fluttertoast.showToast(msg: 'Error loading model: $e');
//     }
//   }
//
//   Future<void> _requestPermissions() async {
//     PermissionStatus status = await Permission.storage.request();
//
//     if (status.isDenied) {
//       Fluttertoast.showToast(msg: "Storage permission denied.");
//       // You might want to open app settings here
//       // openAppSettings();
//     } else if (status.isPermanentlyDenied) {
//       Fluttertoast.showToast(msg: "Storage permission permanently denied. Please enable it in settings.");
//       openAppSettings();
//     }
//   }
//
//   Future<void> _pickAudioFile() async {
//     await _requestPermissions(); // Request permissions first
//
//     if (!(await Permission.storage.isGranted)) {
//       if (!(await Permission.storage.isGranted)){
//         Fluttertoast.showToast(msg: "Storage permission not granted.");
//         return;
//       }
//     }
//
//
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['wav'],
//       );
//
//       if (result != null && result.files.single.path != null) {
//         setState(() {
//           _pickedFilePath = result.files.single.path;
//           statusMessage = 'File selected: ${result.files.single.name}';
//           _predictionResults = null; // Clear previous results
//         });
//         _processAndPredict();
//       } else {
//         Fluttertoast.showToast(msg: "No file selected.");
//         setState(() {
//           statusMessage = 'File selection cancelled.';
//         });
//       }
//     } catch (e) {
//       print('Error picking file: $e');
//       Fluttertoast.showToast(msg: 'Error picking file: $e');
//       setState(() {
//         statusMessage = 'Error picking file: $e';
//       });
//     }
//   }
//   Future<Map<String, dynamic>> _decodeWavFile(String filePath) async {
//
//     // Using dummy data for now as a fallback for demonstration
//     print("⚠️ WARNING: Using DUMMY audio data. Implement _decodeWavFile for real functionality!");
//     await Future.delayed(const Duration(milliseconds: 100)); // Simulate async work
//     const int dummyOriginalSampleRate = 44100; // Common sample rate
//     const int dummyChannels = 1; // Assume mono
//     const int durationSeconds = 1; // 1 second of dummy audio
//     final int numSamples = dummyOriginalSampleRate * durationSeconds * dummyChannels;
//     final Random random = Random();
//     // Generate simple sine wave dummy audio normalized to [-0.5, 0.5]
//     final List<double> dummySamples = List.generate(numSamples,
//             (i) => sin(2 * pi * 440 * i / dummyOriginalSampleRate) * 0.5);
//
//     return {
//       'samples': dummySamples,
//       'sampleRate': dummyOriginalSampleRate,
//       'channels': dummyChannels,
//     };
//   }
//
//   Future<Float32List?> _preprocessAudio(String filePath) async {
//     try {
//       // Read the file
//       final file = File(filePath);
//       final bytes = await file.readAsBytes();
//
//       // Parse WAV header (44 bytes)
//       if (bytes.length < 44) throw Exception("Invalid WAV file (too short)");
//
//       // Check if it's a valid WAV file
//       if (String.fromCharCodes(bytes.sublist(0, 4)) != "RIFF" ||
//           String.fromCharCodes(bytes.sublist(8, 12)) != "WAVE") {
//         throw Exception("Invalid WAV file format");
//       }
//
//       // Extract audio format (1 for PCM)
//       final audioFormat = bytes.sublist(20, 22);
//       if (audioFormat[0] != 1 || audioFormat[1] != 0) {
//         throw Exception("Only PCM format supported");
//       }
//
//       // Get number of channels (1 for mono, 2 for stereo)
//       final numChannels = bytes[22];
//
//       // Get sample rate (e.g., 44100)
//       final sampleRate = bytes.sublist(24, 28);
//       final sampleRateInt = sampleRate[0] |
//       sampleRate[1] << 8 |
//       sampleRate[2] << 16 |
//       sampleRate[3] << 24;
//
//       // Get bits per sample (16 for 16-bit PCM)
//       final bitsPerSample = bytes[34] | (bytes[35] << 8);
//       if (bitsPerSample != 16) throw Exception("Only 16-bit PCM supported");
//
//       // Find the data chunk
//       int dataOffset = 36;
//       while (dataOffset + 8 < bytes.length &&
//           String.fromCharCodes(bytes.sublist(dataOffset, dataOffset+4)) != "data") {
//         final chunkSize = bytes[dataOffset+4] |
//         bytes[dataOffset+5] << 8 |
//         bytes[dataOffset+6] << 16 |
//         bytes[dataOffset+7] << 24;
//         dataOffset += 8 + chunkSize;
//       }
//
//       if (dataOffset + 8 >= bytes.length) throw Exception("No data chunk found");
//
//       final dataSize = bytes[dataOffset+4] |
//       bytes[dataOffset+5] << 8 |
//       bytes[dataOffset+6] << 16 |
//       bytes[dataOffset+7] << 24;
//
//       final audioStart = dataOffset + 8;
//       final audioEnd = audioStart + dataSize;
//       if (audioEnd > bytes.length) throw Exception("Invalid data chunk size");
//
//       // Convert to float32 array normalized to [-1.0, 1.0]
//       final numSamples = dataSize ~/ (numChannels * (bitsPerSample ~/ 8));
//       final samples = Float32List(numSamples);
//
//       for (int i = 0; i < numSamples; i++) {
//         final sampleOffset = audioStart + i * numChannels * 2;
//         // For simplicity, just use first channel if stereo
//         final sample = (bytes[sampleOffset] | (bytes[sampleOffset+1] << 8)).toSigned(16);
//         samples[i] = sample / 32768.0; // Normalize to [-1.0, 1.0]
//       }
//
//       // Resample to 16kHz if needed
//       const targetSampleRate = 16000;
//       if (sampleRateInt == targetSampleRate) {
//         return samples;
//       }
//
//       final ratio = sampleRateInt / targetSampleRate;
//       final newLength = (samples.length / ratio).floor();
//       final resampled = Float32List(newLength);
//
//       for (int i = 0; i < newLength; i++) {
//         final srcIndex = i * ratio;
//         final indexBefore = srcIndex.floor();
//         final indexAfter = min(samples.length - 1, srcIndex.ceil());
//         final fraction = srcIndex - indexBefore;
//
//         resampled[i] = samples[indexBefore] * (1 - fraction) +
//             samples[indexAfter] * fraction;
//       }
//
//       return resampled;
//     } catch (e) {
//       print('Error in audio preprocessing: $e');
//       return null;
//     }
//   }
//
//   Future<void> _processAndPredict() async {
//     if (_pickedFilePath == null || interpreter == null) return;
//
//     setState(() {
//       isProcessing = true;
//       statusMessage = 'Processing audio...';
//       _predictionResults = null;
//     });
//
//     try {
//       // 1. Preprocess audio
//       final inputAudio = await _preprocessAudio(_pickedFilePath!);
//       if (inputAudio == null) throw Exception("Preprocessing failed");
//
//       // 2. Prepare input tensor
//       final inputTensor = interpreter!.getInputTensor(0);
//
//       // 3. Run inference
//       final outputTensor = interpreter!.getOutputTensor(0);
//       final outputBuffer = Float32List(outputTensor.shape.reduce((a, b) => a * b));
//
//       interpreter!.resizeInputTensor(0, [inputAudio.length]);
//       interpreter!.allocateTensors();
//
//       final inputBuffer = inputAudio.buffer.asFloat32List();
//       interpreter!.run(inputBuffer, outputBuffer);
//
//       // 4. Process results
//       final probabilities = _softmax(outputBuffer.toList());
//
//       final results = <String, double>{};
//       for (int i = 0; i < probabilities.length; i++) {
//         if (i < _classNames.length) {
//           results[_classNames[i]] = probabilities[i] * 100;
//         }
//       }
//
//       // Navigate to ResultsScreen with the prediction results
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResultsScreen(
//             audioPath: _pickedFilePath!,
//             predictionResults: results,
//           ),
//         ),
//       );
//
//     } catch (e) {
//       setState(() {
//         statusMessage = 'Error: ${e.toString()}';
//       });
//       print('Error during prediction: $e');
//     } finally {
//       setState(() {
//         isProcessing = false;
//       });
//     }
//   }
//   List<double> _softmax(List<double> logits) {
//     double maxLogit = logits.reduce(max);
//     List<double> exps = logits.map((logit) => exp(logit - maxLogit)).toList(); // Subtract maxLogit for numerical stability
//     double sumExps = exps.reduce((a, b) => a + b);
//     return exps.map((e) => e / sumExps).toList();
//   }
//
//   @override
//   void dispose() {
//     interpreter?.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Baby Cry Analyzer 👶'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.audiotrack),
//                 label: const Text('Pick .wav Audio File'),
//                 onPressed: isProcessing ? null : _pickAudioFile,
//                 style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12)),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 statusMessage,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 16,
//                     color: statusMessage.toLowerCase().contains('error')
//                         ? Colors.red
//                         : Colors.black87),
//               ),
//               const SizedBox(height: 10),
//               if (_pickedFilePath != null && !isProcessing)
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Selected: ${_pickedFilePath!.split('/').last}',
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               if (isProcessing)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20.0),
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//               if (_predictionResults != null && !isProcessing) ...[
//                 const SizedBox(height: 20),
//                 Text(
//                   'Prediction Results:',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 10),
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       children: _predictionResults!.entries.map((entry) {
//                         // Find the highest probability to highlight it
//                         bool isHighest = true;
//                         double currentProb = entry.value;
//                         for (var val in _predictionResults!.values) {
//                           if (val > currentProb) {
//                             isHighest = false;
//                             break;
//                           }
//                         }
//                         // Handle cases where multiple might have the exact same max value (though unlikely with float)
//                         if (isHighest && _predictionResults!.values.where((v) => v == currentProb).length > 1) {
//                           // If multiple share the max, we can just pick the first one or not highlight specially
//                           // For simplicity, if it's among the highest, style it.
//                           isHighest = (_predictionResults!.values.reduce(max) == currentProb);
//                         }
//
//
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 entry.key,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
//                                   color: isHighest ? Theme.of(context).colorScheme.primary : Colors.black,
//                                 ),
//                               ),
//                               Text(
//                                 '${entry.value.toStringAsFixed(2)}%',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
//                                   color: isHighest ? Theme.of(context).colorScheme.primary : Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// extension ReshapeList<T> on List<T> {
//   List reshape(List<int> dimensions) {
//     if (dimensions.isEmpty) return this;
//
//     List<dynamic> reshapedList = [];
//     int totalElements = dimensions.reduce((a, b) => a * b);
//     if (totalElements != length) {
//       throw ArgumentError('Total elements in dimensions do not match list length.');
//     }
//
//     List<T> currentList = List<T>.from(this); // Make a mutable copy
//
//     List _buildNestedList(List<int> dims) {
//       if (dims.length == 1) {
//         return currentList.sublist(0, dims[0]);
//       }
//
//       List nested = [];
//       int subListLength = dims.sublist(1).reduce((a, b) => a * b);
//       for (int i = 0; i < dims[0]; i++) {
//         nested.add(_buildNestedList(dims.sublist(1)));
//         currentList.removeRange(0, subListLength);
//       }
//       return nested;
//     }
// if (dimensions.length == 2 && dimensions[0] == 1) {
//       return [List<T>.from(this)]; // Returns List<List<T>>
//     } else if (dimensions.length == 1){
//       return List<T>.from(this); // Returns List<T>
//     }
//     throw UnimplementedError("General reshape. Initialize output buffer with correct dimensions directly.");
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Result.dart';

class CryCaptureScreen extends StatefulWidget {
  const CryCaptureScreen({super.key});

  @override
  State<CryCaptureScreen> createState() => _CryCaptureScreenState();
}

class _CryCaptureScreenState extends State<CryCaptureScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();

  late final Interpreter? interpreter;
  String? currentRecordingPath;
  bool isRecording = false;

  bool isProcessing = false;

  int recordDuration = 0;
  Timer? timer;
  String statusMessage = 'Ready to record';

  // Model output classes
  final List<String> _classNames = [
    'Belly Pain',
    'Burping',
    'Discomfort',
    'Hungry',
    'Others',
    'Tired'
  ];

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      statusMessage = 'Loading model...';
    });
    try {
      interpreter = await Interpreter.fromAsset('assets/fmodel.tflite');
      print('Input Tensors: ${interpreter!.getInputTensors()}');
      print('Output Tensors: ${interpreter!.getOutputTensors()}');
      setState(() {
        statusMessage = 'Model loaded. Ready to record.';
      });
    } catch (e) {
      print('Failed to load TFLite model: $e');
      setState(() {
        statusMessage = 'Error loading model: $e';
      });
      Fluttertoast.showToast(msg: 'Error loading model: $e');
    }
  }
  Future<void> _checkAndRequestPermissions() async {
    final microphoneStatus = await Permission.microphone.status;
    final storageStatus = await Permission.storage.status;

    if (microphoneStatus.isDenied || storageStatus.isDenied) {
      final statuses = await [Permission.microphone, Permission.storage].request();
      if (!statuses[Permission.microphone]!.isGranted ||
          !statuses[Permission.storage]!.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Microphone and storage permissions required.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
            duration: const Duration(minutes: 1),
          ),
        );
      }
    }
  }

  Future<String> _getRecordingPath() async {
    final Directory directory = Platform.isAndroid
        ? await getExternalStorageDirectory() as Directory
        : await getApplicationDocumentsDirectory();

    final String path = '${directory.path}/WhatsAppAudioClone';
    final audioDir = Directory(path);
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    return '$path/$fileName';
  }

  void _startTimer() {
    recordDuration = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordDuration++;
      });
    });
  }

  void _stopTimer() {
    timer?.cancel();
  }

  Future<void> _startRecording() async {
    if (await audioRecorder.hasPermission()) {
      try {
        currentRecordingPath = await _getRecordingPath();
        await audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: currentRecordingPath!,
        );
        setState(() {
          isRecording = true;
          statusMessage = 'Recording...';
        });
        _startTimer();
      } catch (e) {
        debugPrint('Error starting recording: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: ${e.toString()}')),
        );
      }
    } else {
      _checkAndRequestPermissions();
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await audioRecorder.stop();
      _stopTimer();
      setState(() {
        isRecording = false;
        currentRecordingPath = path;
        statusMessage = 'Processing recording...';
        isProcessing = true;
      });

      if (path != null) {
        final results = await _processAndPredict();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              audioPath: path,
              predictionResults: results,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
          statusMessage = 'Ready to record';
        });
      }
    }
  }

  Future<Map<String, double>> _processAndPredict() async {
    if (currentRecordingPath == null || interpreter == null) {
      throw Exception("No recording or interpreter available");
    }

    try {
      final inputAudio = await _preprocessAudio(currentRecordingPath!);
      if (inputAudio == null) throw Exception("Preprocessing failed");

      final inputTensor = interpreter!.getInputTensor(0);
      final outputTensor = interpreter!.getOutputTensor(0);
      final outputBuffer = Float32List(outputTensor.shape.reduce((a, b) => a * b));

      interpreter!.resizeInputTensor(0, [inputAudio.length]);
      interpreter!.allocateTensors();

      final inputBuffer = inputAudio.buffer.asFloat32List();
      interpreter!.run(inputBuffer, outputBuffer);

      final probabilities = _softmax(outputBuffer.toList());

      final results = <String, double>{};
      for (int i = 0; i < probabilities.length; i++) {
        if (i < _classNames.length) {
          results[_classNames[i]] = probabilities[i] * 100;
        }
      }

      return results;
    } catch (e) {
      print('Error during prediction: $e');
      throw Exception("Prediction failed: $e");
    }
  }

  Future<Float32List?> _preprocessAudio(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      if (bytes.length < 44) throw Exception("Invalid WAV file (too short)");

      if (String.fromCharCodes(bytes.sublist(0, 4)) != "RIFF" ||
          String.fromCharCodes(bytes.sublist(8, 12)) != "WAVE") {
        throw Exception("Invalid WAV file format");
      }

      final audioFormat = bytes.sublist(20, 22);
      if (audioFormat[0] != 1 || audioFormat[1] != 0) {
        throw Exception("Only PCM format supported");
      }

      final numChannels = bytes[22];
      final sampleRate = bytes.sublist(24, 28);
      final sampleRateInt = sampleRate[0] |
      sampleRate[1] << 8 |
      sampleRate[2] << 16 |
      sampleRate[3] << 24;

      final bitsPerSample = bytes[34] | (bytes[35] << 8);
      if (bitsPerSample != 16) throw Exception("Only 16-bit PCM supported");

      int dataOffset = 36;
      while (dataOffset + 8 < bytes.length &&
          String.fromCharCodes(bytes.sublist(dataOffset, dataOffset + 4)) != "data") {
        final chunkSize = bytes[dataOffset + 4] |
        bytes[dataOffset + 5] << 8 |
        bytes[dataOffset + 6] << 16 |
        bytes[dataOffset + 7] << 24;
        dataOffset += 8 + chunkSize;
      }

      if (dataOffset + 8 >= bytes.length) throw Exception("No data chunk found");

      final dataSize = bytes[dataOffset + 4] |
      bytes[dataOffset + 5] << 8 |
      bytes[dataOffset + 6] << 16 |
      bytes[dataOffset + 7] << 24;

      final audioStart = dataOffset + 8;
      final audioEnd = audioStart + dataSize;
      if (audioEnd > bytes.length) throw Exception("Invalid data chunk size");

      final numSamples = dataSize ~/ (numChannels * (bitsPerSample ~/ 8));
      final samples = Float32List(numSamples);

      for (int i = 0; i < numSamples; i++) {
        final sampleOffset = audioStart + i * numChannels * 2;
        final sample = (bytes[sampleOffset] | (bytes[sampleOffset + 1] << 8)).toSigned(16);
        samples[i] = sample / 32768.0;
      }

      const targetSampleRate = 16000;
      if (sampleRateInt == targetSampleRate) {
        return samples;
      }

      final ratio = sampleRateInt / targetSampleRate;
      final newLength = (samples.length / ratio).floor();
      final resampled = Float32List(newLength);

      for (int i = 0; i < newLength; i++) {
        final srcIndex = i * ratio;
        final indexBefore = srcIndex.floor();
        final indexAfter = min(samples.length - 1, srcIndex.ceil());
        final fraction = srcIndex - indexBefore;

        resampled[i] = samples[indexBefore] * (1 - fraction) +
            samples[indexAfter] * fraction;
      }

      return resampled;
    } catch (e) {
      print('Error in audio preprocessing: $e');
      return null;
    }
  }

  List<double> _softmax(List<double> logits) {
    double maxLogit = logits.reduce(max);
    List<double> exps = logits.map((logit) => exp(logit - maxLogit)).toList();
    double sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }



  @override
  void dispose() {
    audioRecorder.dispose();
    timer?.cancel();
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Cry Analyzer 👶'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isRecording)
                Text(
                  'Recording... $recordDuration sec',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (isProcessing)
                const Column(
                  children: [
                    Text(
                      'Analyzing cry...',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                  ],
                )
              else
                Text(
                  statusMessage,
                  style: TextStyle(
                    fontSize: 24,
                    color: statusMessage.toLowerCase().contains('error')
                        ? Colors.red
                        : Colors.black87,
                  ),
                ),
              const SizedBox(height: 40),
              GestureDetector(
                onLongPress: isRecording ? _stopRecording : _startRecording,
                onTap: () {
                  if (isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: isRecording ? Colors.redAccent : Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isRecording
                            ? Colors.red.withOpacity(0.5)
                            : Colors.blue.withOpacity(0.5),
                        blurRadius: isRecording ? 20 : 10,
                        spreadRadius: isRecording ? 5 : 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              if (currentRecordingPath != null && !isRecording && !isProcessing) ...[
                const SizedBox(height: 30),
                Column(
                  children: [
                    const Text(
                      'Last Recording:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        currentRecordingPath!.split('/').last,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
