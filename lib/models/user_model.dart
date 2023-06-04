import 'package:firebase_database/firebase_database.dart';

// -----------------Timo------------------------------
class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? businessName;
  String? IDNo;
  String? email;
  String? phone;
  String? address;
  String? skill;
  String? displayPhotoUrl;
  String? role;
  String? status;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.businessName,
    this.IDNo,
    this.email,
    this.phone,
    this.address,
    this.skill,
    this.displayPhotoUrl,
    this.role,
    this.status,
  });

  UserModel.fromSnapshot(DataSnapshot snap) {
    id = snap.key;
    phone = (snap.value as dynamic)["phone"];
    firstName = (snap.value as dynamic)["firstName"];
    lastName = (snap.value as dynamic)["lastName"];
    businessName = (snap.value as dynamic)["businessName"];
    IDNo = (snap.value as dynamic)["IDNo"];
    email = (snap.value as dynamic)["email"];
    phone = (snap.value as dynamic)["phone"];
    address = (snap.value as dynamic)["address"];
    skill = (snap.value as dynamic)["skill"];
    displayPhotoUrl = (snap.value as dynamic)["displayPhotoUrl"];
    role = (snap.value as dynamic)["role"];
    status = (snap.value as dynamic)["status"];
  }
}

// -----------------Timo------------------------------