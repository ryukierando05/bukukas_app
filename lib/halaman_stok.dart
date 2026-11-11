import 'package:flutter/material.dart';

class HalamanStok extends StatelessWidget {
  const HalamanStok({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data untuk stok
    final List<Map<String, dynamic>> stokBarang = [
      {'nama': 'Beras Premium', 'stok': 15, 'satuan': 'Karung', 'warna': Colors.orange},
      {'nama': 'Minyak Goreng', 'stok': 24, 'satuan': 'Botol', 'warna': Colors.yellow},
      {'nama': 'Gula Pasir', 'stok': 10, 'satuan': 'Kg', 'warna': Colors.blue},
      {'nama': 'Telur Ayam', 'stok': 5, 'satuan': 'Tray', 'warna': Colors.brown},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manajemen Stok & Utang',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF033524)),
            ),
            const SizedBox(height: 16),
            // Card ringkasan utang
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Utang Dagang', style: TextStyle(color: Colors.red, fontSize: 12)),
                      Text('Rp 1.500.000', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Daftar Stok Barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // ListView.builder untuk daftar stok
            Expanded(
              child: ListView.builder(
                itemCount: stokBarang.length,
                itemBuilder: (context, index) {
                  final item = stokBarang[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (item['warna'] as Color).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.inventory_2, color: item['warna'] as Color),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text('${item['stok']} ${item['satuan']}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}