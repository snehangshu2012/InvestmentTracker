import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

/// Exports the given list of investment maps to a CSV file and opens the share sheet.
class ExportHelper {
  /// investments: List of maps returned by LocalDbService.exportAllData()['investments'].
  static Future<void> exportInvestmentsCsv(
      List<Map<String, dynamic>> investments) async {
    // 1. Build CSV content
    final buffer = StringBuffer();
    buffer.writeln(
        'Name,Type,Amount,Start Date,Maturity Date,Current Value,Gains Loss,Gains %');
    for (final inv in investments) {
      final name = inv['name'] ?? '';
      final type = inv['type'] ?? '';
      final amount = inv['amount']?.toString() ?? '';
      final start = inv['startDate'] ?? '';
      final maturity = inv['maturityDate'] ?? '';
      final current = inv['currentValue']?.toString() ?? '';
      final gain = inv['gainsLoss']?.toString() ?? '';
      final gainPct = inv['gainsLossPercentage']?.toString() ?? '';
      buffer.writeln(
          '$name,$type,$amount,$start,$maturity,$current,$gain,$gainPct');
    }

    // 2. Write CSV to a temporary file
    final now = DateTime.now();
    final formatted = DateFormat('yyyyMMdd_HHmmss').format(now);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/investments_export_$formatted.csv');
    await file.writeAsString(buffer.toString());

    // 3. Share the CSV
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
    );
  }
}
