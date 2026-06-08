import 'package:gideoncomputer/model/course/course_viewmodel.dart';
import 'package:gideoncomputer/screens/course/detail_course_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/course_card.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<CourseViewModel>(context, listen: false);
    _selectedCategory = vm.selectedCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.getAllCourse();
      vm.getAllCategory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Reset search field dan kembalikan ke filter category aktif
  void _resetSearch(CourseViewModel vm) {
    _controller.clear();
    vm.filterCourseByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CourseViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text(
          'Course Learning',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search ─────────────────────────────────────────────
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _resetSearch(vm),
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                hintText: 'Search course...',
              ),
              onChanged: (val) {
                setState(() {}); // update suffixIcon
                if (val.isEmpty) {
                  // Kalau search dikosongkan, kembalikan ke filter category aktif
                  vm.filterCourseByCategory(_selectedCategory);
                } else {
                  // Search override filter — filter di client dari _allCourse
                  vm.searchCourseByName(val);
                }
              },
            ),
            const SizedBox(height: 8),

            // ── Filter Category ────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: vm.isLoadingCategory
                  ? const SizedBox(
                      height: 36,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Row(
                      children: [
                        _buildChip(vm, 'All'),
                        ...vm.allCategory.map(
                          (cat) => _buildChip(vm, cat.categoryName ?? ''),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),

            // ── Course List ────────────────────────────────────────
            Expanded(
              child: vm.isLoadingCourse
                  ? const Center(child: CircularProgressIndicator())
                  : vm.allCourse.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _controller.text.isNotEmpty
                                ? 'Tidak ada course untuk "${_controller.text}"'
                                : 'Belum ada kursus tersedia.',
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: vm.allCourse.length,
                      itemBuilder: (context, index) {
                        final course = vm.allCourse[index];
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailCourseScreen(courseId: course),
                              ),
                            );
                          },
                          child: CourseCard(
                            courseImage: course.courseImage ?? '',
                            courseName: course.courseName ?? '',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(CourseViewModel vm, String label) {
    final isSelected = vm.selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        selected: isSelected,
        selectedColor: const Color(0xFFD32F2F),
        backgroundColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFFFFEBEE),
            width: 1.5,
          ),
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategory = label;
            _controller.clear(); // reset search saat ganti category
          });
          vm.filterCourseByCategory(label);
        },
      ),
    );
  }
}
