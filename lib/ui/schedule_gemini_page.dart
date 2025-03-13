import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:schedule_generator_test/ui/schedule_list.dart';
import '../database/schedule_database.dart';
import '../service/schedule_service.dart';

class ScheduleGeminiPage extends StatefulWidget {
  const ScheduleGeminiPage({super.key});

  @override
  State<ScheduleGeminiPage> createState() => _ScheduleGeminiPageState();
}

class _ScheduleGeminiPageState extends State<ScheduleGeminiPage> {
  final TextEditingController _scheduleNameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedPriority = "Prioritas Tinggi";
  DateTime? _deadlineFrom;
  DateTime? _deadlineUntil;
  String _scheduleResult = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    dotenv.load(); // Load API Key dari .env
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _deadlineFrom = picked;
        } else {
          _deadlineUntil = picked;
        }
      });
    }
  }

  Future<void> generateSchedule() async {
    setState(() => _isLoading = true);

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate = _deadlineFrom != null ? formatter.format(_deadlineFrom!) : "Tidak dipilih";
    String untilDate = _deadlineUntil != null ? formatter.format(_deadlineUntil!) : "Tidak dipilih";

    final result = await ScheduleService.generateSchedule(
      _scheduleNameController.text,
      _selectedPriority,
      _durationController.text,
      fromDate,
      untilDate,
    );

    setState(() {
      _scheduleResult = result;
      _isLoading = false;
    });

    // Simpan ke database
    final newSchedule = {
      'name': _scheduleNameController.text,
      'priority': _selectedPriority,
      'duration': _durationController.text,
      'fromDate': fromDate,
      'untilDate': untilDate,
      'result': result,
    };

    await ScheduleDatabase.instance.insertSchedule(newSchedule);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Generator"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              child: Column(
                children: [
                  _buildTextField(_scheduleNameController, "Nama Schedule", Icons.schedule),
                  const SizedBox(height: 10),
                  _buildDropdown(),
                  const SizedBox(height: 10),
                  _buildTextField(_durationController, "Durasi (jam)", Icons.timer, isNumber: true),
                  const SizedBox(height: 10),
                  _buildDatePicker("Dari: ", _deadlineFrom, () => _selectDate(context, true)),
                  _buildDatePicker("Hingga: ", _deadlineUntil, () => _selectDate(context, false)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading ? const Center(child: CircularProgressIndicator()) : _buildResultCard(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "generate",
            onPressed: _isLoading ? null : generateSchedule,
            backgroundColor: Colors.deepPurple,
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Generate"),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "view",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScheduleListPage()),
              );
            },
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.list),
            label: const Text("Lihat Jadwal"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      onChanged: (String? newValue) {
        setState(() => _selectedPriority = newValue!);
      },
      items: ["Prioritas Tinggi", "Prioritas Sedang", "Prioritas Rendah"]
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      decoration: InputDecoration(
        labelText: "Prioritas",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return ListTile(
      title: Text(date == null ? "$label Pilih Tanggal" : "$label ${DateFormat('yyyy-MM-dd').format(date)}"),
      trailing: const Icon(Icons.calendar_today),
      tileColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  Widget _buildResultCard() {
    return _scheduleResult.isNotEmpty
        ? _buildCard(child: Text(_scheduleResult, style: const TextStyle(fontSize: 16)))
        : const SizedBox.shrink();
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }
}
