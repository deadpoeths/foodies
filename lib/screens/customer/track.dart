import 'package:flutter/material.dart';

class TrackPage extends StatelessWidget {
  const TrackPage({super.key});

  final List<Map<String, dynamic>> _steps = const [
    {
      'label': 'Chef is preparing meal',
      'icon': Icons.kitchen,
    },
    {
      'label': 'Rider picked up your order',
      'icon': Icons.directions_bike,
    },
    {
      'label': 'Rider is on the way',
      'icon': Icons.delivery_dining,
    },
    {
      'label': 'Order delivered',
      'icon': Icons.check_circle,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Track Your Order', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: _steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(step['icon'], color: Colors.green, size: 32),
                    if (index < _steps.length - 1)
                      Container(
                        height: 40,
                        width: 2,
                        color: Colors.green,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      step['label'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
