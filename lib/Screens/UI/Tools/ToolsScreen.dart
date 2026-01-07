import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolsController extends GetxController {
  final RxList<Map<String, dynamic>> tools = <Map<String, dynamic>>[
    {
      'title': 'Quiz Generator',
      'description': 'Create custom quizzes from any topic',
      'icon': Icons.quiz_outlined,
      'color': const Color(0xFF2196F3),
      'route': '/quiz-generator',
    },
    {
      'title': 'Study Timer',
      'description': 'Track your study sessions with Pomodoro',
      'icon': Icons.timer_outlined,
      'color': const Color(0xFF10B981),
      'route': '/study-timer',
    },
    {
      'title': 'Flashcards',
      'description': 'Create and review flashcards',
      'icon': Icons.style_outlined,
      'color': const Color(0xFFF59E0B),
      'route': '/flashcards',
    },
    {
      'title': 'Essay Checker',
      'description': 'Analyze and improve your essays',
      'icon': Icons.spellcheck_outlined,
      'color': const Color(0xFF8B5CF6),
      'route': '/essay-checker',
    },
    {
      'title': 'Progress Tracker',
      'description': 'Visualize your learning progress',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFFEC4899),
      'route': '/progress-tracker',
    },
    {
      'title': 'Study Planner',
      'description': 'Plan your study schedule',
      'icon': Icons.calendar_today_outlined,
      'color': const Color(0xFF06B6D4),
      'route': '/study-planner',
    },
    {
      'title': 'Notes Manager',
      'description': 'Organize your study notes',
      'icon': Icons.note_outlined,
      'color': const Color(0xFFEF4444),
      'route': '/notes',
    },
    {
      'title': 'Mock Test',
      'description': 'Take full-length practice exams',
      'icon': Icons.assignment_outlined,
      'color': const Color(0xFF6366F1),
      'route': '/mock-test',
    },
  ].obs;

  void openTool(String route) {
    // Navigate to tool or show coming soon
    Get.snackbar(
      'Coming Soon',
      'This feature is under development',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      icon: const Icon(Icons.info_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ToolsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Tools',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Section
          _buildHeaderSection(),
          const SizedBox(height: 24),

          // Tools Grid
          _buildToolsGrid(controller),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.build_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Tools',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Boost your productivity with these tools',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(ToolsController controller) {
    return Obx(() => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: controller.tools.length,
      itemBuilder: (context, index) {
        final tool = controller.tools[index];
        return _buildToolCard(tool, controller);
      },
    ));
  }

  Widget _buildToolCard(Map<String, dynamic> tool, ToolsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.openTool(tool['route']),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (tool['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tool['icon'],
                    size: 36,
                    color: tool['color'],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tool['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  tool['description'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}