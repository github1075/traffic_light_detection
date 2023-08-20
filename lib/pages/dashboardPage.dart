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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjust the height as needed
        child: Container(
          decoration: BoxDecoration(
            color: Colors.indigo[400],
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20), // Adjust the radius as needed
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Traffic Light Detection',
              style: TextStyle(fontSize: 24), // Adjust the font size as needed
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CreatePostPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      drawer: DrawerPage(),
      body: Center(child: PostPage()),
    );
  }
}
