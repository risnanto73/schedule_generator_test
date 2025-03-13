import 'package:flutter/material.dart';
import '../database/schedule_database.dart';
import 'schedule_detail_page.dart';

class ScheduleListPage extends StatefulWidget {
  @override
  _ScheduleListPageState createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await ScheduleDatabase.instance.getSchedules();
    setState(() => _schedules = schedules);
  }

  Future<void> _deleteSchedule(int id) async {
    await ScheduleDatabase.instance.deleteSchedule(id);
    _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jadwal Tersimpan"), backgroundColor: Colors.deepPurple),
      body: _schedules.isEmpty
          ? const Center(child: Text("Belum ada jadwal tersimpan"))
          : ListView.builder(
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5, // Lebih elegan
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleDetailPage(schedule: schedule),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nomor Urutan dengan Warna Latar Belakang
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12), // Spacer

                    // Isi Card (Nama, From → Until, Prioritas)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Schedule
                          Text(
                            schedule['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 6), // Spacer

                          // From → Until dengan ikon kalender
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              Text(
                                "${schedule['fromDate']} → ${schedule['untilDate']}",
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8), // Spacer

                          // Prioritas dengan badge yang lebih menarik
                          _buildPriorityBadge(schedule['priority']),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12), // Spacer

                    // Tombol Hapus (Tengah Kanan)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                      onPressed: () => _deleteSchedule(schedule['id']),
                    ),
                  ],
                ),
              ),
            ),
          );

        },
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority) {
      case "Prioritas Tinggi":
        color = Colors.red;
        break;
      case "Prioritas Sedang":
        color = Colors.yellow;
        break;
      case "Prioritas Rendah":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(
        priority,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
