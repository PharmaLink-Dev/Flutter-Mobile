import 'package:flutter/material.dart';

/**
 * SearchBarWidget
 * ----------------
 * A simple search bar with a search icon.
 * Used for searching supplement products.
 */
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search for supplement products...", // placeholder text
        prefixIcon: const Icon(Icons.search, color: Colors.grey), // left icon
        filled: true, // enable background color
        fillColor: Colors.grey[100], // light gray background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // rounded edges
          borderSide: BorderSide.none, // no border line
        ),
      ),
    );
  }
}
