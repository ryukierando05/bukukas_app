import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum UtangStatus { baru, ditunggu, lewat, lunas }

class UtangItem {
  String name;
  int amount;
  UtangStatus status;

  UtangItem({
    required this.name,
    required this.amount,
    this.status = UtangStatus.baru,
  });
}

class StockItem {
  final String name;
  final int pricePerUnit;
  int quantity;
  final int maxQuantity;

  StockItem({
    required this.name,
    required this.pricePerUnit,
    this.quantity = 0,
    this.maxQuantity = 100,
  });
}

class UtangStokPage extends StatefulWidget {
  final List< UtangItem > utangList;
  final List< StockItem > stockList;
  final String activeWallet;
  final int dapurBalance;
  final int usahaBalance;
  final VoidCallback onDataChanged;
  final void Function(StockItem item, int qty, int totalCost, String wallet) onRestockConfirmed;

  const UtangStokPage({
    super.key,
    required this.utangList,
    required this.stockList,
    required this.activeWallet,
    required this.dapurBalance,
    required this.usahaBalance,
    required this.onDataChanged,
    required this.onRestockConfirmed,
  });

  @override
  State< UtangStokPage > createState() => _UtangStokPageState();
}

class _UtangStokPageState extends State< UtangStokPage > {
  bool isBukuUtang = true;

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

  void _showAddUtangDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog< void >(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Tambahkan Utang',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nama Pelanggan',
                  hintText: 'Contoh: Bu Rina',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Nominal Utang (Rp)',
                  hintText: 'Contoh: 120000',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                final amount = int.tryParse(amountController.text.trim()) ?? 0;
                if (name.isEmpty || amount <= 0) return;

                setState(() {
                  widget.utangList.insert(
                    0,
                    UtangItem(name: name, amount: amount, status: UtangStatus.baru),
                  );
                });
                widget.onDataChanged();
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showManageUtangDialog(UtangItem item) {
    final nameController = TextEditingController(text: item.name);
    final amountController = TextEditingController(text: item.amount.toString());
    UtangStatus selectedStatus = item.status;

    showDialog< void >(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Status & Edit Utang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Status:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusChoiceChip(
                            label: 'Ditunggu',
                            symbol: '...',
                            bgColor: const Color(0xFFE2E8F0),
                            fgColor: const Color(0xFF475569),
                            isSelected: selectedStatus == UtangStatus.ditunggu,
                            onTap: () => setDialogState(() => selectedStatus = UtangStatus.ditunggu),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusChoiceChip(
                            label: 'Lewat',
                            symbol: '!',
                            bgColor: const Color(0xFFFEE2E2),
                            fgColor: const Color(0xFFDC2626),
                            isSelected: selectedStatus == UtangStatus.lewat,
                            onTap: () => setDialogState(() => selectedStatus = UtangStatus.lewat),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusChoiceChip(
                            label: 'Lunas',
                            symbol: '✓',
                            bgColor: const Color(0xFFDCFCE7),
                            fgColor: const Color(0xFF16A34A),
                            isSelected: selectedStatus == UtangStatus.lunas,
                            onTap: () => setDialogState(() => selectedStatus = UtangStatus.lunas),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Ubah Data Utang:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Nominal (Rp)',
                        prefixText: 'Rp ',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.utangList.remove(item);
                    });
                    widget.onDataChanged();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final updatedName = nameController.text.trim();
                    final updatedAmount = int.tryParse(amountController.text.trim()) ?? item.amount;
                    setState(() {
                      if (updatedName.isNotEmpty) item.name = updatedName;
                      if (updatedAmount > 0) item.amount = updatedAmount;
                      item.status = selectedStatus;
                    });
                    widget.onDataChanged();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChoiceChip({
    required String label,
    required String symbol,
    required Color bgColor,
    required Color fgColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? fgColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                symbol,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestockDialog(StockItem item) {
    final int remainingCapacity = item.maxQuantity - item.quantity;
    if (remainingCapacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${item.name} sudah penuh (100/100)!'),
          backgroundColor: const Color(0xFF087653),
        ),
      );
      return;
    }

    final qtyController = TextEditingController();
    String selectedWallet = widget.activeWallet;

    showDialog< void >(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final int inputQty = int.tryParse(qtyController.text.trim()) ?? 0;
            final bool isOverMax = inputQty > remainingCapacity;
            final int validQty = isOverMax ? remainingCapacity : inputQty;
            final int totalCost = validQty * item.pricePerUnit;
            final int currentWalletBalance =
                selectedWallet == 'Dapur' ? widget.dapurBalance : widget.usahaBalance;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restok ${item.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Harga satuan: Rp ${_formatAmount(item.pricePerUnit)} / unit • Sisa ruang: $remainingCapacity',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Jumlah yang ingin dibeli',
                        hintText: 'Maksimal $remainingCapacity',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        errorText: isOverMax ? 'Maksimal stok adalah 100 (sisa $remainingCapacity)' : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Potong saldo dari:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWalletPickButton(
                            label: '🏠 Dapur',
                            balanceText: 'Rp ${_formatAmount(widget.dapurBalance)}',
                            isSelected: selectedWallet == 'Dapur',
                            onTap: () => setDialogState(() => selectedWallet = 'Dapur'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildWalletPickButton(
                            label: '🏪 Usaha',
                            balanceText: 'Rp ${_formatAmount(widget.usahaBalance)}',
                            isSelected: selectedWallet == 'Usaha',
                            onTap: () => setDialogState(() => selectedWallet = 'Usaha'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembelian:',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                              Text(
                                'Rp ${_formatAmount(totalCost)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stok setelah beli: ${item.quantity + validQty} / ${item.maxQuantity}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          if (totalCost > currentWalletBalance && validQty > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Catatan: Saldo Dompet $selectedWallet akan menjadi minus.',
                                style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: (validQty > 0 && !isOverMax)
                      ? () {
                          widget.onRestockConfirmed(item, validQty, totalCost, selectedWallet);
                          final int newStock = item.quantity;
                          final int leftToMax = item.maxQuantity - newStock;
                          Navigator.pop(dialogContext);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Berhasil beli $validQty ${item.name}! Stok sekarang $newStock/100 (sisa ruang $leftToMax).',
                              ),
                              backgroundColor: const Color(0xFF087653),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Beli', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWalletPickButton({
    required String label,
    required String balanceText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFDBEAFE) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF1D4ED8) : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF1D4ED8) : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  balanceText,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final contentWidth = isWide ? 680.0 : constraints.maxWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        children: [
                          _buildTopTab(
                            icon: Icons.menu_book_rounded,
                            label: 'Buku Utang',
                            isSelected: isBukuUtang,
                            onTap: () => setState(() => isBukuUtang = true),
                          ),
                          _buildTopTab(
                            icon: Icons.inventory_2_rounded,
                            label: 'Cek Stok',
                            isSelected: !isBukuUtang,
                            onTap: () => setState(() => isBukuUtang = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isBukuUtang) _buildBukuUtangView() else _buildCekStokView(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1D4ED8) : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBukuUtangView() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _showAddUtangDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tambahkan Utang',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              enabledMouseCursor: SystemMouseCursors.click,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.utangList.isEmpty)
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Belum ada catatan utang...',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.utangList.length,
            itemBuilder: (context, index) {
              final item = widget.utangList[index];
              return _buildUtangCard(item);
            },
          ),
      ],
    );
  }

  Widget _buildUtangCard(UtangItem item) {
    final bool isLunas = item.status == UtangStatus.lunas;

    Color btnBgColor;
    Widget btnChild;

    switch (item.status) {
      case UtangStatus.baru:
        btnBgColor = const Color(0xFF22C55E);
        btnChild = const Icon(Icons.add, color: Colors.white, size: 22);
        break;
      case UtangStatus.ditunggu:
        btnBgColor = const Color(0xFFE2E8F0);
        btnChild = const Text(
          '...',
          style: TextStyle(
            color: Color(0xFF475569),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        );
        break;
      case UtangStatus.lewat:
        btnBgColor = const Color(0xFFFEE2E2);
        btnChild = const Text(
          '!',
          style: TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        );
        break;
      case UtangStatus.lunas:
        btnBgColor = const Color(0xFFDCFCE7);
        btnChild = const Icon(Icons.check, color: Color(0xFF16A34A), size: 20);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: isLunas
                ? const Text(
                    'Lunas ✓',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rp ${_formatAmount(item.amount)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showManageUtangDialog(item),
              child: Container(
                width: 64,
                height: 36,
                decoration: BoxDecoration(
                  color: btnBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: btnChild),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCekStokView() {
    return Column(
      children: [
        const Text(
          '— Tampilan Cek Stok —',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.stockList.length,
          itemBuilder: (context, index) {
            return _buildStockCard(widget.stockList[index]);
          },
        ),
      ],
    );
  }

  Widget _buildStockCard(StockItem item) {
    final double ratio = (item.quantity / item.maxQuantity).clamp(0.0, 1.0);
    final int remaining = item.maxQuantity - item.quantity;

    Color barColor;
    String statusText;

    if (item.quantity == 0) {
      barColor = Colors.transparent;
      statusText = 'Stok kosong (0/100) • Sisa kapasitas $remaining';
    } else if (item.quantity <= 30) {
      barColor = const Color(0xFFEF4444);
      statusText = 'Menipis! (${item.quantity}/100) • Sisa ruang $remaining';
    } else if (item.quantity <= 70) {
      barColor = const Color(0xFFF59E0B);
      statusText = 'Segera restok (${item.quantity}/100) • Sisa ruang $remaining';
    } else {
      barColor = const Color(0xFF22C55E);
      statusText = 'Aman (${item.quantity}/100) • Sisa ruang $remaining';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation< Color >(barColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _showRestockDialog(item),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              enabledMouseCursor: SystemMouseCursors.click,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              '+ Restok',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}