import '../Model/SubjectModel.dart';

class CSSSubjectsService {
  // Get all CSS subjects with their materials and quiz types
  static List<SubjectModel> getAllCSSSubjects() {
    return [
      // English Essay
      SubjectModel(
        id: 'english_essay',
        name: 'English Essay',
        icon: '✍️',
        color: '#6366F1',
        description: 'Master essay writing skills',
        quizTypes: [
          'Essay Outlines',
          'Topic Analysis',
          'Argument Building',
          'Essay Structure',
        ],
        materials: [
          EducationalMaterial(
            type: 'book',
            title: 'How to Write Better Essays',
            author: 'Bryan Greetham',
            link: 'https://www.amazon.com/How-Write-Better-Essays-Greetham/dp/1137281642',
            description: 'Comprehensive guide to essay writing',
          ),
          EducationalMaterial(
            type: 'pdf',
            title: 'CSS Essay Writing Guide',
            link: 'https://www.fpsc.gov.pk/downloads',
            description: 'Official FPSC essay writing guidelines',
          ),
          EducationalMaterial(
            type: 'video',
            title: 'Essay Writing Masterclass',
            link: 'https://www.youtube.com/results?search_query=css+essay+writing+tutorial',
            description: 'Video tutorials on CSS essay writing',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'Purdue Online Writing Lab',
            link: 'https://owl.purdue.edu/owl/general_writing/academic_writing/essay_writing/index.html',
            description: 'Comprehensive essay writing resources',
          ),
          EducationalMaterial(
            type: 'practice',
            title: 'Past Papers - Essays',
            link: 'https://www.fpsc.gov.pk/downloads',
            description: 'Previous CSS essay topics and solutions',
          ),
        ],
      ),

      // English (Precis & Composition)
      SubjectModel(
        id: 'english_precis_composition',
        name: 'English (Precis & Composition)',
        icon: '📝',
        color: '#EC4899',
        description: 'Enhance comprehension & writing',
        quizTypes: [
          'Precis Writing',
          'Comprehension',
          'Grammar & Usage',
          'Vocabulary',
        ],
        materials: [
          EducationalMaterial(
            type: 'book',
            title: 'Practical English Usage',
            author: 'Michael Swan',
            link: 'https://www.amazon.com/Practical-English-Usage-Michael-Swan/dp/0194202437',
            description: 'Complete English grammar reference',
          ),
          EducationalMaterial(
            type: 'book',
            title: 'Word Power Made Easy',
            author: 'Norman Lewis',
            link: 'https://archive.org/details/WordPowerMadeEasy_201604',
            description: 'Vocabulary building classic',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'CSS Forums - English Section',
            link: 'https://www.cssforum.com.pk/css-compulsory-subjects/english-precis-composition/',
            description: 'Community discussions and resources',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'Grammarly Blog',
            link: 'https://www.grammarly.com/blog/',
            description: 'Grammar tips and writing advice',
          ),
          EducationalMaterial(
            type: 'practice',
            title: 'Precis Practice Tests',
            link: 'https://www.fpsc.gov.pk/downloads',
            description: 'Practice precis writing exercises',
          ),
        ],
      ),

      // General Science & Ability
      SubjectModel(
        id: 'general_science_ability',
        name: 'General Science & Ability',
        icon: '🔬',
        color: '#10B981',
        description: 'Build scientific knowledge',
        quizTypes: [
          'Multiple Choice',
          'True/False',
          'Scientific Reasoning',
          'General Knowledge',
        ],
        materials: [
          EducationalMaterial(
            type: 'video',
            title: 'Khan Academy - Science',
            link: 'https://www.khanacademy.org/science',
            description: 'Free science video lectures',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'Scientific American',
            link: 'https://www.scientificamerican.com/',
            description: 'Latest scientific discoveries and articles',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'NASA - Science',
            link: 'https://science.nasa.gov/',
            description: 'Space and earth science resources',
          ),
          EducationalMaterial(
            type: 'pdf',
            title: 'General Science Notes',
            link: 'https://www.cssforum.com.pk/css-compulsory-subjects/general-science-ability/',
            description: 'Compiled science notes for CSS',
          ),
          EducationalMaterial(
            type: 'practice',
            title: 'Science MCQs Bank',
            link: 'https://www.fpsc.gov.pk/downloads',
            description: 'Practice multiple choice questions',
          ),
        ],
      ),

      // Current Affairs
      SubjectModel(
        id: 'current_affairs',
        name: 'Current Affairs',
        icon: '🌍',
        color: '#F59E0B',
        description: 'Stay updated with world events',
        quizTypes: [
          'Multiple Choice',
          'Current Events Quiz',
          'Short Answer',
          'Analysis Questions',
        ],
        materials: [
          EducationalMaterial(
            type: 'website',
            title: 'Dawn News',
            link: 'https://www.dawn.com/',
            description: 'Leading Pakistani newspaper',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'The News International',
            link: 'https://www.thenews.com.pk/',
            description: 'Daily news and analysis',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'BBC News',
            link: 'https://www.bbc.com/news',
            description: 'International news coverage',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'Al Jazeera',
            link: 'https://www.aljazeera.com/',
            description: 'Global news and current affairs',
          ),
          EducationalMaterial(
            type: 'pdf',
            title: 'Monthly Current Affairs Digest',
            link: 'https://www.cssforum.com.pk/css-optional-subjects/current-affairs/',
            description: 'Compiled monthly current affairs',
          ),
          EducationalMaterial(
            type: 'practice',
            title: 'Current Affairs MCQs',
            link: 'https://www.fpsc.gov.pk/downloads',
            description: 'Monthly updated MCQs on current affairs',
          ),
        ],
      ),

      // Pakistan Affairs
      SubjectModel(
        id: 'pakistan_affairs',
        name: 'Pakistan Affairs',
        icon: '🇵🇰',
        color: '#8B5CF6',
        description: 'Understand national dynamics',
        quizTypes: [
          'Multiple Choice',
          'Historical Events',
          'Political System',
          'Geography & Demographics',
        ],
        materials: [
          EducationalMaterial(
            type: 'book',
            title: 'Pakistan Affairs for CSS',
            author: 'Ikram Rabbani',
            link: 'https://www.cssforum.com.pk/css-compulsory-subjects/pakistan-affairs/',
            description: 'Comprehensive Pakistan affairs guide',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'Government of Pakistan',
            link: 'https://www.pakistan.gov.pk/',
            description: 'Official government portal',
          ),
          EducationalMaterial(
            type: 'pdf',
            title: 'Pakistan Economic Survey',
            link: 'https://www.finance.gov.pk/survey_2324.html',
            description: 'Annual economic report',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'PBS - Pakistan Bureau of Statistics',
            link: 'https://www.pbs.gov.pk/',
            description: 'Official statistics and data',
          ),
          EducationalMaterial(
            type: 'video',
            title: 'Pakistan History Documentaries',
            link: 'https://www.youtube.com/results?search_query=pakistan+history+documentary',
            description: 'Visual learning resources',
          ),
          EducationalMaterial(
            type: 'practice',
            title: 'Pakistan Affairs MCQs',
            link: 'https://www.fpsc.gov.pk/downloads',
            description: 'Practice questions on Pakistan',
          ),
        ],
      ),

      // Islamic Studies / Comparative Religion
      SubjectModel(
        id: 'islamic_studies',
        name: 'Islamic Studies / Comparative Religion',
        icon: '📖',
        color: '#06B6D4',
        description: 'Explore religious knowledge',
        quizTypes: [
          'Multiple Choice',
          'Quranic Verses',
          'Hadith Knowledge',
          'Comparative Analysis',
        ],
        materials: [
          EducationalMaterial(
            type: 'book',
            title: 'Islamic Studies for CSS',
            author: 'Dogar Publishers',
            link: 'https://www.cssforum.com.pk/css-compulsory-subjects/islamiat-ethics/',
            description: 'Complete Islamic studies guide for CSS',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'Quran.com',
            link: 'https://quran.com/',
            description: 'Online Quran with translations',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'Sunnah.com',
            link: 'https://sunnah.com/',
            description: 'Hadith collection and search',
          ),
          EducationalMaterial(
            type: 'website',
            title: 'IslamicFinder',
            link: 'https://www.islamicfinder.org/',
            description: 'Islamic resources and prayer times',
          ),
          EducationalMaterial(
            type: 'pdf',
            title: 'Islamic Jurisprudence Notes',
            link: 'https://www.cssforum.com.pk/css-compulsory-subjects/islamiat-ethics/',
            description: 'Fiqh and Islamic law concepts',
          ),
          EducationalMaterial(
            type: 'practice',
            title: 'Islamic Studies MCQs',
            link: 'https://www.fpsc.gov.pk/downloads',
            description: 'Practice questions and past papers',
          ),
        ],
      ),
    ];
  }

  // Get subject by ID
  static SubjectModel? getSubjectById(String id) {
    try {
      return getAllCSSSubjects().firstWhere((subject) => subject.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get subjects by enrolled course titles (from enrollment screen)
  static List<SubjectModel> getSubjectsByEnrolledCourses(
      List<String> enrolledCourses) {
    final allSubjects = getAllCSSSubjects();
    return allSubjects
        .where((subject) => enrolledCourses.contains(subject.name))
        .toList();
  }

  // Get material types for a subject
  static Map<String, int> getMaterialTypeCount(SubjectModel subject) {
    final Map<String, int> count = {};
    for (var material in subject.materials) {
      count[material.type] = (count[material.type] ?? 0) + 1;
    }
    return count;
  }

  // Get completed materials count
  static int getCompletedMaterialsCount(SubjectModel subject) {
    return subject.materials.where((m) => m.isCompleted).length;
  }

  // Get material completion percentage
  static double getMaterialCompletionPercentage(SubjectModel subject) {
    if (subject.materials.isEmpty) return 0.0;
    final completed = getCompletedMaterialsCount(subject);
    return (completed / subject.materials.length) * 100;
  }

  // Get quiz type statistics
  static Map<String, dynamic> getQuizTypeStatistics(SubjectModel subject) {
    if (subject.progress == null) {
      return {
        'totalQuizzes': 0,
        'averageAccuracy': 0.0,
        'bestPerformingType': null,
        'worstPerformingType': null,
      };
    }

    final quizTypes = subject.progress!.quizTypeProgress;
    if (quizTypes.isEmpty) {
      return {
        'totalQuizzes': 0,
        'averageAccuracy': 0.0,
        'bestPerformingType': null,
        'worstPerformingType': null,
      };
    }

    final totalQuizzes =
    quizTypes.values.fold(0, (sum, qt) => sum + qt.attemptedQuizzes);
    final avgAccuracy = quizTypes.values.isEmpty
        ? 0.0
        : quizTypes.values.fold(0.0, (sum, qt) => sum + qt.accuracy) /
        quizTypes.length;

    String? bestType;
    String? worstType;
    double bestAccuracy = 0.0;
    double worstAccuracy = 100.0;

    quizTypes.forEach((type, progress) {
      if (progress.accuracy > bestAccuracy) {
        bestAccuracy = progress.accuracy;
        bestType = type;
      }
      if (progress.accuracy < worstAccuracy && progress.attemptedQuizzes > 0) {
        worstAccuracy = progress.accuracy;
        worstType = type;
      }
    });

    return {
      'totalQuizzes': totalQuizzes,
      'averageAccuracy': avgAccuracy,
      'bestPerformingType': bestType,
      'worstPerformingType': worstType,
    };
  }
}