import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/course/course_viewmodel.dart';
import '../model/profile/profile_viewmodel.dart';
import '../api/course_api.dart';

class EnrollBottomBar extends StatelessWidget {
  final String courseId;
  final String courseName;

  const EnrollBottomBar({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color.fromARGB(62, 158, 158, 158), blurRadius: 15),
        ],
      ),
      child: Row(
        children: [
          // Tombol Hubungi Admin
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _contactAdmin(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF126E64),
                side: const BorderSide(color: Color(0xFF126E64)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.phone_android, size: 18),
              label: const Text(
                'Hubungi Admin',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Tombol Punya Kode
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showCodeDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF126E64),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.vpn_key_rounded, size: 18),
              label: const Text(
                'Punya Kode?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Buka WhatsApp dengan pesan otomatis
  void _contactAdmin(BuildContext context) async {
    const adminPhone = '6281234567890'; // ← ganti dengan nomor admin
    final message = Uri.encodeComponent(
      'Halo Admin, saya ingin mendaftar course *$courseName*. Mohon informasi lebih lanjut. Terima kasih!',
    );
    final url = Uri.parse('https://wa.me/$adminPhone?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  // Dialog input kode
  void _showCodeDialog(BuildContext context) {
    final codeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.vpn_key_rounded, color: Color(0xFF126E64)),
                  SizedBox(width: 8),
                  Text('Masukkan Kode', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masukkan kode course yang kamu dapatkan dari admin.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Contoh: FLUTTER-ABC123',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF126E64),
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                        color: Color(0xFF126E64),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final code = codeController.text.trim().toUpperCase();
                          if (code.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kode tidak boleh kosong'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          try {
                            await _redeemCode(context, code);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF126E64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Tukarkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _redeemCode(BuildContext context, String code) async {
    final courseVM = Provider.of<CourseViewModel>(context, listen: false);
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

    // Validasi dan redeem kode
    await CourseAPI().redeemCourseCode(code, courseId);

    // Refresh enrolled courses
    await profileVM.getEnrolledCourse();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil! Kamu sekarang bisa mengakses course ini.'),
          backgroundColor: Color(0xFF126E64),
        ),
      );
      Navigator.pop(context); // kembali dari detail screen
    }
  }
}
