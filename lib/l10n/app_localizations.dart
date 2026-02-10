import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocaleInfo> supportedLocales = [
    LocaleInfo('en', 'English', '🇺🇸'),
    LocaleInfo('ar', 'العربية', '🇸🇦'),
    LocaleInfo('es', 'Español', '🇪🇸'),
    LocaleInfo('fr', 'Français', '🇫🇷'),
    LocaleInfo('de', 'Deutsch', '🇩🇪'),
    LocaleInfo('zh', '中文', '🇨🇳'),
    LocaleInfo('ja', '日本語', '🇯🇵'),
    LocaleInfo('ko', '한국어', '🇰🇷'),
    LocaleInfo('hi', 'हिन्दी', '🇮🇳'),
    LocaleInfo('pt', 'Português', '🇧🇷'),
    LocaleInfo('ru', 'Русский', '🇷🇺'),
    LocaleInfo('tr', 'Türkçe', '🇹🇷'),
    LocaleInfo('id', 'Bahasa Indonesia', '🇮🇩'),
    LocaleInfo('it', 'Italiano', '🇮🇹'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _en,
    'ar': _ar,
    'es': _es,
    'fr': _fr,
    'de': _de,
    'zh': _zh,
    'ja': _ja,
    'ko': _ko,
    'hi': _hi,
    'pt': _pt,
    'ru': _ru,
    'tr': _tr,
    'id': _id,
    'it': _it,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // ===== ENGLISH =====
  static const Map<String, String> _en = {
    'appName': 'Yes Sir',
    'tagline': 'Your order. Executed.',
    'loading': 'Deploying...',
    // Nav
    'navHome': 'Home',
    'navMissions': 'Missions',
    'navCalendar': 'Calendar',
    'navReports': 'Reports',
    // Home
    'goodMorning': 'Good morning',
    'goodAfternoon': 'Good afternoon',
    'goodEvening': 'Good evening',
    'commander': 'Commander',
    'todayMissions': "Today's Missions",
    'upcomingMissions': 'Upcoming Missions',
    'noMissionsToday': 'No missions today',
    'noMissionsTodaySub': 'Your day is clear, Commander.',
    'askAI': 'Ask Private LongCat',
    'viewAll': 'View All',
    'quickActions': 'Quick Actions',
    'newMission': 'New Mission',
    'aiAdvisor': 'AI Advisor',
    'dailyReport': 'Daily Report',
    // Missions
    'searchMissions': 'Search missions...',
    'all': 'All',
    'starred': 'Starred',
    'pending': 'Pending',
    'active': 'Active',
    'completed': 'Completed',
    'noMissions': 'No Missions',
    'createFirst': 'Create your first mission, Commander.',
    'newMissionTitle': 'New Mission',
    'missionTitle': 'Mission Title',
    'missionObjective': 'Mission objective...',
    'missionDetails': 'Details',
    'missionDetailsHint': 'Mission details (optional)...',
    'priorityLevel': 'Priority Level',
    'setDueDate': 'Set due date (optional)',
    'deployMission': 'Deploy Mission',
    'deleteMission': 'Delete Mission',
    'abortMission': 'Abort mission',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'missionDetailsTitle': 'Mission Details',
    'updateStatus': 'Update Status',
    'setReminder': 'Set Reminder',
    'breakDown': 'Break Down with AI',
    // AI
    'commandCenter': 'Command Center',
    'pvtLongcat': 'Pvt. LongCat',
    'readyForOrders': 'Ready for orders',
    'giveOrder': 'Give your order, Commander...',
    'statusReport': 'Status Report',
    'planMyDay': 'Plan My Day',
    'prioritize': 'Prioritize',
    'motivateMe': 'Motivate Me',
    'breakDownTask': 'Break Down Task',
    'weeklyPlan': 'Weekly Plan',
    'aiWelcome': 'Private LongCat reporting for duty.\nGive your first order, Commander.',
    'tokensDepleted': 'Daily token reserves depleted. Tokens reset at midnight.',
    'insufficientTokens': 'Insufficient tokens for this operation.',
    'tokensRemaining': 'tokens remaining today',
    'errorRetry': 'Encountered an error. Please retry your order.',
    // Reports
    'afterActionReport': 'After-Action Report',
    'today': 'Today',
    'total': 'Total',
    'inProgress': 'In Progress',
    'missionDistribution': 'Mission Distribution',
    'noDataYet': 'No mission data yet',
    'aiTokenUsage': 'AI Token Usage',
    'premium': 'Premium',
    'weeklyUsage': 'This week',
    'tokensUsed': 'tokens used',
    'missionStreak': 'Mission Streak',
    'days': 'days',
    'keepItUp': 'Keep it up, Commander!',
    'startStreak': 'Complete a mission to start your streak!',
    // Settings
    'settings': 'Settings',
    'account': 'Account',
    'premiumStatus': 'Premium Status',
    'upgradePremium': 'Upgrade to Premium',
    'premiumActive': 'Premium Active',
    'data': 'Data',
    'clearChat': 'Clear Chat History',
    'clearChatConfirm': 'Delete all chat messages?',
    'clear': 'Clear',
    'about': 'About',
    'version': 'Version',
    'language': 'Language',
    'notifications': 'Notifications',
    'reminderSettings': 'Reminder Settings',
    'enableReminders': 'Enable Reminders',
    'reminderBefore': 'Remind before due',
    'minutes': 'minutes',
    // Reminder
    'reminderTitle': 'Mission Reminder',
    'reminderBody': 'Your mission is due soon',
    'missionDueSoon': 'Mission due in',
    'overdue': 'Overdue',
    // Priorities
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'critical': 'Critical',
    // Statuses
    'statusPending': 'Pending',
    'statusActive': 'Active',
    'statusCompleted': 'Completed',
    'statusFailed': 'Failed',
    // Templates
    'templates': 'Templates',
    'workTemplates': 'Work',
    'personalTemplates': 'Personal',
    'healthTemplates': 'Health',
    // Proactive
    'aiSuggestion': 'AI Suggestion',
    'suggestedMissions': 'Suggested missions based on your patterns',
    'freeTime': 'You have free time. Tackle these missions!',
    'streakBonus': 'Streak bonus! Keep completing missions.',
  };

  // ===== ARABIC =====
  static const Map<String, String> _ar = {
    'appName': 'نعم سيدي',
    'tagline': 'أوامركم. تُنفَّذ.',
    'loading': 'جاري النشر...',
    'navHome': 'الرئيسية',
    'navMissions': 'المهام',
    'navCalendar': 'التقويم',
    'navReports': 'التقارير',
    'goodMorning': 'صباح الخير',
    'goodAfternoon': 'مساء الخير',
    'goodEvening': 'مساء الخير',
    'commander': 'القائد',
    'todayMissions': 'مهام اليوم',
    'upcomingMissions': 'المهام القادمة',
    'noMissionsToday': 'لا مهام لليوم',
    'noMissionsTodaySub': 'يومك خالٍ، أيها القائد.',
    'askAI': 'اسأل الجندي لونغكات',
    'viewAll': 'عرض الكل',
    'quickActions': 'إجراءات سريعة',
    'newMission': 'مهمة جديدة',
    'aiAdvisor': 'مستشار ذكي',
    'dailyReport': 'تقرير يومي',
    'searchMissions': 'بحث في المهام...',
    'all': 'الكل',
    'starred': 'المميزة',
    'pending': 'قيد الانتظار',
    'active': 'نشطة',
    'completed': 'مكتملة',
    'noMissions': 'لا توجد مهام',
    'createFirst': 'أنشئ مهمتك الأولى، أيها القائد.',
    'newMissionTitle': 'مهمة جديدة',
    'missionTitle': 'عنوان المهمة',
    'missionObjective': 'هدف المهمة...',
    'missionDetails': 'التفاصيل',
    'missionDetailsHint': 'تفاصيل المهمة (اختياري)...',
    'priorityLevel': 'مستوى الأولوية',
    'setDueDate': 'تحديد تاريخ الاستحقاق',
    'deployMission': 'نشر المهمة',
    'deleteMission': 'حذف المهمة',
    'abortMission': 'إلغاء المهمة',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'missionDetailsTitle': 'تفاصيل المهمة',
    'updateStatus': 'تحديث الحالة',
    'setReminder': 'تعيين تذكير',
    'breakDown': 'تقسيم بواسطة الذكاء',
    'commandCenter': 'مركز القيادة',
    'pvtLongcat': 'الجندي لونغكات',
    'readyForOrders': 'جاهز للأوامر',
    'giveOrder': 'أعطِ أمرك، أيها القائد...',
    'statusReport': 'تقرير الحالة',
    'planMyDay': 'خطط يومي',
    'prioritize': 'رتب الأولويات',
    'motivateMe': 'حمّسني',
    'breakDownTask': 'قسّم المهمة',
    'weeklyPlan': 'الخطة الأسبوعية',
    'aiWelcome': 'الجندي لونغكات جاهز للخدمة.\nأعطِ أمرك الأول، أيها القائد.',
    'afterActionReport': 'تقرير ما بعد العمل',
    'today': 'اليوم',
    'total': 'الإجمالي',
    'inProgress': 'قيد التنفيذ',
    'missionDistribution': 'توزيع المهام',
    'noDataYet': 'لا توجد بيانات بعد',
    'aiTokenUsage': 'استهلاك رموز الذكاء',
    'premium': 'مميز',
    'settings': 'الإعدادات',
    'account': 'الحساب',
    'language': 'اللغة',
    'notifications': 'الإشعارات',
    'reminderSettings': 'إعدادات التذكير',
    'enableReminders': 'تفعيل التذكيرات',
    'about': 'حول',
    'version': 'الإصدار',
    'low': 'منخفض',
    'medium': 'متوسط',
    'high': 'عالي',
    'critical': 'حرج',
    'templates': 'القوالب',
    'workTemplates': 'العمل',
    'personalTemplates': 'شخصي',
    'healthTemplates': 'الصحة',
  };

  // ===== SPANISH =====
  static const Map<String, String> _es = {
    'appName': 'Sí Señor',
    'tagline': 'Su orden. Ejecutada.',
    'loading': 'Desplegando...',
    'navHome': 'Inicio',
    'navMissions': 'Misiones',
    'navCalendar': 'Calendario',
    'navReports': 'Informes',
    'goodMorning': 'Buenos días',
    'goodAfternoon': 'Buenas tardes',
    'goodEvening': 'Buenas noches',
    'commander': 'Comandante',
    'todayMissions': 'Misiones de hoy',
    'newMission': 'Nueva misión',
    'noMissions': 'Sin misiones',
    'searchMissions': 'Buscar misiones...',
    'all': 'Todo',
    'starred': 'Favoritas',
    'pending': 'Pendiente',
    'active': 'Activa',
    'completed': 'Completada',
    'settings': 'Configuración',
    'language': 'Idioma',
    'commandCenter': 'Centro de mando',
    'pvtLongcat': 'Sold. LongCat',
    'giveOrder': 'Da tu orden, Comandante...',
    'statusReport': 'Informe de estado',
    'planMyDay': 'Planificar mi día',
    'prioritize': 'Priorizar',
    'motivateMe': 'Motívame',
    'afterActionReport': 'Informe post-acción',
    'low': 'Bajo',
    'medium': 'Medio',
    'high': 'Alto',
    'critical': 'Crítico',
  };

  // ===== FRENCH =====
  static const Map<String, String> _fr = {
    'appName': 'Oui Monsieur',
    'tagline': 'Votre ordre. Exécuté.',
    'loading': 'Déploiement...',
    'navHome': 'Accueil',
    'navMissions': 'Missions',
    'navCalendar': 'Calendrier',
    'navReports': 'Rapports',
    'goodMorning': 'Bonjour',
    'goodAfternoon': 'Bon après-midi',
    'goodEvening': 'Bonsoir',
    'commander': 'Commandant',
    'todayMissions': 'Missions du jour',
    'newMission': 'Nouvelle mission',
    'noMissions': 'Aucune mission',
    'searchMissions': 'Rechercher des missions...',
    'settings': 'Paramètres',
    'language': 'Langue',
    'commandCenter': 'Centre de commandement',
    'giveOrder': 'Donnez votre ordre, Commandant...',
    'statusReport': 'Rapport d\'état',
    'planMyDay': 'Planifier ma journée',
    'afterActionReport': 'Rapport après action',
    'low': 'Bas',
    'medium': 'Moyen',
    'high': 'Haut',
    'critical': 'Critique',
  };

  // ===== GERMAN =====
  static const Map<String, String> _de = {
    'appName': 'Jawohl',
    'tagline': 'Ihr Befehl. Ausgeführt.',
    'navHome': 'Start',
    'navMissions': 'Missionen',
    'navCalendar': 'Kalender',
    'navReports': 'Berichte',
    'goodMorning': 'Guten Morgen',
    'goodAfternoon': 'Guten Tag',
    'goodEvening': 'Guten Abend',
    'commander': 'Kommandant',
    'todayMissions': 'Heutige Missionen',
    'newMission': 'Neue Mission',
    'settings': 'Einstellungen',
    'language': 'Sprache',
    'low': 'Niedrig',
    'medium': 'Mittel',
    'high': 'Hoch',
    'critical': 'Kritisch',
  };

  // ===== CHINESE =====
  static const Map<String, String> _zh = {
    'appName': '是的长官',
    'tagline': '您的命令，已执行。',
    'navHome': '首页',
    'navMissions': '任务',
    'navCalendar': '日历',
    'navReports': '报告',
    'goodMorning': '早上好',
    'goodAfternoon': '下午好',
    'goodEvening': '晚上好',
    'commander': '指挥官',
    'todayMissions': '今日任务',
    'newMission': '新任务',
    'noMissions': '暂无任务',
    'searchMissions': '搜索任务...',
    'settings': '设置',
    'language': '语言',
    'commandCenter': '指挥中心',
    'giveOrder': '下达命令，指挥官...',
    'statusReport': '状态报告',
    'planMyDay': '规划我的一天',
    'low': '低',
    'medium': '中',
    'high': '高',
    'critical': '紧急',
  };

  // ===== JAPANESE =====
  static const Map<String, String> _ja = {
    'appName': 'イエッサー',
    'tagline': 'ご命令。実行済み。',
    'navHome': 'ホーム',
    'navMissions': 'ミッション',
    'navCalendar': 'カレンダー',
    'navReports': 'レポート',
    'goodMorning': 'おはようございます',
    'goodAfternoon': 'こんにちは',
    'goodEvening': 'こんばんは',
    'commander': '司令官',
    'todayMissions': '今日のミッション',
    'newMission': '新しいミッション',
    'settings': '設定',
    'language': '言語',
    'low': '低',
    'medium': '中',
    'high': '高',
    'critical': '緊急',
  };

  // ===== KOREAN =====
  static const Map<String, String> _ko = {
    'appName': '예스 서',
    'tagline': '명령 수행 완료.',
    'navHome': '홈',
    'navMissions': '임무',
    'navCalendar': '캘린더',
    'navReports': '보고서',
    'goodMorning': '좋은 아침',
    'goodAfternoon': '좋은 오후',
    'goodEvening': '좋은 저녁',
    'commander': '사령관',
    'todayMissions': '오늘의 임무',
    'newMission': '새 임무',
    'settings': '설정',
    'language': '언어',
    'low': '낮음',
    'medium': '보통',
    'high': '높음',
    'critical': '긴급',
  };

  // ===== HINDI =====
  static const Map<String, String> _hi = {
    'appName': 'जी सर',
    'tagline': 'आपका आदेश। पूरा हुआ।',
    'navHome': 'होम',
    'navMissions': 'मिशन',
    'navCalendar': 'कैलेंडर',
    'navReports': 'रिपोर्ट',
    'goodMorning': 'सुप्रभात',
    'goodAfternoon': 'शुभ दोपहर',
    'goodEvening': 'शुभ संध्या',
    'commander': 'कमांडर',
    'todayMissions': 'आज के मिशन',
    'newMission': 'नया मिशन',
    'settings': 'सेटिंग्स',
    'language': 'भाषा',
    'low': 'कम',
    'medium': 'मध्यम',
    'high': 'उच्च',
    'critical': 'गंभीर',
  };

  // ===== PORTUGUESE =====
  static const Map<String, String> _pt = {
    'appName': 'Sim Senhor',
    'tagline': 'Sua ordem. Executada.',
    'navHome': 'Início',
    'navMissions': 'Missões',
    'navCalendar': 'Calendário',
    'navReports': 'Relatórios',
    'goodMorning': 'Bom dia',
    'goodAfternoon': 'Boa tarde',
    'goodEvening': 'Boa noite',
    'commander': 'Comandante',
    'todayMissions': 'Missões de hoje',
    'newMission': 'Nova missão',
    'settings': 'Configurações',
    'language': 'Idioma',
    'low': 'Baixo',
    'medium': 'Médio',
    'high': 'Alto',
    'critical': 'Crítico',
  };

  // ===== RUSSIAN =====
  static const Map<String, String> _ru = {
    'appName': 'Есть Сэр',
    'tagline': 'Ваш приказ. Выполнен.',
    'navHome': 'Главная',
    'navMissions': 'Миссии',
    'navCalendar': 'Календарь',
    'navReports': 'Отчёты',
    'goodMorning': 'Доброе утро',
    'goodAfternoon': 'Добрый день',
    'goodEvening': 'Добрый вечер',
    'commander': 'Командир',
    'todayMissions': 'Миссии на сегодня',
    'newMission': 'Новая миссия',
    'settings': 'Настройки',
    'language': 'Язык',
    'low': 'Низкий',
    'medium': 'Средний',
    'high': 'Высокий',
    'critical': 'Критический',
  };

  // ===== TURKISH =====
  static const Map<String, String> _tr = {
    'appName': 'Emredersiniz',
    'tagline': 'Emriniz. Yerine getirildi.',
    'navHome': 'Ana Sayfa',
    'navMissions': 'Görevler',
    'navCalendar': 'Takvim',
    'navReports': 'Raporlar',
    'goodMorning': 'Günaydın',
    'goodAfternoon': 'Tünaydın',
    'goodEvening': 'İyi akşamlar',
    'commander': 'Komutan',
    'todayMissions': 'Bugünün görevleri',
    'newMission': 'Yeni görev',
    'settings': 'Ayarlar',
    'language': 'Dil',
    'low': 'Düşük',
    'medium': 'Orta',
    'high': 'Yüksek',
    'critical': 'Kritik',
  };

  // ===== INDONESIAN =====
  static const Map<String, String> _id = {
    'appName': 'Siap Komandan',
    'tagline': 'Perintah Anda. Dilaksanakan.',
    'navHome': 'Beranda',
    'navMissions': 'Misi',
    'navCalendar': 'Kalender',
    'navReports': 'Laporan',
    'goodMorning': 'Selamat pagi',
    'goodAfternoon': 'Selamat siang',
    'goodEvening': 'Selamat malam',
    'commander': 'Komandan',
    'todayMissions': 'Misi hari ini',
    'newMission': 'Misi baru',
    'settings': 'Pengaturan',
    'language': 'Bahasa',
    'low': 'Rendah',
    'medium': 'Sedang',
    'high': 'Tinggi',
    'critical': 'Kritis',
  };

  // ===== ITALIAN =====
  static const Map<String, String> _it = {
    'appName': 'Sì Signore',
    'tagline': 'Il vostro ordine. Eseguito.',
    'navHome': 'Home',
    'navMissions': 'Missioni',
    'navCalendar': 'Calendario',
    'navReports': 'Rapporti',
    'goodMorning': 'Buongiorno',
    'goodAfternoon': 'Buon pomeriggio',
    'goodEvening': 'Buonasera',
    'commander': 'Comandante',
    'todayMissions': 'Missioni di oggi',
    'newMission': 'Nuova missione',
    'settings': 'Impostazioni',
    'language': 'Lingua',
    'low': 'Basso',
    'medium': 'Medio',
    'high': 'Alto',
    'critical': 'Critico',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations._localizedValues.containsKey(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

class LocaleInfo {
  final String code;
  final String name;
  final String flag;

  const LocaleInfo(this.code, this.name, this.flag);
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    notifyListeners();
  }
}
