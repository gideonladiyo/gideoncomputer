import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/data.dart';

class CertificateAPI {
  static Future<File> generate(
      PdfPageFormat pageFormat, CustomData data) async {
    final pdf = pw.Document();

    // Load logo asset
    final logoData = await rootBundle.load('assets/gideon_logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Load fonts
    final poppinsRegular = await PdfGoogleFonts.poppinsRegular();
    final poppinsBold = await PdfGoogleFonts.poppinsBold();
    final greatVibes = await PdfGoogleFonts.greatVibesRegular();

    // Load avatar if available
    Uint8List? avatarBytes;
    if (data.avatarUrl != null && data.avatarUrl!.isNotEmpty) {
      try {
        final response = await http
            .get(Uri.parse(data.avatarUrl!))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          avatarBytes = response.bodyBytes;
        }
      } catch (e) {
        // Fallback gracefully on timeout or network error
        print('Error loading avatar image for certificate: $e');
      }
    }
    final avatarImage =
        avatarBytes != null ? pw.MemoryImage(avatarBytes) : null;

    // Date calculations
    final issueDate = DateTime.tryParse(data.issuedAt ?? '') ?? DateTime.now();
    final startDate = issueDate.subtract(const Duration(days: 47));
    final endDate = issueDate.subtract(const Duration(days: 5));

    String formatIndonesianDate(DateTime date, {bool includeYear = true}) {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      final day = date.day.toString().padLeft(2, '0');
      final month = months[date.month - 1];
      final year = date.year.toString();
      return includeYear ? '$day $month $year' : '$day $month';
    }

    final startFormatted = formatIndonesianDate(startDate,
        includeYear: startDate.year != endDate.year);
    final endFormatted = formatIndonesianDate(endDate, includeYear: true);
    final issueFormatted = formatIndonesianDate(issueDate, includeYear: true);

    // Force landscape dimensions if a4 is portrait
    final isPortrait = pageFormat.width < pageFormat.height;
    final landscapeFormat = isPortrait
        ? PdfPageFormat(pageFormat.height, pageFormat.width)
        : pageFormat;

    // Page format with padding/margins
    final customFormat = landscapeFormat.copyWith(
      marginLeft: 45,
      marginRight: 45,
      marginTop: 45,
      marginBottom: 45,
    );

    // Fetch sections and their quiz attempts dynamically from Supabase
    List<_Competency> competencies = [];
    String programName = 'Operator Komputer';

    if (data.courseId != null && data.courseId!.isNotEmpty) {
      try {
        final supabase = Supabase.instance.client;
        final currentUser = supabase.auth.currentUser;

        // Fetch sections for the course ordered by ID/sequence
        final sectionsResponse = await supabase
            .from('sections')
            .select('id, section_name')
            .eq('course_id', data.courseId!)
            .order('id', ascending: true);

        final sectionsList = sectionsResponse as List;

        for (int i = 0; i < sectionsList.length; i++) {
          final section = sectionsList[i];
          final sectionId = section['id'] as String;
          final sectionName =
              section['section_name'] as String? ?? 'Section ${i + 1}';

          String grade = 'Kompeten'; // default fallback

          try {
            // Fetch quizzes for this section
            final quizzesList = await supabase
                .from('quizzes')
                .select('id')
                .eq('section_id', sectionId);

            final quizzesResponseList = quizzesList as List?;
            if (quizzesResponseList != null &&
                quizzesResponseList.isNotEmpty &&
                currentUser != null) {
              final quizId = quizzesResponseList.first['id'] as String;
              final attemptsResponse = await supabase
                  .from('quiz_attempts')
                  .select('score')
                  .eq('quiz_id', quizId)
                  .eq('user_id', currentUser.id)
                  .order('score', ascending: false)
                  .limit(1)
                  .maybeSingle();

              if (attemptsResponse != null && attemptsResponse['score'] != null) {
                final score = attemptsResponse['score'] as int;
                grade = '$score'; // show the numeric score
              }
            }
          } catch (quizError) {
            // Silently fallback to "Kompeten" if quiz details aren't accessible
          }

          competencies.add(_Competency(
            i + 1,
            'SEC-${(i + 1).toString().padLeft(2, '0')}',
            sectionName,
            grade,
          ));
        }

        programName = data.courseName ?? 'Teknologi Informasi';
      } catch (e) {
        print('Error fetching dynamic competency sections: $e');
      }
    }

    // Fallback static list (Operator Komputer) if database has no sections or fetching failed
    if (competencies.isEmpty) {
      competencies = [
        _Competency(1, 'J.63OPR00.001.2', 'Menggunakan Perangkat Komputer',
            'Kompeten'),
        _Competency(
            2, 'J.63OPR00.002.2', 'Menggunakan Sistem Operasi', 'Kompeten'),
        _Competency(3, 'J.63OPR00.003.2', 'Menggunakan Peralatan Peripheral',
            'Kompeten'),
        _Competency(4, 'J.63OPR00.004.2',
            'Menggunakan Perangkat Lunak Pengolah Kata Tingkat Dasar', 'Kompeten'),
        _Competency(5, 'J.63OPR00.005.2',
            'Menggunakan Perangkat Lunak Lembar Sebar (Spreadsheet) Tingkat Dasar', 'Kompeten'),
        _Competency(6, 'J.63OPR00.006.2',
            'Menggunakan Perangkat Lunak Presentasi Tingkat Dasar', 'Kompeten'),
        _Competency(7, 'J.63OPR00.007.2',
            'Menggunakan Penelusur Situs Web (Web Browser)', 'Kompeten'),
        _Competency(8, 'J.63OPR00.008.2',
            'Menggunakan Perangkat Lunak Pengakses Surat Elektronik (e-Mail Client)', 'Kompeten'),
        _Competency(9, 'J.63OPR00.011.2',
            'Menggunakan Perangkat Lunak Pengolah Kata Tingkat Lanjut', 'Kompeten'),
        _Competency(10, 'J.63OPR00.012.2',
            'Menggunakan Perangkat Lunak Lembar Kerja Tingkat Lanjut', 'Kompeten'),
        _Competency(11, 'J.63OPR00.013.2',
            'Menggunakan Perangkat Lunak Presentasi Tingkat Lanjut', 'Kompeten'),
      ];
      programName = 'Teknologi Informasi dan Komunikasi (Operator Komputer)';
    }

    // Divide competencies equally into left and right columns
    final half = (competencies.length / 2).ceil();
    final leftItems = competencies.sublist(0, half);
    final rightItems = competencies.sublist(half);

    // Pad the right side if it has fewer items than the left side
    while (rightItems.length < leftItems.length) {
      rightItems.add(_Competency(0, '', '', ''));
    }

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: customFormat,
          theme: pw.ThemeData.withFont(
            base: poppinsRegular,
            bold: poppinsBold,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              margin: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromHex('#126E64'), // Outer Teal border
                  width: 10,
                ),
              ),
              child: pw.Container(
                margin: const pw.EdgeInsets.all(3), // Spacer
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#FFA500'), // Inner Gold border
                    width: 2,
                  ),
                ),
                child: pw.Stack(
                  alignment: pw.Alignment.center,
                  children: [
                    // Watermark logo
                    pw.Opacity(
                      opacity: 0.08,
                      child: pw.Image(logoImage, width: 260),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 5),
            // Header Row
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 50,
                  height: 60,
                  child: pw.Image(logoImage),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'LEMBAGA PENDIDIKAN DAN PELATIHAN KERJA (LPPK)',
                        style: pw.TextStyle(
                          font: poppinsBold,
                          fontSize: 11,
                          color: PdfColors.black,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'GIDEON',
                        style: pw.TextStyle(
                          font: poppinsBold,
                          fontSize: 26,
                          color: PdfColor.fromHex('#F58220'),
                          letterSpacing: 2,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Terdaftar No. 563/228/D.TK/2009 & No. 421.9/2002/2019',
                        style: pw.TextStyle(
                          font: poppinsRegular,
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 65), // Balance out the logo (50) + spacing (15)
              ],
            ),

            // Certificate Number (No. Seri)
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(right: 25, top: 4),
                child: pw.Text(
                  'No. Seri : ${data.certificateNumber ?? 'Op..2019-032'}',
                  style: pw.TextStyle(
                    font: poppinsRegular,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),

            pw.Spacer(flex: 1),

            // Elegant cursive title "Sertifikat"
            pw.Text(
              'Sertifikat',
              style: pw.TextStyle(
                font: greatVibes,
                fontSize: 44,
                color: PdfColor.fromHex('#8B5A2B'),
              ),
            ),

            pw.Spacer(flex: 1),

            // Recipient section
            pw.Text(
              'Diberikan Kepada:',
              style: pw.TextStyle(
                font: poppinsRegular,
                fontSize: 9.5,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.SizedBox(height: 6),

            pw.Text(
              data.name ?? '',
              style: pw.TextStyle(
                font: poppinsBold,
                fontSize: 16,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.SizedBox(height: 4),

            pw.Text(
              'Tempat dan Tanggal Lahir : Jakarta, 14 Maret 1993',
              style: pw.TextStyle(
                font: poppinsRegular,
                fontSize: 9.5,
              ),
            ),

            pw.Spacer(flex: 1),

            pw.Text(
              'Telah berhasil menyelesaikan kegiatan PROGRAM PELATIHAN ${(data.courseName ?? '').toUpperCase()}',
              style: pw.TextStyle(
                font: poppinsBold,
                fontSize: 10,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),

            pw.Text(
              'Yang diselenggarakan pada tanggal : $startFormatted – $endFormatted dengan hasil SANGAT MEMUASKAN.',
              style: pw.TextStyle(
                font: poppinsRegular,
                fontSize: 9,
              ),
              textAlign: pw.TextAlign.center,
            ),

            pw.Spacer(flex: 2),

            // Signature block and photo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // 3x4 photo frame
                pw.Container(
                  width: 54, // 18 * 3
                  height: 72, // 18 * 4
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                        color: PdfColor.fromHex('#B71C1C'), width: 1.5),
                    color: PdfColor.fromHex('#B71C1C'),
                  ),
                  child: avatarImage != null
                      ? pw.Image(avatarImage, fit: pw.BoxFit.cover)
                      : pw.Center(
                          child: pw.Text(
                            '3 x 4\nFOTO',
                            style: pw.TextStyle(
                              font: poppinsBold,
                              fontSize: 7.5,
                              color: PdfColors.white,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                ),
                pw.SizedBox(width: 40),

                // Signature Text
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Sorong, $issueFormatted',
                      style: pw.TextStyle(
                        font: poppinsRegular,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'KEPALA LPPK GIDEON',
                      style: pw.TextStyle(
                        font: poppinsBold,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(height: 38), // Signature space
                    pw.Text(
                      'PARSIMIN, SE., PFC.',
                      style: pw.TextStyle(
                        font: poppinsBold,
                        fontSize: 9,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(width: 20),
              ],
            ),
            pw.SizedBox(height: 5),
          ],
        ),
      ),
    );

    // ── PAGE 2: BACK PAGE ────────────────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: customFormat,
        theme: pw.ThemeData.withFont(
          base: poppinsRegular,
          bold: poppinsBold,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 10),
            pw.Text(
              'DAFTAR UNIT KOMPETENSI',
              style: pw.TextStyle(
                font: poppinsBold,
                fontSize: 14,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Jurusan / Program : $programName',
              style: pw.TextStyle(
                font: poppinsRegular,
                fontSize: 10,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 20),
            competencies.length <= 6
                ? pw.Container(
                    width: 550,
                    child: buildCompetencyTable(
                        competencies, poppinsRegular, poppinsBold),
                  )
                : pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: buildCompetencyTable(
                            leftItems, poppinsRegular, poppinsBold),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Expanded(
                        child: buildCompetencyTable(
                            rightItems, poppinsRegular, poppinsBold),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );

    return CertificateAPI.saveDocument(
      name: 'gideon_computer_certificate.pdf',
      pdf: pdf,
    );
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }

  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }
}

class _Competency {
  final int no;
  final String code;
  final String title;
  final String grade;

  _Competency(this.no, this.code, this.title, this.grade);
}

pw.Widget buildCompetencyTable(
    List<_Competency> items, pw.Font fontNormal, pw.Font fontBold) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
    columnWidths: const {
      0: pw.FixedColumnWidth(22), // No
      1: pw.FixedColumnWidth(75), // Kode Unit
      2: pw.FlexColumnWidth(), // Unit Kompetensi
      3: pw.FixedColumnWidth(55), // Nilai/Hasil
    },
    children: [
      // Table Header Row
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F0F0F0')),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text('No.',
                style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                textAlign: pw.TextAlign.center),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text('Kode Unit',
                style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                textAlign: pw.TextAlign.center),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text('Unit Kompetensi / Materi',
                style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                textAlign: pw.TextAlign.center),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text('Nilai',
                style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                textAlign: pw.TextAlign.center),
          ),
        ],
      ),
      // Table Content Rows
      ...items.map((item) {
        final isBlank = item.no == 0;
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(
                isBlank ? '' : '${item.no}.',
                style: pw.TextStyle(font: fontNormal, fontSize: 7.5),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(
                item.code,
                style: pw.TextStyle(font: fontNormal, fontSize: 7.5),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: pw.Text(
                item.title,
                style: pw.TextStyle(font: fontNormal, fontSize: 7.5),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(
                isBlank ? '' : item.grade,
                style: pw.TextStyle(font: fontNormal, fontSize: 7.5),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        );
      }).toList(),
    ],
  );
}
