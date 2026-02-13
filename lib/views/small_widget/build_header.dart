import 'package:flutter/material.dart';

Widget buildHeader(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      color: Color(0xFF1B5E20),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assalamu Alaikum,',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const Text(
          'Welcome to Sapeel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Prayer: Asr',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '03:45 PM',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '15 Ramadan, 1445',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Friday, March 2024',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
