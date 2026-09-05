import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'tambah_transaksi_page.dart';

class TransaksiListPage extends StatefulWidget {
  const TransaksiListPage({super.key});

  @override
  State<TransaksiListPage> createState() => TransaksiListPageState();
}

class TransaksiListPageState extends State<TransaksiListPage> {
  List<Map<String, dynamic>> _daftarTransaksi = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadTransaksi();
  }

  Future<void> loadTransaksi() async {
    setState(() => _loading = true);

    // Ambil data transaksi sekaligus nama barangnya (join lewat relasi bahan_id)
    final data = await supabase
        .from('transaksi_stok')
        .select('*, bahan(nama_bahan, satuan)')
        .order('waktu', ascending: false)
        .limit(50);

    setState(() {
      _daftarTransaksi = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadTransaksi,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: kTealDark,
              foregroundColor: Colors.white,
              pinned: true,
              expandedHeight: 130,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  'Transaksi Stok',
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
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_daftarTransaksi.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Belum ada transaksi tercatat.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final trx = _daftarTransaksi[index];
                    final bahan = trx['bahan'] as Map<String, dynamic>?;
                    final isMasuk = trx['jenis'] == 'masuk';
                    final waktu = DateTime.tryParse(trx['waktu'] ?? '');

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
                              color: isMasuk
                                  ? const Color(0xFFD3EFDD)
                                  : const Color(0xFFF9D6D6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isMasuk ? Icons.call_received : Icons.call_made,
                              color: isMasuk
                                  ? const Color(0xFF2E7D46)
                                  : const Color(0xFFB23B3B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bahan?['nama_bahan'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  waktu != null
                                      ? DateFormat(
                                          'd MMM yyyy, HH:mm',
                                        ).format(waktu)
                                      : '-',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                                if ((trx['catatan'] ?? '')
                                    .toString()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    trx['catatan'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${isMasuk ? '+' : '-'}${trx['jumlah']} ${bahan?['satuan'] ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMasuk
                                  ? const Color(0xFF2E7D46)
                                  : const Color(0xFFB23B3B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: _daftarTransaksi.length),
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
          loadTransaksi();
        },
        icon: const Icon(Icons.add),
        label: const Text('Catat Transaksi'),
      ),
    );
  }
}
