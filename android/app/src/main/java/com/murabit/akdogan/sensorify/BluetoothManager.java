package com.murabit.akdogan.sensorify;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.logging.Logger;

public class BluetoothManager {
    Logger LOGGER = Logger.getLogger("CüneydTest");
    private static final String appName = "MEDAS";
    private static final UUID UUID_INSECURE = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    public static BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    private Context mContext;
    private AcceptThread mInsecureAcceptThread;
    private ConnectThread mConnectThread;
    private BluetoothDevice mmDevice;
    private UUID deviceUUID;
    private ConnectedThread mConnectedThread;
    private BluetoothDevice mBTDevice;

    BluetoothManager(Context context) {
        this.mContext = context;
        start();
    }
    // Bu fonksiyon cihazları taramaya yarar. Çevrede bulunan cihazların bir listesini geri döndürür.
    public void scanDevices(final OnDeviceScanListener listener) {
        List<Map<String, String>> deviceMapList = new ArrayList<>();
        try {
            BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
            if (adapter == null) {
                listener.onScanComplete(deviceMapList);
                return;
            }

            if (adapter.isDiscovering()) {
                adapter.cancelDiscovery();
            }

            Set<String> scannedAddresses = new HashSet<>();
            IntentFilter filter = new IntentFilter();
            filter.addAction(BluetoothDevice.ACTION_FOUND);
            filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED);
            filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);

            BroadcastReceiver receiver = new BroadcastReceiver() {
                public void onReceive(Context context, Intent intent) {
                    String action = intent.getAction();
                    if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                        BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                        String name = device.getName() != null ? device.getName() : "Unknown";
                        String address = device.getAddress();
                        if (!scannedAddresses.contains(address)) {
                            scannedAddresses.add(address);
                            Map<String, String> deviceMap = new HashMap<>();
                            deviceMap.put("name", name);
                            deviceMap.put("address", address);
                            deviceMapList.add(deviceMap);
                            Logger LOGGER = Logger.getLogger("CüneydTest");
                            LOGGER.info(deviceMapList.toString());
                        }
                    } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
                        context.unregisterReceiver(this);
                        listener.onScanComplete(deviceMapList);
                    }
                }
            };

            mContext.registerReceiver(receiver, filter);

            if (!adapter.isDiscovering()) {
                adapter.startDiscovery();
            }

            new Handler().postDelayed(() -> {
                Logger LOGGER = Logger.getLogger("CüneydTest");
                LOGGER.info("Tarama durduruldu");
                adapter.cancelDiscovery();
            }, 4000);
        } catch (SecurityException e) {
            listener.onScanComplete(deviceMapList);
        }
    }

    public interface OnDeviceScanListener {
        void onScanComplete(List<Map<String, String>> deviceMapList);
    }

    // Bu fonksiyon kendisine gelen MAC adresine göre cihazın pair(eşleşme) durumunu geri döndürür
    public boolean isDevicePaired(final String deviceAddress) {
        try {
            boolean paired = false;
            BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
            Set<BluetoothDevice> mPairedDevices = adapter.getBondedDevices();
            if (mPairedDevices.size() > 0) {
                for (BluetoothDevice mDevice : mPairedDevices) {
                    if (mDevice.getAddress().equalsIgnoreCase(deviceAddress)) {
                        Logger LOGGER = Logger.getLogger("CüneydTest");
                        LOGGER.info("Kayıtlı " + deviceAddress);
                        paired = true;
                        break;
                    }
                }
            }
            LOGGER.info(String.valueOf(paired));
            return paired;
        } catch (SecurityException e) {
            return false;
        }
    }

    // Bu fonksiyon cihazın sistem bluetooth ayarlarını açar
    public boolean openBluetoothSettings() {
        Intent intent = new Intent();
        intent.setAction(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS);
        mContext.startActivity(intent);
        return true;
    }

    // Bu fonksiyon okuma fonksiyonumuz için gerekli. Bu fonksiyon tüm olayı başlatır.
    public boolean startConnection(String address){
        LOGGER.info("Cihaz adresi bu: " + address);
        LOGGER.info("Bağlantı başlatılıyor.");
        try {
            Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();
            for (BluetoothDevice device : pairedDevices) {
                LOGGER.info(device.getAddress());
                if (device.getAddress().equals(address)) {
                    mBTDevice = device;
                    LOGGER.info("Aygıt bulundu");
                    break;
                }
            }
        }catch (SecurityException e){
            LOGGER.info("Cihaz bağlı değil");
        }
        if(mBTDevice!=null){
            startClient(mBTDevice, UUID_INSECURE);
            return true;
        }else{
            LOGGER.info("Aygıt bulunamadı");
            return false;
        }
    }

    private class AcceptThread extends Thread {
        private final BluetoothServerSocket mmServerSocket;

        public AcceptThread() {
            BluetoothServerSocket tmp = null;
            try {
                tmp = mBluetoothAdapter.listenUsingInsecureRfcommWithServiceRecord(appName, UUID_INSECURE);
            } catch (IOException e) {
                LOGGER.info("AcceptThread: IOException: " + e.getMessage());

            } catch (SecurityException e) {
                LOGGER.info("AcceptThread: SecurityException: " + e.getMessage());

            }

            mmServerSocket = tmp;
        }

        public void run() {
            LOGGER.info("Accept Thread çalışıyor");
            BluetoothSocket socket = null;
            try {
                LOGGER.info("RFCOMM server socket başladı.....");
                socket = mmServerSocket.accept();
                LOGGER.info("RFCOMM server socket kabul etti.....");
            } catch (IOException e) {
                LOGGER.info("AcceptThread: IOException: " + e.getMessage());
            }
            if (socket != null) {
                connected(socket, mmDevice);
            }
            LOGGER.info("Accept Thread sona erdi");
        }

        public void cancel() {
            LOGGER.info("Accept Thread iptal edildi");
            try {
                mmServerSocket.close();
            } catch (IOException e) {
                LOGGER.info("Soket kapatılırken şu hatayı aldı: " + e.getMessage());
            }
        }
    }

    private class ConnectThread extends Thread {
        private BluetoothSocket mmSocket;

        public ConnectThread(BluetoothDevice device, UUID uuid) {
            LOGGER.info("ConnectThread başladı");
            mmDevice = device;
            deviceUUID = uuid;
        }

        public void run() {
            BluetoothSocket tmp = null;
            try {
                tmp = mmDevice.createRfcommSocketToServiceRecord(deviceUUID);
                LOGGER.info("Soket açıldı");
            } catch (IOException e) {
                LOGGER.info("AcceptThread: IOException: " + e.getMessage());
            } catch (SecurityException e) {
                LOGGER.info("AcceptThread: SecurityException: " + e.getMessage());
            }
            mmSocket = tmp;
            try {
                mBluetoothAdapter.cancelDiscovery();
                mmSocket.connect();
            } catch (IOException e) {
                LOGGER.info("AcceptThread: IOException: " + e.getMessage());
                try {
                    mmSocket.close();
                } catch (IOException e1) {
                    LOGGER.info("AcceptThread: IOException: " + e1.getMessage());
                }
            } catch (SecurityException e) {
                LOGGER.info("AcceptThread: SecurityException: " + e.getMessage());
            }
            connected(mmSocket, mmDevice);
        }

        public void cancel() {
            try {
                LOGGER.info("Client soket kapatılıyor");
                mmSocket.close();
            } catch (IOException e) {
                LOGGER.info("Kapatma işlemi hatası var: " + e.getMessage());
            }
        }
    }


    public synchronized void start(){
        LOGGER.info("Başla");
        if (mConnectThread != null){
            mConnectThread.cancel();
            mConnectThread = null;
        }
        if(mInsecureAcceptThread == null){
            mInsecureAcceptThread = new AcceptThread();
            mInsecureAcceptThread.start();
        }

    }
    public void startClient(BluetoothDevice device, UUID uuid){
        LOGGER.info("startClient fonksiyonu başladı");
        mConnectThread = new ConnectThread(device, uuid);
        mConnectThread.start();
    }
    private class ConnectedThread extends Thread{
        private final BluetoothSocket mmSocket;
        private final InputStream mmInStream;
        private final OutputStream mmOutStream;
        public ConnectedThread(BluetoothSocket socket){
            LOGGER.info("Connected Thread başladı");
            mmSocket = socket;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            try {
                tmpIn = mmSocket.getInputStream();
                tmpOut = mmSocket.getOutputStream();
            }catch (IOException e){

                LOGGER.info("Bir hata var ve ne olduğunu bilmiyorum sen bir bak: " + e.getMessage());
            }
            mmInStream = tmpIn;
            mmOutStream = tmpOut;
        }
        public void run(){
            byte[] buffer = new byte[1024];
            int bytes;
            while (true){
                try {
                    bytes = mmInStream.read(buffer);
                    String incomingMessage = new String(buffer, 0, bytes);
                    MainActivity.sendDataToFlutter(incomingMessage);
                    LOGGER.info("InputStream: " + incomingMessage);
                }catch (IOException e){
                    LOGGER.info("Okuma hatası: " + e.getMessage());
                    break;
                }
            }
        }
        public void write(byte[] bytes){
            String text = new String(bytes, Charset.defaultCharset());
            LOGGER.info("Yazılıyor: " + text);
            try {
                LOGGER.info(Arrays.toString(bytes));
                mmOutStream.write(bytes);
                mmOutStream.flush();
            } catch (IOException e) {
                LOGGER.info("Mesaj yazılırken hata aldı: " + e.getMessage());
            }
        }
        public void cancel(){
            try{
                mmSocket.close();
            }catch (IOException e){
                LOGGER.info("Kapatma işlemi hatası var: " + e.getMessage());
            }
        }
    }

    private void connected(BluetoothSocket mmSocket, BluetoothDevice mmDevice) {
        LOGGER.info("Connected fonksiyonu çalıştı");
        mConnectedThread = new ConnectedThread(mmSocket);
        synchronized (mContext) {
            mContext.notify();
        }
        mConnectedThread.start();
    }
    public void write(byte[] out){
        String text = new String(out, Charset.defaultCharset());
        LOGGER.info(text);

        if (mConnectedThread != null) {
            mConnectedThread.write(out);
        } else {
            LOGGER.info("ConnectedThread null olduğu için write çağrılamadı.");
        }
    }
    public boolean writeAsync(byte[] out) {
        LOGGER.info("Asenkron yazma işlemi başlatıldı");
        new Thread(new Runnable() {
            @Override
            public void run() {
                if (mConnectedThread != null) {
                    LOGGER.info("Yazma işlemi");
                    mConnectedThread.write(out);
                } else {
                    // mConnectedThread hazır olana kadar bekle
                    synchronized (mContext) {
                        try {
                            LOGGER.info("Bekliyor");
                            mContext.wait();
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }

                    // mConnectedThread hazır olduktan sonra yazma işlemini gerçekleştir
                    if (mConnectedThread != null) {
                        mConnectedThread.write(out);
                    }
                }
            }
        }).start();
        return true;
    }

}