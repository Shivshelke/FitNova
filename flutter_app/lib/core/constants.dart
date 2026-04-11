/// API and app-wide constants
class AppConstants {
  // ── Backend API Base URL ──────────────────────────────────────────────────────
  // Use 10.0.2.2 for Android emulator (maps to host machine's localhost)
  // Change to your machine's local IP (e.g., 192.168.1.5) for real device
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // ── Auth endpoints ────────────────────────────────────────────────────────────
  static const String signupEndpoint = '/auth/signup';
  static const String loginEndpoint = '/auth/login';
  static const String googleAuthEndpoint = '/auth/google';
  static const String meEndpoint = '/auth/me';
  static const String profileEndpoint = '/auth/profile';

  // ── Dashboard ─────────────────────────────────────────────────────────────────
  static const String dashboardEndpoint = '/dashboard';

  // ── Workouts ──────────────────────────────────────────────────────────────────
  static const String workoutsEndpoint = '/workouts';
  static const String workoutLogsEndpoint = '/workout-logs';

  // ── Diet ──────────────────────────────────────────────────────────────────────
  static const String mealsEndpoint = '/meals';
  static const String foodSearchEndpoint = '/food/search';
  static const String foodEndpoint = '/food';

  // ── Progress ──────────────────────────────────────────────────────────────────
  static const String progressEndpoint = '/progress';
  static const String weightHistoryEndpoint = '/progress/weight';

  // ── Goals ─────────────────────────────────────────────────────────────────────
  static const String goalsEndpoint = '/goals';
  static const String goalCompletionEndpoint = '/goals/completion';

  // ── AI ────────────────────────────────────────────────────────────────────────
  static const String workoutSuggestionsEndpoint = '/ai/workout-suggestions';
  static const String dietTipsEndpoint = '/ai/diet-tips';

  // ── Secure Storage Keys ───────────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // ── Shared Prefs Keys ─────────────────────────────────────────────────────────
  static const String darkModeKey = 'dark_mode';
  static const String onboardingKey = 'onboarding_complete';

  // ── Fitness Goals ─────────────────────────────────────────────────────────────
  static const Map<String, String> goalLabels = {
    'weight_loss': 'Weight Loss',
    'weight_gain': 'Weight Gain',
    'maintenance': 'Maintenance',
    'muscle_building': 'Muscle Building',
  };

  // ── Meal Types ────────────────────────────────────────────────────────────────
  static const List<String> mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
  static const Map<String, String> mealTypeLabels = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack',
  };
}
