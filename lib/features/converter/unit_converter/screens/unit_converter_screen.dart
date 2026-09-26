import 'package:flutter/material.dart';
import 'package:ms_smart_tools/core/utils/core_utils.dart';
import '../../land/land_logic.dart';
import '../length_logic.dart';
import '../weight_volume_logic.dart';
import '../time_logic.dart';

class UnitConverterScreen extends StatelessWidget {
  const UnitConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unit Converter'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Land'),
              Tab(text: 'Length'),
              Tab(text: 'Weight'),
              Tab(text: 'Liquid'),
              Tab(text: 'Time'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UnitTab(type: 'land'),
            _UnitTab(type: 'length'),
            _UnitTab(type: 'weight'),
            _UnitTab(type: 'liquid'),
            _UnitTab(type: 'time'),
          ],
        ),
      ),
    );
  }
}

class _UnitTab extends StatefulWidget {
  final String type;
  const _UnitTab({required this.type});

  @override
  State<_UnitTab> createState() => _UnitTabState();
}

class _UnitTabState extends State<_UnitTab> {
  final TextEditingController _controller = TextEditingController();
  late String _selectedUnit;
  Map<String, double> _results = {};

  final Map<String, Map<String, String>> _unitData = {
    'land': {
      'hectare': 'Hectare',
      'acre': 'Acre',
      'bigha': 'Bigha',
      'are': 'Are',
      'katha': 'Katha',
      'decimal': 'Decimal / Shatak',
      'sqm': 'Sq. Meter (Sqm)',
      'sqft': 'Sq. Feet (Sq. Ft)',
    },
    'length': {
      'nautical_mile': 'Nautical Mile',
      'mile': 'Mile',
      'km': 'Kilometer (KM)',
      'hm': 'Hectometer (HM)',
      'dam': 'Decameter (DAM)',
      'meter': 'Meter',
      'yard': 'Yard',
      'haat': 'Haat',
      'feet': 'Foot',
      'dm': 'Decimeter (DM)',
      'inch': 'Inch',
      'cm': 'Centimeter (CM)',
      'mm': 'Millimeter (MM)',
    },
    'weight': {
      'kg': 'Kilogram (KG)',
      'hg': 'Hectogram (HG)',
      'oz': 'Ounce (Oz)',
      'dag': 'Decagram (DAG)',
      'g': 'Gram (G)',
      'dg': 'Decigram (DG)',
      'cg': 'Centigram (CG)',
      'mg': 'Milligram (MG)',
      'mon': 'Maund',
      'ton': 'Ton',
      'lb': 'Pound (Lb)',
    },
    'liquid': {
      'kl': 'Kiloliter (KL)',
      'hl': 'Hectoliter (HL)',
      'dal': 'Decaliter (DAL)',
      'gallon': 'Gallon',
      'liter': 'Liter',
      'cup': 'Cup',
      'dl': 'Deciliter (DL)',
      'tbsp': 'Tablespoon (Tbsp)',
      'cl': 'Centiliter (CL)',
      'tsp': 'Teaspoon (Tsp)',
      'ml': 'Milliliter (ML)',
    },
    'time': {
      'millennium': 'Millennium',
      'century': 'Century',
      'yuga': 'Yuga',
      'decade': 'Decade',
      'year': 'Year',
      'month': 'Month',
      'week': 'Week',
      'day': 'Day',
      'hour': 'Hour',
      'minute': 'Minute',
      'second': 'Second',
    },
  };

  @override
  void initState() {
    super.initState();
    switch (widget.type) {
      case 'land':
        _selectedUnit = 'decimal';
        break;
      case 'length':
        _selectedUnit = 'meter';
        break;
      case 'weight':
        _selectedUnit = 'kg';
        break;
      case 'liquid':
        _selectedUnit = 'liter';
        break;
      case 'time':
        _selectedUnit = 'second';
        break;
      default:
        _selectedUnit = _unitData[widget.type]!.keys.first;
    }
  }

  void _calculate(String value) {
    double input = BanglaUtils.parse(value);
    if (input == 0 && value != '0') {
      setState(() => _results = {});
      return;
    }

    setState(() {
      switch (widget.type) {
        case 'land':
          _results = LandLogic.convert(input, _selectedUnit);
          break;
        case 'length':
          _results = LengthLogic.convert(input, _selectedUnit);
          break;
        case 'weight':
          _results = WeightVolumeLogic.convertWeight(input, _selectedUnit);
          break;
        case 'liquid':
          _results = WeightVolumeLogic.convertVolume(input, _selectedUnit);
          break;
        case 'time':
          _results = TimeLogic.convertTime(input, _selectedUnit);
          break;
      }
    });
  }

  String _formatResult(double val) {
    if (val.abs() < 0.0001 && val != 0) {
      return val.toStringAsExponential(4);
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
                      if (val != null) {
                        setState(() => _selectedUnit = val);
                        _calculate(_controller.text);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      case 'land':
        return Colors.green;
      case 'length':
        return Colors.deepOrange;
      case 'weight':
        return Colors.indigo;
      case 'liquid':
        return Colors.pink;
      case 'time':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case 'land':
        return Icons.landscape;
      case 'length':
        return Icons.straighten;
      case 'weight':
        return Icons.scale;
      case 'liquid':
        return Icons.opacity;
      case 'time':
        return Icons.timer;
      default:
        return Icons.calculate;
    }
  }
}
