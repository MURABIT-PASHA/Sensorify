import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/pages/bluetooth_status_page.dart';
import 'package:sensorify/theme.dart';
import 'package:sensorify/widgets/scan_dialog.dart';

import 'provider/bluetooth_status_provider.dart';
import 'pages/device_page.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  [
    Permission.location,
    Permission.storage,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan
  ].request().then((status) {
    runApp(
      //TODO: Multiple provider eklemeyi unutma order status içinde eklemen gerekiyor
      ChangeNotifierProvider(
        create: (context) => BluetoothStatusProvider(),
        child: const Sensorify(),
      ),
    );
  });
}

class Sensorify extends StatelessWidget {
  const Sensorify({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Sensorify',
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.dark,
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothManager bluetoothManager = BluetoothManager();
  Rx<bool> isBluetoothAvailable = false.obs;
  Rx<bool> isDeviceConnected = false.obs;

  void checkBluetoothStatus() {
    isBluetoothAvailable.value = bluetoothManager.checkBluetoothStatus();
  }

  void startCheck() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      checkBluetoothStatus();
    });
  }

  @override
  void initState() {
    startCheck();
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothStatus =
        Provider.of<BluetoothStatusProvider>(context, listen: true);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: primaryBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Obx(
        () => Scaffold(
            appBar: !bluetoothStatus.isDeviceConnected
                ? AppBar(
                    centerTitle: true,
                    title: const Text("Sensorify"),
                    actions: isBluetoothAvailable.value
                        ? [
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (builder) => AlertDialog(
                                    title: const Text("Scan Devices"),
                                    content: ScanDialog(
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              3,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.watch, color: Colors.red),
                            )
                          ]
                        : null,
                  )
                : null,
            body: isBluetoothAvailable.value
                ? bluetoothStatus.isDeviceConnected
                    ? const DevicePage()
                    : const Center(
                        child: Text("Hiçbir cihaz bağlı değil"),
                      )
                : const BluetoothStatusPage()),
      ),
    );
  }
}
