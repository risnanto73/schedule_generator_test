import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScheduleOpenAiPage extends StatefulWidget {
  const ScheduleOpenAiPage({super.key});

  @override
  State<ScheduleOpenAiPage> createState() => _ScheduleOpenAiPageState();
}

class _ScheduleOpenAiPageState extends State<ScheduleOpenAiPage> {
  final TextEditingController _scheduleNameController = TextEditingController();
  String _selectedPriority = "Prioritas Tinggi";
  final TextEditingController _durationController = TextEditingController();
  DateTime? _deadlineFrom;
  DateTime? _deadlineUntil;
  String _scheduleResult = "";
  bool _isLoading = false;

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

    final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? "";
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate = _deadlineFrom != null ? formatter.format(_deadlineFrom!) : "Tidak dipilih";
    String untilDate = _deadlineUntil != null ? formatter.format(_deadlineUntil!) : "Tidak dipilih";

    final Map<String, dynamic> requestBody = {
      "model": "gpt-4o",
      "messages": [
        {
          "role": "user",
          "content": "Buatkan jadwal dengan nama ${_scheduleNameController.text}, berdasarkan prioritas $_selectedPriority, durasi ${_durationController.text} jam, dari $fromDate hingga $untilDate."
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _scheduleResult = data['choices'][0]['message']['content'];
        });
      } else {
        setState(() {
          _scheduleResult = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _scheduleResult = "Terjadi kesalahan: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Generator - OpenAI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _scheduleNameController,
              decoration: const InputDecoration(labelText: "Nama Schedule"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              onChanged: (String? newValue) {
                setState(() => _selectedPriority = newValue!);
              },
              items: ["Prioritas Tinggi", "Prioritas Sedang", "Prioritas Rendah"]
                  .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              decoration: const InputDecoration(labelText: "Prioritas"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: "Durasi (jam)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _deadlineFrom == null ? "Pilih Tanggal Mulai" : "Dari: ${DateFormat('yyyy-MM-dd').format(_deadlineFrom!)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, true),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _deadlineUntil == null ? "Pilih Tanggal Selesai" : "Hingga: ${DateFormat('yyyy-MM-dd').format(_deadlineUntil!)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, false),
                )
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : generateSchedule,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Generate Schedule"),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _scheduleResult,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
