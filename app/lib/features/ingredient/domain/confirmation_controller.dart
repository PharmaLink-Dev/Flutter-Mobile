import 'package:flutter/foundation.dart';
import 'package:app/features/ingredient/data/ingredient.dart';

class ConfirmItem {
  final Ingredient ingredient;
  bool checked;
  final bool isManual;

  ConfirmItem({
    required this.ingredient,
    this.checked = true,
    this.isManual = false,
  });
}

class ConfirmationController extends ChangeNotifier {
  final List<ConfirmItem> _items = [];
  bool _confirmed = false;

  List<ConfirmItem> get items => List.unmodifiable(_items);
  bool get isConfirmed => _confirmed;
  bool get canAnalyze => _confirmed && _items.isNotEmpty;

  void loadFromIngredients(List<Ingredient> list) {
    _items
      ..clear()
      ..addAll(list.map((e) => ConfirmItem(ingredient: e, checked: true)));
    notifyListeners();
  }

  void toggleAt(int index, bool value) {
    if (index < 0 || index >= _items.length) return;
    _items[index].checked = value;
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void addManual(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    _items.add(
      ConfirmItem(
        ingredient: Ingredient(name: n, status: 'เพิ่มเอง'),
        checked: true,
        isManual: true,
      ),
    );
    notifyListeners();
  }

  void editAt(int index, String newName) {
    if (index < 0 || index >= _items.length) return;
    final n = newName.trim();
    if (n.isEmpty) return;

    final oldItem = _items[index];
    _items[index] = ConfirmItem(
      ingredient: Ingredient(
        name: n,
        status: oldItem.ingredient.status,
        description: oldItem.ingredient.description,
        riskLevel: oldItem.ingredient.riskLevel,
      ),
      checked: oldItem.checked,
      isManual: oldItem.isManual,
    );
    notifyListeners();
  }

  void setConfirmed(bool v) {
    _confirmed = v;
    notifyListeners();
  }
}
