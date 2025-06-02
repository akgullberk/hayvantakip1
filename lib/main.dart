import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModel importları
import 'viewmodels/pet_viewmodel.dart';
import 'viewmodels/meal_tracking_viewmodel.dart';
import 'viewmodels/health_tracking_viewmodel.dart';
import 'viewmodels/pet_photo_viewmodel.dart';

// Ana ekran importu
import 'views/home/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final vm = PetViewModel();
            vm.init();
            return vm;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final vm = MealTrackingViewModel();
            vm.initDatabase();
            return vm;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => HealthTrackingViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => PetPhotoViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evcil Hayvan Takip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
