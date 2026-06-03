import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/certificate/certificate_model.dart';

class SupabaseCertificateAPI {
  final supabase = Supabase.instance.client;

  // Ambil semua certificate milik user
  Future<List<CertificateModel>> fetchMyCertificates() async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('certificates')
        .select('''
          *,
          course:courses (*)
        ''')
        .eq('user_id', user!.id)
        .order('issued_at', ascending: false);

    return (response as List).map((e) => CertificateModel.fromJson(e)).toList();
  }

  // Cek apakah user sudah punya certificate untuk course tertentu
  Future<CertificateModel?> fetchCertificateByCourse(String courseId) async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('certificates')
        .select('''
          *,
          course:courses (*)
        ''')
        .eq('user_id', user!.id)
        .eq('course_id', courseId)
        .maybeSingle();

    if (response == null) return null;
    return CertificateModel.fromJson(response);
  }
}
