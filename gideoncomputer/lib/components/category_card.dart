import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String img;
  final String title;
  final String desc;
  final VoidCallback? onTap; // ← tambah

  const CategoryCard({
    super.key,
    required this.img,
    required this.title,
    required this.desc,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ← wrap dengan GestureDetector
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(radius: 30, backgroundImage: NetworkImage(img)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              desc,
              style: TextStyle(fontSize: 11, color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
