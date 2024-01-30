import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditPage extends StatefulWidget {
  const CreditPage({Key? key}) : super(key: key);

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sensorify"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                padding: EdgeInsets.only(top: 20, bottom: 20),
                alignment: Alignment.center,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/developer.jpg'),
                      ),
                      shape: BoxShape.circle),
                ),
              ),
              Text('Murabıt Akdoğan', style: TextStyle(fontSize: 20),),
              Divider(
                height: 10,
                thickness: 2,
                indent: MediaQuery.of(context).size.width/4,
                endIndent: MediaQuery.of(context).size.width/4,
              ),
              Text('Android Developer', style: TextStyle(fontSize: 15),),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text.rich(
                  TextSpan(
                    text: 'Bu uygulama ücretsiz kullanım için tasarlanmıştır. Tüm telif hakları geliştiriciye ait olup yayımlanması değiştirilmesi serbesttir. Herhangi bir hata durumunda ',
                    children: <TextSpan>[
                      TextSpan(
                        text: 'link',
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = ()  async {
                            final url = Uri.parse('https://example.com');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                      ),
                      TextSpan(
                        text: 'te verilen repoya pull request oluşturabilirsiniz.',
                      ),
                    ],
                  ),
                )

              )
            ],
          ),
        ),
      ),
    );
  }
}
