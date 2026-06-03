import 'dart:io';

import 'package:gideoncomputer/screens/homescreen/main_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/profile/profile_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
                    color: Color(0xFF126E64)),
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF126E64)),
          titleTextStyle: const TextStyle(color: Colors.black),
          centerTitle: true,
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(62, 158, 158, 158),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded,
                      color: Color(0xFF126E64)),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF126E64),
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Identity'),
              // Tab(text: 'Change Password'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EditIdentityScreen(),
            // ChangePasswordOnEditProfileScreen(),
          ],
        ),
      ),
    );
  }
}

class EditIdentityScreen extends StatefulWidget {
  const EditIdentityScreen({super.key});

  @override
  State<EditIdentityScreen> createState() => _EditIdentityScreenState();
}

class _EditIdentityScreenState extends State<EditIdentityScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController fullnameController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<ProfileViewModel>(context, listen: false);
    fullnameController = TextEditingController(
      text: user.userData.fullname ?? '',
    );
  }

  @override
  void dispose() {
    fullnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<ProfileViewModel>(context, listen: false);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar (hanya tampil, tidak bisa diubah) ──
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          user.userData.avatar ?? '',
                        ),
                        onBackgroundImageError: (_, __) {},
                        child: user.userData.avatar == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Full Name ──
                    const Text(
                      'Full Name',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: fullnameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: 'Masukkan nama lengkap',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Email (read only — tidak bisa diubah) ──
                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: user.userData.email ?? '',
                      readOnly: true,
                      enabled: false,
                      style: TextStyle(color: Colors.grey[600]),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: 'Email',
                        helperText: 'Email tidak dapat diubah',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Tombol Save ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(62, 158, 158, 158),
                blurRadius: 15,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isSaving
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;

                    setState(() => isSaving = true);
                    try {
                      await Provider.of<ProfileViewModel>(
                        context,
                        listen: false,
                      ).updateProfile(fullname: fullnameController.text.trim());
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui'),
                          backgroundColor: Color(0xFF126E64),
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => isSaving = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF126E64),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'SAVE CHANGES',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}

class ChangePasswordOnEditProfileScreen extends StatefulWidget {
  const ChangePasswordOnEditProfileScreen({super.key});

  @override
  State<ChangePasswordOnEditProfileScreen> createState() =>
      _ChangePasswordOnEditProfileScreenState();
}

class _ChangePasswordOnEditProfileScreenState
    extends State<ChangePasswordOnEditProfileScreen> {
  var formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  bool _passwordVisible = true;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<ProfileViewModel>(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Old Password'),
                        TextFormField(
                          controller: currentPasswordController,
                          // initialValue: user.userData.password,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            hintText: 'Enter your old password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(_passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                          ),
                          validator: (val) {
                            if (val == null) {
                              return 'Masukkan password saat ini!';
                            } else if (val.length < 4) {
                              return 'Password yang dimasukkan kurang dari 4 karakter!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Password'),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            hintText: 'Enter your password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(_passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                          ),
                          // onChanged: (val) {
                          //   newPasswordController.text = val;
                          // },
                          onSaved: (val) {
                            newPasswordController.text = val!;
                          },
                          validator: (val) {
                            if (val!.length < 4) {
                              return 'Password yang dimasukkan kurang dari 4 karakter!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Confirm Password'),
                        TextFormField(
                          controller: confirmNewPasswordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            hintText: 'Enter the same password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(_passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                          ),
                          // onChanged: (val) {
                          //   confirmNewPasswordController.text = val;
                          // },
                          onSaved: (val) {
                            confirmNewPasswordController.text = val!;
                          },
                          validator: (val) {
                            if (confirmNewPasswordController.text !=
                                newPasswordController.text) {
                              return 'Password yang dimasukkan tidak sama!';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(62, 158, 158, 158),
                blurRadius: 15,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  await user.changePassword(
                    newPasswordController.text,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(index: 3),
                    ),
                  );
                } else {
                  return;
                }
              },
              child: const Text('SAVE CHANGES'),
            ),
          ),
        ),
      ],
    );
  }
}



// class SaveBottomBar extends StatelessWidget {
//   const SaveBottomBar({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 70,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Color.fromARGB(62, 158, 158, 158),
//             blurRadius: 15,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: ElevatedButton(
//           onPressed: () => Navigator.pushNamed(
//             context,
//             '/mainpage',
//           ),
//           child: const Text('SAVE CHANGES'),
//         ),
//       ),
//     );
//   }
// }
