import 'package:flutter/material.dart';

import 'frosted_glass_box.dart';

class ContentBox extends StatelessWidget {
  final double width;
  final String name;
  final IconData icon;
  final VoidCallback onTap;
  const ContentBox(
      {super.key,
        required this.width,
        required this.name,
        required this.icon,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FrostedGlassBox(
        width: width,
        height: 120,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: 60,
              ),
              Text(
                name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}