import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'halaman_utang_stok.dart';

class ProfilData {
  String businessName;
  String businessSubtitle;
  IconData avatarIcon;
  Color avatarColor;
  String? securityPin;
  bool reminderEnabled;
  String reminderSchedule;
  String officerPhone;

  ProfilData({
    this.businessName = 'Warung Bu Sari',
    this.businessSubtitle = 'Kedai Makan • Bekasi',
    this.avatarIcon = Icons.ramen_dining,
    this.avatarColor = const Color(0xFFF97316),
    this.securityPin,
    this.reminderEnabled = true,
    this.reminderSchedule = 'Setiap Senin, 09:00',
    this.officerPhone = '0812-3456-7890',
  });
}

class ProfilPage extends StatefulWidget {
  final ProfilData profilData;
  final List< Map< String, dynamic > > transactions;
  final List< UtangItem > utangList;
  final List< StockItem > stockList;
  final int dapurIncome;
  final int dapurExpense;
  final int usahaIncome;
  final int usahaExpense;
  final VoidCallback onProfileUpdated;

  const ProfilPage({
    super.key,
    required this.profilData,
    required this.transactions,
    required this.utangList,
    required this.stockList,
    required this.dapurIncome,
    required this.dapurExpense,
    required this.usahaIncome,
    required this.usahaExpense,
    required this.onProfileUpdated,
  });

  @override
  State< ProfilPage > createState() => _ProfilPageState();
}

class _ProfilPageState extends State< ProfilPage > {
  final List< Map< String, dynamic > > avatarChoices = [
    {'icon': Icons.ramen_dining, 'label': 'Kuliner'},
    {'icon': Icons.local_cafe, 'label': 'Kopi'},
    {'icon': Icons.storefront, 'label': 'Toko'},
    {'icon': Icons.restaurant, 'label': 'Warung'},
    {'icon': Icons.bakery_dining, 'label': 'Roti'},
    {'icon': Icons.local_grocery_store, 'label': 'Sembako'},
  ];

  final List< Color > colorChoices = [
    const Color(0xFFF97316),
    const Color(0xFF087653),
    const Color(0xFF1D4ED8),
    const Color(0xFF7C3AED),
    const Color(0xFFDC2626),
  ];

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

  int get bankableScore {
    int score = 25;
    if (widget.transactions.isNotEmpty) score += 25;
    final bool hasDapur = widget.dapurIncome > 0 || widget.dapurExpense > 0;
    final bool hasUsaha = widget.usahaIncome > 0 || widget.usahaExpense > 0;
    if (hasDapur && hasUsaha) score += 25;
    if (widget.stockList.any((s) => s.quantity > 0)) score += 15;
    if (!widget.utangList.any((u) => u.status == UtangStatus.lewat)) score += 10;
    return score.clamp(0, 100);
  }

  int get activeUtangCount =>
      widget.utangList.where((u) => u.status != UtangStatus.lunas).length;

  int get activeUtangTotal => widget.utangList
      .where((u) => u.status != UtangStatus.lunas)
      .fold(0, (sum, u) => sum + u.amount);

  void _showEditProfilDialog() {
    final nameController = TextEditingController(text: widget.profilData.businessName);
    final subController = TextEditingController(text: widget.profilData.businessSubtitle);
    IconData selectedIcon = widget.profilData.avatarIcon;
    Color selectedColor = widget.profilData.avatarColor;

    showDialog< void >(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Edit Profil Usaha',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: selectedColor,
                        child: Icon(selectedIcon, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nama Usaha',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subController,
                      decoration: InputDecoration(
                        labelText: 'Kategori & Kota',
                        hintText: 'Contoh: Kedai Makan • Bekasi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Pilih Ikon Usaha:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: avatarChoices.map((choice) {
                        final IconData icon = choice['icon'] as IconData;
                        final bool isSelected = selectedIcon == icon;
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setDialogState(() => selectedIcon = icon),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withOpacity(0.15)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? selectedColor : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 22,
                                color: isSelected ? selectedColor : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Warna Avatar:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: colorChoices.map((color) {
                        final bool isSelected = selectedColor == color;
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.black87 : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
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
                    backgroundColor: const Color(0xFF087653),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final newName = nameController.text.trim();
                    final newSub = subController.text.trim();
                    setState(() {
                      if (newName.isNotEmpty) widget.profilData.businessName = newName;
                      if (newSub.isNotEmpty) widget.profilData.businessSubtitle = newSub;
                      widget.profilData.avatarIcon = selectedIcon;
                      widget.profilData.avatarColor = selectedColor;
                    });
                    widget.onProfileUpdated();
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

  void _showBankableScoreDialog() {
    final bool hasTx = widget.transactions.isNotEmpty;
    final bool hasDualWallet = (widget.dapurIncome > 0 || widget.dapurExpense > 0) &&
        (widget.usahaIncome > 0 || widget.usahaExpense > 0);
    final bool hasStock = widget.stockList.any((s) => s.quantity > 0);
    final bool noOverdueDebt = !widget.utangList.any((u) => u.status == UtangStatus.lewat);

    showDialog< void >(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skor Kesiapan Modal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$bankableScore/100',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMissionTile('Akun usaha terverifikasi (+25)', true),
              _buildMissionTile('Mencatat transaksi keuangan (+25)', hasTx),
              _buildMissionTile('Pisahkan Dompet Dapur & Usaha (+25)', hasDualWallet),
              _buildMissionTile('Kelola stok bahan baku (+15)', hasStock),
              _buildMissionTile('Bebas piutang lewat jatuh tempo (+10)', noOverdueDebt),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087653),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissionTile(String text, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF16A34A) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: done ? Colors.black87 : Colors.grey.shade600,
                fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPinDialog() {
    final pinController = TextEditingController(text: widget.profilData.securityPin ?? '');
    bool isPinActive = widget.profilData.securityPin != null;

    showDialog< void >(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Ubah PIN Keamanan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aktifkan Kunci PIN', style: TextStyle(fontSize: 14)),
                    activeColor: const Color(0xFF087653),
                    value: isPinActive,
                    onChanged: (val) => setDialogState(() => isPinActive = val),
                  ),
                  if (isPinActive) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: pinController,
                      obscureText: true,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Masukkan 4 Digit PIN',
                        hintText: '****',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087653),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (isPinActive && pinController.text.length < 4) return;
                    setState(() {
                      widget.profilData.securityPin =
                          isPinActive ? pinController.text : null;
                    });
                    widget.onProfileUpdated();
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isPinActive
                              ? 'PIN keamanan 4 digit berhasil disimpan!'
                              : 'Kunci PIN dinonaktifkan.',
                        ),
                        backgroundColor: const Color(0xFF087653),
                      ),
                    );
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

  void _showReminderDialog() {
    bool enabled = widget.profilData.reminderEnabled;
    String schedule = widget.profilData.reminderSchedule;
    final schedules = [
      'Setiap Hari, 19:00',
      'Setiap Senin, 09:00',
      'Setiap Jumat, 15:00',
      'Akhir Bulan, 10:00',
    ];

    showDialog< void >(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Pengingat Tagihan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notifikasi Otomatis', style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      '$activeUtangCount tagihan aktif (Rp ${_formatAmount(activeUtangTotal)})',
                      style: const TextStyle(fontSize: 12),
                    ),
                    activeColor: const Color(0xFF087653),
                    value: enabled,
                    onChanged: (val) => setDialogState(() => enabled = val),
                  ),
                  if (enabled) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Jadwal Pengingat:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField< String >(
                      value: schedules.contains(schedule) ? schedule : schedules.first,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: schedules
                          .map((s) => DropdownMenuItem< String >(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => schedule = val);
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087653),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.profilData.reminderEnabled = enabled;
                      widget.profilData.reminderSchedule = schedule;
                    });
                    widget.onProfileUpdated();
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

  void _showBantuanSuaraSheet() {
    final int dapurBal = widget.dapurIncome - widget.dapurExpense;
    final int usahaBal = widget.usahaIncome - widget.usahaExpense;
    final lowStocks = widget.stockList.where((s) => s.quantity <= 30).map((s) => s.name).toList();
    final String stockBrief = lowStocks.isEmpty
        ? 'Semua stok bahan dalam kondisi aman.'
        : 'Perhatian, stok ${lowStocks.join(", ")} masih menipis dan perlu restok.';

    final String spokenScript =
        'Halo ${widget.profilData.businessName}. '
        'Sisa saldo Dompet Dapur saat ini Rp ${_formatAmount(dapurBal)}, '
        'dan saldo Dompet Usaha Rp ${_formatAmount(usahaBal)}. '
        'Terdapat $activeUtangCount catatan utang pelanggan senilai Rp ${_formatAmount(activeUtangTotal)}. '
        '$stockBrief';

    showModalBottomSheet< void >(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.volume_up_rounded, color: Color(0xFF1D4ED8)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Suara BukuKas',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Membacakan kondisi keuangan terkini',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '"$spokenScript"',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPdfPreviewSheet() {
    final int dapurBal = widget.dapurIncome - widget.dapurExpense;
    final int usahaBal = widget.usahaIncome - widget.usahaExpense;

    showModalBottomSheet< void >(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Color(0xFF1D4ED8), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pratinjau Laporan PDF — ${widget.profilData.businessName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profilData.businessName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      widget.profilData.businessSubtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 20),
                    _buildReportRow('Saldo Dompet Dapur', 'Rp ${_formatAmount(dapurBal)}'),
                    _buildReportRow('Saldo Dompet Usaha', 'Rp ${_formatAmount(usahaBal)}'),
                    _buildReportRow('Total Transaksi Tercatat', '${widget.transactions.length} transaksi'),
                    _buildReportRow('Piutang Belum Lunas', 'Rp ${_formatAmount(activeUtangTotal)}'),
                    _buildReportRow('Skor Kesiapan Modal', '$bankableScore / 100'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Laporan_${widget.profilData.businessName.replaceAll(" ", "_")}.pdf berhasil dicetak!',
                        ),
                        backgroundColor: const Color(0xFF1D4ED8),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text(
                    'Unduh & Cetak PDF',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showWhatsAppSheet() {
    final phoneController = TextEditingController(text: widget.profilData.officerPhone);
    final int usahaBal = widget.usahaIncome - widget.usahaExpense;
    final String waMessage =
        '*Laporan Keuangan Usaha - ${widget.profilData.businessName}*\n'
        'Kategori: ${widget.profilData.businessSubtitle}\n'
        '• Pemasukan Usaha: Rp ${_formatAmount(widget.usahaIncome)}\n'
        '• Pengeluaran Usaha: Rp ${_formatAmount(widget.usahaExpense)}\n'
        '• Saldo Bersih Usaha: Rp ${_formatAmount(usahaBal)}\n'
        '• Skor Kesiapan Modal: $bankableScore/100\n'
        'Dikirim via Aplikasi BukuKas';

    showModalBottomSheet< void >(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.chat_rounded, color: Color(0xFF16A34A), size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Kirim ke WhatsApp Petugas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor WhatsApp Petugas KUR / Koperasi',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Text(
                  waMessage,
                  style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF14532D)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    widget.profilData.officerPhone = phoneController.text.trim();
                    Clipboard.setData(ClipboardData(text: waMessage));
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pesan laporan disalin & siap dikirim ke ${widget.profilData.officerPhone}!',
                        ),
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text(
                    'Salin & Kirim ke WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPin = widget.profilData.securityPin != null;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final contentWidth = isWide ? 600.0 : constraints.maxWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 96),
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _showEditProfilDialog,
                        child: Stack(
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                color: widget.profilData.avatarColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.profilData.avatarColor.withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.profilData.avatarIcon,
                                color: Colors.white,
                                size: 46,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF033524),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _showEditProfilDialog,
                        child: Column(
                          children: [
                            Text(
                              widget.profilData.businessName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.profilData.businessSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _showBankableScoreDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF22C55E), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: Color(0xFF15803D), size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Skor Kesiapan Modal (KUR)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF14532D),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: bankableScore / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.white,
                                        valueColor: const AlwaysStoppedAnimation< Color >(
                                          Color(0xFF16A34A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$bankableScore/100',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildMenuTile(
                      icon: Icons.lock_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Ubah PIN Keamanan',
                      badgeText: hasPin ? 'Aktif' : 'Nonaktif',
                      badgeColor: hasPin ? const Color(0xFF16A34A) : Colors.grey,
                      onTap: _showPinDialog,
                    ),
                    const SizedBox(height: 10),
                    _buildMenuTile(
                      icon: Icons.notifications_active_rounded,
                      iconBg: const Color(0xFFFEF9C3),
                      iconColor: const Color(0xFFCA8A04),
                      title: 'Pengingat Tagihan',
                      badgeText: widget.profilData.reminderEnabled ? 'On' : 'Off',
                      badgeColor: widget.profilData.reminderEnabled
                          ? const Color(0xFF16A34A)
                          : Colors.grey,
                      onTap: _showReminderDialog,
                    ),
                    const SizedBox(height: 10),
                    _buildMenuTile(
                      icon: Icons.campaign_rounded,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      title: 'Bantuan Suara',
                      badgeText: 'Dengar',
                      badgeColor: const Color(0xFF1D4ED8),
                      onTap: _showBantuanSuaraSheet,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _showPdfPreviewSheet,
                        icon: const Icon(Icons.description_rounded, color: Colors.white),
                        label: const Text(
                          'Cetak Laporan ke PDF',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          enabledMouseCursor: SystemMouseCursors.click,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _showWhatsAppSheet,
                        icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                        label: const Text(
                          'Kirim ke WhatsApp Petugas',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          enabledMouseCursor: SystemMouseCursors.click,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}