import 'package:flutter/material.dart';
import '../components/news_list.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent News'),
      ),
      body: const SafeArea(
        child: 
            NewsList()
      ),
    );
  }
}
