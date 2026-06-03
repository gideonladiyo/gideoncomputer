import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ConfirmPasswordResetScreen extends StatefulWidget {
  const ConfirmPasswordResetScreen({super.key});

  @override
  State<ConfirmPasswordResetScreen> createState() =>
      _ConfirmPasswordResetScreenState();
}

class _ConfirmPasswordResetScreenState
    extends State<ConfirmPasswordResetScreen> {
  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Check Your Email',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 32, top: 14),
              height: 300,
              child: Column(
                children: [
                  Image.asset('assets/email_icon.png', width: 200, height: 200),
                  const SizedBox(height: 26),
                  const Text('Check Your Email',
                      style: TextStyle(fontSize: 28)),
                  const Text(
                    'We sent a password reset link to',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    email ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      ),
                      child: const Text('BACK TO LOGIN'),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t receive the email?'),
                TextButton(
                  onPressed: () async {
                    if (email != null && email.isNotEmpty) {
                      try {
                        EasyLoading.show(status: 'Mengirim ulang...');
                        await Supabase.instance.client.auth.resetPasswordForEmail(
                          email,
                          redirectTo: 'io.supabase.flutter://reset-callback/',
                        );
                        EasyLoading.showSuccess('Link terkirim ulang!');
                      } catch (e) {
                        EasyLoading.showError('Gagal kirim ulang: $e');
                      }
                    }
                  },
                  child: Text(
                    'Resend again',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
