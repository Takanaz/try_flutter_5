import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:try_flutter_5/main.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
        appBar: AppBar(title: const Text('マイページ')),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  user.photoURL!,
                ),
                radius: 40.0,
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName!,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ユーザーID：${user.uid}')),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('登録日：${user.metadata.creationTime!}')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                      return const SignInPage();
                    }),
                    (route) => false,
                  );
                },
                child: const Text('サインアウト'),
              ),
            ],
          ),
        ));
  }
}
