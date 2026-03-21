import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'google_drive_service.dart';

class BackupRepository {
  BackupRepository(this._service);
  final GoogleDriveService _service;

  Future<bool> isSignedIn() async {
    return _service.isSignedInAsync();
  }

  Future<bool> signIn() async {
    return _service.signIn();
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  GoogleSignInAccount? get currentUser => _service.currentUser;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _service.onCurrentUserChanged;

  Future<bool> createBackup() async {
    return _service.uploadBackup();
  }

  Future<List<BackupInfo>> getBackups() async {
    return _service.listBackups();
  }

  Future<bool> restoreBackup(BackupInfo backup) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final tempPath = p.join(dbFolder.path, 'temp_restore.db');
    final success = await _service.downloadBackup(backup.id, tempPath);
    if (!success) return false;

    final originalPath = await _service.getDatabasePath();
    if (originalPath == null) return false;

    final originalFile = File(originalPath);
    final backupPath = '$originalPath.backup';

    try {
      if (await originalFile.exists()) {
        await originalFile.copy(backupPath);
      }
      final tempFile = File(tempPath);
      await tempFile.copy(originalPath);
      await tempFile.delete();
      return true;
    } catch (e) {
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.copy(originalPath);
        await backupFile.delete();
      }
      return false;
    }
  }

  Future<String?> getDatabasePath() async {
    return _service.getDatabasePath();
  }
}
