import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class QuizGeneratorController extends GetxController {
  final RxString selectedFileName = ''.obs;
  final RxString selectedFilePath = ''.obs;
  final RxString quizContent = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerated = false.obs;

  late final GenerativeModel model;

  // TODO: Replace with your actual Gemini API key
  static const String GEMINI_API_KEY = 'YOUR_API_KEY_HERE';

  @override
  void onInit() {
    super.onInit();
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: GEMINI_API_KEY,
    );
  }

  Future<void> pickFromStorage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        selectedFilePath.value = result.files.single.path!;
        selectedFileName.value = result.files.single.name;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        selectedFilePath.value = image.path;
        selectedFileName.value = image.name;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> generateQuiz() async {
    if (selectedFilePath.value.isEmpty) {
      Get.snackbar(
        'No File',
        'Please select a document first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final file = File(selectedFilePath.value);
      final fileBytes = await file.readAsBytes();

      final prompt = '''
Based on this document, create 10 multiple-choice questions (MCQs).
Format each question as follows:

Question [Number]: [Question text]
A) [Option A]
B) [Option B]
C) [Option C]
D) [Option D]
Correct Answer: [Letter]
Explanation: [Brief explanation]

Make sure questions cover key concepts from the document.
Ensure all options are plausible but only one is correct.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('application/pdf', fileBytes),
        ])
      ];

      final response = await model.generateContent(content);
      quizContent.value = response.text ?? 'No quiz generated';
      isGenerated.value = true;

      Get.snackbar(
        'Success',
        'Quiz generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate quiz: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadQuiz(String format, String fileName) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (format == 'pdf') {
        await _saveAsPDF(fileName);
      } else {
        await _saveAsWord(fileName);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download quiz: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveAsPDF(String fileName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'MCQ Quiz',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated from: $selectedFileName',
              style: pw.TextStyle(
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              quizContent.value,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ];
        },
      ),
    );

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/$fileName.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    Get.snackbar(
      'Success',
      'Quiz saved to: $path',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () => OpenFile.open(path),
        child: const Text('Open', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _saveAsWord(String fileName) async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/$fileName.txt';
    final file = File(path);

    final content = '''
MCQ QUIZ
Generated from: $selectedFileName

${quizContent.value}
''';

    await file.writeAsString(content);

    Get.snackbar(
      'Success',
      'Quiz saved as text file: $path',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () => OpenFile.open(path),
        child: const Text('Open', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void reset() {
    selectedFileName.value = '';
    selectedFilePath.value = '';
    quizContent.value = '';
    isGenerated.value = false;
  }
}