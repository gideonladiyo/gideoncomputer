import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselHero extends StatelessWidget {
  const CarouselHero({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 130.0,
        autoPlay: true,
      ),
      items: [
        GestureDetector(
          onTap: () {},
          child: Card(
            elevation: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                'assets/banner/banner1.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Card(
            elevation: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                'assets/banner/banner2.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Card(
            elevation: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                'assets/banner/banner3.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
