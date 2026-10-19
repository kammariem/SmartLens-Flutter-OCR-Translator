import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../theme/widgets/app_navigation.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';


class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isProcessing = false;
  String _recognizedText = '';
  String _translatedText = '';
  TranslateLanguage _sourceLanguage = TranslateLanguage.english;
  TranslateLanguage _targetLanguage = TranslateLanguage.spanish;
  bool _isTranslating = false;

  final List<TranslateLanguage> _supportedLanguages = [
    TranslateLanguage.english,
    TranslateLanguage.spanish,
    TranslateLanguage.french,
    TranslateLanguage.german,
    TranslateLanguage.italian,
    TranslateLanguage.portuguese,
    TranslateLanguage.chinese,
    TranslateLanguage.japanese,
    TranslateLanguage.korean,
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  TextRecognitionScript _getScriptForLanguage(TranslateLanguage language) {
    switch (language) {
      case TranslateLanguage.chinese:
        return TextRecognitionScript.chinese;
      case TranslateLanguage.japanese:
        return TextRecognitionScript.japanese;
      case TranslateLanguage.korean:
        return TextRecognitionScript.korean;
      default:
        return TextRecognitionScript.latin;
    }
  }

  Future<void> _identifyLanguage(String text) async {
    final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    try {
      final String languageCode =
          await languageIdentifier.identifyLanguage(text);

      if (languageCode != 'und') {
        final detectedLanguage = _supportedLanguages.firstWhere(
          (element) => element.bcpCode == languageCode,
          orElse: () => _sourceLanguage,
        );

        if (detectedLanguage != _sourceLanguage) {
          setState(() {
            _sourceLanguage = detectedLanguage;
          });
        }
      }
    } catch (e) {
      debugPrint('Language Identification Error: $e');
    } finally {
      await languageIdentifier.close();
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  Future<void> _captureAndRecognize() async {
    if (_controller == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _recognizedText = '';
      _translatedText = '';
    });

    try {
      await _initializeControllerFuture;
      final XFile image = await _controller!.takePicture();

      final inputImage = InputImage.fromFile(File(image.path));
      final script = _getScriptForLanguage(_sourceLanguage);
      final textRecognizer = TextRecognizer(script: script);

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      setState(() {
        _recognizedText = recognizedText.text;
      });
      
      if (_recognizedText.isNotEmpty) {
        await _identifyLanguage(_recognizedText);
        await _translateText();
      }
    } catch (e) {
      debugPrint('OCR Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText.isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final modelManager = OnDeviceTranslatorModelManager();
      
      // Check and download source model
      if (!await modelManager.isModelDownloaded(_sourceLanguage.bcpCode)) {
        debugPrint('Downloading source model: ${_sourceLanguage.bcpCode}...');
        if (await modelManager.downloadModel(_sourceLanguage.bcpCode)) {
           debugPrint('Source model downloaded.');
        } else {
           throw 'Failed to download source language model.';
        }
      }

      // Check and download target model
      if (!await modelManager.isModelDownloaded(_targetLanguage.bcpCode)) {
        debugPrint('Downloading target model: ${_targetLanguage.bcpCode}...');
        if (await modelManager.downloadModel(_targetLanguage.bcpCode)) {
           debugPrint('Target model downloaded.');
        } else {
           throw 'Failed to download target language model.';
        }
      }

      final translator = OnDeviceTranslator(
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      final translatedText = await translator.translateText(_recognizedText);
      await translator.close();

      setState(() {
        _translatedText = translatedText;
      });
    } catch (e) {
      debugPrint('Translation Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Camera preview
            Expanded(
              flex: 3,
              child: _controller == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_controller!);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
            ),

            // OCR result
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('From:', style: AppTextStyles.bodySmall),
                              DropdownButton<TranslateLanguage>(
                                value: _sourceLanguage,
                                isExpanded: true,
                                dropdownColor: AppColors.surface,
                                underline: Container(),
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: AppColors.primary),
                                items: _supportedLanguages
                                    .map((TranslateLanguage language) {
                                  return DropdownMenuItem<TranslateLanguage>(
                                    value: language,
                                    child: Text(
                                      language.name.toUpperCase(),
                                      style: AppTextStyles.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (TranslateLanguage? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _sourceLanguage = newValue;
                                      if (_recognizedText.isNotEmpty) {
                                        _translateText();
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.arrow_forward,
                              color: AppColors.textSecondary),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('To:', style: AppTextStyles.bodySmall),
                              DropdownButton<TranslateLanguage>(
                                value: _targetLanguage,
                                isExpanded: true,
                                dropdownColor: AppColors.surface,
                                underline: Container(),
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: AppColors.primary),
                                items: _supportedLanguages
                                    .map((TranslateLanguage language) {
                                  return DropdownMenuItem<TranslateLanguage>(
                                    value: language,
                                    child: Text(
                                      language.name.toUpperCase(),
                                      style: AppTextStyles.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (TranslateLanguage? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _targetLanguage = newValue;
                                      if (_recognizedText.isNotEmpty) {
                                        _translateText();
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            const TabBar(
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                              tabs: [
                                Tab(text: 'Original'),
                                Tab(text: 'Translation'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // Original Text Tab
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _recognizedText.isEmpty
                                            ? 'No Text Detected.'
                                            : _recognizedText,
                                        style: AppTextStyles.body,
                                      ),
                                    ),
                                  ),
                                  // Translated Text Tab
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: _isTranslating
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : SingleChildScrollView(
                                            child: Text(
                                              _translatedText.isEmpty
                                                  ? 'No translation available.'
                                                  : _translatedText,
                                              style: AppTextStyles.body.copyWith(
                                                color: AppColors.primary,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Capture button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: FloatingActionButton(
                onPressed: _captureAndRecognize,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 1),
    );
  }
}
