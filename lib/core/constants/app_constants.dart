// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Feedback App';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'feedback.db';
  static const int databaseVersion = 1;
  static const String feedbackTable = 'feedback';

  // Routes
  static const String loginRoute = '/';
  static const String userDetailsRoute = '/user-details';
  static const String bugDescriptionRoute = '/bug-description';
  static const String mediaCollectionRoute = '/media-collection';
  static const String thankYouRoute = '/thank-you';

  // Thank You screen auto-redirect delay (seconds)
  static const int thankYouRedirectDelay = 5;

  // CSV Export
  static const String csvFileName = 'feedback_export.csv';

  // Validation
  static const int descriptionMaxLength = 1000;
  static const int bugTitleMaxLength = 100;
}
