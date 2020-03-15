import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/MainFirestore.dart';

class InitFireStore extends MainFirestore {
  InitFireStore() : super();
  void getTaskData(String i, String x){
  }
  void updateTask(String i, String x){
  }
  void addingTokenData(String t) async {
    DocumentReference docRef = db.collection("users").document(uid);
    bool exists = false;
    await db
        .collection("users")
        .document(uid)
        .get()
        .then((DocumentSnapshot data) {
      exists = data.exists;
    });
    if (!exists)
      docRef.setData({"token": t, "gpa": -1, "currGpa": -1});
    else
      docRef.setData({"token": t}, merge: true);
  }
}