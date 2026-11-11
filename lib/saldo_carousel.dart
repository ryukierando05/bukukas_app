import 'package:flutter/material.dart';

class SaldoCarousel extends StatelessWidget {
  final int dapurBalance;
  final int usahaBalance;
  final String formatAmount;
  final String activeWallet;
  final ValueChanged<String> onWalletChanged;

  const SaldoCarousel({
    super.key,
    required this.dapurBalance,
    required this.usahaBalance,
    required this.formatAmount,
    required this.activeWallet,
    required this.onWalletChanged,
  });

  // formatAmount dikirim sebagai String Function(int); helper di bawah.
  int _dummy() => 0;

  @override
  Widget build(BuildContext context) {
    // [Responsive] Lebar item mengikuti lebar layar (clamp supaya tidak ekstrem).
    final screenWidth = MediaQuery.of(context).size.width;
    final itemExtent = (screenWidth - 96).clamp(240.0, 420.0);

    final items = <Map<String, dynamic>>[
      {'wallet': 'Dapur', 'label': '🏠 Dompet Dapur', 'balance': dapurBalance},
      {'wallet': 'Usaha', 'label': '🏪 Dompet Usaha', 'balance': usahaBalance},
    ];

    return SizedBox(
      height: 150,
      child: CarouselView(
        // [MultiChild] CarouselView: widget carousel bawaan Flutter 3.44+.
        itemExtent: itemExtent,
        shrinkExtent: itemExtent * 0.9,
        elevation: 0,
        backgroundColor: Colors.transparent,
        onTap: (index) => onWalletChanged(items[index]['wallet'] as String),
        children: items.map((item) {
          final isActive = activeWallet == item['wallet'];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4ADE80) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? const Color(0xFF22C55E) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    color: Color(0xFF033524),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // [Responsive] Ukuran font nominal mengikuti lebar layar.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp ${(item['balance'] as int)}',
                    style: const TextStyle(
                      color: Color(0xFF033524),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? 'Dompet aktif' : 'Ketuk untuk pilih',
                  style: TextStyle(
                    color: const Color(0xFF033524).withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
