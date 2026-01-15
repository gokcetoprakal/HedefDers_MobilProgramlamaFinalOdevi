import 'dart:convert';
import 'package:flutter/material.dart';
import '/services/database_helper.dart'; // DatabaseHelper yolunu kontrol edin

class DersProgramiPage extends StatefulWidget {
  const DersProgramiPage({super.key});

  @override
  State<DersProgramiPage> createState() => _DersProgramiPageState();
}

class _DersProgramiPageState extends State<DersProgramiPage> {
  String secilenGun = 'Pazartesi';
  String secilenTur = 'Ders';

  final TextEditingController isimController = TextEditingController();
  final TextEditingController zamanController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> programVerisi = {
    'Pazartesi': [],
    'Salı': [],
    'Çarşamba': [],
    'Perşembe': [],
    'Cuma': [],
    'Cumartesi': [],
    'Pazar': [],
  };

  final Map<String, Color> turRenkleri = {
    'Ders': const Color(0xFF1E88FF),
    'Kurs': const Color(0xFF4FC3F7),
    'Etkinlik': const Color(0xFFB3E5FC),
  };

  @override
  void initState() {
    super.initState();
    programYukle();
  }

  // 🔹 SQLite'A KAYDET
  Future<void> programKaydet() async {
    final encoded = jsonEncode(
      programVerisi.map(
        (gun, liste) => MapEntry(
          gun,
          liste
              .map(
                (v) => {
                  'isim': v['isim'],
                  'zaman': v['zaman'],
                  'renk': (v['renk'] as Color).value, // Color -> int
                },
              )
              .toList(),
        ),
      ),
    );

    // DatabaseHelper kullanarak kaydet
    await DatabaseHelper.instance.veriyiKaydet('ders_programi', encoded);
  }

  // 🔹 SQLite'DAN YÜKLE
  Future<void> programYukle() async {
    final jsonString = await DatabaseHelper.instance.veriyiGetir(
      'ders_programi',
    );

    if (jsonString == null) return;

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    setState(() {
      programVerisi = decoded.map(
        (gun, liste) => MapEntry(
          gun,
          List<Map<String, dynamic>>.from(
            liste.map(
              (v) => {
                'isim': v['isim'],
                'zaman': v['zaman'],
                'renk': Color(v['renk']), // int -> Color
              },
            ),
          ),
        ),
      );
    });
  }

  // 🔹 EKLE
  void veriEkle() {
    if (isimController.text.isEmpty || zamanController.text.isEmpty) return;

    setState(() {
      programVerisi[secilenGun]!.add({
        'isim': isimController.text,
        'zaman': zamanController.text,
        'renk': turRenkleri[secilenTur],
      });

      programVerisi[secilenGun]!.sort(
        (a, b) => a['zaman'].compareTo(b['zaman']),
      );

      isimController.clear();
      zamanController.clear();
    });

    programKaydet();
  }

  // 🔹 SİL
  void satirSil(String gun, int index) {
    setState(() {
      programVerisi[gun]!.removeAt(index);
    });

    programKaydet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ustPanel(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: programVerisi.keys.map(gunKarti).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 ÜST PANEL
  Widget ustPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: secilenGun,
                  isExpanded: true,
                  onChanged: (v) => setState(() => secilenGun = v!),
                  items: programVerisi.keys
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                ),
              ),
              const SizedBox(width: 10),
              ...['Ders', 'Kurs', 'Etkinlik'].map(
                (tur) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ChoiceChip(
                    label: Text(tur, style: const TextStyle(fontSize: 12)),
                    selected: secilenTur == tur,
                    selectedColor: turRenkleri[tur],
                    onSelected: (_) => setState(() => secilenTur = tur),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: isimController,
                  decoration: const InputDecoration(hintText: "Ders Adı"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: zamanController,
                  decoration: const InputDecoration(hintText: "09:00"),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Color(0xFF1E88FF),
                  size: 35,
                ),
                onPressed: veriEkle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 GÜN KARTI
  Widget gunKarti(String gun) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gun,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            if (programVerisi[gun]!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "// Veri girilmemiş",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ...programVerisi[gun]!.asMap().entries.map((e) {
              final idx = e.key;
              final v = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: v['renk'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        v['isim'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(v['zaman']),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => satirSil(gun, idx),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black54,
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
