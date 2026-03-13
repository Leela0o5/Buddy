class AppConstants {
  // App name and version
  static const String appName = 'Buddy';
  static const String appVersion = '1.0.0';
  
  // Focus session durations (in min)
  static const int quickStart = 5;      // Start Small Mode
  static const int quickFocus = 10;     // Quick focus
  static const int normalFocus = 15;    // Standard focus
  static const int deepFocus = 25;      // Deep work
  
  static const List<int> allSessionDurations = [
    quickStart,
    quickFocus,
    normalFocus,
    deepFocus,
  ];
  
  // Timing constants
  static const int distractionAlertDelayMs = 100; // Check for distraction after 100ms of app pause
  static const int hapticFeedbackIntervalMs = 60000; // Vibrate every minute
  
  // Analytics thresholds
  static const int burnoutSessionThreshold = 4; // Alert after 4 sessions
  static const int burnoutTimeWindowMinutes = 120; // Within 2 hours
  
  // Notification timing (24-hour format)
  static const int morningReminderHour = 9;     // 9 AM
  static const int afternoonReminderHour = 13;  // 1 PM
  static const int eveningReminderHour = 16;    // 4 PM
  
  // UI Sizing
  static const double largeButtonHeight = 56;
  static const double mediumButtonHeight = 48;
  static const double smallButtonHeight = 40;
  
  // Animation durations
  static const Duration timerAnimationDuration = Duration(milliseconds: 500);
  static const Duration confettiDuration = Duration(seconds: 3);
  static const Duration fadeInDuration = Duration(milliseconds: 300);
  
  // Hive Box Names
  static const String focusSessionsBox = 'focus_sessions';
  static const String tasksBox = 'tasks';
  static const String reflectionsBox = 'reflections';
  static const String preferencesBox = 'preferences';
}

/// String constants for UI text, messages, and labels
class AppStrings {
  // Navigation
  static const String homeTab = 'Focus';
  static const String tasksTab = 'Tasks';
  static const String analyticsTab = 'Insights';
  static const String settingsTab = 'Settings';
  
  // Home Screen
  static const String startFocus = 'Start Focus';
  static const String startSmallMode = 'Start Small (5 min)';
  static const String selectDuration = 'Session Length';
  static const String todaySessions = 'Sessions Today';
  static const String currentStreak = 'Current Streak';
  
  // Timer Screen
  static const String focusSession = 'Focus Session';
  static const String timeRemaining = 'Time Remaining';
  static const String sessionComplete = 'Session Complete!';
  static const String pauseSession = 'Pause';
  static const String resumeSession = 'Resume';
  static const String cancelSession = 'Cancel';
  static const String youHaveBeenFocusing = 'You\'ve been focusing for';
  
  // Task Manager
  static const String addTask = 'Add Task';
  static const String taskTitle = 'Task';
  static const String subtasks = 'Subtasks';
  static const String noTasks = 'No tasks yet.\nAdd one to get started!';
  
  // Reflection
  static const String howWasFocus = 'How was your focus?';
  static const String whatHelpedYouFocus = 'What helped you focus?';
  static const String energyLevel = 'Energy Level';
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';
  
  // Analytics
  static const String focusAnalytics = 'Focus Analytics';
  static const String totalFocusTime = 'Total Focus Time';
  static const String sessionsCompleted = 'Sessions Completed';
  static const String bestFocusHours = 'Best Focus Hours';
  static const String distractionRate = 'Distraction Rate';
  
  // Settings
  static const String settings = 'Settings';
  static const String theme = 'Theme';
  static const String darkMode = 'Dark Mode';
  static const String notifications = 'Notifications';
  static const String enableNotifications = 'Enable Notifications';
  static const String hapticFeedback = 'Haptic Feedback';
  static const String soundFeedback = 'Sound';
  
  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  
  // Messages
  static const String distractionDetected = 'Looks like you got distracted. Want to resume?';
  static const String burnoutAlert = 'You\'ve completed multiple sessions. Take a break!';
  static const String encouragement = 'Great focus! Keep it up, buddy!';
}