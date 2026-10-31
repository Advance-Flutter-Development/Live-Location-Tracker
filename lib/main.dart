import "package:flutter/material.dart";
import "package:live_location_tracker/features/location/presentation/pages/location_page.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const LocationPage());
  }
}
