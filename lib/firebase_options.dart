import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_1a4BIdre7YzzWYFv-njolhltMDyeitE',
    appId: '1:476583007511:web:khuyenmaitram',
    messagingSenderId: '476583007511',
    projectId: 'chamcongtram',
    authDomain: 'chamcongtram.firebaseapp.com',
    storageBucket: 'chamcongtram.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_1a4BIdre7YzzWYFv-njolhltMDyeitE',
    appId: '1:476583007511:android:1e6061907be9bb65ce1352',
    messagingSenderId: '476583007511',
    projectId: 'chamcongtram',
    storageBucket: 'chamcongtram.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYayXy1_hUz04C3iJo9-lX2ruAsDMqm50',
    appId: '1:476583007511:ios:53970f3be146a349ce1352',
    messagingSenderId: '476583007511',
    projectId: 'chamcongtram',
    storageBucket: 'chamcongtram.firebasestorage.app',
    iosBundleId: 'com.tram.khuyenMaiTram',
  );
}
