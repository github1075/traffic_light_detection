
import 'package:flutter/material.dart';
import 'package:traffic_light_detection/pages/createPostPage.dart';
import 'package:traffic_light_detection/pages/drawerPage.dart';
import 'package:traffic_light_detection/pages/postPage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:Text(
          'Traffic Light Detection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions:  [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePostPage()),
              );
            },
          ),
        ],
      ),
      drawer: DrawerPage(),
      body: Center(child: PostPage()),
    );
  }
}
