import 'package:flutter/material.dart';
import 'halaman_input.dart';
import 'halaman_laporan.dart';
import 'saldo_carousel.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087653)),
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
          if (isIncome) {
            dapurIncome += amount;
          } else {
            dapurExpense += amount;
          }
        } else if (wallet == 'Usaha') {
          if (isIncome) {
            usahaIncome += amount;
          } else {
            usahaExpense += amount;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;

    int currentIncome = activeWallet == 'Dapur' ? dapurIncome : usahaIncome;
    int currentExpense = activeWallet == 'Dapur' ? dapurExpense : usahaExpense;

    List<Map<String, dynamic>> visibleTransactions =
        transactions.where((t) => t['wallet'] == activeWallet).toList();

    final dapurBalance = dapurIncome - dapurExpense;
    final usahaBalance = usahaIncome - usahaExpense;

    return Scaffold(
      // Hanya ada 2 kondisi: Laporan (index 1) atau Beranda (index 0)
      // Menu ke-2 dan ke-3 kita buat mengarah ke Beranda saja (atau kita nonaktifkan)
      body: selectedNavIndex == 1
          ? LaporanPage(
              transactions: transactions,
              income: currentIncome,
              expense: currentExpense,
              activeWallet: activeWallet,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final contentWidth = constraints.maxWidth > 720
                    ? 680.0
                    : constraints.maxWidth;

                final header = Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: isLandscape ? 20 : 48,
                    left: 24,
                    right: 24,
                    bottom: 20,
                  ),
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
                      Text(
                        isLandscape
                            ? 'Halo, Pejuang Keluarga! 👋 (Landscape)'
                            : 'Halo, Pejuang Keluarga! 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
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
                );

                final cards = Column(
                  children: [
                    SaldoCarousel(
                      dapurBalance: dapurBalance,
                      usahaBalance: usahaBalance,
                      activeWallet: activeWallet,
                      onWalletChanged: (w) => setState(() => activeWallet = w),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildIncomeExpenseCard('↓ Uang Masuk', 'Rp ${formatAmount(currentIncome)}', true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildIncomeExpenseCard('↑ Uang Keluar', 'Rp ${formatAmount(currentExpense)}', false)),
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibleTransactions.length,
                        padding: const EdgeInsets.only(bottom: 80), 
                        itemBuilder: (context, index) {
                          final tx = visibleTransactions[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    tx['category'] ?? 'Transaksi',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                        },
                      ),
                  ],
                );

                return Column(
                  children: [
                    header,
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: isMobile ? double.infinity : contentWidth, 
                            child: cards,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: selectedNavIndex == 0 
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                FloatingActionButton(
                  onPressed: _openInputPage,
                  mouseCursor: SystemMouseCursors.click,
                  backgroundColor: const Color(0xFFF97316),
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                if (media.size.width > 600) 
                  Positioned(
                    top: -30,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF033524),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Catat',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            )
          : null,
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
            // Tombol ini kita biarkan ada, tapi kalau diklik tidak terjadi apa-apa (hanya UI)
            _buildBottomNavIcon(Icons.inventory_2, 'Utang/Stok', 0), 
            _buildBottomNavIcon(Icons.person, 'Profil', 0),
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
              child: Text(
                title,
                style: TextStyle(
                  color: isIncome ? Colors.green.shade900 : Colors.red.shade900,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: TextStyle(
                  color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
