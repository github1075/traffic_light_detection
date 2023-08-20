import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:traffic_light_detection/pages/commentPage.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('statuses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(child: Text('No posts available'));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return PostCard(document: documents[index]);
            },
          );
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot document;

  const PostCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final status = document.data() as Map<String, dynamic>;
    final statusId = document.id;
    final likedBy = status['likeBy'] as List<dynamic>?;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var user = _auth.currentUser;
    final isLiked = likedBy?.contains(user!.email) ?? false;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the user's profile picture (if available)
            status['profilePicture'] != null
                ? CircleAvatar(
              backgroundImage: NetworkImage(status['profilePicture']),
              radius: 30,
            )
                : SizedBox.shrink(),
            SizedBox(height: 8),
            Text(
              '${status['userName'] ?? ''}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              status['timestamp'] != null
                  ? DateFormat('dd MMM, yyyy HH:mm')
                  .format(status['timestamp'].toDate())
                  : '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status['text'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            status['image'] != null
                ? AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                status['image'],
                fit: BoxFit.cover,
              ),
            )
                : SizedBox.shrink(),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  color: isLiked ? Colors.blue : Colors.grey,
                  onPressed: () {
                    if (!isLiked) {
                      FirebaseFirestore.instance
                          .collection('statuses')
                          .doc(statusId)
                          .update({
                        'likes': FieldValue.increment(1),
                        'likeBy': FieldValue.arrayUnion([user!.email]),
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('statuses')
                          .doc(statusId)
                          .update({
                        'likes': FieldValue.increment(-1),
                        'likeBy': FieldValue.arrayRemove([user!.email]),
                      });
                    }
                  },
                ),
                Text(
                  "${status['likes'] ?? 0} Likes  ",
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  icon: Icon(Icons.comment_bank_outlined),
                  color: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CommentPage(url: statusId)));
                  },
                ),
                Text(
                  "${status['comments'] ?? 0} Comments",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
