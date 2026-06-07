import 'package:gideoncomputer/screens/screen.dart';
import 'package:flutter/material.dart';

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({super.key});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(62, 158, 158, 158),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left_outlined,
                    color: Color(0xFFD32F2F)),
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFD32F2F)),
          titleTextStyle: const TextStyle(color: Colors.black),
          centerTitle: true,
          title: const Text(
            'My Course',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(62, 158, 158, 158),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_outline,
                      color: Color(0xFFD32F2F)),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFD32F2F),
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Progress'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ActiveCourseScreen(),
            ProgressCourseScreen(),
          ],
        ),
      ),
    );
  }
}
