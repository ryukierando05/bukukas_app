import 'package:flutter/material.dart';

class SaldoCarousel extends StatelessWidget {
  final int dapurBalance;
  final int usahaBalance;
  final String activeWallet;
  final ValueChanged<String> onWalletChanged;

  const SaldoCarousel({
    super.key,
    required this.dapurBalance,
    required this.usahaBalance,
    required this.activeWallet,
    required this.onWalletChanged,
  });

  String _formatAmount(int amount) {
    String amountStr = amount.toString();
    String result = "";
    String reversed = amountStr.split('').reversed.join('');
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) result += ".";
      result += reversed[i];
    }
    return result.split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan saldo mana yang akan ditampilkan berdasarkan dompet aktif
    final int balance = activeWallet == 'Dapur' ? dapurBalance : usahaBalance;
    final String label = activeWallet == 'Dapur' ? '🏠 Dompet Dapur' : '🏪 Dompet Usaha';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80), // Warna hijau cerah
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF22C55E),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF033524),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Rp ${_formatAmount(balance)}',
              style: const TextStyle(
                color: Color(0xFF033524),
                fontSize: 32, // Ukuran font dibuat lebih besar karena space-nya lega
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sisa uang Anda saat ini',
            style: TextStyle(
              color: Color(0xFF033524),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
