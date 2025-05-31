import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class PostStorage {
  bool _initialized = false;

  PostStorage();

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
    if (kDebugMode) {
      print('Initialized default Firebase app $app');
    }
  }

  Future<Stream<DocumentSnapshot>> getStream() async {
    if (!isInitialized) {
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore.collection('posts').doc('forms').snapshots();
  }

  bool get isInitialized => _initialized;

  Future<Stream<QuerySnapshot>> getFormsStream() async {
    if (!isInitialized) {
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore.collection('posts').snapshots();
  }

  Future<bool> writeForm(String name, String desc, GeoPoint latLng) async {
    try {
      if (!isInitialized) {
        await initializeDefault();
      }
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('posts').add({
        'name': name,
        'description': desc,
        'location': latLng,
      });
      return true;
    } catch (error) {
      if (kDebugMode) {
        print('Failed to write form: $error');
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> readAllForms() async {
    try {
      if (!isInitialized) {
        await initializeDefault();
      }
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore.collection('posts').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Failed to read forms: $error');
      }
      return [];
    }
  }
}
