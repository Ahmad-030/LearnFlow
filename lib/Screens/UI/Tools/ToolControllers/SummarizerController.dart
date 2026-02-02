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

class SummarizerController extends GetxController {
  final RxString selectedFileName = ''.obs;
  final RxString selectedFilePath = ''.obs;
  final RxString summary = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSummarized = false.obs;

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

  Future<void> summarizeDocument() async {
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
Please provide a comprehensive summary of this document. 
Include:
- Main topic and key points
- Important details and findings
- Conclusions or recommendations (if any)
- Overall context and significance

Make the summary clear, concise, and well-structured.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('application/pdf', fileBytes),
        ])
      ];

      final response = await model.generateContent(content);
      summary.value = response.text ?? 'No summary generated';
      isSummarized.value = true;

      Get.snackbar(
        'Success',
        'Document summarized successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to summarize: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSummaryAsPDF(String fileName) async {
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
                  'Document Summary',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Original Document: $selectedFileName',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                summary.value,
                style: const pw.TextStyle(fontSize: 14),
                textAlign: pw.TextAlign.justify,
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
        'Summary saved to: $path',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => OpenFile.open(path),
          child: const Text('Open', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void reset() {
    selectedFileName.value = '';
    selectedFilePath.value = '';
    summary.value = '';
    isSummarized.value = false;
  }
}