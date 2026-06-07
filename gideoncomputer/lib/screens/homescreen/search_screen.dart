import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/course/course_viewmodel.dart';
import '../../components/course_card.dart';
import '../course/detail_course_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CourseViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Reset search saat keluar
            vm.searchCourseByName('');
            Navigator.pop(context);
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _controller.clear();
                        vm.searchCourseByName('');
                        setState(() {});
                      },
                    )
                  : null,
              hintText: 'Search course...',
              border: InputBorder.none,
            ),
            onChanged: (val) {
              vm.searchCourseByName(val);
              setState(() {}); // update suffixIcon
            },
          ),
        ),
      ),
      body: Consumer<CourseViewModel>(
        builder: (context, courseVM, _) {
          // Belum mulai search
          if (_controller.text.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Cari course yang ingin dipelajari',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Loading
          if (courseVM.isLoadingCourse) {
            return const Center(child: CircularProgressIndicator());
          }

          // Tidak ada hasil
          if (courseVM.allCourse.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada course untuk "${_controller.text}"',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Hasil search
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: courseVM.allCourse.length,
            itemBuilder: (context, index) {
              final course = courseVM.allCourse[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailCourseScreen(courseId: course),
                    ),
                  );
                },
                child: CourseCard(
                  courseImage: course.courseImage ?? '',
                  courseName: course.courseName ?? '',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
