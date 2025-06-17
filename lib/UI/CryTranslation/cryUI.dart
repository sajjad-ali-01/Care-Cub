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
//   Interpreter? _interpreter;
//   String? _pickedFilePath;
//   Map<String, double>? _predictionResults;
//   bool _isProcessing = false;
//   String _statusMessage = 'Please load a .wav audio file.';
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
//       _statusMessage = 'Loading model...';
//     });
//     try {
//       _interpreter = await Interpreter.fromAsset('assets/models.tflite');
//       // Print model input/output details for debugging
//       print('Input Tensors: ${_interpreter!.getInputTensors()}');
//       print('Output Tensors: ${_interpreter!.getOutputTensors()}');
//       setState(() {
//         _statusMessage = 'Model loaded. Ready to pick audio.';
//       });
//     } catch (e) {
//       print('Failed to load TFLite model: $e');
//       setState(() {
//         _statusMessage = 'Error loading model: $e';
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
//           _statusMessage = 'File selected: ${result.files.single.name}';
//           _predictionResults = null; // Clear previous results
//         });
//         _processAndPredict();
//       } else {
//         Fluttertoast.showToast(msg: "No file selected.");
//         setState(() {
//           _statusMessage = 'File selection cancelled.';
//         });
//       }
//     } catch (e) {
//       print('Error picking file: $e');
//       Fluttertoast.showToast(msg: 'Error picking file: $e');
//       setState(() {
//         _statusMessage = 'Error picking file: $e';
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
//     if (_pickedFilePath == null || _interpreter == null) return;
//
//     setState(() {
//       _isProcessing = true;
//       _statusMessage = 'Processing audio...';
//       _predictionResults = null;
//     });
//
//     try {
//       // 1. Preprocess audio
//       final inputAudio = await _preprocessAudio(_pickedFilePath!);
//       if (inputAudio == null) throw Exception("Preprocessing failed");
//
//       // Debug: Print first 10 samples
//       print("First 10 samples: ${inputAudio.sublist(0, 10)}");
//
//       // 2. Prepare input tensor
//       final inputTensor = _interpreter!.getInputTensor(0);
//       print("Model input details: shape=${inputTensor.shape} type=${inputTensor.type}");
//
//       // 3. Run inference
//       final outputTensor = _interpreter!.getOutputTensor(0);
//       final outputBuffer = Float32List(outputTensor.shape.reduce((a, b) => a * b));
//
//       // For dynamic shape models
//       _interpreter!.resizeInputTensor(0, [inputAudio.length]);
//       _interpreter!.allocateTensors();
//
//       // Correct way to set input and get output in tflite_flutter
//       final inputBuffer = inputAudio.buffer.asFloat32List();
//       _interpreter!.run(inputBuffer, outputBuffer);
//
//       // Debug: Print raw output
//       print("Raw output: ${outputBuffer.sublist(0, outputBuffer.length)}");
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
//       setState(() {
//         _predictionResults = results;
//         _statusMessage = 'Prediction complete';
//       });
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error: ${e.toString()}';
//       });
//       print('Error during prediction: $e');
//     } finally {
//       setState(() {
//         _isProcessing = false;
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
//     _interpreter?.close();
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
//                 onPressed: _isProcessing ? null : _pickAudioFile,
//                 style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12)),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 _statusMessage,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 16,
//                     color: _statusMessage.toLowerCase().contains('error')
//                         ? Colors.red
//                         : Colors.black87),
//               ),
//               const SizedBox(height: 10),
//               if (_pickedFilePath != null && !_isProcessing)
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Selected: ${_pickedFilePath!.split('/').last}',
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               if (_isProcessing)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20.0),
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//               if (_predictionResults != null && !_isProcessing) ...[
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
import 'package:audioplayers/audioplayers.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Cry Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CryCaptureScreen(),
    );
  }
}

class CryCaptureScreen extends StatefulWidget {
  const CryCaptureScreen({super.key});

  @override
  State<CryCaptureScreen> createState() => _CryCaptureScreenState();
}

class _CryCaptureScreenState extends State<CryCaptureScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Interpreter? _interpreter;
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isProcessing = false;
  double _playbackPosition = 0.0;
  double _playbackDuration = 0.0;
  int _recordDuration = 0;
  Timer? _timer;
  String _statusMessage = 'Ready to record';

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
    _initAudioPlayerListeners();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _statusMessage = 'Loading model...';
    });
    try {
      _interpreter = await Interpreter.fromAsset('assets/models.tflite');
      print('Input Tensors: ${_interpreter!.getInputTensors()}');
      print('Output Tensors: ${_interpreter!.getOutputTensors()}');
      setState(() {
        _statusMessage = 'Model loaded. Ready to record.';
      });
    } catch (e) {
      print('Failed to load TFLite model: $e');
      setState(() {
        _statusMessage = 'Error loading model: $e';
      });
      Fluttertoast.showToast(msg: 'Error loading model: $e');
    }
  }

  void _initAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          _isPlaying = true;
        });
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _playbackDuration = duration.inMilliseconds.toDouble();
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _playbackPosition = position.inMilliseconds.toDouble();
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _playbackPosition = 0.0;
      });
    });
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
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      try {
        _currentRecordingPath = await _getRecordingPath();
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: _currentRecordingPath!,
        );
        setState(() {
          _isRecording = true;
          _statusMessage = 'Recording...';
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
      final path = await _audioRecorder.stop();
      _stopTimer();
      setState(() {
        _isRecording = false;
        _currentRecordingPath = path;
        _statusMessage = 'Processing recording...';
        _isProcessing = true;
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
          _isProcessing = false;
          _statusMessage = 'Ready to record';
        });
      }
    }
  }

  Future<Map<String, double>> _processAndPredict() async {
    if (_currentRecordingPath == null || _interpreter == null) {
      throw Exception("No recording or interpreter available");
    }

    try {
      final inputAudio = await _preprocessAudio(_currentRecordingPath!);
      if (inputAudio == null) throw Exception("Preprocessing failed");

      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputBuffer = Float32List(outputTensor.shape.reduce((a, b) => a * b));

      _interpreter!.resizeInputTensor(0, [inputAudio.length]);
      _interpreter!.allocateTensors();

      final inputBuffer = inputAudio.buffer.asFloat32List();
      _interpreter!.run(inputBuffer, outputBuffer);

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

  Future<void> _playRecording() async {
    if (_currentRecordingPath != null && !_isPlaying) {
      try {
        await _audioPlayer.play(DeviceFileSource(_currentRecordingPath!));
        setState(() {
          _isPlaying = true;
        });
      } catch (e) {
        debugPrint('Error playing audio: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: ${e.toString()}')),
        );
      }
    } else if (_isPlaying) {
      await _audioPlayer.pause();
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _playbackPosition = 0.0;
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    _interpreter?.close();
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
              if (_isRecording)
                Text(
                  'Recording... $_recordDuration sec',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (_isProcessing)
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
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 24,
                    color: _statusMessage.toLowerCase().contains('error')
                        ? Colors.red
                        : Colors.black87,
                  ),
                ),
              const SizedBox(height: 40),
              GestureDetector(
                onLongPress: _isRecording ? _stopRecording : _startRecording,
                onTap: () {
                  if (_isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.redAccent : Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isRecording
                            ? Colors.red.withOpacity(0.5)
                            : Colors.blue.withOpacity(0.5),
                        blurRadius: _isRecording ? 20 : 10,
                        spreadRadius: _isRecording ? 5 : 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              if (_currentRecordingPath != null && !_isRecording && !_isProcessing) ...[
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
                        _currentRecordingPath!.split('/').last,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            size: 50,
                            color: _isPlaying ? Colors.orange : Colors.green,
                          ),
                          onPressed: _playRecording,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.stop_circle,
                            size: 50,
                            color: Colors.red,
                          ),
                          onPressed: _stopPlayback,
                        ),
                      ],
                    ),
                    Slider(
                      min: 0.0,
                      max: _playbackDuration,
                      value: _playbackPosition.clamp(0.0, _playbackDuration),
                      onChanged: (newValue) {
                        setState(() {
                          _playbackPosition = newValue;
                        });
                        _audioPlayer.seek(
                            Duration(milliseconds: newValue.toInt()));
                      },
                    ),
                    Text(
                      '${Duration(milliseconds: _playbackPosition.toInt()).inMinutes.remainder(60).toString().padLeft(2, '0')}:'
                          '${Duration(milliseconds: _playbackPosition.toInt()).inSeconds.remainder(60).toString().padLeft(2, '0')} / '
                          '${Duration(milliseconds: _playbackDuration.toInt()).inMinutes.remainder(60).toString().padLeft(2, '0')}:'
                          '${Duration(milliseconds: _playbackDuration.toInt()).inSeconds.remainder(60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14),
                    ),
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
class ResultsScreen extends StatefulWidget {
  final String audioPath;
  final Map<String, double> predictionResults;

  const ResultsScreen({
    super.key,
    required this.audioPath,
    required this.predictionResults,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
  }

  // Method to get suggestions for each condition
  List<String> _getSuggestions(String condition) {
    switch (condition) {
      case 'Discomfort':
        return [
          'Check diaper and clothing for tightness or irritation',
          'Try different holding positions to relieve pressure',
          'Gently massage baby\'s back or tummy'
        ];
      case 'Burping':
        return [
          'Hold baby upright against your shoulder',
          'Pat or rub back gently in circular motions',
          'Try walking while holding baby upright'
        ];
      case 'Belly Pain':
        return [
          'Do bicycle leg movements to relieve gas',
          'Apply gentle tummy massage clockwise',
          'Consult with the Doctor'
        ];
      case 'Hungry':
        return [
          'Offer feeding if it\'s been 2-3 hours',
          'Ensure proper latch if breastfeeding'
        ];
      case 'Tired':
        return [
          'Swaddle snugly to mimic womb feeling',
          'Reduce stimulation and dim lights',
          'Try gentle rocking or white noise'
        ];
      default:
        return [
          'The provided voice is not for the baby cry please record again'
        ];
    }
  }

  Widget _getCategoryAvatar(String category, {double size = 40}) {
    String imagePath;
    Color color;

    switch (category) {
      case 'Belly Pain':
        imagePath = "assets/images/belly_pain.png"; // Update with your actual image path
        color = Colors.redAccent;
        break;
      case 'Burping':
        imagePath = "assets/images/burping.png"; // Update with your actual image path
        color = Colors.orangeAccent;
        break;
      case 'Discomfort':
        imagePath = "assets/images/discomfort.png"; // Update with your actual image path
        color = Colors.blue;
        break;
      case 'Hungry':
        imagePath = "assets/images/feed.png"; // Update with your actual image path
        color = Colors.greenAccent;
        break;
      case 'Tired':
        imagePath = "assets/images/tired.png"; // Update with your actual image path
        color = Colors.purpleAccent;
        break;
      default:
        imagePath = "assets/images/default.png"; // Update with your actual image path
        color = Colors.grey;
    }

    return CircleAvatar(
      radius: size,
      backgroundColor: color.withOpacity(0.2),
      backgroundImage: AssetImage(imagePath),
      child: imagePath.isEmpty
          ? Icon(Icons.help_outline, color: color, size: size * 0.6)
          : null, // Show icon if image fails to load
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort predictions by percentage (highest first)
    final sortedPredictions = widget.predictionResults.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highestPrediction = sortedPredictions.isNotEmpty
        ? sortedPredictions.first
        : null;

    final topSuggestions = _selectedFilter != null
        ? _getSuggestions(_selectedFilter!)
        : _getSuggestions(highestPrediction?.key ?? 'Others');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CryCaptureScreen(),
            ),
          );
        },
        child: const Icon(Icons.mic,color: Colors.white,),
        backgroundColor: Colors.deepOrange.shade600,
      ),
      body: CustomScrollView(
        slivers: [
          // Expanded AppBar with most likely reason
          SliverAppBar(
            expandedHeight: 120,
            leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (highestPrediction != null)
                    _getCategoryAvatar(highestPrediction.key, size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${highestPrediction?.value.toStringAsFixed(0)}% Likely to be',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          highestPrediction?.key ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              background: Container(
                color: Colors.deepOrange.shade600,
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt,color: Colors.white,),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Filter Recommendations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...sortedPredictions
                              .where((entry) => entry.key != 'Others')
                              .map((entry) {
                            return RadioListTile<String>(
                              title: Text(entry.key),
                              value: entry.key,
                              groupValue: _selectedFilter,
                              onChanged: (value) {
                                setState(() {
                                  _selectedFilter = value;
                                });
                                Navigator.pop(context);
                              },
                              secondary: _getCategoryAvatar(entry.key, size: 24),
                            );
                          }),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = null;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Reset Filter'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),

          // Main content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Predictions with progress bars
                    const Text(
                      'All predictions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sortedPredictions.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${entry.value.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: entry.value / 100,
                              backgroundColor: Colors.grey[300],
                              color: _getProgressBarColor(entry.key),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Top 3 Recommendations
                    const SizedBox(height: 8),
                    const Text(
                      'Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFilter != null
                          ? 'For $_selectedFilter'
                          : 'For ${highestPrediction?.key ?? 'your baby'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...topSuggestions.take(3).map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4, right: 12),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Did it work section
                    const SizedBox(height: 0),
                    const Divider(),
                    const SizedBox(height: 0),
                    const Text(
                      'Did these suggestions help?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.green.shade400),
                            ),
                            onPressed: () {
                              // Handle yes action
                            },
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.red.shade400),
                            ),
                            onPressed: () {
                              // Handle no action
                            },
                            child: Text(
                              'No',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Color _getProgressBarColor(String category) {
    switch (category) {
      case 'Belly Pain':
        return Colors.redAccent;
      case 'Burping':
        return Colors.orangeAccent;
      case 'Discomfort':
        return Colors.blue;
      case 'Hungry':
        return Colors.greenAccent;
      case 'Tired':
        return Colors.purpleAccent;
      case 'Others':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}