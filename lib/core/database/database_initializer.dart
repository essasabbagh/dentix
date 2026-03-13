import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseInitializer {
  static const dbName = "dentixflow.db";

  static Future<File> getDatabaseFile() async {
    final dir = await getApplicationSupportDirectory();

    final dbFolder = Directory(p.join(dir.path, "database"));

    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }

    final file = File(p.join(dbFolder.path, dbName));

    return file;
  }
}