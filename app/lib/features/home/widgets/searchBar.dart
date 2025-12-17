import 'dart:async';

import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/features/ingredient/presentation/widgets/ingredient_result_card.dart';
import 'package:app/features/home/data/onSearch.dart' as search_data;

typedef OnSearch = Future<List<Ingredient>> Function(String query);

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    required this.primaryColor,
    this.onSearch,
  });

  final Color primaryColor;
  final OnSearch? onSearch;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  Timer? _debounce;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Ingredient> _results = [];

  static const _debounceDuration = Duration(milliseconds: 500);
  static const _minKeywordLength = 2;

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerSearch(String value) async {
    final query = value.trim();
    if (query.length < _minKeywordLength) {
      // เคลียร์ state โหลดเมื่อเคอร์เซอร์ถูกลบจนสั้น
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final onSearchFn = widget.onSearch ?? search_data.onSearch;
      final results = await onSearchFn(query);
      if (!mounted) return;

      setState(() {
        _results = results;
      });

      if (_results.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    // ถ้าช่องว่าง หรือสั้นมาก ยังไม่ต้องยิง RPC
    if (value.trim().length < _minKeywordLength) {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
      _results = [];
      _removeOverlay();
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      _triggerSearch(value);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final appColors = Theme.of(context).extension<AppColorExtension>()!;

        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeOverlay,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(0, 56),
                  child: Material(
                    elevation: 8,
                    color: appColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final ingredient = _results[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: IngredientResultCard(
                              ingredient: ingredient,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.only(left: 20, right: 10),
        height: 54,
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    offset: const Offset(0, 10),
                    blurRadius: 50,
                    color: widget.primaryColor.withValues(alpha: 0.23),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                style: TextStyle(color: appColors.text),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: appColors.textSecondary,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            if (_isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.primaryColor.withValues(alpha: 0.7),
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: appColors.textSecondary,
                ),
                onPressed: () => _triggerSearch(_controller.text),
              ),
          ],
        ),
      ),
    );
  }
}
