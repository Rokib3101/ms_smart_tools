import 'package:flutter/material.dart';
import 'package:ms_smart_tools/core/utils/core_utils.dart';
import '../physics_logic.dart';

class PhysicsConverterScreen extends StatelessWidget {
  const PhysicsConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Physics Converter'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Speed'),
              Tab(text: 'Temperature'),
              Tab(text: 'Pressure'),
              Tab(text: 'Power'),
              Tab(text: 'Data'),
              Tab(text: 'Energy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PhysicsTab(type: 'speed'),
            _PhysicsTab(type: 'temp'),
            _PhysicsTab(type: 'pressure'),
            _PhysicsTab(type: 'power'),
            _PhysicsTab(type: 'data'),
            _PhysicsTab(type: 'energy'),
          ],
        ),
      ),
    );
  }
}

class _PhysicsTab extends StatefulWidget {
  final String type;
  const _PhysicsTab({required this.type});

  @override
  State<_PhysicsTab> createState() => _PhysicsTabState();
}

class _PhysicsTabState extends State<_PhysicsTab> {
  final TextEditingController _controller = TextEditingController();
  late String _selectedUnit;
  Map<String, double> _results = {};

  final Map<String, Map<String, String>> _unitData = {
    'speed': {
      'kmh': 'km/h',
      'ms': 'm/s',
      'mph': 'mph',
    },
    'temp': {
      'c': 'Celsius (°C)',
      'f': 'Fahrenheit (°F)',
      'k': 'Kelvin (K)',
    },
    'pressure': {
      'pa': 'Pascal (Pa)',
      'bar': 'Bar',
      'psi': 'PSI',
    },
    'power': {
      'w': 'Watt (W)',
      'kw': 'Kilowatt (kW)',
      'hp': 'Horsepower (HP)',
    },
    'data': {
      'bit': 'Bit',
      'b': 'Byte',
      'kb': 'Kilobyte (KB)',
      'mb': 'Megabyte (MB)',
      'gb': 'Gigabyte (GB)',
      'tb': 'Terabyte (TB)',
    },
    'energy': {
      'j': 'Joule (J)',
      'cal': 'Calorie (cal)',
      'kcal': 'Kilocalorie (kcal)',
      'btu': 'BTU',
      'kwh': 'Kilowatt Hour (kWh)',
      'ev': 'Electron Volt (eV)',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedUnit = _unitData[widget.type]!.keys.first;
  }

  void _calculate(String value) {
    double input = BanglaUtils.parse(value);
    if (input == 0 && value != '0') {
      setState(() => _results = {});
      return;
    }

    setState(() {
      switch (widget.type) {
        case 'speed': _results = PhysicsLogic.convertSpeed(input, _selectedUnit); break;
        case 'temp': _results = PhysicsLogic.convertTemp(input, _selectedUnit); break;
        case 'pressure': _results = PhysicsLogic.convertPressure(input, _selectedUnit); break;
        case 'power': _results = PhysicsLogic.convertPower(input, _selectedUnit); break;
        case 'data': _results = PhysicsLogic.convertData(input, _selectedUnit); break;
        case 'energy': _results = PhysicsLogic.convertEnergy(input, _selectedUnit); break;
      }
    });
  }

  String _formatResult(double val) {
    if (val.abs() < 0.0001 && val != 0) {
      return val.toStringAsExponential(2);
    }
    return val.toStringAsFixed(val.abs() < 0.1 ? 5 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final units = _unitData[widget.type]!;
    final themeColor = _getThemeColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(labelText: 'Select Unit', border: OutlineInputBorder()),
                    items: units.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (val) {
                      setState(() => _selectedUnit = val!);
                      _calculate(_controller.text);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    onChanged: _calculate,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Enter Value',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(_getIcon(), color: themeColor),
                      filled: true,
                      fillColor: themeColor.withValues(alpha: 0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_results.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Converted Results:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._results.entries.where((e) => e.key != _selectedUnit && units.containsKey(e.key)).map((e) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: themeColor.withValues(alpha: 0.35), width: 1.2),
                      ),
                      child: ListTile(
                        title: Text(units[e.key] ?? e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _formatResult(e.value),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeColor),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
        ],
      ),
    );
  }

  Color _getThemeColor() {
    switch (widget.type) {
      case 'speed': return Colors.red;
      case 'temp': return Colors.orange;
      case 'pressure': return Colors.purple;
      case 'power': return Colors.amber[800]!;
      case 'data': return Colors.blue;
      case 'energy': return Colors.indigo;
      default: return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case 'speed': return Icons.speed;
      case 'temp': return Icons.thermostat;
      case 'pressure': return Icons.compress;
      case 'power': return Icons.bolt;
      case 'data': return Icons.data_usage;
      case 'energy': return Icons.electric_bolt;
      default: return Icons.science;
    }
  }
}
