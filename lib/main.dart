import 'package:flutter/material.dart';
import 'halaman_input.dart';
import 'halaman_laporan.dart';

void main() {
  runApp(const BukuKasApp());
}

class BukuKasApp extends StatelessWidget {
  const BukuKasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BukuKas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087653),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedNavIndex = 0;
  String activeWallet = 'Dapur';

  int dapurIncome = 0;
  int dapurExpense = 0;

  int usahaIncome = 0;
  int usahaExpense = 0;

  List<Map<String, dynamic>> transactions = [];

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

  void _openInputPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InputPage()),
    );

    if (result != null) {
      setState(() {
        transactions.insert(0, result as Map<String, dynamic>);
        bool isIncome = result['isIncome'];
        int amount = result['amount'];
        String wallet = result['wallet'];

        if (wallet == 'Dapur') {
          if (isIncome) dapurIncome += amount;
          else dapurExpense += amount;
        } else if (wallet == 'Usaha') {
          if (isIncome) usahaIncome += amount;
          else usahaExpense += amount;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentIncome = activeWallet == 'Dapur' ? dapurIncome : usahaIncome;
    int currentExpense = activeWallet == 'Dapur' ? dapurExpense : usahaExpense;
    int currentBalance = currentIncome - currentExpense;

    List<Map<String, dynamic>> visibleTransactions = transactions
        .where((t) => t['wallet'] == activeWallet)
        .toList();

    return Scaffold(
      body: selectedNavIndex == 1
          ? LaporanPage(
              transactions: transactions,
              income: currentIncome,
              expense: currentExpense,
              activeWallet: activeWallet,
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF033524),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo, Pejuang Keluarga! 👋',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A5C41),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          children: [
                            _buildTab('🏠 Dompet Dapur', activeWallet == 'Dapur', 'Dapur'),
                            _buildTab('🏪 Dompet Usaha', activeWallet == 'Usaha', 'Usaha'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text('Sisa Uang Anda', style: TextStyle(color: Color(0xFF033524), fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                'Rp ${formatAmount(currentBalance)}',
                                style: const TextStyle(color: Color(0xFF033524), fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildIncomeExpenseCard('↓ Uang Masuk', 'Rp ${formatAmount(currentIncome)}', true),
                            const SizedBox(width: 16),
                            _buildIncomeExpenseCard('↑ Uang Keluar', 'Rp ${formatAmount(currentExpense)}', false),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Terbaru', style: TextStyle(color: Color(0xFF033524), fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        if (visibleTransactions.isEmpty)
                          Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: const Center(
                              child: Text('Kosong...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
                            ),
                          )
                        else
                          Column(
                            children: visibleTransactions.map((tx) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tx['category'] ?? 'Transaksi', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      '${tx['isIncome'] ? '+' : '-'}${formatAmount(tx['amount'])}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: tx['isIncome'] ? Colors.green.shade700 : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _openInputPage,
        mouseCursor: SystemMouseCursors.click,
        backgroundColor: const Color(0xFFF97316),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavIcon(Icons.home, 'Beranda', 0),
            _buildBottomNavIcon(Icons.bar_chart, 'Laporan', 1),
            const SizedBox(width: 48),
            _buildBottomNavIcon(Icons.inventory_2, 'Utang/Stok', 2),
            _buildBottomNavIcon(Icons.person, 'Profil', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected, String walletType) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => activeWallet = walletType),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF064E3B) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseCard(String title, String amount, bool isIncome) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(title, style: TextStyle(color: isIncome ? Colors.green.shade900 : Colors.red.shade900, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text(amount, style: TextStyle(color: isIncome ? Colors.green.shade700 : Colors.red.shade700, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavIcon(IconData icon, String label, int navIndex) {
    final isSelected = selectedNavIndex == navIndex;
    final color = isSelected ? const Color(0xFF087653) : Colors.grey;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => selectedNavIndex = navIndex),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}