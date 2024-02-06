import 'package:flutter/material.dart';

class SocketStatusPage extends StatelessWidget {
  const SocketStatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Icon(
          Icons.private_connectivity_outlined,
          color: Colors.grey,
          size: 100.0,
        ),
        Text("Soket bağlantısını başlatmanız gerekmekte.")
      ],
    ));
  }
}
