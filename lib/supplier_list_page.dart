import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'tambah_supplier_page.dart';

class SupplierListPage extends StatefulWidget {
  const SupplierListPage({super.key});

  @override
  State<SupplierListPage> createState() => SupplierListPageState();
}

class SupplierListPageState extends State<SupplierListPage> {
  List<Map<String, dynamic>> _daftarSupplier = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadSupplier();
  }

  Future<void> loadSupplier() async {
    setState(() => _loading = true);
    final data = await supabase
        .from('supplier')
        .select()
        .order('nama_supplier', ascending: true);
    setState(() {
      _daftarSupplier = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  Future<void> _hubungiWa(String nomor) async {
    var nomorBersih = nomor.replaceAll(RegExp(r'[^0-9]'), '');
    if (nomorBersih.startsWith('0')) {
      nomorBersih = '62${nomorBersih.substring(1)}';
    }
    final url = Uri.parse('https://wa.me/$nomorBersih');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka WhatsApp')),
        );
      }
    }
  }

  Future<void> _hubungiTelepon(String nomor) async {
    final url = Uri.parse('tel:$nomor');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka aplikasi telepon')),
        );
      }
    }
  }

  Future<void> _hubungiEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka aplikasi email')),
        );
      }
    }
  }

  Future<void> _hapusSupplier(Map<String, dynamic> supplier) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus supplier?'),
        content: Text(
          'Data "${supplier['nama_supplier']}" akan dihapus permanen. Yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      await supabase.from('supplier').delete().eq('id', supplier['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier berhasil dihapus')),
        );
      }
      loadSupplier();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  void _bukaMenuAksi(Map<String, dynamic> supplier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: kTealDark),
              title: const Text('Edit Supplier'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TambahSupplierPage(supplierEdit: supplier),
                  ),
                );
                loadSupplier();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Hapus Supplier',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _hapusSupplier(supplier);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadSupplier,
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
                  'Data Supplier',
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
            else if (_daftarSupplier.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Belum ada data supplier.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final s = _daftarSupplier[index];
                    final wa = (s['kontak_wa'] ?? '').toString();
                    final telp = (s['kontak_telp'] ?? '').toString();
                    final email = (s['kontak_email'] ?? '').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: kBgLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: const Icon(
                                  Icons.local_shipping_outlined,
                                  color: kTealDark,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s['nama_supplier'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if ((s['catatan'] ?? '')
                                        .toString()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        s['catatan'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.black45,
                                ),
                                onPressed: () => _bukaMenuAksi(s),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          if (wa.isNotEmpty ||
                              telp.isNotEmpty ||
                              email.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (wa.isNotEmpty)
                                  _TombolKontak(
                                    icon: Icons.chat,
                                    label: 'WhatsApp',
                                    color: const Color(0xFF2E7D46),
                                    onTap: () => _hubungiWa(wa),
                                  ),
                                if (wa.isNotEmpty &&
                                    (telp.isNotEmpty || email.isNotEmpty))
                                  const SizedBox(width: 10),
                                if (telp.isNotEmpty)
                                  _TombolKontak(
                                    icon: Icons.call,
                                    label: 'Telepon',
                                    color: kTealDark,
                                    onTap: () => _hubungiTelepon(telp),
                                  ),
                                if (telp.isNotEmpty && email.isNotEmpty)
                                  const SizedBox(width: 10),
                                if (email.isNotEmpty)
                                  _TombolKontak(
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                    color: const Color(0xFF9A7418),
                                    onTap: () => _hubungiEmail(email),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }, childCount: _daftarSupplier.length),
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
            MaterialPageRoute(builder: (context) => const TambahSupplierPage()),
          );
          loadSupplier();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Supplier'),
      ),
    );
  }
}

class _TombolKontak extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TombolKontak({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
