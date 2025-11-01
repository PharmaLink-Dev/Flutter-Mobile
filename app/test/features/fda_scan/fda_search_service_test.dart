import 'package:app/features/fda_scan/data/fda_search_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FdaSearchService should fetch and parse data correctly', () async {
    final service = FdaSearchService();
    final result = await service.fetchByFdpdtno('1310044910142');

    // ignore: avoid_print
    print(result);

    expect(result, isA<Map<String, String?>>());
    expect(result['เลขสารบบ'], '13-1-00449-1-0142');
    expect(result['ชื่อผลิตภัณฑ์(TH)'], isNotNull);
  });
}
