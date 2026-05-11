
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final snapshot = await FirebaseFirestore.instance.collection('jobs').limit(5).get();
  for (var doc in snapshot.docs) {
    print('Job ID: ${doc.id}');
    print('Data: ${doc.data()}');
  }
}
