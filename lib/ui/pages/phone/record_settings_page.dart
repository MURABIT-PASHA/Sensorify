import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensorify/helpers/socket_helper.dart';
import 'package:sensorify/models/message_model.dart';
import 'package:sensorify/models/record_settings_model.dart';
import 'package:sensorify/provider/socket_status_provider.dart';
import 'package:sensorify/types.dart';
import 'package:sensorify/ui/pages/phone/record_listener_page.dart';
import 'package:sensorify/widgets/frosted_glass_box.dart';

class RecordSettingsPage extends StatefulWidget {
  const RecordSettingsPage({Key? key}) : super(key: key);

  @override
  State<RecordSettingsPage> createState() => _RecordSettingsPageState();
}

class _RecordSettingsPageState extends State<RecordSettingsPage> {
  Map<SensorType, bool> selectedSensors = {};
  int _durationDelay = 0;
  final Rx<DurationType> _durationType = DurationType.ms.obs;
  final TextEditingController _delayController = TextEditingController();

  final Widget accelerometerIcon = SvgPicture.asset(
      "assets/icons/accelerometer.svg",
      semanticsLabel: 'Accelerometer Logo');
  final Widget gyroscopeIcon = SvgPicture.asset("assets/icons/gyroscope.svg",
      semanticsLabel: 'Gyroscope Logo');
  final Widget magnetometerIcon = SvgPicture.asset(
      "assets/icons/magnetometer.svg",
      semanticsLabel: 'Magnetometer Logo');

  @override
  void initState() {
    for (var type in SensorType.values) {
      selectedSensors[type] = false;
    }
    super.initState();
  }

  RecordSettings? checkParameters() {
    if (_durationDelay != 0) {
      int falseCount = 0;

      selectedSensors.forEach((key, value) {
        if (value == false) {
          falseCount++;
        }
      });
      if (falseCount < 3) {
        final RecordSettings finalSettings = RecordSettings(
            durationDelay: _durationDelay,
            durationType: _durationType.value,
            selectedSensors: selectedSensors);
        return finalSettings;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height - 100;
    double width = MediaQuery.of(context).size.width;
    final socketStatus =
        Provider.of<SocketStatusProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sensorify"),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            height: height / 2,
            child: ListView.builder(
              itemCount: SensorType.values.length,
              itemBuilder: (BuildContext context, int index) {
                return FrostedGlassBox(
                  width: width,
                  height: 50,
                  child: ListTile(
                    leading: Icon(
                      Icons.save,
                      color: selectedSensors[SensorType.values[index]]!
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(
                      SensorType.values[index].name.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 10),
                      height: 50,
                      width: 50,
                      child: SensorType.values[index].name ==
                              SensorType.accelerometer.name
                          ? accelerometerIcon
                          : SensorType.values[index].name ==
                                  SensorType.magnetometer.name
                              ? magnetometerIcon
                              : gyroscopeIcon,
                    ),
                    onTap: () {
                      setState(
                        () {
                          selectedSensors[SensorType.values[index]] =
                              !(selectedSensors[SensorType.values[index]] ??
                                  false);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            height: height / 2,
            child: Column(
              children: [
                FrostedGlassBox(
                  width: width,
                  height: 50,
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: width - 100,
                          height: 45,
                          child: TextField(
                            controller: _delayController,
                            onChanged: (value) {
                              try {
                                _durationDelay = int.parse(value);
                              } catch (exception) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Wrong argument"),
                                  ),
                                );
                                _delayController.clear();
                              }
                            },
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: "Time delay",
                              hintStyle: const TextStyle(
                                  color: Colors.white12,
                                  fontStyle: FontStyle.italic),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Obx(
                            () => DropdownButtonHideUnderline(
                              child: DropdownButton(
                                borderRadius: BorderRadius.circular(12),
                                value: _durationType.value.name,
                                items: const [
                                  DropdownMenuItem(
                                    value: "ms",
                                    child: Text("ms"),
                                  ),
                                  DropdownMenuItem(
                                    value: "s",
                                    child: Text("s"),
                                  )
                                ],
                                onChanged: (value) {
                                  switch (value) {
                                    case "ms":
                                      _durationType.value = DurationType.ms;
                                      break;
                                    case "s":
                                      _durationType.value = DurationType.s;
                                      break;
                                    default:
                                      _durationType.value = DurationType.ms;
                                      break;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final model = checkParameters();
                    if (model != null) {
                      if (await writeAndReadPermission()) {
                        SocketHelper.sendMessage(
                            MessageModel(
                                orderType: MessageOrderType.start,
                                recordSettings: model),
                            socketStatus.socketAddress).then((value) => Get.to(const RecordListenerPage()));
                      }
                    }
                  },
                  child: FrostedGlassBox(
                    width: width / 2,
                    height: 50,
                    child: const Center(
                      child: Text("Start Record"),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<bool> writeAndReadPermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    } else {
      await [Permission.storage].request();
      return false;
    }
  }
}
