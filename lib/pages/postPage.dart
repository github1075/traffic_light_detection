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
      appBar: AppBar(
        title: Text('Post Page'),
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the user's profile picture (if available)
              status['profilePicture'] != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(status['profilePicture']),
              )
                  : SizedBox.shrink(), // Or show nothing if the profile picture is null
              Text(
                '${status['userName']}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('dd MMM, yyyy HH:mm')
                    .format(status['timestamp'].toDate()),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                status['text'],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Container(
            child: status['image'] != null
                ? Image.network(status['image'])
                : null,
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up),
                color: isLiked ? Colors.blue : Colors.grey,
                onPressed: () {
                  // ... Like/Unlike functionality ...
                },
              ),
              Text(
                "${status['likes']} Likes  ",
                style: const TextStyle(color: Colors.grey),
              ),
              IconButton(
                icon: const Icon(Icons.comment_bank_outlined),
                color: Colors.grey,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CommentPage(url: statusId)));
                },
              ),
              status['comments'] == 0
                  ? const Text(
                "0 Comments  ",
                style: TextStyle(color: Colors.grey),
              )
                  : Text(
                "${status['comments']} Comments",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
