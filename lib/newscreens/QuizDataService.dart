import '../Model/QuizModel.dart';

/// Service to provide quiz data for all CSS subjects
class QuizDataService {
  // English Essay Quizzes
  static List<QuizModel> getEnglishEssayQuizzes() {
    return [
      QuizModel(
        id: 'essay_outline_1',
        subjectId: 'english_essay',
        title: 'Essay Structure Fundamentals',
        quizType: 'Essay Outlines',
        duration: 15,
        passingScore: 70,
        difficulty: 'easy',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'What is the primary purpose of an introduction in an essay?',
            options: [
              'To provide a summary of the essay',
              'To hook the reader and present the thesis statement',
              'To present all arguments in detail',
              'To conclude the essay'
            ],
            correctOptionIndex: 1,
            explanation: 'The introduction should capture attention and clearly present the thesis statement that guides the entire essay.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'How many main paragraphs should a standard CSS essay have?',
            options: ['2-3', '3-5', '5-7', '7-10'],
            correctOptionIndex: 1,
            explanation: 'A well-structured CSS essay typically contains 3-5 main body paragraphs, each developing a distinct point.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'What is the recommended length for a CSS essay?',
            options: ['500-800 words', '800-1200 words', '1200-2000 words', '2000-3000 words'],
            correctOptionIndex: 2,
            explanation: 'CSS essays should ideally be 1200-2000 words to adequately develop arguments while maintaining focus.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'Which element is essential in every body paragraph?',
            options: [
              'A quotation',
              'A topic sentence',
              'A counter-argument',
              'Statistical data'
            ],
            correctOptionIndex: 1,
            explanation: 'Every body paragraph must begin with a clear topic sentence that introduces the main idea of that paragraph.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'What should the conclusion primarily do?',
            options: [
              'Introduce new arguments',
              'Repeat the introduction',
              'Synthesize main points and restate the thesis',
              'Ask rhetorical questions'
            ],
            correctOptionIndex: 2,
            explanation: 'The conclusion should synthesize the main arguments and restate the thesis in light of the evidence presented.',
            points: 1,
          ),
        ],
      ),
      QuizModel(
        id: 'essay_topics_1',
        subjectId: 'english_essay',
        title: 'Current Affairs Essay Topics',
        quizType: 'Topic Analysis',
        duration: 20,
        passingScore: 70,
        difficulty: 'medium',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'When writing on "Climate Change and Pakistan", which aspect is most critical to address?',
            options: [
              'Global warming statistics only',
              'Pakistan-specific vulnerabilities and adaptation strategies',
              'Historical climate data',
              'International climate agreements'
            ],
            correctOptionIndex: 1,
            explanation: 'For CSS essays, relating global issues to Pakistan\'s context and proposing solutions is crucial.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'What makes an essay topic suitable for CSS examination?',
            options: [
              'It\'s controversial',
              'It has contemporary relevance and national importance',
              'It\'s technical',
              'It\'s philosophical'
            ],
            correctOptionIndex: 1,
            explanation: 'CSS essay topics should have contemporary relevance and relate to national or international importance.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'In an essay on "Democracy in Pakistan", what should be the primary focus?',
            options: [
              'History of democracy worldwide',
              'Challenges, achievements, and future prospects in Pakistani context',
              'Democratic theories only',
              'Comparison with Western democracies'
            ],
            correctOptionIndex: 1,
            explanation: 'Essays should analyze Pakistan-specific challenges, achievements, and provide forward-looking perspectives.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'How should you approach an essay on "Youth and Nation Building"?',
            options: [
              'Focus only on problems',
              'Balance challenges with solutions and youth potential',
              'Write about other countries',
              'Discuss only education'
            ],
            correctOptionIndex: 1,
            explanation: 'A balanced approach discussing challenges, solutions, and positive contributions creates a strong essay.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'What type of evidence strengthens an essay most effectively?',
            options: [
              'Personal opinions only',
              'Mix of statistics, expert opinions, and real-world examples',
              'Only quotations',
              'Only theoretical concepts'
            ],
            correctOptionIndex: 1,
            explanation: 'Strong essays combine multiple types of evidence including data, expert views, and concrete examples.',
            points: 1,
          ),
        ],
      ),
    ];
  }

  // English Precis & Composition Quizzes
  static List<QuizModel> getEnglishPrecisCompositionQuizzes() {
    return [
      QuizModel(
        id: 'precis_basics_1',
        subjectId: 'english_precis_composition',
        title: 'Precis Writing Fundamentals',
        quizType: 'Precis Writing',
        duration: 15,
        passingScore: 70,
        difficulty: 'easy',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'What is the ideal length of a precis compared to the original passage?',
            options: ['1/4 of original', '1/3 of original', '1/2 of original', '2/3 of original'],
            correctOptionIndex: 1,
            explanation: 'A precis should be approximately one-third the length of the original passage.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Which point of view should be used in precis writing?',
            options: [
              'First person',
              'Second person',
              'Third person',
              'Mix of all'
            ],
            correctOptionIndex: 2,
            explanation: 'Precis should always be written in third person, maintaining objectivity.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'What should be avoided in a precis?',
            options: [
              'Main ideas',
              'Author\'s viewpoint',
              'Personal opinions and examples',
              'Logical flow'
            ],
            correctOptionIndex: 2,
            explanation: 'A precis must exclude personal opinions, interpretations, and additional examples not in the original.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'How should a precis be titled?',
            options: [
              'Copy the original title',
              'Create a new suitable title',
              'No title needed',
              'Use the first line'
            ],
            correctOptionIndex: 1,
            explanation: 'A precis should have a suitable title that captures the essence of the passage, not the original title.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'What tense should generally be used in precis writing?',
            options: [
              'Future tense',
              'Past tense',
              'Present tense',
              'Mix of tenses'
            ],
            correctOptionIndex: 2,
            explanation: 'Present tense is generally preferred in precis writing to maintain consistency and clarity.',
            points: 1,
          ),
        ],
      ),
      QuizModel(
        id: 'grammar_usage_1',
        subjectId: 'english_precis_composition',
        title: 'Grammar and Usage Essentials',
        quizType: 'Grammar & Usage',
        duration: 20,
        passingScore: 70,
        difficulty: 'medium',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'Identify the correct sentence:',
            options: [
              'Neither of the students have submitted their assignments',
              'Neither of the students has submitted their assignment',
              'Neither of the students has submitted his or her assignment',
              'Neither of the students have submitted his assignment'
            ],
            correctOptionIndex: 2,
            explanation: '"Neither" is singular and requires "has". "His or her" maintains grammatical agreement.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Choose the correct usage:',
            options: [
              'The data are conclusive',
              'The data is conclusive',
              'The datas are conclusive',
              'The datas is conclusive'
            ],
            correctOptionIndex: 0,
            explanation: '"Data" is the plural of "datum" and takes a plural verb in formal writing.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'Which sentence uses the subjunctive mood correctly?',
            options: [
              'If I was rich, I would travel',
              'If I were rich, I would travel',
              'If I am rich, I would travel',
              'If I will be rich, I would travel'
            ],
            correctOptionIndex: 1,
            explanation: 'The subjunctive mood uses "were" for hypothetical or contrary-to-fact situations.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'Identify the sentence with correct parallel structure:',
            options: [
              'She likes reading, writing, and to paint',
              'She likes to read, writing, and painting',
              'She likes reading, writing, and painting',
              'She likes to read, to write, and painting'
            ],
            correctOptionIndex: 2,
            explanation: 'Parallel structure requires consistent grammatical forms: all gerunds or all infinitives.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'Choose the correct preposition:',
            options: [
              'She is angry at me',
              'She is angry with me',
              'She is angry on me',
              'She is angry to me'
            ],
            correctOptionIndex: 1,
            explanation: 'The correct idiom is "angry with" (person) or "angry at" (situation).',
            points: 1,
          ),
        ],
      ),
    ];
  }

  // General Science & Ability Quizzes
  static List<QuizModel> getGeneralScienceQuizzes() {
    return [
      QuizModel(
        id: 'science_mcq_1',
        subjectId: 'general_science_ability',
        title: 'Scientific Concepts - Biology',
        quizType: 'Multiple Choice',
        duration: 15,
        passingScore: 70,
        difficulty: 'medium',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'What is the powerhouse of the cell?',
            options: ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi apparatus'],
            correctOptionIndex: 1,
            explanation: 'Mitochondria generate most of the cell\'s ATP through cellular respiration.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Which blood group is known as the universal donor?',
            options: ['A', 'B', 'AB', 'O'],
            correctOptionIndex: 3,
            explanation: 'O negative blood can be given to patients of any blood type in emergencies.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'What is the normal human body temperature in Celsius?',
            options: ['35°C', '36°C', '37°C', '38°C'],
            correctOptionIndex: 2,
            explanation: 'Normal human body temperature is approximately 37°C or 98.6°F.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'Which vitamin is produced when skin is exposed to sunlight?',
            options: ['Vitamin A', 'Vitamin C', 'Vitamin D', 'Vitamin E'],
            correctOptionIndex: 2,
            explanation: 'Vitamin D is synthesized in the skin upon exposure to UVB radiation from sunlight.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'What is the largest organ in the human body?',
            options: ['Liver', 'Brain', 'Skin', 'Heart'],
            correctOptionIndex: 2,
            explanation: 'The skin is the largest organ, covering approximately 20 square feet in adults.',
            points: 1,
          ),
        ],
      ),
      QuizModel(
        id: 'science_physics_1',
        subjectId: 'general_science_ability',
        title: 'Physics Fundamentals',
        quizType: 'Scientific Reasoning',
        duration: 20,
        passingScore: 70,
        difficulty: 'medium',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'What is the SI unit of force?',
            options: ['Joule', 'Newton', 'Watt', 'Pascal'],
            correctOptionIndex: 1,
            explanation: 'Newton is the SI unit of force, defined as kg⋅m/s².',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Speed of light in vacuum is approximately:',
            options: ['3×10⁶ m/s', '3×10⁷ m/s', '3×10⁸ m/s', '3×10⁹ m/s'],
            correctOptionIndex: 2,
            explanation: 'The speed of light in vacuum is approximately 299,792,458 m/s or 3×10⁸ m/s.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'What happens to the volume of a gas if temperature increases at constant pressure?',
            options: [
              'Decreases',
              'Remains same',
              'Increases',
              'Becomes zero'
            ],
            correctOptionIndex: 2,
            explanation: 'According to Charles\'s Law, volume increases with temperature at constant pressure.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'Which law states "For every action, there is an equal and opposite reaction"?',
            options: [
              'Newton\'s First Law',
              'Newton\'s Second Law',
              'Newton\'s Third Law',
              'Law of Conservation'
            ],
            correctOptionIndex: 2,
            explanation: 'Newton\'s Third Law of Motion describes action-reaction pairs.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'What type of energy is stored in a stretched spring?',
            options: [
              'Kinetic energy',
              'Potential energy',
              'Thermal energy',
              'Chemical energy'
            ],
            correctOptionIndex: 1,
            explanation: 'A stretched or compressed spring stores elastic potential energy.',
            points: 1,
          ),
        ],
      ),
    ];
  }

  // Current Affairs Quizzes
  static List<QuizModel> getCurrentAffairsQuizzes() {
    return [
      QuizModel(
        id: 'current_affairs_1',
        subjectId: 'current_affairs',
        title: 'International Affairs - 2024',
        quizType: 'Current Events Quiz',
        duration: 20,
        passingScore: 70,
        difficulty: 'medium',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'Which organization focuses on global climate action?',
            options: ['WHO', 'UNFCCC', 'UNESCO', 'UNICEF'],
            correctOptionIndex: 1,
            explanation: 'UNFCCC (United Nations Framework Convention on Climate Change) coordinates global climate efforts.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'What is the main goal of Sustainable Development Goals (SDGs)?',
            options: [
              'Military expansion',
              'Global sustainable development by 2030',
              'Space exploration',
              'Digital transformation'
            ],
            correctOptionIndex: 1,
            explanation: 'SDGs are 17 goals set by UN to achieve sustainable development by 2030.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'Which country is NOT a permanent member of UN Security Council?',
            options: ['USA', 'China', 'Russia', 'Germany'],
            correctOptionIndex: 3,
            explanation: 'The five permanent members are USA, UK, France, Russia, and China.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'What does BRICS stand for?',
            options: [
              'Brazil, Russia, India, China, Spain',
              'Brazil, Russia, India, China, South Africa',
              'Belgium, Russia, India, China, Sweden',
              'Brazil, Romania, India, China, Switzerland'
            ],
            correctOptionIndex: 1,
            explanation: 'BRICS comprises Brazil, Russia, India, China, and South Africa.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'Which summit focuses on economic cooperation in Asia-Pacific?',
            options: ['G7', 'G20', 'APEC', 'ASEAN'],
            correctOptionIndex: 2,
            explanation: 'APEC (Asia-Pacific Economic Cooperation) promotes free trade in Asia-Pacific region.',
            points: 1,
          ),
        ],
      ),
    ];
  }

  // Pakistan Affairs Quizzes
  static List<QuizModel> getPakistanAffairsQuizzes() {
    return [
      QuizModel(
        id: 'pakistan_history_1',
        subjectId: 'pakistan_affairs',
        title: 'Pakistan History Fundamentals',
        quizType: 'Historical Events',
        duration: 20,
        passingScore: 70,
        difficulty: 'easy',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'When was Pakistan created?',
            options: ['14 August 1946', '14 August 1947', '14 August 1948', '14 August 1949'],
            correctOptionIndex: 1,
            explanation: 'Pakistan gained independence on 14 August 1947.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Who is known as Quaid-e-Azam?',
            options: [
              'Allama Iqbal',
              'Liaquat Ali Khan',
              'Muhammad Ali Jinnah',
              'Fatima Jinnah'
            ],
            correctOptionIndex: 2,
            explanation: 'Muhammad Ali Jinnah, the founder of Pakistan, is called Quaid-e-Azam (Great Leader).',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'What was the Lahore Resolution passed in?',
            options: ['1930', '1935', '1940', '1945'],
            correctOptionIndex: 2,
            explanation: 'The historic Lahore Resolution demanding separate Muslim state was passed on 23 March 1940.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'Who was the first Prime Minister of Pakistan?',
            options: [
              'Muhammad Ali Jinnah',
              'Liaquat Ali Khan',
              'Khawaja Nazimuddin',
              'Iskander Mirza'
            ],
            correctOptionIndex: 1,
            explanation: 'Liaquat Ali Khan served as the first Prime Minister of Pakistan from 1947-1951.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'When was the first Constitution of Pakistan adopted?',
            options: ['1947', '1956', '1962', '1973'],
            correctOptionIndex: 1,
            explanation: 'Pakistan\'s first Constitution was adopted on 23 March 1956.',
            points: 1,
          ),
        ],
      ),
      QuizModel(
        id: 'pakistan_geography_1',
        subjectId: 'pakistan_affairs',
        title: 'Geography of Pakistan',
        quizType: 'Geography & Demographics',
        duration: 15,
        passingScore: 70,
        difficulty: 'easy',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'What is the highest peak in Pakistan?',
            options: ['Nanga Parbat', 'K2', 'Rakaposhi', 'Tirich Mir'],
            correctOptionIndex: 1,
            explanation: 'K2 (8,611 meters) is the highest peak in Pakistan and second highest in the world.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'Which is the longest river in Pakistan?',
            options: ['Jhelum', 'Chenab', 'Ravi', 'Indus'],
            correctOptionIndex: 3,
            explanation: 'The Indus River, approximately 3,180 km long, is Pakistan\'s longest river.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'How many provinces does Pakistan have?',
            options: ['3', '4', '5', '6'],
            correctOptionIndex: 1,
            explanation: 'Pakistan has four provinces: Punjab, Sindh, Khyber Pakhtunkhwa, and Balochistan.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'Which is the largest province of Pakistan by area?',
            options: ['Punjab', 'Sindh', 'Balochistan', 'KPK'],
            correctOptionIndex: 2,
            explanation: 'Balochistan is the largest province, covering about 44% of Pakistan\'s total area.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'What is the national language of Pakistan?',
            options: ['Punjabi', 'Sindhi', 'Urdu', 'English'],
            correctOptionIndex: 2,
            explanation: 'Urdu is the national language of Pakistan, though English is the official language.',
            points: 1,
          ),
        ],
      ),
    ];
  }

  // Islamic Studies Quizzes
  static List<QuizModel> getIslamicStudiesQuizzes() {
    return [
      QuizModel(
        id: 'islamic_basics_1',
        subjectId: 'islamic_studies',
        title: 'Pillars of Islam',
        quizType: 'Multiple Choice',
        duration: 15,
        passingScore: 70,
        difficulty: 'easy',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'How many pillars of Islam are there?',
            options: ['3', '4', '5', '6'],
            correctOptionIndex: 2,
            explanation: 'There are five pillars of Islam: Shahada, Salat, Zakat, Sawm, and Hajj.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'What is the first pillar of Islam?',
            options: ['Prayer', 'Fasting', 'Declaration of Faith', 'Charity'],
            correctOptionIndex: 2,
            explanation: 'Shahada (Declaration of Faith) is the first pillar of Islam.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'How many times do Muslims pray daily?',
            options: ['3', '4', '5', '6'],
            correctOptionIndex: 2,
            explanation: 'Muslims are required to pray five times daily: Fajr, Dhuhr, Asr, Maghrib, and Isha.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'In which month do Muslims fast?',
            options: ['Muharram', 'Ramadan', 'Shawwal', 'Rajab'],
            correctOptionIndex: 1,
            explanation: 'Muslims fast during the month of Ramadan, the ninth month of Islamic calendar.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'What is Zakat?',
            options: [
              'Fasting',
              'Pilgrimage',
              'Obligatory charity',
              'Prayer'
            ],
            correctOptionIndex: 2,
            explanation: 'Zakat is obligatory charity, typically 2.5% of savings, given to the poor and needy.',
            points: 1,
          ),
        ],
      ),
      QuizModel(
        id: 'quran_knowledge_1',
        subjectId: 'islamic_studies',
        title: 'Quranic Knowledge',
        quizType: 'Quranic Verses',
        duration: 20,
        passingScore: 70,
        difficulty: 'medium',
        createdAt: DateTime.now(),
        questions: [
          QuizQuestion(
            id: 'q1',
            question: 'How many chapters (Surahs) are in the Quran?',
            options: ['110', '114', '120', '124'],
            correctOptionIndex: 1,
            explanation: 'The Holy Quran contains 114 Surahs (chapters).',
            points: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: 'What is the longest Surah in the Quran?',
            options: ['Al-Baqarah', 'Al-Imran', 'An-Nisa', 'Al-Maidah'],
            correctOptionIndex: 0,
            explanation: 'Surah Al-Baqarah (The Cow) is the longest chapter with 286 verses.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q3',
            question: 'Which Surah is known as the heart of the Quran?',
            options: ['Al-Fatiha', 'Yasin', 'Al-Mulk', 'Ar-Rahman'],
            correctOptionIndex: 1,
            explanation: 'Surah Yasin is often called the heart of the Quran.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q4',
            question: 'In which city was the Quran first revealed?',
            options: ['Makkah', 'Madinah', 'Jerusalem', 'Damascus'],
            correctOptionIndex: 0,
            explanation: 'The Quran was first revealed to Prophet Muhammad (PBUH) in Makkah.',
            points: 1,
          ),
          QuizQuestion(
            id: 'q5',
            question: 'How many years did it take for the complete revelation of Quran?',
            options: ['10 years', '15 years', '20 years', '23 years'],
            correctOptionIndex: 3,
            explanation: 'The Quran was revealed over a period of approximately 23 years.',
            points: 1,
          ),
        ],
      ),
    ];
  }

  // Get all quizzes for a specific subject
  static List<QuizModel> getQuizzesForSubject(String subjectId) {
    switch (subjectId) {
      case 'english_essay':
        return getEnglishEssayQuizzes();
      case 'english_precis_composition':
        return getEnglishPrecisCompositionQuizzes();
      case 'general_science_ability':
        return getGeneralScienceQuizzes();
      case 'current_affairs':
        return getCurrentAffairsQuizzes();
      case 'pakistan_affairs':
        return getPakistanAffairsQuizzes();
      case 'islamic_studies':
        return getIslamicStudiesQuizzes();
      default:
        return [];
    }
  }

  // Get all quizzes
  static List<QuizModel> getAllQuizzes() {
    return [
      ...getEnglishEssayQuizzes(),
      ...getEnglishPrecisCompositionQuizzes(),
      ...getGeneralScienceQuizzes(),
      ...getCurrentAffairsQuizzes(),
      ...getPakistanAffairsQuizzes(),
      ...getIslamicStudiesQuizzes(),
    ];
  }
}