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
    String prefix = amount < 0 ? "-" : "";
    String amountStr = amount.abs().toString();
    String result = "";
    String reversed = amountStr.split('').reversed.join('');
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) result += ".";
      result += reversed[i];
    }
    return prefix + result.split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    final bool isDapur = activeWallet == 'Dapur';
    final int balance = isDapur ? dapurBalance : usahaBalance;
    final String label = isDapur ? '🏠 Dompet Dapur' : '🏪 Dompet Usaha';
    final bool isDeficit = balance < 0;

    final Color bgColor = isDeficit ? const Color(0xFFFEE2E2) : const Color(0xFF4ADE80);
    final Color borderColor = isDeficit ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
    final Color textColor = isDeficit ? const Color(0xFF991B1B) : const Color(0xFF033524);

    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -100 && isDapur) {
            onWalletChanged('Usaha');
          } else if (velocity > 100 && !isDapur) {
            onWalletChanged('Dapur');
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  label,
                  key: ValueKey(label),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: FittedBox(
                  key: ValueKey('$activeWallet-$balance'),
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp ${_formatAmount(balance)}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDeficit ? 'Saldo minus! Pengeluaran berlebih' : 'Sisa uang Anda saat ini',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      _buildDot(isDapur, textColor),
                      const SizedBox(width: 6),
                      _buildDot(!isDapur, textColor),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}