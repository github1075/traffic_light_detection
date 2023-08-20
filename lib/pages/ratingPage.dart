import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double rating = 0.0;
  late double userRating;
  late double averageRating;
  late bool isUserRatingLoaded;
  late bool isAverageRatingLoaded;

  final CollectionReference ratingsCollection =
  FirebaseFirestore.instance.collection('Ratings');
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    userRating = 0.0;
    averageRating = 0.0;
    isUserRatingLoaded = false;
    isAverageRatingLoaded = false;
    loadUserRating();
    loadAverageUserRating();
  }

  Future<void> loadUserRating() async {
    DocumentSnapshot docSnapshot = await ratingsCollection.doc(uid).get();
    isUserRatingLoaded = docSnapshot.exists;
    if (isUserRatingLoaded) {
      userRating = docSnapshot.get('userRating');
    } else {
      await ratingsCollection.doc(uid).set({'userRating': userRating});
    }
    setState(() {});
  }

  Future<void> loadAverageUserRating() async {
    double totalRating = 0.0;
    int count = 0;
    QuerySnapshot querySnapshot = await ratingsCollection.get();
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      totalRating += data['userRating'] ?? 0;
      count++;
    });

    averageRating = count > 0 ? totalRating / count : 0.0;
    isAverageRatingLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isUserRatingLoaded && isAverageRatingLoaded)
              Column(
                children: [
                  Text('Your Rating: $userRating'),
                  SizedBox(height: 20),
                  Text('App Rating: ${averageRating.toStringAsFixed(2)}'),
                  SizedBox(height: 20),
                  RatingBar.builder(
                    initialRating: userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (newRating) async {
                      await ratingsCollection.doc(uid).update({'userRating': newRating});
                      setState(() {
                        userRating = newRating;
                        loadAverageUserRating();
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Rating: $userRating',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else
              CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
