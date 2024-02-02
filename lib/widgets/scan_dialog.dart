import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/provider/device_status_provider.dart';

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
    final SocketStatusProvider socketStatus = Provider.of<SocketStatusProvider>(context);
    final double contextHeight = widget.height;
    final double contextWidth = widget.width;

    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          height: contextHeight / 2,
          width: contextWidth,
          child: Container()
        ),
      ),
    );
  }
}
