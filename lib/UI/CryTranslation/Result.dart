import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:audio_waveforms/audio_waveforms.dart';

class CryPredictionScreen extends StatefulWidget {
  final String audioPath;

  const CryPredictionScreen({super.key, required this.audioPath});

  @override
  State<CryPredictionScreen> createState() => _CryPredictionScreenState();
}

class _CryPredictionScreenState extends State<CryPredictionScreen> {
  late tfl.Interpreter _interpreter;
  List<String> _labels = [];
  bool _isLoading = true;
  Map<String, double> _predictions = {};
  String _errorMessage = '';
  List<double>? _audioSamples;

  final List<String> _myClasses = [
    'belly_pain',
    'burping',
    'discomfort',
    'hungry',
    'tired',
    'others'
  ];

  @override
  void initState() {
    super.initState();
    _initModelAndProcessAudio();
  }

  Future<void> _initModelAndProcessAudio() async {
    try {
      // 1. Verify WAV file exists
      final audioFile = File(widget.audioPath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found at ${widget.audioPath}');
      }

      // 2. Load model and labels
      await _loadModel();

      // 3. Process audio and run inference
      await _processAndClassifyAudio(audioFile);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _loadModel() async {
    try {
      // Load model with debugging
      print('Loading TensorFlow Lite model...');
      final interpreterOptions = tfl.InterpreterOptions();
      _interpreter = await tfl.Interpreter.fromAsset(
        'assets/model.tflite',
        options: interpreterOptions,
      );

      // Print model details
      print('Model input details: ${_interpreter.getInputTensor(0)}');
      print('Model output details: ${_interpreter.getOutputTensor(0)}');

      // Load labels
      final labelTxt = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelTxt.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      print('Loaded ${_labels.length} labels');
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  Future<void> _processAndClassifyAudio(File audioFile) async {
    try {
      // 1. Read and validate WAV file
      print('Processing WAV file...');
      final bytes = await audioFile.readAsBytes();
      if (bytes.length < 44) throw Exception('Invalid WAV file (too short)');

      // 2. Extract audio data from WAV (skip header)
      final audioData = _extractAudioDataFromWav(bytes);
      print('Extracted ${audioData.length} samples');

      // 3. Preprocess audio
      final processedAudio = _preprocessAudio(audioData);
      _audioSamples = processedAudio; // Store for visualization

      // 4. Prepare model input
      final inputShape = _interpreter.getInputTensor(0).shape;
      final input = _prepareModelInput(processedAudio, inputShape);

      // 5. Run inference
      print('Running inference...');
      final output = List.filled(
        _interpreter.getOutputTensor(0).shape.reduce((a, b) => a * b),
        0.0,
      ).reshape(_interpreter.getOutputTensor(0).shape);

      _interpreter.run(input, output);

      // 6. Process results
      _processInferenceResults(output[0]);
    } catch (e) {
      throw Exception('Audio processing failed: $e');
    }
  }

  List<double> _extractAudioDataFromWav(Uint8List bytes) {
    // Skip WAV header (first 44 bytes) and convert to samples
    final dataStart = 44;
    final dataBytes = bytes.sublist(dataStart);

    // Convert bytes to 16-bit PCM samples (-32768 to 32767)
    final buffer = Int16List.view(dataBytes.buffer);
    return buffer.map((sample) => sample / 32768.0).toList();
  }

  List<double> _preprocessAudio(List<double> samples) {
    // 1. Resample if needed (assuming original is 16kHz)
    // 2. Normalize
    final maxVal = samples.fold(0.0, (prev, e) => max(prev, e.abs()));
    return maxVal > 0 ? samples.map((e) => e / maxVal).toList() : samples;
  }

  List<List<double>> _prepareModelInput(List<double> audio, List<int> shape) {
    if (shape.length != 2) throw Exception('Expected 2D input shape');

    final targetLength = shape[1];
    final input = List<double>.filled(targetLength, 0.0);

    // Copy or pad audio to match model input length
    final length = min(audio.length, targetLength);
    for (var i = 0; i < length; i++) {
      input[i] = audio[i].clamp(-1.0, 1.0);
    }

    return [input]; // Add batch dimension
  }

  void _processInferenceResults(List<double> output) {
    final probabilities = _softmax(output);
    final results = <String, double>{};

    for (var i = 0; i < min(_myClasses.length, probabilities.length); i++) {
      results[_myClasses[i]] = probabilities[i] * 100;
    }

    setState(() {
      _predictions = results;
      _isLoading = false;
    });

    print('Inference results: $results');
  }

  List<double> _softmax(List<double> input) {
    final expValues = input.map((e) => exp(e)).toList();
    final sumExp = expValues.reduce((a, b) => a + b);
    return expValues.map((e) => e / sumExp).toList();
  }

  void _handleError(dynamic error) {
    print('Error: $error');
    setState(() {
      _isLoading = false;
      _errorMessage = error.toString();
    });
  }

  String _getSuggestion() {
    if (_predictions.isEmpty) return 'No prediction available';

    final highest = _predictions.entries.reduce((a, b) => a.value > b.value ? a : b);

    switch (highest.key) {
    case 'discomfort':
    return 'Try adjusting the baby\'s position or checking for any irritants.';
    case 'burping':
    return 'Hold the baby upright and gently pat their back to help them burp.';
    case 'belly_pain':
    return 'Consider massaging the baby\'s tummy or consulting a pediatrician.';
    case 'hungry':
    return 'Try feeding the baby.';
    case 'tired':
    return 'Put the baby in a calm environment to help them sleep.';
    case 'others':
    return 'The cry pattern doesn\'t match common needs. Check for other signs.';
    default:
    return 'No suggestion available.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = _getSuggestion();

    return Scaffold(
      backgroundColor: const Color(0xFFDFFAFF),
      appBar: AppBar(
        title: const Text('Cry Prediction Result'),
        backgroundColor: const Color(0xFFDFFAFF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Audio waveform visualization
            if (_audioSamples != null)
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                // child: AudioWaveform(
                //   samples: _audioSamples!,
                //   color: Colors.blue,
                // ),
              ),

            const SizedBox(height: 20),

            // Prediction results
            if (_predictions.isEmpty)
              const Text('No predictions available', style: TextStyle(fontSize: 18))
            else
              ..._buildPredictionWidgets(),

            const SizedBox(height: 20),

            // Suggestion
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Suggestion: $suggestion',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPredictionWidgets() {
    return _predictions.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              '${entry.key.replaceAll('_', ' ').toUpperCase()}: ${entry.value.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16),
            ),
            LinearProgressIndicator(
              value: entry.value / 100,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
              minHeight: 8,
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}