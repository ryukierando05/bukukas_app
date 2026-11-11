import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  bool isIncome = true;
  String amountString = "";
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.rice_bowl, 'name': 'Bahan'},
    {'icon': Icons.moped, 'name': 'Bensin'},
    {'icon': Icons.store, 'name': 'Modal'},
    {'icon': Icons.local_fire_department, 'name': 'Gas'},
    {'icon': Icons.people, 'name': 'Gaji'},
    {'icon': Icons.receipt, 'name': 'Tagihan'},
    {'icon': Icons.shopping_bag, 'name': 'Belanja'},
    {'icon': Icons.build, 'name': 'Servis'},
  ];

  String get formattedAmount {
    if (amountString.isEmpty) return "0";
    String result = "";
    String reversed = amountString.split('').reversed.join('');
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) result += ".";
      result += reversed[i];
    }
    return result.split('').reversed.join('');
  }

  void _onNumberPress(String digit) {
    setState(() {
      if (amountString.length < 12) amountString += digit;
    });
  }

  void _onBackspace() {
    setState(() {
      if (amountString.isNotEmpty) {
        amountString = amountString.substring(0, amountString.length - 1);
      }
    });
  }

  void _saveTransaction() async {
    if (amountString.isEmpty || amountString == "0") return;
    if (!isIncome && selectedCategory == null) return;

    final String? chosenWallet = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Simpan ke mana?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWalletOption('Dapur', '🏠 Dompet Dapur'),
              const SizedBox(height: 12),
              _buildWalletOption('Usaha', '🏪 Dompet Usaha'),
            ],
          ),
        );
      },
    );

    // Peringatan hilang jika kita menambahkan pengecekan `mounted` di sini
    if (!mounted) return;

    if (chosenWallet != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penyimpanan berhasil!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFF087653),
          duration: Duration(seconds: 2),
        ),
      );

      final transactionData = {
        'isIncome': isIncome,
        'amount': int.parse(amountString),
        'wallet': chosenWallet,
        'category': isIncome ? 'Pemasukan' : selectedCategory,
      };

      if (mounted) Navigator.pop(context, transactionData);
    }
  }

  Widget _buildWalletOption(String walletId, String label) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => Navigator.pop(context, walletId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [Responsive] Baca MediaQuery untuk orientasi
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;

    bool isSaveActive = amountString.isNotEmpty && amountString != "0" && (isIncome || selectedCategory != null);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          mouseCursor: SystemMouseCursors.click,
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        // [Responsive] LayoutBuilder memilih susunan berdasarkan ruang tersedia.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720;
            // Konten inti (toggle, nominal, kategori, numpad).
            final mainColumn = Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                isIncome = true;
                                selectedCategory = null;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isIncome ? const Color(0xFFE8F5E9) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Center(
                                  child: Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                      color: isIncome ? const Color(0xFF087653) : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => setState(() => isIncome = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !isIncome ? Colors.red.shade600 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Center(
                                  child: Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      color: !isIncome ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // [Responsive] FittedBox + ukuran font mengikuti lebar layar.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Rp $formattedAmount',
                    style: TextStyle(
                      color: isIncome ? const Color(0xFF087653) : Colors.red.shade600,
                      fontSize: isWide ? 52 : 44,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!isIncome) ...[
                  const Text("Pilih kategori", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    // [Responsive] Tinggi grid kategori mengikuti orientasi.
                    height: isLandscape ? 100 : 115,
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    // [MultiChild] GridView.builder untuk kategori.
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // [Responsive] 3 kolom portrait, 5 kolom landscape.
                        crossAxisCount: isLandscape ? 5 : 3,
                        childAspectRatio: isLandscape ? 2.2 : 1.6,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        bool isSelected = selectedCategory == cat['name'];
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setState(() => selectedCategory = cat['name']),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orange.shade50 : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(cat['icon'], size: 18, color: isSelected ? Colors.orange : Colors.blue),
                                  const SizedBox(height: 2),
                                  Text(cat['name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  const SizedBox(height: 24),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Column(
                    children: [
                      _buildNumpadRow(['1', '2', '3'], isLandscape),
                      const SizedBox(height: 8),
                      _buildNumpadRow(['4', '5', '6'], isLandscape),
                      const SizedBox(height: 8),
                      _buildNumpadRow(['7', '8', '9'], isLandscape),
                      const SizedBox(height: 8),
                      _buildNumpadRow(['000', '0', 'back'], isLandscape),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isSaveActive ? _saveTransaction : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF087653),
                              disabledBackgroundColor: Colors.grey.shade300,
                              enabledMouseCursor: SystemMouseCursors.click,
                              disabledMouseCursor: SystemMouseCursors.basic,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              'SIMPAN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSaveActive ? Colors.white : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );

            // [Responsive] Di layar sangat lebar (tablet/desktop), beri margin tengah.
            if (constraints.maxWidth > 720) {
              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: mainColumn,
                  ),
                ),
              );
            }

            return SingleChildScrollView(child: mainColumn);
          },
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> items, bool isLandscape) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNumpadButton(items[0], isLandscape),
        const SizedBox(width: 12),
        _buildNumpadButton(items[1], isLandscape),
        const SizedBox(width: 12),
        _buildNumpadButton(items[2], isLandscape),
      ],
    );
  }

  Widget _buildNumpadButton(String label, bool isLandscape) {
    bool isIcon = label == 'back';
    // [Responsive] Ukuran tombol menyesuaikan orientasi.
    final btnWidth = isLandscape ? 90.0 : 75.0;
    final btnHeight = isLandscape ? 44.0 : 48.0;
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        if (isIcon) {
          _onBackspace();
        } else {
          _onNumberPress(label);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: btnWidth,
        height: btnHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 2, offset: const Offset(0, 1)),
          ],
        ),
        child: Center(
          child: isIcon
              ? const Icon(Icons.backspace_outlined, size: 20)
              : Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
