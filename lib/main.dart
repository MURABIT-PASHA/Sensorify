import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/backend/bluetooth_manager.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/pages/bluetooth_status_page.dart';
import 'package:sensorify/provider/device_status_provider.dart';
import 'package:sensorify/provider/order_status_provider.dart';
import 'package:sensorify/theme.dart';
import 'package:sensorify/widgets/scan_dialog.dart';
import 'pages/device_page.dart';

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
        ChangeNotifierProvider(create: (context) => DeviceStatusProvider()),
        ChangeNotifierProvider(create: (context) => OrderStatusProvider()),
      ],
      child: GetMaterialApp(
          title: 'Sensorify',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: ThemeMode.dark,
          home: const HomePage()),
    );
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
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((value) {
      startCheck();
    });
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothStatus =
        Provider.of<DeviceStatusProvider>(context, listen: true);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: primaryBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Obx(() {
        bluetoothStatus.checkRegistration();
        return Scaffold(
          appBar: !bluetoothStatus.isDeviceConnected
              ? AppBar(
                  centerTitle: true,
                  title: const Text("Sensorify"),
                  actions: isBluetoothAvailable.value
                      ? [
                          IconButton(
                            onPressed: () async {
                              if (bluetoothStatus.isDeviceRegistered) {
                                bluetoothManager
                                    .connectToBluetoothDevice(
                                        bluetoothStatus.deviceAddress)
                                    .then((value) => bluetoothStatus
                                        .updateConnectionStatus(true));
                              } else {
                                Get.defaultDialog(
                                  title: "Cihazları keşfet",
                                  content: ScanDialog(
                                    width:
                                        MediaQuery.of(context).size.width - 100,
                                    height: MediaQuery.of(context).size.height *
                                        2 /
                                        3,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.watch,
                                color: bluetoothStatus.isDeviceConnected
                                    ? Colors.green
                                    : Colors.red),
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
              : const BluetoothStatusPage(),
        );
      }),
    );
  }
}
