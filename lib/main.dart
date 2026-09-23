import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // Required for plugins like flutter_secure_storage and local_auth
  // that use platform channels before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: SpendWiseApp()));
}
