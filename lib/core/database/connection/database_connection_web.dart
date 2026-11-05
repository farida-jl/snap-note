import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

LazyDatabase createDatabaseConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'snap_note',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    return result.resolvedExecutor;
  });
}
