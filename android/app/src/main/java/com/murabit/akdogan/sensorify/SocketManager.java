package com.murabit.akdogan.sensorify;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Enumeration;
import java.util.logging.Logger;

public class SocketManager {
    private static Logger LOGGER = Logger.getLogger("SENSORIFY");
    Socket mSocket;
    PrintWriter mPrintWriter;

    private static final int PORT = 7800;

    public void sendMessage(String address, String message){
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    mSocket = new Socket(address, 7800);
                    mPrintWriter = new PrintWriter(mSocket.getOutputStream());
                    mPrintWriter.write(message);
                    mPrintWriter.flush();
                    mPrintWriter.close();
                    mSocket.close();
                } catch (IOException e) {
                    LOGGER.info(e.getMessage());
                }
            }
        });
        thread.start();
    }

    public void startServer() {
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                byte[] buffer = new byte[1024];
                int bytes;
                try (ServerSocket serverSocket = new ServerSocket(PORT, 0, InetAddress.getByName(getIPConfig()))) {
                    System.out.println("Server başlatıldı, port: " + PORT);

                    while (true) {
                        try (Socket clientSocket = serverSocket.accept();
                             BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()))) {
                            String incomingMessage = in.readLine();
                            LOGGER.info(incomingMessage);
                            MainActivity.sendDataToFlutter(incomingMessage);
                        } catch (IOException e) {
                            LOGGER.info(e.getMessage());
                        }
                    }
                } catch (IOException e) {
                    LOGGER.info(e.getMessage());
                }
            }
        });
        thread.start();
    }

    public String getIPConfig() {
        try {
            for (Enumeration<NetworkInterface> nis = NetworkInterface.getNetworkInterfaces(); nis.hasMoreElements();) {
                NetworkInterface ni = nis.nextElement();
                for (Enumeration<InetAddress> ias = ni.getInetAddresses(); ias.hasMoreElements();) {
                    InetAddress ia = ias.nextElement();
                    if (!ia.isLoopbackAddress() && ia instanceof java.net.Inet4Address) {
                        return ia.getHostAddress();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
