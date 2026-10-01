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
      'sq_mi': 'Square Mile (sq mi)',
      'sq_km': 'Square Kilometer (km²)',
      'hectare': 'Hectare (ha)',
      'acre': 'Acre (ac)',
      'bigha': 'Bigha (bigha)',
      'are': 'Are (a)',
      'katha': 'Katha (katha)',
      'decimal': 'Decimal / Shatak (dec)',
      'sqm': 'Square Meter (m²)',
      'sq_yd': 'Square Yard (sq yd)',
      'sqft': 'Square Feet (ft²)',
      'sq_in': 'Square Inch (sq in)',
      'sq_cm': 'Square Centimeter (cm²)',
      'sq_mm': 'Square Millimeter (mm²)',
    },
    'length': {
      'pc': 'Parsec (pc)',
      'ly': 'Light Year (ly)',
      'au': 'Astronomical Unit (au)',
      'nautical_mile': 'Nautical Mile (nmi)',
      'mile': 'Mile (mi)',
      'km': 'Kilometer (km)',
      'hm': 'Hectometer (hm)',
      'dam': 'Decameter (dam)',
      'fathom': 'Fathom (fathom)',
      'meter': 'Meter (m)',
      'yard': 'Yard (yd)',
      'haat': 'Haat (haat)',
      'feet': 'Foot (ft)',
      'dm': 'Decimeter (dm)',
      'inch': 'Inch (in)',
      'cm': 'Centimeter (cm)',
      'mm': 'Millimeter (mm)',
      'um': 'Micrometer (µm)',
      'nm': 'Nanometer (nm)',
      'angstrom': 'Angstrom (Å)',
    },
    'weight': {
      'ton': 'Ton (t)',
      'quintal': 'Quintal (q)',
      'mon': 'Maund (mon)',
      'stone': 'Stone (st)',
      'kg': 'Kilogram (kg)',
      'lb': 'Pound (lb)',
      'hg': 'Hectogram (hg)',
      'dag': 'Decagram (dag)',
      'oz': 'Ounce (oz)',
      'g': 'Gram (g)',
      'dg': 'Decigram (dg)',
      'cg': 'Centigram (cg)',
      'mg': 'Milligram (mg)',
      'ug': 'Microgram (µg)',
      'ng': 'Nanogram (ng)',
    },
    'liquid': {
      'kl': 'Kiloliter (kL)',
      'hl': 'Hectoliter (hL)',
      'barrel_us': 'Barrel US (bbl)',
      'dal': 'Decaliter (daL)',
      'gallon': 'Gallon (gal)',
      'liter': 'Liter (L)',
      'quart': 'Quart (qt)',
      'pint': 'Pint (pt)',
      'cup': 'Cup (cup)',
      'dl': 'Deciliter (dL)',
      'floz': 'Fluid Ounce (fl oz)',
      'cubic_inch': 'Cubic Inch (in³)',
      'tbsp': 'Tablespoon (tbsp)',
      'cl': 'Centiliter (cL)',
      'tsp': 'Teaspoon (tsp)',
      'ml': 'Milliliter (mL)',
      'ul': 'Microliter (µL)',
    },
    'time': {
      'millennium': 'Millennium (mil)',
      'century': 'Century (c)',
      'yuga': 'Yuga (yuga)',
      'decade': 'Decade (dec)',
      'year': 'Year (yr)',
      'month': 'Month (mo)',
      'week': 'Week (wk)',
      'day': 'Day (d)',
      'hour': 'Hour (h)',
      'minute': 'Minute (min)',
      'second': 'Second (s)',
      'ms': 'Millisecond (ms)',
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
