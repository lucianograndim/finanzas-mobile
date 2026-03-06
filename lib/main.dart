import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  runApp(const FinanzasApp());
}
