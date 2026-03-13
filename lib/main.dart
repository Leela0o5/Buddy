import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Later Tasks:
  // 1. Initialize Hive 
  // 2. Initialize local notifications 

  runApp(
    const ProviderScope(
      child: Buddy(),
    ),
  );
}