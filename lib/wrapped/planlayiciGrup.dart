import 'package:flutter/material.dart';
import '/pages/ders.dart';
import '/pages/kurs.dart';
import '/pages/program.dart';

class PlanlayiciGrup extends StatefulWidget {
  const PlanlayiciGrup({super.key});

  @override
  State<PlanlayiciGrup> createState() => _PlanlayiciGrupState();
}

class _PlanlayiciGrupState extends State<PlanlayiciGrup> {
  int _currentIndex = 0;

  // Sayfaların listesi
  final List<Widget> _pages = [
    const DersPage(),
    const KursPage(),
    const DersProgramiPage(),
  ];

  // Sayfa indexine göre başlık döndüren yardımcı fonksiyon
  String _getAppBarTitle() {
    if (_currentIndex == 0) return "DERSLER";
    if (_currentIndex == 1) return "KURSLAR";
    return "DERS PROGRAMI";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 136, 255),
        elevation: 0,
        centerTitle: true,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 30, 136, 255),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Dersler'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Kurslar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Program',
          ),
        ],
      ),
    );
  }
}
