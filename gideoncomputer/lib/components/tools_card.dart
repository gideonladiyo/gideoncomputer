import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsCard extends StatelessWidget {
  final String? toolsName;
  final String? imgUrl;
  final String? toolUrl;

  const ToolsCard({super.key, this.toolsName, this.imgUrl, this.toolUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon/Logo tool
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: imgUrl != null && imgUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imgUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.build_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : const Icon(Icons.build_outlined, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            // Nama tool
            Expanded(
              child: Text(
                toolsName ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Tombol download/visit
            if (toolUrl != null && toolUrl!.isNotEmpty)
              TextButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(toolUrl!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Download'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
