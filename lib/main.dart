import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'models/habit.dart';
import 'models/habit_group.dart';
import 'providers/habit_group_provider.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HabitGroupAdapter());
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<HabitGroup>('habit_groups');
  await Hive.openBox<Habit>('habits');

  // Initialize notification service
  await NotificationService().init();
  
  // Reschedule all notifications on app startup
  final habits = Hive.box<Habit>('habits').values.toList();
  final groups = Hive.box<HabitGroup>('habit_groups').values.toList();
  await NotificationService().rescheduleAll(habits: habits, groups: groups);

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

