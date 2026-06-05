// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/bug_description/bloc/bug_bloc.dart';
import 'features/export/bloc/export_bloc.dart';
import 'features/export/services/csv_export_service.dart';
import 'features/feedback_cubit/feedback_cubit.dart';
import 'features/media_collection/bloc/media_bloc.dart';
import 'features/user_details/bloc/user_details_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up get_it dependency injection
  setupDI();

  runApp(const FeedbackApp());
}

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC — manages Google Sign-In / Firebase Auth state
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),

        // FeedbackCubit — accumulates form data across all screens
        // Data is committed to DB only on final Submit (Screen 4)
        BlocProvider<FeedbackCubit>(
          create: (_) => FeedbackCubit(),
        ),

        // UserDetails BLoC — form validation for Screen 2
        BlocProvider<UserDetailsBloc>(
          create: (_) => UserDetailsBloc(),
        ),

        // Bug BLoC — form validation for Screen 3
        BlocProvider<BugBloc>(
          create: (_) => BugBloc(),
        ),

        // Media BLoC — image/video file picking for Screen 4
        BlocProvider<MediaBloc>(
          create: (_) => MediaBloc(),
        ),

        // Export BLoC — biometric auth + CSV generation
        BlocProvider<ExportBloc>(
          create: (_) => ExportBloc(
            csvExportService: GetIt.instance<CsvExportService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Feedback App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
