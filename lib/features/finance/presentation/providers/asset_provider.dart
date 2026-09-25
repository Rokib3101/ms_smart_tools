import 'package:flutter/material.dart';
import '../../data/models/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../../data/repositories/hive_asset_repository.dart';

class AssetProvider extends ChangeNotifier {
  final AssetRepository _repository;
  List<Asset> _assets = [];

  List<Asset> get assets => _assets;

  AssetProvider({AssetRepository? repository})
      : _repository = repository ?? HiveAssetRepository() {
    _loadAssets();
  }

  void _loadAssets() {
    _assets = _repository.getAssets();
    notifyListeners();
  }

  double get totalAssetValue => _assets.fold(0, (sum, item) => sum + item.amount);

  Future<void> addAsset(String name, double amount) async {
    final newAsset = Asset.create(name: name, amount: amount);
    _assets.add(newAsset);
    await _repository.addAsset(newAsset);
    notifyListeners();
  }

  Future<void> updateAsset(String id, {String? name, double? amount}) async {
    final index = _assets.indexWhere((element) => element.id == id);
    if (index != -1) {
      final updatedAsset = _assets[index].copyWith(
        name: name,
        amount: amount,
        lastModified: DateTime.now(),
      );
      _assets[index] = updatedAsset;
      await _repository.updateAsset(updatedAsset);
      notifyListeners();
    }
  }

  Future<void> deleteAsset(String id) async {
    _assets.removeWhere((element) => element.id == id);
    await _repository.deleteAsset(id);
    notifyListeners();
  }
}
