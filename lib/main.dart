import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/pages/socket_status_page.dart';
import 'package:sensorify/provider/socket_status_provider.dart';
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

  Future checkPermissions() async {
    await Permission.storage.request();
  }

  @override
  void initState() {
    checkPermissions();
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final socketStatus =
        Provider.of<SocketStatusProvider>(context, listen: true);
    socketStatus.checkRegistration();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: primaryBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Sensorify"),
          actions: [
            IconButton(onPressed: ()async{
              await socketStatus.registerSocketAddress('NULL');
            }, icon: const Icon(Icons.watch_off, color: Colors.grey,)),
            IconButton(
              onPressed: () async {
                if (socketStatus.isSocketRegistered) {
                  if(socketStatus.isSocketConnected) {
                    SocketHelper socketHelper = SocketHelper();
                    socketHelper.closeConnection();
                    socketStatus.updateConnectionStatus(false);
                  }else{
                    SocketHelper socketHelper = SocketHelper();
                    socketHelper.connect(url: socketStatus.socketAddress).then((value){
                      if(value){
                        socketStatus.updateConnectionStatus(true);
                      }else{
                        Get.snackbar('Hata', 'Sokete bağlanılamadı');
                      }
                    });
                  }
                } else {
                  Get.defaultDialog(
                    title: "Socket URL",
                    content: ScanDialog(
                      width: MediaQuery.of(context).size.width - 100,
                      height: MediaQuery.of(context).size.height * 2 / 3,
                    ),
                  );
                }
              },
              icon: Icon(Icons.watch,
                  color: socketStatus.isSocketConnected
                      ? Colors.green
                      : Colors.red),
            )
          ],
        ),
        body: socketStatus.isSocketConnected
            ? socketStatus.isOtherDeviceConnected
                ? const DevicePage()
                : const Center(
                    child: Text("Hiçbir cihaz bağlı değil"),
                  )
            : const SocketStatusPage(),
      ),
    );
  }
}
