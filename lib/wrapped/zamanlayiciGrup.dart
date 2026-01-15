import 'package:flutter/material.dart';
import '/pages/pomodoro.dart';
import '/pages/kronometre.dart';

class ZamanlayiciGrup extends StatefulWidget {
  const ZamanlayiciGrup({super.key});

  @override
  State<ZamanlayiciGrup> createState() => _ZamanlayiciGrupState();
}

class _ZamanlayiciGrupState extends State<ZamanlayiciGrup> {
  int _currentIndex = 0;

  // Sayfa listesi
  final List<Widget> _pages = [const PomodoroPage(), const KronometrePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 136, 255),
        elevation: 0,
        centerTitle: true,
        title: Text(
          _currentIndex == 0 ? "POMODORO" : "KRONOMETRE",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // Geri tuşu: Hangi sayfada olursan ol tek bir geri tuşu ana sayfaya döner
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
            _currentIndex =
                index; // Sayfa değişince AppBar başlığı da otomatik değişir
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Pomodoro'),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Kronometre',
          ),
        ],
      ),
    );
  }
}
