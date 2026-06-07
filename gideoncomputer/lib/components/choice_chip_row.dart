import 'package:flutter/material.dart';

class ChoiceChipRow extends StatelessWidget {
  const ChoiceChipRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List categories = [
      'All',
      'Backend Engineer',
      'Frontend Engineer',
      'Mobile Developer',
      'UI/UX Designer',
    ];
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                return ChoiceChip(
                  label: Text(
                    categories[index],
                  ),
                  selected: false,
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFFFFEBEE),
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
