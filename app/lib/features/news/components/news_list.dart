import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsList extends StatelessWidget {
  final List<Map<String, String>> newsArticles;
  const NewsList({super.key}): newsArticles = const [
    {
      'title': 'Flutter 3.24 Released!',
      'url': 'https://flutter.dev/docs/whats-new'
    },
    {
      'title': 'Dart 3.5 Introduces Records and Patterns',
      'url': 'https://dart.dev'
    },
    {
      'title': 'Google I/O 2025 Highlights',
      'url': 'https://io.google'
    },
    {
      'title': 'Top 5 Big Black Men',
      'url': 'https://www.youtube.com/watch?v=n0E3fNgIjWM'
    }
  ];

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: newsArticles.length,
      itemBuilder: (context, index) {
        final article = newsArticles[index];
        return ListTile(
          title: Text(
            article['title']!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blueAccent,
            ),
          ),
          trailing: const Icon(Icons.open_in_new, color: Colors.grey),
          onTap: () => _openUrl(article['url']!),
        );
      },
    );
  }
}
