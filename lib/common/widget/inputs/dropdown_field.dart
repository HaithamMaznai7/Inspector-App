import 'package:flutter/material.dart';

class FDropdownField<T> extends StatelessWidget {
  const FDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.onChanged,
    this.value,
  });

  final String label;
  final List<T> items;
  final Function(T?)? onChanged;
  final T? value; 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          DropdownButton<T>(
            value: value,
            hint: Text("Select $label"),
            isExpanded: true,
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ),
                )
                .toList(),
                isDense: true,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
