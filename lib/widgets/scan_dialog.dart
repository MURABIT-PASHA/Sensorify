import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/models/connection_settings_model.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/provider/socket_status_provider.dart';
import 'package:sensorify/types.dart';

class ScanDialog extends StatefulWidget {
  final double width;
  final double height;
  const ScanDialog({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<ScanDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String? hostAddress;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Future setHostAddress() async {
    hostAddress = await SocketHelper.getHostAddress();
  }

  @override
  void initState() {
    setHostAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          height: widget.height / 2,
          width: widget.width,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 5,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: (result != null)
                        ? Text(
                            'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          final socketStatus =
          Provider.of<SocketStatusProvider>(context, listen: false);
          if (hostAddress != null) {
            SocketHelper.sendMessage(
              MessageModel(
                orderType: MessageOrderType.connect,
                connectionSettings: ConnectionSettings(
                    hostAddress: hostAddress ?? "NULL",
                    clientAddress: result!.code ?? "NULL",
                    portNumber: 7800),
              ),
              result!.code ?? "NULL",
            ).then((value) {
              socketStatus
                  .registerSocketAddress(result!.code ?? "NULL")
                  .then((value) {
                if (value) {
                  socketStatus.updateConnectionStatus(true);
                  Get.back();
                }
              });
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
