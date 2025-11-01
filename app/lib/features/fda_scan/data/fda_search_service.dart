import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' show Document;

class FdaSearchService {
  static const _base =
      'https://porta.fda.moph.go.th/FDA_SEARCH_ALL/PRODUCT/FRM_PRODUCT_FOOD.aspx';

  /// Build the FDA portal URL from any raw input containing digits.
  static Uri buildUriForFdpdtno(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return Uri.parse('$_base?fdpdtno=$digits');
  }

  /// Heuristic to decide if parsed result looks valid.
  /// Consider valid only when:
  /// - FDA number has at least 10 digits (ignoring dashes/spaces), AND
  /// - At least one of product name TH/EN or license holder is present.
  static bool isValidResult(Map<String, String?> data) {
    String norm(String? s) => (s ?? '').trim();
    final idDigits = norm(data['เลขสารบบ']).replaceAll(RegExp(r'[^0-9]'), '');
    final hasId = idDigits.length >= 10;
    final hasNameOrHolder =
        norm(data['ชื่อผลิตภัณฑ์(TH)']).isNotEmpty ||
        norm(data['ชื่อผลิตภัณฑ์(EN)']).isNotEmpty ||
        norm(data['ชื่อผู้รับอนุญาต']).isNotEmpty;

    return hasId && hasNameOrHolder;
  }


  /// Returns a map of selected fields, or null values if not found
  Future<Map<String, String?>> fetchByFdpdtno(String raw) async {
    final uri = buildUriForFdpdtno(raw);

    final resp = await http
        .get(uri)
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final Document doc = parse(resp.body);

    final ids = <String, String>{
      'เลขสารบบ': 'ContentPlaceHolder1_lbl_fdpdtno',
      'ชื่อผลิตภัณฑ์(TH)': 'ContentPlaceHolder1_lbl_thai',
      'ชื่อผลิตภัณฑ์(EN)': 'ContentPlaceHolder1_lbl_eng',
      'ชื่อผู้รับอนุญาต': 'ContentPlaceHolder1_lbl_name',
      'สถานะผลิตภัณฑ์': 'ContentPlaceHolder1_lbl_lcnstatus0',
    };

    return ids.map((label, id) {
      final el = doc.querySelector('#$id');
      return MapEntry(label, el?.text.trim());
    });
  }
}
