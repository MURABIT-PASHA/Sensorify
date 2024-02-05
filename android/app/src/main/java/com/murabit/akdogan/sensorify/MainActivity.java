package com.murabit.akdogan.sensorify;

import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import java.util.logging.Logger;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String EVENT_CHANNEL = "com.murabit.akdogan/event";
    private static final String METHOD_CHANNEL = "com.murabit.akdogan/method";
    private static final Logger LOGGER = Logger.getLogger("MURABIT LOG");
    SocketManager socketManager = new SocketManager();
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

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "sendMessage":
                                    String message = call.argument("message");
                                    String address = call.argument("address");
                                    LOGGER.info(message);
                                    socketManager.sendMessage(address, message);
                                    result.success("Success");
                                    break;
                                case "getAddressInfo":
                                    result.success(socketManager.getIPConfig());
                                    break;
                                case "startServer":
                                    socketManager.startServer();
                                    result.success("Success");
                                    break;
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
