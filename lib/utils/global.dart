import 'package:handyman_finder/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth firebaseAuthObject = FirebaseAuth.instance;

User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
