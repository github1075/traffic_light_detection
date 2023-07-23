import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double rating=0.0;


  bool isDocExists=false;
  final CollectionReference ratingsCollection = FirebaseFirestore.instance.collection('Ratings');
  final String uid = (FirebaseAuth.instance.currentUser?.uid).toString() ;
  //user rating
  Future<double?> getUserRating()async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Ratings').doc(uid).get();
    isDocExists = docSnapshot.exists;
    if (isDocExists) {
      rating=await docSnapshot.get("userRating");
    }
    else {
      FirebaseFirestore.instance.collection('Ratings').doc(uid).set({
        'userRating': rating
      });
    }
    return rating;
  }
  //average rating
  Future<double> getAverageUserRating() async {
    double averageRating=0.0;
    double totalRating=0.0;
    int count = 0;
    await ratingsCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalRating += data['userRating'] ?? 0;
        count++;

      });
    });
   print(count);
    averageRating=(totalRating / count);
    return averageRating ;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      getUserRating();
      getAverageUserRating();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate This App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<double?>(
              future: getUserRating(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Your Rating=${snapshot.data}');
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
            SizedBox(height: 20,),
            FutureBuilder<double?>(
              future: getAverageUserRating(),
              builder: (context,snapshot){
                if(snapshot.hasData){
                  return Text("App Rating=${snapshot.data}");
                }
                else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),

            RatingBar.builder(
              initialRating:rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                ratingsCollection.doc(uid).update({
                  'userRating':rating
                });
                setState(() {
                  this.rating = rating;
                  getAverageUserRating();
                });
              },
            ),
            SizedBox(height: 10.0),
            Text('Rating : $rating',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
