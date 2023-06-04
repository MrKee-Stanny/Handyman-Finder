import 'package:firebase_database/firebase_database.dart';
import 'package:handyman_finder/models/user_model.dart';
import 'package:handyman_finder/utils/global.dart';

class HelperMethods {
  //--------------------Doctor--------------------
  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = firebaseAuthObject.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }
}
//------------------------Doctor-------------------------
