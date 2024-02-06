import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/models/connection_settings_model.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/ui/pages/phone/device_page.dart';
import 'package:sensorify/provider/socket_status_provider.dart';
import 'package:sensorify/types.dart';
import 'package:sensorify/ui/pages/phone/listener_page.dart';
import 'package:sensorify/widgets/scan_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SocketHelper socket = SocketHelper();
  Stream<dynamic> get messageStream => socket.getStream();

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
      child: Builder(builder: (context) {
        SocketHelper.startServer().then((value) {
          messageStream.listen((message) {
            MessageModel model = MessageModel.fromJson(json.decode(message));
            switch (model.orderType) {
              case MessageOrderType.start:
                return;
              case MessageOrderType.stop:
                return;
              case MessageOrderType.record:
                return;
              case MessageOrderType.watch:
                return;
              case MessageOrderType.connect:
                String hostAddress =
                    model.connectionSettings?.hostAddress ?? "NULL";
                if (hostAddress != "NULL") {
                  socketStatus.registerSocketAddress(hostAddress);
                  socketStatus.updateConnectionStatus(true);
                  Get.offAll(const ListenerPage());
                }
            }
          });
        });
        if (socketStatus.isSocketConnected) {
          return DevicePage();
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  SocketHelper.getHostAddress().then((host) {
                    showDialog(
                        context: context,
                        builder: (builder) {
                          double width = MediaQuery.of(context).size.width;
                          return AlertDialog(
                            backgroundColor: secondaryForegroundColor,
                            titlePadding: const EdgeInsets.only(top: 10),
                            insetPadding: const EdgeInsets.all(15),
                            contentPadding: const EdgeInsets.only(bottom: 10),
                            title: SizedBox(
                              width: width - 20,
                              height: 20,
                              child: const Text(
                                "Telefonu bağla",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: primaryBackgroundColor),
                                maxLines: 1,
                              ),
                            ),
                            content: Container(
                              width: width - 20,
                              height: width - 20,
                              alignment: Alignment.center,
                              child: host.isNotEmpty
                                  ? QrImageView(
                                      data: host,
                                      version: QrVersions.auto,
                                    )
                                  : const CircularProgressIndicator(),
                            ),
                          );
                        });
                  });
                }),
            centerTitle: true,
            title: const Text("Sensorify"),
            actions: [
              IconButton(
                onPressed: () async {
                  await socketStatus.registerSocketAddress('NULL');
                  socketStatus.updateConnectionStatus(false);
                },
                icon: const Icon(
                  Icons.watch_off,
                  color: Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (socketStatus.isSocketRegistered) {
                    if (socketStatus.isSocketConnected) {
                      socketStatus.updateConnectionStatus(false);
                    } else {
                      socketStatus.updateConnectionStatus(true);
                      String hostAddress = await SocketHelper.getHostAddress();
                      SocketHelper.sendMessage(
                          MessageModel(
                            orderType: MessageOrderType.connect,
                            connectionSettings: ConnectionSettings(
                                hostAddress: hostAddress,
                                clientAddress: socketStatus.socketAddress,
                                portNumber: 7800),
                          ),
                          socketStatus.socketAddress);
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
          body: const Center(
            child: Text("Hiçbir cihaz bağlı değil"),
          ),
        );
      }),
    );
  }
}
