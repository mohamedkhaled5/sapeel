import 'package:flutter/material.dart';

class AlQuranWidget extends StatelessWidget {
  const AlQuranWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Al-Quran")),
      body: const Center(child: Text("Al-Quran Widget")),
    );
  }
}
