import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post({
    required this.text,
    required this.createdAt,
    required this.posterName,
    required this.posterImageUrl,
    required this.posterId,
    required this.reference,
  });

  factory Post.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final map = snapshot.data()!;

    return Post(
      text: map['text'],
      createdAt: (map['createdAt'] as Timestamp),
      posterName: map['posterName'],
      posterImageUrl: map['posterImageUrl'],
      posterId: map['posterId'],
      reference: snapshot.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': createdAt,
      'posterName': posterName,
      'posterImageUrl': posterImageUrl,
      'posterId': posterId,
    };
  }

  final String text;
  final Timestamp createdAt;
  final String posterName;
  final String posterImageUrl;
  final String posterId;
  final DocumentReference reference;
}
