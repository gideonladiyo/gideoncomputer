import 'package:gideoncomputer/components/carousel_hero.dart';
import 'package:gideoncomputer/components/logo.dart';
import 'package:gideoncomputer/components/teks_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/course_card.dart';
import '../../model/course/course_viewmodel.dart';
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
            const SizedBox(height: 12),
            SizedBox(
              height: 75,
              child: Consumer<CourseViewModel>(
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
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: vm.allCategory.length,
                    itemBuilder: (context, index) {
                      final category = vm.allCategory[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: InkWell(
                          onTap: () {
                            final courseVM = Provider.of<CourseViewModel>(
                              context,
                              listen: false,
                            );
                            courseVM.filterCourseByCategory(
                              category.categoryName ?? '',
                            );
                            
                            // Switch tab if inside MainPage to preserve bottom navigation bar
                            final mainPageState = context.findAncestorStateOfType<MainPageState>();
                            if (mainPageState != null) {
                              mainPageState.setTab(1);
                            } else {
                              Navigator.pushNamed(context, '/courseScreen');
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 170,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    category.categoryImage ?? '',
                                  ),
                                  backgroundColor: Colors.grey[200],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        category.categoryName ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Explore →',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
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
