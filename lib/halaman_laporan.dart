import 'package:flutter/material.dart';

class LaporanPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final int income;
  final int expense;
  final String activeWallet;

  const LaporanPage({
    super.key,
    required this.transactions,
    required this.income,
    required this.expense,
    required this.activeWallet,
  });

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String selectedPeriod = 'Mingguan';

  final Map<String, Color> categoryColors = {
    'Bahan': const Color(0xFF22C55E),
    'Makanan': const Color(0xFF22C55E),
    'Modal': const Color(0xFF3B82F6),
    'Tagihan': const Color(0xFFEAB308),
    'Bensin': const Color(0xFFEF4444),
    'Gas': const Color(0xFFA855F7),
    'Gaji': const Color(0xFFF97316),
    'Belanja': const Color(0xFF1E3A8A),
    'Servis': Colors.black,
  };

  Map<String, int> get categoryTotals {
    Map<String, int> totals = {};
    for (var tx in widget.transactions) {
      if (!tx['isIncome'] && tx['wallet'] == widget.activeWallet) {
        String cat = tx['category'] ?? 'Lainnya';
        int amount = tx['amount'] as int;
        totals[cat] = (totals[cat] ?? 0) + amount;
      }
    }
    return totals;
  }

  String formatAmount(int amount) {
    String amountStr = amount.toString();
    String result = "";
    String reversed = amountStr.split('').reversed.join('');
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) result += ".";
      result += reversed[i];
    }
    return result.split('').reversed.join('');
  }

  String get periodListTitle {
    switch (selectedPeriod) {
      case 'Harian':
        return 'Hari ini';
      case 'Mingguan':
        return 'Minggu ini';
      case 'Bulanan':
        return 'Bulan ini';
      default:
        return 'Hari ini';
    }
  }

  @override
  Widget build(BuildContext context) {
    // [Responsive] MediaQuery untuk orientasi.
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;

    final totals = categoryTotals;
    final int balance = widget.income - widget.expense;
    final bool isPositive = balance > 0;

    // [Vibe Coding] Refinement: filter transaksi sekali saja (di luar builder)
    // agar tidak dihitung ulang tiap item -> hasil dari prompt "optimalkan list".
    final filteredTransactions = widget.transactions
        .where((t) => t['wallet'] == widget.activeWallet)
        .toList();

    return SafeArea(
      // [Responsive] LayoutBuilder: susun pie chart & legenda berdampingan saat landscape.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pieChart = SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: PieChartPainter(
                categoryTotals: totals,
                categoryColors: categoryColors,
              ),
            ),
          );

          final legend = totals.isEmpty
              ? const SizedBox.shrink()
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  // [MultiChild] GridView.builder alternatif: kita pakai Wrap + Row.
                  children: totals.keys.map((cat) {
                    final color = categoryColors[cat] ?? Colors.grey;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(cat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight
