import 'package:flutter/material.dart';
import '/wrapped/planlayiciGrup.dart';
import '/wrapped/zamanlayiciGrup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedef Ders: Ders Takip Uygulaması',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 136, 255),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "HEDEF DERS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.track_changes,
              size: 128,
              color: Color.fromARGB(255, 30, 136, 255),
            ),
            const SizedBox(height: 50),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlanlayiciGrup(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_calendar, size: 30),
              label: const Text('PLANLAYICI', style: TextStyle(fontSize: 25)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 80),
                backgroundColor: const Color.fromARGB(255, 30, 136, 255),
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ZamanlayiciGrup(),
                  ),
                );
              },
              icon: const Icon(Icons.timer, size: 30),
              label: const Text('ZAMANLAYICI', style: TextStyle(fontSize: 25)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 80),
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
