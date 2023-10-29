package com.murabit.akdogan.sensorify;
import androidx.annotation.NonNull;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.logging.Logger;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String BLUETOOTH_CHANNEL = "com.sensorify/bluetooth";
    private static final String EVENT_CHANNEL = "com.sensorify/sensor";

    BluetoothManager bluetoothManager = new BluetoothManager(this);
    private static EventChannel.EventSink eventSink;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink = new MainThreadEventSink(events);
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink = null;
                    }
                });
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BLUETOOTH_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "scanDevices":
                                    bluetoothManager.scanDevices(result::success);
                                    break;
                                case "checkPairStatus": {
                                    String address = call.argument("address");
                                    result.success(bluetoothManager.isDevicePaired(address));
                                    break;
                                }
                                case "write":
                                    HashMap message = call.argument("message");
                                    result.success(bluetoothManager.writeAsync(message.toString().getBytes(StandardCharsets.UTF_8)));
                                    break;
                                case "startRead":{
                                    String address = call.argument("address");
                                    result.success(bluetoothManager.startConnection(address));
                                    break;
                                }
                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }

    public static void sendDataToFlutter(String data) {
        if (eventSink != null) {
            eventSink.success(data);
        }
        if (eventSink == null) {
            Logger logger = Logger.getLogger("TEST HATA");
            logger.info("eventSink null");
        }
    }

}
