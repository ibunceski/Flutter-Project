// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:notesapp/extensions/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;

// import 'package:notesapp/services/crud/crud_exceptions.dart';

// class NotesService {
//   Database? _db;

//   DatabaseUser? _user;

//   List<DatabaseNote> _notes = [];
//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController =
//         StreamController<List<DatabaseNote>>.broadcast(onListen: () {
//       _notesStreamController.sink.add(_notes);
//     });
//   } //singleton
//   factory NotesService() => _shared;

//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter(
//         (note) {
//           final currrentUser = _user;
//           if (currrentUser != null) {
//             return note.userId == currrentUser.id;
//           } else {
//             throw UserShouldBeSetBeforeReadingAllNotesException();
//           }
//         },
//       );

//   Future<DatabaseUser> getOrCreateUser(
//       {required String email, bool setAsCurrentUser = true}) async {
//     try {
//       final user = await findUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUserException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       await db.execute(createUserTable);
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //catch
//     }
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: "email = ?",
//       whereArgs: [email.toLowerCase()],
//     );

//     if (deletedCount != 1) {
//       throw CouldNotDeleteUserException();
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: "email = ?",
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isNotEmpty) {
//       throw UserAlreadyExistsException();
//     }

//     final userId =
//         await db.insert(userTable, {emailColumn: email.toLowerCase()});

//     return DatabaseUser(id: userId, email: email);
//   }

//   Future<DatabaseUser> findUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: "email = ?",
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isEmpty) {
//       throw CouldNotFindUserException();
//     }

//     return DatabaseUser.fromRow(results.first);
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final dbUser = await findUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUserException();
//     }

//     const text = "";

//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final deletedCount =
//         await db.delete(noteTable, where: "id = ?", whereArgs: [id]);

//     if (deletedCount == 0) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return await db.delete(noteTable);
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final result = await db.query(
//       noteTable,
//       limit: 1,
//       where: "id = ?",
//       whereArgs: [id],
//     );

//     if (result.isEmpty) {
//       throw CouldNotFindNoteException();
//     } else {
//       final note = DatabaseNote.fromRow(result.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final notes = await db.query(noteTable);

//     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }

//   Future<DatabaseNote> updateNote(
//       {required DatabaseNote note, required String text}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     await getNote(id: note.id);

//     final updatesCount = await db.update(
//       noteTable,
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: "id = ?",
//       whereArgs: [note.id],
//     );

//     if (updatesCount == 0) {
//       throw CouldNotUpdateNoteException();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((currNote) => currNote.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({required this.id, required this.email});

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => "Person, ID = $id, email = $email";

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   String toString() =>
//       "Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text";

//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = "notes.db";
// const noteTable = "note";
// const userTable = "user";
// const idColumn = 'id';
// const emailColumn = "email";
// const userIdColumn = "user_id";
// const textColumn = "text";
// const isSyncedWithCloudColumn = "is_synced_with_cloud";
// const createUserTable = '''
//   CREATE TABLE IF NOT EXISTS "user" (
//     "id"	INTEGER NOT NULL,
//     "email"	TEXT NOT NULL UNIQUE,
//     PRIMARY KEY("id" AUTOINCREMENT)
//     );
//   ''';
// const createNoteTable = '''
//   CREATE TABLE IF NOT EXISTS "note" (
//     "id"	INTEGER NOT NULL,
//     "user_id"	INTEGER NOT NULL,
//     "text"	TEXT,
//     "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//     PRIMARY KEY("id" AUTOINCREMENT),
//     FOREIGN KEY("user_id") REFERENCES "user"("id")
//   );
// ''';
