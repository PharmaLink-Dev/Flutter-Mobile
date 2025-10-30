import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsList extends StatelessWidget {
  final List<Map<String, String>> newsArticles;
  const NewsList({super.key}): newsArticles = const [
    {
      'title': 'Flutter 3.24 Released!',
      'url': 'https://flutter.dev/docs/whats-new',
      'description': "This page contains current and recent announcements of what's new on the flutter website"
    },
    {
      'title': 'ข่าวล่าสุด ข่าวด่วน ประเด็นร้อน ข่าวไทยรัฐ',
      'url': 'https://www.thairath.co.th',
      'description': "ไทยรัฐ ทันทุกเหตุการณ์ ข่าวล่าสุด กีฬา บันเทิง สุขภาพ กิน เที่ยว หวย ดวง คอลัมน์ เรื่องย่อละคร ดูไทยรัฐทีวีสดและย้อนหลัง และอีกมากมาย."
    },
    {
      'title': 'Google I/O 2025 Highlights',
      'url': 'https://io.google',
      'description': "Check out the highlights and anything you might have missed"
    },
    {
      'title': 'Top 5 Big Black Man',
      'url': 'https://www.youtube.com/watch?v=n0E3fNgIjWM',
      'description': "Very educational"
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
          leading: FlutterLogo(size: 72.0),
          title: Text(
            article['title']!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blueAccent,
            ),
          ),
          subtitle: Text(
            article['description']!,
            ),
          trailing: const Icon(Icons.open_in_new, color: Colors.grey),
          onTap: () => _openUrl(article['url']!),
        );
      },
    );
  }
}
