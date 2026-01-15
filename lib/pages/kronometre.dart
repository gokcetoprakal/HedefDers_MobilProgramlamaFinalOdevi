import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '/services/database_helper.dart';

class KronometrePage extends StatefulWidget {
  const KronometrePage({super.key});

  @override
  State<KronometrePage> createState() => _KronometrePageState();
}

class _KronometrePageState extends State<KronometrePage>
    with WidgetsBindingObserver {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFromDb();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose(); // ❗ timer iptal edilmez
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveToDb();
    }
  }

  /* ---------------- DATABASE ---------------- */

  Future<void> _loadFromDb() async {
    final sec = await DatabaseHelper.instance.veriyiGetir('kron_sec');
    final run = await DatabaseHelper.instance.veriyiGetir('kron_run');
    final start = await DatabaseHelper.instance.veriyiGetir('kron_start');

    _seconds = sec != null ? int.parse(sec) : 0;
    _isRunning = run == '1';

    if (_isRunning && start != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(int.parse(start));
      _seconds += DateTime.now().difference(startTime).inSeconds;
      _startTimer(fromRestore: true);
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveToDb() async {
    await DatabaseHelper.instance.veriyiKaydet('kron_sec', _seconds.toString());
    await DatabaseHelper.instance.veriyiKaydet(
      'kron_run',
      _isRunning ? '1' : '0',
    );

    if (_isRunning && _startTime != null) {
      await DatabaseHelper.instance.veriyiKaydet(
        'kron_start',
        _startTime!.millisecondsSinceEpoch.toString(),
      );
    }
  }

  /* ---------------- TIMER ---------------- */

  void _startTimer({bool fromRestore = false}) {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      if (_seconds % 10 == 0) _saveToDb();
      if (mounted) setState(() {});
    });

    if (!fromRestore) _startTime = DateTime.now();
  }

  void _toggleTimer() {
    _isRunning = !_isRunning;

    if (_isRunning) {
      _startTime = DateTime.now();
      _startTimer();
    } else {
      _timer?.cancel();
      _timer = null;
    }

    _saveToDb();
    setState(() {});
  }

  void _reset() async {
    _seconds = 0;
    _isRunning = false;
    _timer?.cancel();
    _timer = null;

    await DatabaseHelper.instance.veriyiKaydet('kron_sec', '0');
    await DatabaseHelper.instance.veriyiKaydet('kron_run', '0');

    if (mounted) setState(() {});
  }

  String _format(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveToDb();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF4DBBFF),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "TOPLAM ODAKLANMA",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Text(
                _format(_seconds),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      onPressed: _reset,
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _toggleTimer,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF4DBBFF),
                        child: Icon(
                          _isRunning ? Icons.pause : Icons.play_arrow,
                          size: 36,
                          color: Colors.black,
                        ),
                      ),
                    ),
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
