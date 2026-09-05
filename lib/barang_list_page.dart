import 'package:flutter/material.dart';
import 'main.dart';
import 'tambah_transaksi_page.dart';
import 'supplier_list_page.dart';

class BarangListPage extends StatefulWidget {
  const BarangListPage({super.key});

  @override
  State<BarangListPage> createState() => BarangListPageState();
}

class BarangListPageState extends State<BarangListPage> {
  List<Map<String, dynamic>> _daftarBarang = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadBarang();
  }

  Future<void> loadBarang() async {
    setState(() => _loading = true);
    final data = await supabase
        .from('bahan')
        .select()
        .order('nama_bahan', ascending: true);
    setState(() {
      _daftarBarang = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  String _statusStok(Map<String, dynamic> barang) {
    final stok = (barang['stok_saat_ini'] as num).toDouble();
    final batasMin = (barang['batas_minimum'] as num).toDouble();
    if (stok <= 0) return 'Habis';
    if (stok <= batasMin) return 'Menipis';
    return 'Aman';
  }

  Color _warnaBadge(String status) {
    switch (status) {
      case 'Habis':
        return const Color(0xFFF9D6D6);
      case 'Menipis':
        return const Color(0xFFFCE9C2);
      default:
        return const Color(0xFFD3EFDD);
    }
  }

  Color _warnaTeksBadge(String status) {
    switch (status) {
      case 'Habis':
        return const Color(0xFFB23B3B);
      case 'Menipis':
        return const Color(0xFF9A7418);
      default:
        return const Color(0xFF2E7D46);
    }
  }

  double _persenStok(Map<String, dynamic> barang) {
    final stok = (barang['stok_saat_ini'] as num).toDouble();
    final batasMin = (barang['batas_minimum'] as num).toDouble();
    final target = batasMin <= 0 ? 1 : batasMin * 3;
    return (stok / target).clamp(0.0, 1.0);
  }

  IconData _iconKategori(String? kategori) {
    switch ((kategori ?? '').toLowerCase()) {
      case 'sayur':
        return Icons.eco_outlined;
      case 'protein':
        return Icons.set_meal_outlined;
      case 'bumbu':
        return Icons.spa_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadBarang,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: kTealDark,
              foregroundColor: Colors.white,
              pinned: true,
              expandedHeight: 150,
              actions: [
                IconButton(
                  icon: const Icon(Icons.local_shipping_outlined),
                  tooltip: 'Data Supplier',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupplierListPage(),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  'Daftar Barang & Stok',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kTealDark, kTealDarker],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: Text(
                      'Pantau ketersediaan seluruh bahan makanan di sini.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_daftarBarang.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Belum ada data barang.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final barang = _daftarBarang[index];
                    final status = _statusStok(barang);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: kBgLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _iconKategori(barang['kategori']),
                              color: kTealDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        barang['nama_bahan'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${barang['stok_saat_ini']} ${barang['satuan']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  barang['kategori'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: _persenStok(barang),
                                    minHeight: 6,
                                    backgroundColor: kBgLight,
                                    color: _warnaTeksBadge(status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _warnaBadge(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _warnaTeksBadge(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: _daftarBarang.length),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kTealDark,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahTransaksiPage(),
            ),
          );
          loadBarang();
        },
        icon: const Icon(Icons.add),
        label: const Text('Catat Barang Masuk'),
      ),
    );
  }
}
