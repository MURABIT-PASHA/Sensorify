import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
        ChangeNotifierProvider(create: (context) => SocketStatusProvider()),
        ChangeNotifierProvider(create: (context) => OrderStatusProvider()),
      ],
      child: GetMaterialApp(
          title: 'Sensorify',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: ThemeMode.dark,
          locale: const Locale('en'),
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
  Rx<bool> isBluetoothAvailable = false.obs;
  Rx<bool> isDeviceConnected = false.obs;

  void startSocketIfConnectedBefore() {}

  @override
  void initState() {
    [
      Permission.storage,
    ].request().then((value) {
      startSocketIfConnectedBefore();
    });
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final socketStatus =
        Provider.of<SocketStatusProvider>(context, listen: true);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: primaryBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Obx(() {
        socketStatus.checkRegistration();
        return Scaffold(
          appBar: !socketStatus.isDeviceConnected
              ? AppBar(
                  centerTitle: true,
                  title: const Text("Sensorify"),
                  actions: [
                      IconButton(
                        onPressed: () async {
                          if (socketStatus.isDeviceRegistered &&
                              socketStatus.deviceAddress != "NULL" &&
                              socketStatus.deviceAddress != "") {
                          } else {
                            Get.defaultDialog(
                              title: "Cihazları keşfet",
                              content: ScanDialog(
                                width: MediaQuery.of(context).size.width - 100,
                                height:
                                    MediaQuery.of(context).size.height * 2 / 3,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.watch,
                            color: socketStatus.isDeviceConnected
                                ? Colors.green
                                : Colors.red),
                      )
                    ])
              : null,
          body: isBluetoothAvailable.value
              ? socketStatus.isDeviceConnected
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
