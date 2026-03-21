import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:dentix/core/utils/app_log.dart';

class GoogleDriveService {
  factory GoogleDriveService() => _instance;
  GoogleDriveService._() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
      AppLog.info('User changed: ${account?.email}', 'GoogleSignIn');
    });
  }

  static final GoogleDriveService _instance = GoogleDriveService._();

  static const _scopes = [
    drive.DriveApi.driveFileScope,
    drive.DriveApi.driveAppdataScope,
  ];

  // TODO: Replace with your actual Windows Client ID from Google Cloud Console
  static const _windowsClientId =
      '1005410756456-u4oc39fu10q2fc6jkman86are4om1u48'
      '.apps.googleusercontent.com';

  // macOS Client ID from Info.plist
  static const _macOSClientId =
      '1005410756456-2lndvo8839olrtaqjc0lcpq933rm8k41'
      '.apps.googleusercontent.com';

  final _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? null
        : (Platform.isWindows ? _windowsClientId : _macOSClientId),
    scopes: _scopes,
  );

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  bool get isSignedIn => _currentUser != null;

  Future<bool> isSignedInAsync() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      AppLog.info(
        'Silent sign in result: ${_currentUser?.email}',
        'GoogleSignIn',
      );
      return _currentUser != null;
    } catch (e) {
      AppLog.error('Silent sign in failed: $e', 'GoogleSignIn');
      return false;
    }
  }

  Future<bool> signIn() async {
    try {
      AppLog.info('Starting sign in process...', 'GoogleSignIn');
      _currentUser = await _googleSignIn.signIn();
      AppLog.info('Sign in completed: ${_currentUser?.email}', 'GoogleSignIn');
      return _currentUser != null;
    } catch (e) {
      AppLog.error('Sign in failed: $e', 'GoogleSignIn');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // disconnect() revokes the token and forces a fresh consent screen on next sign-in
      await _googleSignIn.disconnect();
      _currentUser = null;
      AppLog.info('Successfully disconnected and signed out', 'GoogleSignIn');
    } catch (e) {
      // If disconnect fails, fall back to simple signOut
      await _googleSignIn.signOut();
      _currentUser = null;
      AppLog.error(
        'Disconnect failed, performed standard sign out: $e',
        'GoogleSignIn',
      );
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    if (_currentUser == null) {
      // Try to sign in silently if not signed in
      await isSignedInAsync();
    }
    if (_currentUser == null) return null;

    final authHeaders = await _currentUser!.authHeaders;
    final client = _AuthenticatedClient(authHeaders);
    return drive.DriveApi(client);
  }

  Future<Map<String, String>?> _getAuthHeaders() async {
    if (_currentUser == null) {
      await isSignedInAsync();
    }
    if (_currentUser == null) return null;
    return _currentUser!.authHeaders;
  }

  Future<String?> getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbFolder.path, 'dentixflow.db');
    final file = File(dbPath);
    if (await file.exists()) {
      return dbPath;
    }
    return null;
  }

  Future<bool> uploadBackup() async {
    final dbPath = await getDatabasePath();
    if (dbPath == null) return false;

    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'dentixflow_backup_$timestamp.db';

      final file = File(dbPath);
      final media = drive.Media(
        file.openRead(),
        await file.length(),
      );

      final driveFile = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];

      AppLog.info('Uploading backup: $fileName', 'GoogleDrive');
      final uploadedFile = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      AppLog.info(
        'Backup uploaded successfully: ${uploadedFile.id}',
        'GoogleDrive',
      );
      return uploadedFile.id != null;
    } catch (e) {
      AppLog.error('Upload failed: $e', 'GoogleDrive');
      return false;
    }
  }

  Future<List<BackupInfo>> listBackups() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return [];

    try {
      AppLog.info('Fetching backup list...', 'GoogleDrive');
      final result = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name contains 'dentixflow_backup_' and trashed=false",
        $fields: 'files(id, name, modifiedTime, size)',
        orderBy: 'modifiedTime desc',
      );

      final backups =
          result.files
              ?.map(
                (f) => BackupInfo(
                  id: f.id!,
                  name: f.name!,
                  modifiedTimeString: f.modifiedTime?.toString() ?? '',
                  size: int.tryParse(f.size?.toString() ?? '0') ?? 0,
                ),
              )
              .toList() ??
          [];
      AppLog.info('Found ${backups.length} backups', 'GoogleDrive');
      return backups;
    } catch (e) {
      AppLog.error('List backups failed: $e', 'GoogleDrive');
      return [];
    }
  }

  Future<bool> downloadBackup(String fileId, String localPath) async {
    final authHeaders = await _getAuthHeaders();
    if (authHeaders == null) return false;

    try {
      AppLog.info('Downloading backup: $fileId', 'GoogleDrive');
      final uri = Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
      );
      final request = http.Request('GET', uri);
      request.headers.addAll(authHeaders);

      final streamedResponse = await http.Client().send(request);
      if (streamedResponse.statusCode != 200) {
        AppLog.error(
          'Download failed with status: ${streamedResponse.statusCode}',
          'GoogleDrive',
        );
        return false;
      }

      final file = File(localPath);
      final sink = file.openWrite();

      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
      }
      await sink.close();

      AppLog.info('Download completed successfully', 'GoogleDrive');
      return true;
    } catch (e) {
      AppLog.error('Download failed: $e', 'GoogleDrive');
      return false;
    }
  }
}

class _AuthenticatedClient extends http.BaseClient {
  _AuthenticatedClient(this._headers);

  final Map<String, String> _headers;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(_headers);
    return http.Client().send(request);
  }
}

class BackupInfo {
  BackupInfo({
    required this.id,
    required this.name,
    required this.modifiedTimeString,
    required this.size,
  });

  final String id;
  final String name;
  final String modifiedTimeString;
  final int size;

  DateTime get modifiedTime {
    return DateTime.tryParse(modifiedTimeString) ?? DateTime.now();
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
