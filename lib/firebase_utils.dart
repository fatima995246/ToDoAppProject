import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/my_users.dart';
import 'model/task.dart';

class FirebaseUtils {
  static CollectionReference<Task> getTasksCollection(String uId) {
    return getUsersCollection()
        .doc(uId)
        .collection(Task.collectionName)
        .withConverter<Task>(
          fromFirestore: ((snapshot, options) =>
              Task.fromFireStore(snapshot.data()!)),
          toFirestore: (task, options) => task.toFireStore(),
        );
  }

  static Future<void> addTaskToFirebase(Task task, String uId) {
    var taskCollection = getTasksCollection(uId); //collection
    DocumentReference<Task> taskDocRef = taskCollection.doc();
    task.id = taskDocRef.id;
    return taskDocRef.set(task);
  }

  static Future<void> deleteTaskFromFireStore(Task task, String uId) {
    return getTasksCollection(uId).doc(task.id).delete();
  }

  static Future<void> editTask(Task task, String uId) {
    return getTasksCollection(uId).doc(task.id).update(task.toFireStore());
  }

  static CollectionReference<MyUser> getUsersCollection() {
    return FirebaseFirestore.instance
        .collection(MyUser.collectionName)
        .withConverter<MyUser>(
          fromFirestore: ((snapshot, options) =>
              MyUser.fromFireStore(snapshot.data())),
          toFirestore: (user, options) => user.toFireStore(),
        );
  }

  static Future<void> addUserToFireStore(MyUser myUser) {
    return getUsersCollection().doc(myUser.id).set(myUser);
  }

  static Future<MyUser?> readUserFromFireStore(String uId) async {
    var querySnapshot = await getUsersCollection().doc(uId).get();
    return querySnapshot.data();
  }

  static Future<void> editIsDone(Task task, String uId) {
    return getTasksCollection(uId).doc(task.id).update({'isDone': task.isDone});
  }
}
