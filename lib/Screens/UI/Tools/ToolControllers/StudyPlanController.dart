import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../../../../Model/ComprehensiveQuizModel.dart';
import '../../../../Services/ComprehensiveQuizService.dart';


class StudyPlanController extends GetxController {
  final _auth = FirebaseAuth.instance;

  // Replace with your actual API key
  static const String GEMINI_API_KEY = 'AIzaSyBzsZ6PdsVtb6SaSaPKHR55fM97646TxMo';

  var isLoading = false.obs;
  var hasCompletedQuiz = false.obs;
  var comprehensiveAttempt = Rxn<ComprehensiveQuizAttempt>();
  var generatedStudyPlan = ''.obs;
  var isGeneratingPlan = false.obs;
  var hasGeneratedPlan = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkQuizStatus();
  }

  /// Check if user has completed the comprehensive quiz
  Future<void> checkQuizStatus() async {
    try {
      isLoading.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Check if comprehensive quiz exists
      final attempt = await ComprehensiveQuizService.getLatestAttempt(userId);

      if (attempt != null) {
        hasCompletedQuiz.value = true;
        comprehensiveAttempt.value = attempt;
      } else {
        hasCompletedQuiz.value = false;
      }

    } catch (e) {
      print('Error checking quiz status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to comprehensive quiz
  void takeComprehensiveQuiz() {
    Get.toNamed('/comprehensive-quiz');
  }

  /// Generate AI study plan based on comprehensive quiz results
  Future<void> generateStudyPlan() async {
    try {
      isGeneratingPlan.value = true;

      if (comprehensiveAttempt.value == null) {
        Get.snackbar('Error', 'No quiz data found');
        return;
      }

      final attempt = comprehensiveAttempt.value!;

      // Prepare performance data for AI
      final performanceData = _preparePerformanceData(attempt);

      // Generate study plan using Gemini
      final studyPlan = await _generateAIStudyPlan(performanceData);

      generatedStudyPlan.value = studyPlan;
      hasGeneratedPlan.value = true;

      Get.snackbar(
        'Success',
        'Study plan generated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate study plan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingPlan.value = false;
    }
  }

  String _preparePerformanceData(ComprehensiveQuizAttempt attempt) {
    StringBuffer data = StringBuffer();

    data.writeln('COMPREHENSIVE QUIZ RESULTS:');
    data.writeln('Overall Accuracy: ${attempt.overallAccuracy.toStringAsFixed(1)}%');
    data.writeln('Total Score: ${attempt.correctAnswers}/${attempt.totalQuestions}');
    data.writeln('Time Taken: ${attempt.timeTaken} minutes');
    data.writeln('Quiz Date: ${attempt.completedAt.toString().split(' ')[0]}');
    data.writeln('\nSUBJECT-WISE PERFORMANCE:');

    // Sort subjects by accuracy (weakest first)
    final sortedSubjects = attempt.subjectPerformance.values.toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

    for (var subjectPerf in sortedSubjects) {
      data.writeln('\n${subjectPerf.subjectName}:');
      data.writeln('  - Accuracy: ${subjectPerf.accuracy.toStringAsFixed(1)}%');
      data.writeln('  - Score: ${subjectPerf.correctAnswers}/${subjectPerf.totalQuestions}');

      if (subjectPerf.weakTopics.isNotEmpty) {
        data.writeln('  - Weak Topics: ${subjectPerf.weakTopics.join(', ')}');
      }

      // Categorize performance
      if (subjectPerf.accuracy < 60) {
        data.writeln('  - Status: CRITICAL - Needs immediate attention');
      } else if (subjectPerf.accuracy < 75) {
        data.writeln('  - Status: NEEDS IMPROVEMENT');
      } else if (subjectPerf.accuracy < 85) {
        data.writeln('  - Status: GOOD - Minor improvements needed');
      } else {
        data.writeln('  - Status: EXCELLENT - Maintain and revise');
      }
    }

    return data.toString();
  }

  Future<String> _generateAIStudyPlan(String performanceData) async {
    try {
      final model = GenerativeModel(
         model: 'gemini-2.0-flash',
        apiKey: GEMINI_API_KEY,
      );

      final prompt = '''
You are an expert CSS (Central Superior Services) exam preparation coach. Based on the comprehensive quiz results below, create a highly personalized 30-day study plan.

$performanceData

INSTRUCTIONS:
1. Create a detailed 30-day study plan that prioritizes weak subjects and topics
2. Allocate more time to subjects with accuracy below 70%
3. Include revision days for strong subjects (accuracy > 85%)
4. Suggest specific topics and activities for each day
5. Include weekly mock tests to track progress
6. Provide time estimates for each day's study plan
7. Include motivational tips and study strategies

FORMAT YOUR RESPONSE AS:
- Week-by-week breakdown (4 weeks)
- Daily tasks with specific subjects and topics
- Estimated study hours per day
- Recommended resources or activities
- Weekly assessment plan

Focus on:
- Weak topics that need immediate attention
- Balanced coverage of all subjects
- Regular revision schedule
- Mock test schedule
- Study techniques for improvement

Make the plan realistic, achievable, and focused on maximum score improvement.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? 'Failed to generate study plan';

    } catch (e) {
      print('Error generating AI study plan: $e');
      rethrow;
    }
  }

  /// Download study plan as PDF
  Future<void> downloadStudyPlan() async {
    try {
      if (generatedStudyPlan.value.isEmpty) {
        Get.snackbar('Error', 'No study plan to download');
        return;
      }

      isLoading.value = true;

      // Request storage permission
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {

        final pdf = pw.Document();
        final attempt = comprehensiveAttempt.value!;

        // Add content to PDF
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return [
                // Header
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'CSS Study Plan - Personalized',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Quiz Summary
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Comprehensive Quiz Results',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text('Overall Accuracy: ${attempt.overallAccuracy.toStringAsFixed(1)}%'),
                      pw.Text('Score: ${attempt.correctAnswers}/${attempt.totalQuestions}'),
                      pw.Text('Date: ${attempt.completedAt.toString().split(' ')[0]}'),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Subject-wise Performance:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      ...attempt.subjectPerformance.values.map((subj) {
                        return pw.Text(
                          '${subj.subjectName}: ${subj.accuracy.toStringAsFixed(1)}% (${subj.correctAnswers}/${subj.totalQuestions})',
                        );
                      }),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Study Plan
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    '30-Day Study Plan',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  generatedStudyPlan.value,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ];
            },
          ),
        );

        // Save PDF
        final output = await getExternalStorageDirectory();
        final file = File('${output!.path}/CSS_Study_Plan_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(await pdf.save());

        Get.snackbar(
          'Success',
          'Study plan downloaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Open file
        await OpenFile.open(file.path);

      } else {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download PDF',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}