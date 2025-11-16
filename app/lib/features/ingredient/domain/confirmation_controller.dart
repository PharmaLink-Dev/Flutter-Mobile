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

  void setConfirmed(bool v) {
    _confirmed = v;
    notifyListeners();
  }
}

