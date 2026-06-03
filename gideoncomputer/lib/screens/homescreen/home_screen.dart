import 'package:gideoncomputer/components/carousel_hero.dart';
import 'package:gideoncomputer/components/logo.dart';
import 'package:gideoncomputer/components/teks_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/category_card.dart';
import '../../components/course_card.dart';
import '../../model/course/course_viewmodel.dart';
import '../../model/profile/profile_viewmodel.dart';
import '../screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print('🟡 [HomeScreen] initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🟡 [HomeScreen] addPostFrameCallback fired');
      final vm = Provider.of<CourseViewModel>(context, listen: false);
      print('🟡 [HomeScreen] calling getAllCategory...');
      vm.getAllCategory();
      print('🟡 [HomeScreen] calling getAllCourse...');
      vm.getAllCourse();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🔵 [HomeScreen] build called');
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Logo()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CarouselHero(),
            const SizedBox(height: 8),
            const Text(
              'Explore Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Consumer<CourseViewModel>(
              builder: (context, vm, child) {
                print(
                  '🔵 [HomeScreen] Category Consumer rebuild — isLoadingCategory=${vm.isLoadingCategory}, count=${vm.allCategory.length}',
                );
                if (vm.isLoadingCategory) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.allCategory.isEmpty) {
                  return const Center(child: Text('Belum ada kategori.'));
                }
                return GridView.builder(
                  itemCount: vm.allCategory.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      img: vm.allCategory[index].categoryImage ?? '',
                      title: vm.allCategory[index].categoryName ?? '',
                      desc: vm.allCategory[index].description ?? '',
                      onTap: () {
                        // Filter course by category lalu navigasi ke CourseScreen
                        final courseVM = Provider.of<CourseViewModel>(
                          context,
                          listen: false,
                        );
                        courseVM.filterCourseByCategory(
                          vm.allCategory[index].categoryName ?? '',
                        );
                        Navigator.pushNamed(context, '/course');
                      },
                    );
                  },
                );
              },
            ),
            TeksBanner(title: 'Top Course'),
            Consumer<CourseViewModel>(
              builder: (context, vm, child) {
                print(
                  '🔵 [HomeScreen] Course Consumer rebuild — isLoadingCourse=${vm.isLoadingCourse}, count=${vm.allCourse.length}',
                );
                if (vm.isLoadingCourse) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.allCourse.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada kursus tersedia.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                final displayCount = vm.allCourse.length < 3
                    ? vm.allCourse.length
                    : 3;
                print('🔵 [HomeScreen] Rendering $displayCount course cards');
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: displayCount,
                  itemBuilder: (context, index) {
                    final course = vm.allCourse[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailCourseScreen(courseId: course),
                          ),
                        );
                      },
                      child: CourseCard(
                        courseImage: course.courseImage ?? '-',
                        courseName: course.courseName ?? '-',
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
