import 'package:flutter/material.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _bahanUtama = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _loading = true);

    final userId = supabase.auth.currentUser!.id;

    final profileData = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    final bahanData = await supabase
        .from('bahan')
        .select()
        .order('stok_saat_ini', ascending: true)
        .limit(5);

    setState(() {
      _profile = profileData;
      _bahanUtama = List<Map<String, dynamic>>.from(bahanData);
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
    final persen = stok / target;
    return persen.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white24,
              child: Icon(Icons.storefront, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('SPPG Priangan Jaya', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Banner utama
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [kTealDark, kTealDarker],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 80),
                              child: Text(
                                'Halo, ${_profile?['nama'] ?? '-'} 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Peran: ${_profile?['role'] ?? '-'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.only(right: 70),
                              child: Text(
                                'Pantau kondisi persediaan bahan dan catat aktivitas terbaru dari sini.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -18,
                        right: 4,
                        child: Image.asset(
                          'assets/images/maskot_makan.png',
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Ketersediaan Bahan Utama',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_bahanUtama.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Belum ada data barang.')),
                    )
                  else
                    ..._bahanUtama.map((barang) {
                      final status = _statusStok(barang);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                              child: const Icon(
                                Icons.eco_outlined,
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
                                      Text(
                                        barang['nama_bahan'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
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
                                  const SizedBox(height: 6),
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
                    }),
                ],
              ),
            ),
    );
  }
}
