import 'dart:async';
import 'package:flutter/material.dart';
import '/services/database_helper.dart'; // SQLite Helper yolu

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage>
    with WidgetsBindingObserver {
  final TextEditingController _workController = TextEditingController(
    text: "25:00",
  );
  final TextEditingController _breakController = TextEditingController(
    text: "05:00",
  );

  Timer? _timer;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isWorkTime = true;

  int _totalWorkSeconds = 0;
  int _totalBreakSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _yukleFromSQLite();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _workController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _kaydetToSQLite();
    }
  }

  // 🔹 SQLITE VERİ YÜKLEME
  Future<void> _yukleFromSQLite() async {
    final remaining = await DatabaseHelper.instance.veriyiGetir('p_remaining');
    final running = await DatabaseHelper.instance.veriyiGetir('p_running');
    final isWork = await DatabaseHelper.instance.veriyiGetir('p_isWork');
    final totalWork = await DatabaseHelper.instance.veriyiGetir('p_workTotal');
    final totalBreak = await DatabaseHelper.instance.veriyiGetir(
      'p_breakTotal',
    );
    final lastTime = await DatabaseHelper.instance.veriyiGetir('p_lastTime');
    final workText = await DatabaseHelper.instance.veriyiGetir('p_workText');
    final breakText = await DatabaseHelper.instance.veriyiGetir('p_breakText');

    setState(() {
      if (remaining != null) _remainingSeconds = int.parse(remaining);
      if (running != null) _isRunning = running == '1';
      if (isWork != null) _isWorkTime = isWork == '1';
      if (totalWork != null) _totalWorkSeconds = int.parse(totalWork);
      if (totalBreak != null) _totalBreakSeconds = int.parse(totalBreak);
      if (workText != null) _workController.text = workText;
      if (breakText != null) _breakController.text = breakText;
    });

    if (_isRunning && lastTime != null) {
      final lastMillis = int.parse(lastTime);
      final diff = (DateTime.now().millisecondsSinceEpoch - lastMillis) ~/ 1000;
      if (diff > 0) {
        setState(() {
          _remainingSeconds -= diff;
          _isWorkTime ? _totalWorkSeconds += diff : _totalBreakSeconds += diff;
        });
      }
      _startTimer();
    }
  }

  // 🔹 SQLITE VERİ KAYDETME
  Future<void> _kaydetToSQLite() async {
    await DatabaseHelper.instance.veriyiKaydet(
      'p_remaining',
      _remainingSeconds.toString(),
    );
    await DatabaseHelper.instance.veriyiKaydet(
      'p_running',
      _isRunning ? '1' : '0',
    );
    await DatabaseHelper.instance.veriyiKaydet(
      'p_isWork',
      _isWorkTime ? '1' : '0',
    );
    await DatabaseHelper.instance.veriyiKaydet(
      'p_workTotal',
      _totalWorkSeconds.toString(),
    );
    await DatabaseHelper.instance.veriyiKaydet(
      'p_breakTotal',
      _totalBreakSeconds.toString(),
    );
    await DatabaseHelper.instance.veriyiKaydet(
      'p_lastTime',
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
    await DatabaseHelper.instance.veriyiKaydet(
      'p_workText',
      _workController.text,
    );
    await DatabaseHelper.instance.veriyiKaydet(
      'p_breakText',
      _breakController.text,
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _kaydetToSQLite();
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _isWorkTime ? _totalWorkSeconds++ : _totalBreakSeconds++;
        } else {
          _isWorkTime = !_isWorkTime;
          _resetTimer();
        }
      });
      if (_remainingSeconds % 10 == 0)
        _kaydetToSQLite(); // 10 saniyede bir oto-kayıt
    });
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = _parseTimeToSeconds(
        _isWorkTime ? _workController.text : _breakController.text,
      );
    });
  }

  int _parseTimeToSeconds(String text) {
    try {
      var parts = text.split(':');
      return (int.parse(parts[0]) * 60) + int.parse(parts[1]);
    } catch (_) {
      return 1500; // Hata durumunda varsayılan 25 dk
    }
  }

  String _formatTime(int seconds) {
    if (seconds < 0) seconds = 0;
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String _formatToMinutes(int seconds) {
    if (seconds < 60) return "$seconds sn";
    return "${seconds ~/ 60} dk";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4DBBFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              _isWorkTime ? "DERS ZAMANI" : "MOLA ZAMANI",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 100,
                color: Colors.white,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _input("ders süresi", _workController),
                IconButton(
                  icon: Icon(
                    _isRunning ? Icons.pause_circle : Icons.play_circle,
                    size: 80,
                    color: Colors.white,
                  ),
                  onPressed: () => _isRunning ? _stopTimer() : _startTimer(),
                ),
                _input("mola süresi", _breakController),
              ],
            ),
            const SizedBox(height: 40),
            _istatistik(),
          ],
        ),
      ),
    );
  }

  Widget _istatistik() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text(
            "BUGÜNKÜ VERİMLİLİK",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const Divider(),
          _row("Toplam odak:", _formatToMinutes(_totalWorkSeconds)),
          _row("Toplam mola:", _formatToMinutes(_totalBreakSeconds)),
          _row(
            "Genel süre:",
            _formatToMinutes(_totalWorkSeconds + _totalBreakSeconds),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: const TextStyle(fontSize: 16)),
          Text(
            r,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Container(
          width: 70,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: c,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (_) {
              _stopTimer();
              _resetTimer();
            },
          ),
        ),
      ],
    );
  }
}
