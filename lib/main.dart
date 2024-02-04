import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/helpers/pathfinder.dart';
import 'package:sensorify/provider/socket_status_provider.dart';
import 'package:sensorify/provider/order_status_provider.dart';
import 'package:sensorify/ui/theme/theme.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const Sensorify());
}

class Sensorify extends StatelessWidget {
  const Sensorify({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SocketStatusProvider()),
        ChangeNotifierProvider(create: (context) => OrderStatusProvider()),
      ],
      child: GetMaterialApp(
        title: 'Sensorify',
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.dark,
        locale: const Locale('en'),
        home: const Pathfinder(),
      ),
    );
  }
}
