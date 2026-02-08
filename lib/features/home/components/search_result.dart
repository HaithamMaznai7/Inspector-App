import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultSheet extends StatelessWidget {
  final TextEditingController controller;

  const SearchResultSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (_, __, ___) {
                final query = controller.text.trim();

                if (query.isEmpty) {
                  return const Center(child: Text('Type to search'));
                }

                return ListView.builder(
                  itemCount: 10,
                  itemBuilder: (_, i) {
                    return ListTile(
                      title: Text('Result "$query" #$i'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
