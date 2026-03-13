import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import 'package:template/core/data/secure_storage_service.dart';
import 'package:template/core/data/storage_service.dart';
import 'package:template/core/utils/file_utils.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

GetIt locator = GetIt.instance;

Future<void> initializeApp() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar and navigation bar appearance
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Allow locator value reassignment
  locator.allowReassignment = true;

  // -------------------------------------------------------------
  //  Register and Initialize FileUtils
  // -------------------------------------------------------------
  await FileUtils.init(); // MUST be awaited before using paths
  locator.registerSingleton<FileUtils>(FileUtils.instance);

  // -------------------------------------------------------------
  // Initialize GetStorage using the support directory
  // -------------------------------------------------------------
  final fileUtils = locator<FileUtils>();

  final storage = GetStorage(
    'AppStorage',
    fileUtils.supportPath,
  );

  await storage.initStorage;

  // Register GetStorage
  locator.registerSingleton<GetStorage>(storage);

  // Register StorageService
  locator.registerLazySingleton<StorageService>(
    () => StorageService(storage),
  );

  // -------------------------------------------------------------
  // Initialize Secure Storage
  // -------------------------------------------------------------
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  locator.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(secureStorage),
  );

  // -------------------------------------------------------------
  // Firebase Services (commented-out in your code)
  // -------------------------------------------------------------
  /*
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    kReleaseMode,
  );

  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(
      errorDetails,
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );
    return true;
  };

  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    AppLog.error('Firebase Messaging initialize failed:');
    AppLog.error('$e');
  }
  */
}
