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

    // [Vibe Coding] Refinement: filter transaksi sekali saja (di luar builder).
    final filteredTransactions = widget.transactions
        .where((t) => t['wallet'] == widget.activeWallet)
        .toList();

    return SafeArea(
      // [Responsive] LayoutBuilder
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
                  children: totals.keys.map((cat) {
                    final color = categoryColors[cat] ?? Colors.grey;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Laporan (${widget.activeWallet})',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033524),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPeriod,
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedPeriod = newValue;
                              });
                            }
                          },
                          items: <String>['Harian', 'Mingguan', 'Bulanan']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // [Responsive] Susunan Pie Chart dan Legenda
                if (isLandscape)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      pieChart,
                      const SizedBox(width: 32),
                      Expanded(child: legend),
                    ],
                  )
                else
                  Column(
                    children: [
                      Center(child: pieChart),
                      const SizedBox(height: 20),
                      legend,
                    ],
                  ),

                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isPositive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isPositive
                          ? '👍 Hebat! Pemasukan lebih besar'
                          : '👎 Waspada! Pengeluaran melebihi/sama dengan pemasukan',
                      style: TextStyle(
                        color: isPositive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  periodListTitle,
                  style: const TextStyle(
                    color: Color(0xFF033524),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Daftar Transaksi
                filteredTransactions.isEmpty
                    ? Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada transaksi',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          final isInc = tx['isIncome'] as bool;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tx['category'] ?? 'Transaksi',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  '${isInc ? '+' : '-'}${formatAmount(tx['amount'] as int)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isInc ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Class untuk menggambar Pie Chart
class PieChartPainter extends CustomPainter {
  final Map<String, int> categoryTotals;
  final Map<String, Color> categoryColors;

  PieChartPainter({required this.categoryTotals, required this.categoryColors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (categoryTotals.isEmpty) {
      final paint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final totalSum = categoryTotals.values.reduce((a, b) => a + b);
    double startAngle = -3.14159 / 2;

    categoryTotals.forEach((category, amount) {
      final sweepAngle = (amount / totalSum) * 2 * 3.14159;
      final paint = Paint()
        ..color = categoryColors[category] ?? Colors.grey
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
