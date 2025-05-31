import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stray_finder/firebase_options.dart';
import 'package:stray_finder/create_posts.dart';
import 'package:stray_finder/show_posts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _initialized = false;
  UserCredential? _userCredential;
  GoogleSignInAccount? googleUser;

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
    if (kDebugMode) {
      print('Initialized default app $app');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!_initialized) {
      await initializeDefault();
    }

    googleUser = await GoogleSignIn().signIn();

    if (kDebugMode) {
      if (googleUser != null) {
        print(googleUser!.displayName);
      }
    }

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    _userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    setState(() {});
    return _userCredential!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: getBody(),
      )),
    );
  }

  List<Widget> getBody() {
    List<Widget> body = [];
    if (googleUser == null) {
      signInWithGoogle();
    } else {
      body.add(ListTile(
        leading: GoogleUserCircleAvatar(identity: googleUser!),
        title: Text(googleUser!.displayName ?? ''),
        subtitle: Text(googleUser!.email),
      ));
      body.add(ElevatedButton(
        child: const Text('Make a Post'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Posts())
          );
        },
      ));
      body.add(ElevatedButton(
        child: const Text('View Posts'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostsList())
          );
        },
      ));
      body.add(ElevatedButton(
        child: const Text('Logout'),
        onPressed: () {
          FirebaseAuth.instance.signOut();
          GoogleSignIn().signOut();
          setState(() {
            googleUser = null;
          });
          Navigator.pop(context);
        },
      ));
    }
    return body;
  }
}
