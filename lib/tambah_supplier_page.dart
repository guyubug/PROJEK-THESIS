import 'package:flutter/material.dart';
import 'main.dart';

class TambahSupplierPage extends StatefulWidget {
  // Kalau supplierEdit diisi (nggak null), form ini otomatis jadi mode EDIT,
  // isian form otomatis ke-fill data lama, dan tombol Simpan akan UPDATE bukan INSERT.
  final Map<String, dynamic>? supplierEdit;

  const TambahSupplierPage({super.key, this.supplierEdit});

  @override
  State<TambahSupplierPage> createState() => _TambahSupplierPageState();
}

class _TambahSupplierPageState extends State<TambahSupplierPage> {
  late final TextEditingController _namaController;
  late final TextEditingController _waController;
  late final TextEditingController _telpController;
  late final TextEditingController _emailController;
  late final TextEditingController _catatanController;

  bool _isSaving = false;

  bool get _modeEdit => widget.supplierEdit != null;

  @override
  void initState() {
    super.initState();
    final s = widget.supplierEdit;
    _namaController = TextEditingController(text: s?['nama_supplier'] ?? '');
    _waController = TextEditingController(text: s?['kontak_wa'] ?? '');
    _telpController = TextEditingController(text: s?['kontak_telp'] ?? '');
    _emailController = TextEditingController(text: s?['kontak_email'] ?? '');
    _catatanController = TextEditingController(text: s?['catatan'] ?? '');
  }

  Future<void> _simpanSupplier() async {
    setState(() => _isSaving = true);

    final data = {
      'nama_supplier': _namaController.text.trim().isEmpty
          ? 'Supplier Tanpa Nama'
          : _namaController.text.trim(),
      'kontak_wa': _waController.text.trim(),
      'kontak_telp': _telpController.text.trim(),
      'kontak_email': _emailController.text.trim(),
      'catatan': _catatanController.text.trim(),
    };

    try {
      if (_modeEdit) {
        await supabase
            .from('supplier')
            .update(data)
            .eq('id', widget.supplierEdit!['id']);
      } else {
        await supabase.from('supplier').insert(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _modeEdit
                  ? 'Supplier berhasil diperbarui'
                  : 'Supplier berhasil ditambahkan',
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
    _namaController.dispose();
    _waController.dispose();
    _telpController.dispose();
    _emailController.dispose();
    _catatanController.dispose();
    super.dispose();
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
                        Padding(
                          padding: const EdgeInsets.only(right: 70),
                          child: Text(
                            _modeEdit ? 'Edit Supplier' : 'Tambah Supplier',
                            style: const TextStyle(
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
                            'Isi data sebisanya, semua kolom boleh dikosongkan.',
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
                    top: 10,
                    right: 25,
                    child: Image.asset(
                      'assets/images/maskot_makan.png',
                      height: 130,
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
                      'Nama Supplier',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: CV Sumber Rejeki',
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Nomor WhatsApp',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _waController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: '08xx'),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Nomor Telepon',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _telpController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: 'Isi'),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'boleh di isi',
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Catatan',
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
                        hintText:
                            'Misal: jam operasional, spesialisasi barang, dll',
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _simpanSupplier,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
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
