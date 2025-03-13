class Schedule {
  final String title;
  final String duration;
  final String from;
  final String until;
  final String priority;
  final String result; // Detail yang akan ditampilkan di halaman lain

  Schedule({
    required this.title,
    required this.duration,
    required this.from,
    required this.until,
    required this.priority,
    required this.result,
  });
}
