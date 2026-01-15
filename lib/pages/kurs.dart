import 'dart:convert';
import 'package:flutter/material.dart';
import '/services/database_helper.dart'; // DatabaseHelper dosya yolunun doğru olduğundan emin olun

class Konu {
  String ad;
  bool tamamlandi;
  late TextEditingController controller;

  Konu(this.ad, this.tamamlandi) {
    controller = TextEditingController(text: ad);
  }

  Map<String, dynamic> toJson() => {'ad': ad, 'tamamlandi': tamamlandi};

  factory Konu.fromJson(Map<String, dynamic> json) {
    return Konu(json['ad'], json['tamamlandi']);
  }
}

class Kurs {
  String ad;
  List<Konu> konular;

  Kurs(this.ad, this.konular);

  Map<String, dynamic> toJson() => {
    'ad': ad,
    'konular': konular.map((k) => k.toJson()).toList(),
  };

  factory Kurs.fromJson(Map<String, dynamic> json) {
    return Kurs(
      json['ad'],
      (json['konular'] as List).map((k) => Konu.fromJson(k)).toList(),
    );
  }
}

class KursPage extends StatefulWidget {
  const KursPage({super.key});

  @override
  State<KursPage> createState() => _KursPageState();
}

class _KursPageState extends State<KursPage> {
  final TextEditingController kursController = TextEditingController();
  List<Kurs> kurslar = [];

  @override
  void initState() {
    super.initState();
    kurslariYukle();
  }

  // SharedPreferences yerine DatabaseHelper.instance.veriyiKaydet kullanıyoruz
  Future<void> kurslariKaydet() async {
    final jsonString = jsonEncode(kurslar.map((k) => k.toJson()).toList());
    await DatabaseHelper.instance.veriyiKaydet('kurslar', jsonString);
  }

  // SharedPreferences yerine DatabaseHelper.instance.veriyiGetir kullanıyoruz
  Future<void> kurslariYukle() async {
    final jsonString = await DatabaseHelper.instance.veriyiGetir('kurslar');

    if (jsonString == null) return;

    final List decoded = jsonDecode(jsonString);
    setState(() {
      kurslar = decoded.map((k) => Kurs.fromJson(k)).toList();
    });
  }

  void kursEkle() {
    if (kursController.text.isEmpty) return;

    setState(() {
      kurslar.add(Kurs(kursController.text, []));
      kursController.clear();
    });

    kurslariKaydet();
  }

  void konuEkle(Kurs kurs) {
    setState(() {
      kurs.konular.add(Konu('', false));
    });

    kurslariKaydet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...kurslar.map(kursKart).toList(),
            const SizedBox(height: 24),
            kursEkleKutusu(),
          ],
        ),
      ),
    );
  }

  Widget kursKart(Kurs kurs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kurs.ad,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    kurslar.remove(kurs);
                  });
                  kurslariKaydet();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...kurs.konular.map((konu) {
            return Row(
              children: [
                Checkbox(
                  value: konu.tamamlandi,
                  onChanged: (value) {
                    setState(() {
                      konu.tamamlandi = value!;
                    });
                    kurslariKaydet();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: konu.controller,
                    decoration: const InputDecoration(
                      hintText: 'Konu gir',
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      konu.ad = text;
                      kurslariKaydet();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      kurs.konular.remove(konu);
                    });
                    kurslariKaydet();
                  },
                ),
              ],
            );
          }),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => konuEkle(kurs),
              child: const Text('Konu ekle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget kursEkleKutusu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C8CFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kurs Adı:',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: kursController,
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
              onPressed: kursEkle,
              child: const Text('Kurs Ekle'),
            ),
          ),
        ],
      ),
    );
  }
}
