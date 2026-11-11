import 'package:flutter/material.dart';
import 'halaman_input.dart';
import 'halaman_laporan.dart';
import 'widgets/saldo_carousel.dart';

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
    // [Responsive] Ambil info layar dari MediaQuery sekali di atas.
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape; // [Responsive]
    final screenWidth = media.size.width;

    int currentIncome = activeWallet == 'Dapur' ? dapurIncome : usahaIncome;
    int currentExpense = activeWallet == 'Dapur' ? dapurExpense : usahaExpense;
    int currentBalance = currentIncome - currentExpense;

    List<Map<String, dynamic>> visibleTransactions =
        transactions.where((t) => t['wallet'] == activeWallet).toList();

    final dapurBalance = dapurIncome - dapurExpense;
    final usahaBalance = usahaIncome - usahaExpense;

    return Scaffold(
      body: selectedNavIndex == 1
          ? LaporanPage(
              transactions: transactions,
              income: currentIncome,
              expense: currentExpense,
              activeWallet: activeWallet,
            )
          : LayoutBuilder( // [Responsive] LayoutBuilder: susun berdasarkan ruang tersedia.
              builder: (context, constraints) {
                // [Responsive] Lebar konten dibatasi agar nyaman di layar lebar.
                final contentWidth = constraints.maxWidth > 720
                    ? 680.0
                    : constraints.maxWidth;

                final header = Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: isLandscape ? 20 : 48, // [Responsive] padding atas beda orientasi
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
                    // [MultiChild] Stack + Positioned: badge overlay di kartu saldo.
                    Stack(
                      children: [
                        // Carousel saldo (MultiChild: CarouselView) di belakang badge.
                        SaldoCarousel(
                          dapurBalance: dapurBalance,
                          usahaBalance: usahaBalance,
                          formatAmount: formatAmount,
                          activeWallet: activeWallet,
                          onWalletChanged: (w) => setState(() => activeWallet = w),
                        ),
                        // Badge kecil menempel di pojok kanan atas.
                        Positioned(
                          top: 0,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Text(
                              'SALDO',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // [Responsive] Di landscape, kartu masuk/keluar & sisa disusun Row.
                    if (isLandscape)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildIncomeExpenseCard('↓ Uang Masuk', 'Rp ${formatAmount(currentIncome)}', true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildIncomeExpenseCard('↑ Uang Keluar', 'Rp ${formatAmount(currentExpense)}', false)),
                        ],
                      )
                    else
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
                      // [MultiChild] ListView.builder untuk daftar transaksi.
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibleTransactions.length,
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
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          // [Responsive] Konten dipusatkan & lebarnya dibatasi.
                          child: SizedBox(width: contentWidth, child: cards),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // [MultiChild] Stack + Positioned untuk badge label di atas FAB.
      floatingActionButton: Stack(
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
    return Expanded( // [MultiChild] Expanded membagi ruang tab rata.
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
    return Expanded( // [MultiChild] Expanded agar dua kartu sama lebar.
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
