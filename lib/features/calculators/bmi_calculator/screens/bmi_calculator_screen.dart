import 'package:flutter/material.dart';
import 'package:ms_smart_tools/core/utils/core_utils.dart';
import '../logic/bmi_logic.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();

  double _bmiResult = 0.0;
  String _category = '';

  void _calculateBmi() {
    double weight = BanglaUtils.parse(_weightController.text);
    int feet = int.tryParse(_feetController.text) ?? 0;
    int inches = int.tryParse(_inchesController.text) ?? 0;

    if (weight > 0 && (feet > 0 || inches > 0)) {
      double heightMeters = BmiLogic.ftInToMeters(feet, inches);
      setState(() {
        _bmiResult = BmiLogic.calculate(weight, heightMeters);
        _category = BmiLogic.getCategory(_bmiResult);
      });
    } else {
      setState(() {
        _bmiResult = 0.0;
        _category = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInputCard(),
            const SizedBox(height: 32),
            if (_bmiResult > 0) ...[
              _buildResultCard(),
              const SizedBox(height: 32),
              _buildBmiChart(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Weight (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateBmi(),
              decoration: InputDecoration(
                hintText: '0.0',
                suffixText: 'kg',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Your Height', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _feetController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateBmi(),
                    decoration: InputDecoration(
                      labelText: 'Feet',
                      hintText: '0',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _inchesController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateBmi(),
                    decoration: InputDecoration(
                      labelText: 'Inches',
                      hintText: '0',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    Color statusColor = _getStatusColor();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          const Text('Your BMI Score', style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(
            _bmiResult.toStringAsFixed(1),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: statusColor),
          ),
          const SizedBox(height: 12),
          Text(
            _category,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BMI Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildChartRow('Underweight', '< 18.5', Colors.blue, _bmiResult < 18.5),
            _buildChartRow('Healthy Weight', '18.5 - 25', Colors.green, _bmiResult >= 18.5 && _bmiResult < 25),
            _buildChartRow('Overweight', '25 - 30', Colors.orange, _bmiResult >= 25 && _bmiResult < 30),
            _buildChartRow('Class 1 Obesity', '30 - 35', Colors.deepOrange, _bmiResult >= 30 && _bmiResult < 35),
            _buildChartRow('Class 2 Obesity', '35 - 40', Colors.red, _bmiResult >= 35 && _bmiResult < 40),
            _buildChartRow('Class 3 Obesity', '> 40', Colors.red[900]!, _bmiResult >= 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChartRow(String category, String range, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: color, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_bmiResult < 18.5) return Colors.blue;
    if (_bmiResult < 25) return Colors.green;
    if (_bmiResult < 30) return Colors.orange;
    if (_bmiResult < 35) return Colors.deepOrange;
    if (_bmiResult < 40) return Colors.red;
    return Colors.red[900]!;
  }
}
