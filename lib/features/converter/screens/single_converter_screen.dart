import 'package:flutter/material.dart';
import 'package:ms_smart_tools/core/utils/core_utils.dart';
import '../land/land_logic.dart';
import '../unit_converter/length_logic.dart';
import '../unit_converter/weight_volume_logic.dart';
import '../unit_converter/time_logic.dart';
import '../unit_converter/physics_logic.dart';

class SingleConverterScreen extends StatefulWidget {
  final String type;
  const SingleConverterScreen({super.key, required this.type});

  @override
  State<SingleConverterScreen> createState() => _SingleConverterScreenState();
}

class _SingleConverterScreenState extends State<SingleConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  late String _selectedUnit;
  Map<String, double> _results = {};

  Map<String, String> get _units {
    switch (widget.type) {
      case 'length':
        return {
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
        };
      case 'area':
        return {
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
        };
      case 'volume':
        return {
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
        };
      case 'mass':
        return {
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
        };
      case 'temp':
        return {
          'c': 'Celsius (°C)',
          'f': 'Fahrenheit (°F)',
          'k': 'Kelvin (K)',
        };
      case 'time':
        return {
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
        };
      case 'speed':
        return {
          'c': 'Speed of light (c)',
          'kms': 'Kilometer per second (km/s)',
          'ms': 'Meter per second (m/s)',
          'kn': 'Knot (kn)',
          'mph': 'Mile per hour (mph)',
          'kmh': 'Kilometer per hour (km/h)',
        };
      case 'pressure':
        return {
          'atm': 'Atmosphere (atm)',
          'bar': 'Bar (bar)',
          'psi': 'Pounds per square inch (PSI)',
          'inhg': 'Inch of mercury (inHg)',
          'mmhg': 'Millimeter of mercury (mmHg)',
          'mbar': 'Millibar (mbar)',
          'pa': 'Pascal (Pa)',
        };
      case 'energy':
        return {
          'mwh': 'Megawatt hour (MWh)',
          'kwh': 'Kilowatt Hour (kWh)',
          'kcal': 'Kilocalorie (kcal)',
          'btu': 'British Thermal Unit (BTU)',
          'kj': 'Kilojoule (kJ)',
          'cal': 'Calorie (cal)',
          'j': 'Joule (J)',
          'ev': 'Electron Volt (eV)',
        };
      default:
        return {};
    }
  }

  @override
  void initState() {
    super.initState();
    final unitsMap = _units;
    if (unitsMap.isNotEmpty) {
      if (widget.type == 'area') {
        _selectedUnit = 'decimal';
      } else if (widget.type == 'length') {
        _selectedUnit = 'meter';
      } else if (widget.type == 'mass') {
        _selectedUnit = 'kg';
      } else if (widget.type == 'volume') {
        _selectedUnit = 'liter';
      } else if (widget.type == 'time') {
        _selectedUnit = 'second';
      } else {
        _selectedUnit = unitsMap.keys.first;
      }
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
        case 'area':
          _results = LandLogic.convert(input, _selectedUnit);
          break;
        case 'length':
          _results = LengthLogic.convert(input, _selectedUnit);
          break;
        case 'mass':
          _results = WeightVolumeLogic.convertWeight(input, _selectedUnit);
          break;
        case 'volume':
          _results = WeightVolumeLogic.convertVolume(input, _selectedUnit);
          break;
        case 'temp':
          _results = PhysicsLogic.convertTemp(input, _selectedUnit);
          break;
        case 'time':
          _results = TimeLogic.convertTime(input, _selectedUnit);
          break;
        case 'speed':
          _results = PhysicsLogic.convertSpeed(input, _selectedUnit);
          break;
        case 'pressure':
          _results = PhysicsLogic.convertPressure(input, _selectedUnit);
          break;
        case 'energy':
          _results = PhysicsLogic.convertEnergy(input, _selectedUnit);
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

  String _getTitle() {
    switch (widget.type) {
      case 'length': return 'Length';
      case 'area': return 'Area';
      case 'volume': return 'Volume';
      case 'mass': return 'Mass';
      case 'temp': return 'Temperature';
      case 'time': return 'Time';
      case 'speed': return 'Speed';
      case 'pressure': return 'Pressure';
      case 'energy': return 'Energy';
      default: return 'Converter';
    }
  }

  Color _getThemeColor() {
    switch (widget.type) {
      case 'length': return Colors.deepOrange;
      case 'area': return Colors.green;
      case 'volume': return Colors.pink;
      case 'mass': return Colors.indigo;
      case 'temp': return Colors.orange;
      case 'time': return Colors.blue;
      case 'speed': return Colors.red;
      case 'pressure': return Colors.purple;
      case 'energy': return Colors.indigo;
      default: return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case 'length': return Icons.straighten;
      case 'area': return Icons.square_foot;
      case 'volume': return Icons.opacity;
      case 'mass': return Icons.scale;
      case 'temp': return Icons.thermostat;
      case 'time': return Icons.timer;
      case 'speed': return Icons.speed;
      case 'pressure': return Icons.compress;
      case 'energy': return Icons.electric_bolt;
      default: return Icons.calculate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = _units;
    final themeColor = _getThemeColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                      value: _selectedUnit,
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
      ),
    );
  }
}
