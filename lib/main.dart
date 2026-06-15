import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  // definicja asynchronicznosci do funkcji main
  // upewniamy sie ze widgety sa zsynchronizowane przed init z bazy
  WidgetsFlutterBinding.ensureInitialized();

  // czekanie na init hivea
  await Hive.initFlutter();
  // czekanie na otwieranie boxa na dane odnosnie anime
  await Hive.openBox('aniqueue_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniQueue',
      home: const HomeScreen(),
    );
  }
}