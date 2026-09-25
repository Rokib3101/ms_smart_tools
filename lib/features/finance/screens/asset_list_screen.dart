import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ms_smart_tools/features/finance/presentation/providers/asset_provider.dart';
import 'package:ms_smart_tools/core/utils/core_utils.dart';
import '../data/models/asset.dart';

class AssetListScreen extends StatelessWidget {
  const AssetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context);
    final assets = assetProvider.assets;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Assets'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: assets.isEmpty
                ? const Center(child: Text('No assets added'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: assets.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _AssetItemRow(asset: assets[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildTotalSection(assetProvider.totalAssetValue),
      floatingActionButton: FloatingActionButton(
        onPressed: () => assetProvider.addAsset('', 0),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.blueGrey[50],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 40), // For delete button space
        ],
      ),
    );
  }

  Widget _buildTotalSection(double total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '৳ ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: total >= 0 ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetItemRow extends StatefulWidget {
  final Asset asset;
  const _AssetItemRow({required this.asset});

  @override
  State<_AssetItemRow> createState() => _AssetItemRowState();
}

class _AssetItemRowState extends State<_AssetItemRow> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset.name);
    _amountController = TextEditingController(
      text: widget.asset.amount == 0 ? '' : widget.asset.amount.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _AssetItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.name != widget.asset.name && _nameController.text != widget.asset.name) {
      _nameController.text = widget.asset.name;
    }
    if (oldWidget.asset.amount != widget.asset.amount &&
        double.tryParse(_amountController.text) != widget.asset.amount) {
      _amountController.text = widget.asset.amount == 0 ? '' : widget.asset.amount.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Asset Name',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (val) {
                assetProvider.updateAsset(widget.asset.id, name: val);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (val) {
                final amount = double.tryParse(val) ?? 0.0;
                assetProvider.updateAsset(widget.asset.id, amount: amount);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yy').format(widget.asset.lastModified),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => assetProvider.deleteAsset(widget.asset.id),
          ),
        ],
      ),
    );
  }
}
