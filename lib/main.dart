import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:try_flutter_5/firebase_options.dart';
import 'package:try_flutter_5/post.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> signInWithGoogle() async {
    final googleUser =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('GoogleSignIn'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in with Google'),
          onPressed: () async {
            signInWithGoogle();
            print(FirebaseAuth.instance.currentUser?.displayName);

            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
                  return const ChatPage();
                }),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}

final postsReference =
    FirebaseFirestore.instance.collection('posts').withConverter<Post>(
  fromFirestore: ((snapshot, _) {
    return Post.fromFireStore(snapshot);
  }),
  toFirestore: ((value, _) {
    return value.toMap();
  }),
);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Post>>(
                stream: postsReference.orderBy('createdAt').snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final post = docs[index].data();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(post.posterImageUrl),
                        ),
                        title: Text(post.posterName),
                        subtitle: Text(post.text),
                      );
                    },
                  );
                }),
          ),
          TextFormField(
            onFieldSubmitted: (text) {
              final user = FirebaseAuth.instance.currentUser!;

              final posterId = user.uid;
              final posterName = user.displayName!;
              final posterImageUrl = user.photoURL!;

              final newDocumentReference = postsReference.doc();

              final newPost = Post(
                text: text,
                createdAt: Timestamp.now(),
                posterName: posterName,
                posterImageUrl: posterImageUrl,
                posterId: posterId,
                reference: newDocumentReference,
              );

              newDocumentReference.set(newPost);
            },
          ),
        ],
      ),
    );
  }
}
