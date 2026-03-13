import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';

/// A reusable utility class that provides high-level methods for working
/// with files and directories in Flutter.
///
/// Supports:
/// - Getting paths of cache, support, documents, and temporary dirs
/// - Saving, reading, writing, appending and deleting files
/// - Copying, moving, renaming files
/// - Checking for existence
/// - Listing files inside directories
///
/// Usage:
///   await FileUtils.init();  // MUST be called before using the class
///
class FileUtils {
  FileUtils._(); // Singleton private constructor

  static final FileUtils instance = FileUtils._();

  static Directory? _cacheDir;
  static Directory? _supportDir;
  static Directory? _documentsDir;
  static Directory? _temporaryDir;

  static final _sep = Platform.pathSeparator;

  /// MUST be called once before accessing directory paths.
  static Future<void> init() async {
    _cacheDir = await getApplicationCacheDirectory();
    _supportDir = await getApplicationSupportDirectory();
    _documentsDir = await getApplicationDocumentsDirectory();
    _temporaryDir = await getTemporaryDirectory();
  }

  // ---------------------------------------------------------------------------
  // Directory Getters
  // ---------------------------------------------------------------------------

  String get cachePath => _cacheDir!.path;
  String get supportPath => _supportDir!.path;
  String get documentsPath => _documentsDir!.path;
  String get temporaryPath => _temporaryDir!.path;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns a valid file path inside any directory.
  String filePath(String directory, String fileName) =>
      '$directory$_sep$fileName';

  /// Ensures a directory exists (creates it if not).
  Future<void> ensureDir(String directory) async {
    final folder = Directory(directory);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
  }

  // ---------------------------------------------------------------------------
  // File Operations
  // ---------------------------------------------------------------------------

  /// Checks if a file exists in a directory.
  Future<bool> fileExists(String directory, String fileName) async {
    final file = File(filePath(directory, fileName));
    return file.exists();
  }

  /// Reads a file as text.
  Future<String> readFile(String directory, String fileName) async {
    await ensureDir(directory);
    final file = File(filePath(directory, fileName));
    if (!await file.exists()) {
      throw FileSystemException('File not found', file.path);
    }
    return file.readAsString();
  }

  /// Reads a file as raw bytes.
  Future<Uint8List> readBytes(String directory, String fileName) async {
    await ensureDir(directory);
    final file = File(filePath(directory, fileName));
    if (!await file.exists()) {
      throw FileSystemException('File not found', file.path);
    }
    return file.readAsBytes();
  }

  /// Writes (overwrites) text into a file.
  Future<void> writeFile(String directory, String fileName, String data) async {
    await ensureDir(directory);
    final file = File(filePath(directory, fileName));
    await file.writeAsString(data, flush: true);
  }

  /// Writes (overwrites) bytes into a file.
  Future<void> writeBytes(
    String directory,
    String fileName,
    Uint8List data,
  ) async {
    await ensureDir(directory);
    final file = File(filePath(directory, fileName));
    await file.writeAsBytes(data, flush: true);
  }

  /// Appends text to a file.
  Future<void> appendFile(
    String directory,
    String fileName,
    String data,
  ) async {
    await ensureDir(directory);
    final file = File(filePath(directory, fileName));
    await file.writeAsString(data, mode: FileMode.append, flush: true);
  }

  /// Deletes a file by its full path.
  Future<void> deleteFile(String fullPath) async {
    try {
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('deleteFile error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Folder Operations
  // ---------------------------------------------------------------------------

  /// Deletes a folder and all its content.
  Future<void> deleteFolder(String directory) async {
    try {
      final dir = Directory(directory);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('deleteFolder error: $e');
    }
  }

  /// Lists all files inside a folder.
  Future<List<FileSystemEntity>> listFiles(String directory) async {
    final dir = Directory(directory);
    if (!await dir.exists()) return [];
    return dir.list().toList();
  }

  // ---------------------------------------------------------------------------
  // Copy / Move / Rename
  // ---------------------------------------------------------------------------

  /// Copies a file to another directory.
  Future<File> copyFile({
    required String fromDirectory,
    required String toDirectory,
    required String fileName,
  }) async {
    await ensureDir(toDirectory);

    final fromPath = filePath(fromDirectory, fileName);
    final toPath = filePath(toDirectory, fileName);

    final file = File(fromPath);
    if (!await file.exists()) {
      throw FileSystemException('Source file does not exist', fromPath);
    }

    return file.copy(toPath);
  }

  /// Moves (renames) a file.
  Future<File> moveFile({
    required String fromDirectory,
    required String toDirectory,
    required String fileName,
  }) async {
    await ensureDir(toDirectory);

    final fromPath = filePath(fromDirectory, fileName);
    final toPath = filePath(toDirectory, fileName);

    final file = File(fromPath);
    if (!await file.exists()) {
      throw FileSystemException('Source file does not exist', fromPath);
    }

    return file.rename(toPath);
  }
}
