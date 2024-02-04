import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sensorify/constants.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/ui/screens/screen_controller.dart';

class WatchHomeScreen extends StatefulWidget {
  final ScreenController state;
  const WatchHomeScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {

  Future startServer() async{
    await SocketHelper.startServer();
  }

  @override
  void initState() {
    FlutterNativeSplash.remove();
    startServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xFF1C1C1E);
    return Scaffold(
        body: Container(
      child: Center(
        child: IconButton(
          onPressed: () async {
            String host = await SocketHelper.getHost();
            if(mounted) {
              showDialog(
              context: context,
              builder: (builder) {
                double width = MediaQuery.of(context).size.width;
                double height = MediaQuery.of(context).size.height;
                return AlertDialog(
                  backgroundColor: secondaryForegroundColor,
                  titlePadding: EdgeInsets.only(top: 10),
                  insetPadding: EdgeInsets.all(15),
                  contentPadding: EdgeInsets.only(bottom: 10),
                  title: SizedBox(
                    width: width - 20,
                    height: 20,
                    child: Text(
                      "Telefonu bağla",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: backgroundColor),
                      maxLines: 1,
                    ),
                  ),
                  content: Container(
                    alignment: Alignment.center,
                    child: host.isNotEmpty
                          ? QrImageView(
                      // eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: secondaryForegroundColor),
                      //  dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: secondaryForegroundColor),
                        data: host,
                        version: QrVersions.auto,
                      )
                          : CircularProgressIndicator(),
                  ),
                );
              }
            );
            }
          },
          icon: const Icon(Icons.private_connectivity_outlined),
        ),
      ),
    ));
  }
}
