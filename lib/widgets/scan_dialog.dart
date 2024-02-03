import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/provider/socket_status_provider.dart';

class ScanDialog extends StatefulWidget {
  final double width;
  final double height;
  const ScanDialog({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<ScanDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RxString portNumber = "".obs;
    final SocketStatusProvider socketStatus =
        Provider.of<SocketStatusProvider>(context);

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
                TextField(
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    portNumber.value = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'Örn. 8080',
                    labelText: 'Port numarasını giriniz',
                    labelStyle: const TextStyle(fontSize: 16),
                  ),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                ),
                ElevatedButton(
                  onPressed: () async{
                    if (checkValidate(portNumber.value)) {
                      final SocketHelper socket = SocketHelper();
                      // host = await SocketHelper.getHost();
                      socket
                          .connect(
                        url: portNumber.value,
                      )
                          .then((value) {
                        if (value) {
                          socketStatus.registerSocketAddress(portNumber.value);
                        }
                        Get.back();
                      });
                    } else {
                      Get.snackbar(
                          'Hata', 'Lütfen doğru bir port numarası giriniz');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    maximumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool checkValidate(String value) {
    if (value.length != 4) {
      return false;
    }
    try {
      int.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}
