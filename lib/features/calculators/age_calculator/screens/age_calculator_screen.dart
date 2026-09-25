import 'package:flutter/material.dart';
import 'package:ms_smart_tools/core/utils/core_utils.dart';
import 'package:intl/intl.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Age & Date Calculator'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Age Calculator'),
              Tab(text: 'Add Duration'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AgeTab(),
            _DateAdditionTab(),
          ],
        ),
      ),
    );
  }
}

class _AgeTab extends StatefulWidget {
  const _AgeTab();

  @override
  State<_AgeTab> createState() => _AgeTabState();
}

class _AgeTabState extends State<_AgeTab> {
  DateTime _birthDate = DateTime(2024, 8, 24);
  DateTime _today = DateTime.now();
  
  Map<String, int> _ageResult = {'years': 0, 'months': 0, 'days': 0};

  void _calculateAge() {
    int years = _today.year - _birthDate.year;
    int months = _today.month - _birthDate.month;
    int days = _today.day - _birthDate.day;

    if (days < 0) {
      months -= 1;
      days += DateTime(_today.year, _today.month, 0).day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    setState(() {
      _ageResult = {'years': years, 'months': months, 'days': days};
    });
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? _birthDate : _today,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
        } else {
          _today = picked;
        }
      });
      _calculateAge();
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateAge();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDatePickerCard('Date of Birth', _birthDate, () => _selectDate(context, true)),
          const SizedBox(height: 16),
          _buildDatePickerCard("Today's Date", _today, () => _selectDate(context, false)),
          const SizedBox(height: 32),
          _buildResultCard(),
        ],
      ),
    );
  }

  Widget _buildDatePickerCard(String label, DateTime date, VoidCallback onTap) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        subtitle: Text(
          DateFormat('dd MMMM, yyyy').format(date),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        trailing: const Icon(Icons.calendar_month, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[700]!, Colors.blue[400]!]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Your Current Age', style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAgeUnit(_ageResult['years']!.toString(), 'Years'),
              _buildAgeUnit(_ageResult['months']!.toString(), 'Months'),
              _buildAgeUnit(_ageResult['days']!.toString(), 'Days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeUnit(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      ],
    );
  }
}

class _DateAdditionTab extends StatefulWidget {
  const _DateAdditionTab();

  @override
  State<_DateAdditionTab> createState() => _DateAdditionTabState();
}

class _DateAdditionTabState extends State<_DateAdditionTab> {
  DateTime _startDate = DateTime.now();
  final TextEditingController _yearController = TextEditingController(text: '0');
  final TextEditingController _monthController = TextEditingController(text: '0');
  final TextEditingController _dayController = TextEditingController(text: '0');
  
  DateTime _resultDate = DateTime.now();

  void _calculateResult() {
    int years = int.tryParse(_yearController.text) ?? 0;
    int months = int.tryParse(_monthController.text) ?? 0;
    int days = int.tryParse(_dayController.text) ?? 0;

    // Calculate new date
    int newYear = _startDate.year + years;
    int newMonth = _startDate.month + months;
    
    // Normalize months
    newYear += (newMonth - 1) ~/ 12;
    newMonth = (newMonth - 1) % 12 + 1;
    
    // Calculate initial target date
    // Note: DateTime constructor rolls over days if month length exceeded
    DateTime temp = DateTime(newYear, newMonth, _startDate.day);
    
    // Add additional days
    setState(() {
      _resultDate = temp.add(Duration(days: days));
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      _calculateResult();
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateResult();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Start Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text(DateFormat('dd MMMM, yyyy').format(_startDate)),
              trailing: const Icon(Icons.calendar_today, color: Colors.blue),
              onTap: () => _selectStartDate(context),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Add Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInputBox(_yearController, 'Years'),
              const SizedBox(width: 12),
              _buildInputBox(_monthController, 'Months'),
              const SizedBox(width: 12),
              _buildInputBox(_dayController, 'Days'),
            ],
          ),
          const SizedBox(height: 40),
          _buildResultDisplay(),
        ],
      ),
    );
  }

  Widget _buildInputBox(TextEditingController controller, String label) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: (_) => _calculateResult(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          const Text('Calculated Date', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            DateFormat('EEEE, dd MMMM, yyyy').format(_resultDate),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            '( ${DateFormat('dd-MM-yyyy').format(_resultDate)} )',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}



