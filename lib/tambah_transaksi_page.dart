import 'package:flutter/material.dart';
import 'main.dart';

class TambahTransaksiPage extends StatefulWidget {
  const TambahTransaksiPage({super.key});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();

  final _namaBaruController = TextEditingController();
  final _kategoriBaruController = TextEditingController();
  final _satuanBaruController = TextEditingController();
  final _batasMinBaruController = TextEditingController();

  List<Map<String, dynamic>> _daftarBahan = [];
  String? _bahanIdTerpilih;
  String _jenis = 'masuk';
  bool _modeBarangBaru = false;
  bool _loadingBahan = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBahan();
  }

  Future<void> _loadBahan() async {
    final data = await supabase
        .from('bahan')
        .select('id, nama_bahan, satuan')
        .order('nama_bahan');

    setState(() {
      _daftarBahan = List<Map<String, dynamic>>.from(data);
      _loadingBahan = false;
    });
  }

  Future<void> _simpanTransaksi() async {
    final jumlah = double.tryParse(_jumlahController.text.trim()) ?? 0;

    setState(() => _isSaving = true);

    try {
      String bahanId;

      if (_modeBarangBaru) {
        final namaBaru = _namaBaruController.text.trim().isEmpty
            ? 'Barang Tanpa Nama'
            : _namaBaruController.text.trim();

        final barangBaru = await supabase
            .from('bahan')
            .insert({
              'nama_bahan': namaBaru,
              'kategori': _kategoriBaruController.text.trim(),
              'satuan': _satuanBaruController.text.trim(),
              'stok_saat_ini': 0,
              'batas_minimum':
                  double.tryParse(_batasMinBaruController.text.trim()) ?? 0,
            })
            .select('id')
            .single();

        bahanId = barangBaru['id'] as String;
      } else {
        if (_bahanIdTerpilih == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pilih barang dulu, ess')),
          );
          setState(() => _isSaving = false);
          return;
        }
        bahanId = _bahanIdTerpilih!;
      }

      await supabase.from('transaksi_stok').insert({
        'bahan_id': bahanId,
        'jenis': _jenis,
        'jumlah': jumlah,
        'dilakukan_oleh': supabase.auth.currentUser!.id,
        'catatan': _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _modeBarangBaru
                  ? 'Barang baru & stok awal berhasil dicatat'
                  : 'Transaksi berhasil dicatat',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _catatanController.dispose();
    _namaBaruController.dispose();
    _kategoriBaruController.dispose();
    _satuanBaruController.dispose();
    _batasMinBaruController.dispose();
    super.dispose();
  }

  Widget _tabJenis(String label, IconData icon, String value) {
    final aktif = _jenis == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _jenis = value;
          if (value == 'keluar') _modeBarangBaru = false;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: aktif ? kTealDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: aktif ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: aktif ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.w600,
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
    return Scaffold(
      backgroundColor: kBgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
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
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.only(right: 70),
                          child: Text(
                            'Catat Transaksi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.only(right: 70),
                          child: Text(
                            'Barang masuk bisa untuk barang baru maupun yang sudah ada.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 20,
                    child: Image.asset(
                      'assets/images/maskot_makan.png',
                      height: 120,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jenis Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _tabJenis('Barang Masuk', Icons.call_received, 'masuk'),
                        const SizedBox(width: 12),
                        _tabJenis('Barang Keluar', Icons.call_made, 'keluar'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_jenis == 'masuk') ...[
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _modeBarangBaru = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: !_modeBarangBaru
                                      ? kTealDark.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: !_modeBarangBaru
                                        ? kTealDark
                                        : Colors.black26,
                                  ),
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Barang Sudah Ada',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: !_modeBarangBaru
                                        ? kTealDark
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _modeBarangBaru = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _modeBarangBaru
                                      ? kTealDark.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _modeBarangBaru
                                        ? kTealDark
                                        : Colors.black26,
                                  ),
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Barang Baru',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _modeBarangBaru
                                        ? kTealDark
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_jenis == 'masuk' && _modeBarangBaru) ...[
                      const Text(
                        'Nama Barang Baru',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _namaBaruController,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Tempe',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _kategoriBaruController,
                        decoration: const InputDecoration(
                          hintText: 'isi kategori barang (opsional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Satuan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _satuanBaruController,
                                  decoration: const InputDecoration(
                                    hintText: 'Kg / Pcs',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Min Stok',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _batasMinBaruController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      const Text(
                        'Pilih Barang',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _loadingBahan
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CircularProgressIndicator(),
                            )
                          : DropdownButtonFormField<String>(
                              initialValue: _bahanIdTerpilih,
                              decoration: const InputDecoration(
                                hintText: 'Pilih barang',
                              ),
                              items: _daftarBahan
                                  .map(
                                    (b) => DropdownMenuItem<String>(
                                      value: b['id'] as String,
                                      child: Text(
                                        '${b['nama_bahan']} (${b['satuan'] ?? '-'})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _bahanIdTerpilih = value),
                            ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      _modeBarangBaru ? 'Jumlah Stok Awal' : 'Jumlah',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _jumlahController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(hintText: '0'),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Catatan (opsional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan keterangan jika perlu',
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _simpanTransaksi,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Simpan'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
