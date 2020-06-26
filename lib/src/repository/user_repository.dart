// Imports
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:rsa_util/rsa_util.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Constructor
  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
    _googleSignIn = googleSignIn ?? GoogleSignIn();
  
  // Logiar con google
  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = 
      await googleUser.authentication;
    final AuthCredential credential =
      GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );
    
    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser();
  }

  // Logeo con credenciales
  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
  }

 
  Future<void> signUp(String email, String password) async{
    return await _firebaseAuth.createUserWithEmailAndPassword(
                                  email: email,
                                  password: password);                      
  }
  Future<void> registreData(String name, String phone,String lastname, String token,String password )
  {
   
    List<String> keys = RSAUtil.generateKeys(1024);
    final String pubKey = keys[0];
    final String priKey = keys[1];
    _firebaseAuth.currentUser().then((currentUser) => Firestore.instance
                                  .collection("users")
                                  .document(currentUser.uid)
                                  .setData({
                                    "uid": currentUser.uid,
                                    "name": name,
                                    "email": currentUser.email,
                                    "lastname":lastname,
                                    "phone":phone,
                                    "token":token,
                                    "pubkey":pubKey,
                                    "prikey":priKey,
                                    "password":password,
                                  })
                                  .catchError((err) => print(err)))
                              .catchError((err) => print(err));
  }

  // Cerrar cession
  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut()
    ]);
  }

  // Esta logueado
  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  // Obtener usuario
  Future<String> getUser() async {
    return (await _firebaseAuth.currentUser()).email;
  }
 Future<String> getId() async {
    return (await _firebaseAuth.currentUser()).uid;
  }

}
