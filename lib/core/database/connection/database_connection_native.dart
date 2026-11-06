import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase createDatabaseConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final databaseFile = File(p.join(directory.path, 'stash_shelf.sqlite'));

    return NativeDatabase.createInBackground(databaseFile);
  });
}
