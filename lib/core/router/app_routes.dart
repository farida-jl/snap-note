/// Route names are the navigation API; URL patterns live in app_router.dart.
abstract final class AppRoutes {
  static const library = 'library';
  static const collections = 'collections';
  static const profile = 'profile';
  static const newNote = 'new-note';
  static const note = 'note';
  static const newPocketLink = 'new-pocket-link';
  static const pocketLink = 'pocket-link';
  static const editPocketLink = 'edit-pocket-link';
  static const newCollection = 'new-collection';
  static const collection = 'collection';

  static Map<String, String> id(int value) {
    assert(value > 0, 'Route IDs must be positive.');
    return {'id': value.toString()};
  }

  static int? parseId(String? value) {
    if (value == null || !RegExp(r'^[0-9]+$').hasMatch(value)) return null;
    final id = int.tryParse(value);
    return id != null && id > 0 ? id : null;
  }
}
