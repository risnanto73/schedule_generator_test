import 'package:flutter/material.dart';

class ScheduleDetailPage extends StatelessWidget {
  final Map<String, dynamic> schedule;

  const ScheduleDetailPage({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Jadwal"), backgroundColor: Colors.deepPurple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Schedule
                Text(
                  schedule['name'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Divider(),

                // Tanggal (From - Until)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${schedule['fromDate']} → ${schedule['untilDate']}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Prioritas dengan Badge Warna
                Row(
                  children: [
                    const Icon(Icons.priority_high, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    _buildPriorityBadge(schedule['priority']),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                // Hasil
                const Text("Hasil:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  schedule['result'],
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk Badge Prioritas
  Widget _buildPriorityBadge(String priority) {
    Color color;
    String text;

    switch (priority) {
      case 'Prioritas Tinggi':
        color = Colors.red;
        text = 'Prioritas Tinggi';
        break;
      case 'Prioritas Sedang':
        color = Colors.orange;
        text = 'Prioritas Sedang';
        break;
      case 'Prioritas Rendah':
        color = Colors.green;
        text = 'Prioritas Rendah';
        break;
      default:
        color = Colors.grey;
        text = 'Tidak Diketahui';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
