import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/habit.dart';
import 'models/habit_group.dart';
import 'providers/habit_group_provider.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(HabitGroupAdapter());
  Hive.registerAdapter(HabitAdapter());

  await Hive.openBox<HabitGroup>('habit_groups');
  await Hive.openBox<Habit>('habits');

  runApp(PeblApp());
}

class PeblApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitGroupProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pebl',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
