import 'package:flutter/material.dart';

class HalamanProfil extends StatelessWidget {
  const HalamanProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Menggunakan CircleAvatar
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF087653),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pengguna BukuKas', // <-- Nama Dummy
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF033524)),
            ),
            const Text('pengguna@bukukas.com', style: TextStyle(color: Colors.grey)), // <-- Email Dummy
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
              child: const Text('Akun Demo', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            // List Menu Pengaturan menggunakan Column & Row
            _buildMenuTile(Icons.store, 'Nama Usaha', 'Warung Berkah'),
            _buildMenuTile(Icons.phone, 'Nomor HP', '0812-3456-7890'),
            _buildMenuTile(Icons.settings, 'Pengaturan Aplikasi', ''),
            _buildMenuTile(Icons.logout, 'Keluar Akun', '', isRed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, {bool isRed = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: isRed ? Colors.red : const Color(0xFF087653)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isRed ? Colors.red : Colors.black)),
                if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (!isRed) const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}