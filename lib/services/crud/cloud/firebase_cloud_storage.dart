import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesapp/services/crud/cloud/cloud_note.dart';
import 'package:notesapp/services/crud/cloud/cloud_storage_constants.dart';
import 'package:notesapp/services/crud/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("notes");

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  void createNewNote({required String userOwnerId}) async {
    await notes.add({
      ownerUserIdFieldName: userOwnerId,
      textFieldName: "",
    });

    Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
      try {
        return await notes
            .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
            .get()
            .then(
              (value) => value.docs.map(
                (doc) {
                  return CloudNote(
                      documentId: doc.id,
                      ownerUserId: doc.data()[ownerUserIdFieldName],
                      text: doc.data()[textFieldName]);
                },
              ),
            );
      } catch (e) {
        throw CouldNotGetAllNotesException();
      }
    }

    Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
        notes.snapshots().map((e) => e.docs
            .map((doc) => CloudNote.fromSnapshot(doc))
            .where((doc) => doc.ownerUserId == ownerUserId));

    Future<void> updateNote(
        {required String documentId, required String text}) async {
      try {
        notes.doc(documentId).update({textFieldName: text});
      } catch (e) {
        throw CouldNotUpdateNoteException();
      }
    }

    Future<void> deleteNote({required String documentId}) async {
      try {
        await notes.doc(documentId).delete();
      } catch (e) {
        throw CouldNotDeleteNoteException();
      }
    }
  }
}
