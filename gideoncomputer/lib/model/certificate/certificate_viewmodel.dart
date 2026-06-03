import 'package:flutter/material.dart';
import '../../api/supabase_certificate_api.dart';
import 'certificate_model.dart';

class CertificateViewModel extends ChangeNotifier {
  bool isLoading = false;

  List<CertificateModel> _certificates = [];
  List<CertificateModel> get certificates => _certificates;

  CertificateModel? _currentCertificate;
  CertificateModel? get currentCertificate => _currentCertificate;

  // Ambil semua certificate milik user
  Future<void> loadMyCertificates() async {
    isLoading = true;
    notifyListeners();
    try {
      _certificates = await SupabaseCertificateAPI().fetchMyCertificates();
    } catch (e) {
      print('🔴 [CertificateViewModel.loadMyCertificates] ERROR: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // Cek certificate untuk course tertentu
  Future<void> checkCertificate(String courseId) async {
    try {
      _currentCertificate = await SupabaseCertificateAPI()
          .fetchCertificateByCourse(courseId);
      notifyListeners();
    } catch (e) {
      print('🔴 [CertificateViewModel.checkCertificate] ERROR: $e');
    }
  }

  bool get hasCertificate => _currentCertificate != null;

  void reset() {
    _certificates = [];
    _currentCertificate = null;
    isLoading = false;
    notifyListeners();
  }
}
