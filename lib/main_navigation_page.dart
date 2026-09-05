import 'package:flutter/material.dart';
import 'main.dart';
import 'home_page.dart';
import 'barang_list_page.dart';
import 'transaksi_list_page.dart';
import 'profil_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // GlobalKey memberi kita "akses jarak jauh" ke tiap halaman,
  // supaya bisa manggil fungsi reload-nya dari sini
  final _homeKey = GlobalKey<HomePageState>();
  final _barangKey = GlobalKey<BarangListPageState>();
  final _transaksiKey = GlobalKey<TransaksiListPageState>();

  late final List<Widget> _pages = [
    HomePage(key: _homeKey),
    BarangListPage(key: _barangKey),
    TransaksiListPage(key: _transaksiKey),
    const ProfilPage(),
  ];

  final _labels = const ['Beranda', 'Barang', 'Catatan', 'Profil'];
  final _icons = const [
    Icons.home_outlined,
    Icons.inventory_2_outlined,
    Icons.receipt_long_outlined,
    Icons.person_outline,
  ];
  final _iconsActive = const [
    Icons.home,
    Icons.inventory_2,
    Icons.receipt_long,
    Icons.person,
  ];

  void _pindahTab(int index) {
    setState(() => _selectedIndex = index);

    // Setiap pindah tab, refresh data halaman yang dituju
    // biar selalu nampilin data terbaru tanpa perlu tarik-refresh manual
    switch (index) {
      case 0:
        _homeKey.currentState?.loadData();
        break;
      case 1:
        _barangKey.currentState?.loadBarang();
        break;
      case 2:
        _transaksiKey.currentState?.loadTransaksi();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_labels.length, (index) {
              final isActive = _selectedIndex == index;
              return GestureDetector(
                onTap: () => _pindahTab(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? kTealDark : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? _iconsActive[index] : _icons[index],
                        size: 22,
                        color: isActive ? Colors.white : Colors.black45,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          _labels[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
