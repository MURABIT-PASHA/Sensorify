package com.murabit.akdogan.sensorify;

import io.flutter.embedding.android.FlutterActivity;


import androidx.annotation.NonNull;

import com.murabit.akdogan.sensorify.socket.SocketManager;

import java.util.logging.Logger;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "com.murabit.akdogan/socket";
    private static Logger LOGGER = Logger.getLogger("MURABIT LOG");
    SocketManager socketManager = new SocketManager();
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("sendMessage")) {
                                String message = call.argument("message").toString();
                                String address = call.argument("address");
                                LOGGER.info(message);
                                socketManager.sendMessage(address, message);
                                result.success("Success");
                            } else if (call.method.equals("getAddressInfo")) {
                                result.success(socketManager.getIPConfig());
                            } else if (call.method.equals("startServer")) {
                                socketManager.startServer();
                                result.success("Success");
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

}
