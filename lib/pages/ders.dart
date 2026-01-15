import 'dart:convert';
import 'package:flutter/material.dart';
import '/services/database_helper.dart'; // DatabaseHelper dosya yoluna dikkat edin

class Gorev {
  String ad;
  bool tamamlandi;
  late TextEditingController controller;

  Gorev(this.ad, this.tamamlandi) {
    controller = TextEditingController(text: ad);
  }

  Map<String, dynamic> toJson() => {'ad': ad, 'tamamlandi': tamamlandi};

  factory Gorev.fromJson(Map<String, dynamic> json) {
    return Gorev(json['ad'], json['tamamlandi']);
  }
}

class Ders {
  String ad;
  List<Gorev> gorevler;

  Ders(this.ad, this.gorevler);

  Map<String, dynamic> toJson() => {
    'ad': ad,
    'gorevler': gorevler.map((g) => g.toJson()).toList(),
  };

  factory Ders.fromJson(Map<String, dynamic> json) {
    return Ders(
      json['ad'],
      (json['gorevler'] as List).map((g) => Gorev.fromJson(g)).toList(),
    );
  }
}

class DersPage extends StatefulWidget {
  const DersPage({super.key});

  @override
  State<DersPage> createState() => _DersPageState();
}

class _DersPageState extends State<DersPage> {
  final TextEditingController dersController = TextEditingController();
  List<Ders> dersler = [];

  @override
  void initState() {
    super.initState();
    dersleriYukle();
  }

  // Verileri SQLite'a kaydeder
  Future<void> dersleriKaydet() async {
    final jsonString = jsonEncode(dersler.map((d) => d.toJson()).toList());
    await DatabaseHelper.instance.veriyiKaydet('dersler', jsonString);
  }

  // Verileri SQLite'dan yükler
  Future<void> dersleriYukle() async {
    final jsonString = await DatabaseHelper.instance.veriyiGetir('dersler');

    if (jsonString == null) return;

    final List decoded = jsonDecode(jsonString);
    setState(() {
      dersler = decoded.map((d) => Ders.fromJson(d)).toList();
    });
  }

  void dersEkle() {
    if (dersController.text.isEmpty) return;
    setState(() {
      dersler.add(Ders(dersController.text, []));
      dersController.clear();
    });
    dersleriKaydet();
  }

  void gorevEkle(Ders ders) {
    setState(() {
      ders.gorevler.add(Gorev('', false));
    });
    dersleriKaydet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...dersler.map(dersKart).toList(),
            const SizedBox(height: 24),
            dersEkleKutusu(),
          ],
        ),
      ),
    );
  }

  Widget dersKart(Ders ders) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ders.ad,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    dersler.remove(ders);
                  });
                  dersleriKaydet();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...ders.gorevler.map((gorev) {
            return Row(
              children: [
                Checkbox(
                  value: gorev.tamamlandi,
                  onChanged: (value) {
                    setState(() {
                      gorev.tamamlandi = value!;
                    });
                    dersleriKaydet();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: gorev.controller,
                    decoration: const InputDecoration(
                      hintText: 'Görev gir',
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      gorev.ad = text;
                      dersleriKaydet();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      ders.gorevler.remove(gorev);
                    });
                    dersleriKaydet();
                  },
                ),
              ],
            );
          }),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => gorevEkle(ders),
              child: const Text('Görev ekle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget dersEkleKutusu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF42B3FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ders Adı:',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dersController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: dersEkle,
              child: const Text('Ders Ekle'),
            ),
          ),
        ],
      ),
    );
  }
}
