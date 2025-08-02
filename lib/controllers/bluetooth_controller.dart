// ignore_for_file: deprecated_member_use, unused_element

import 'dart:convert';

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:slurvo_task/utls/snackbar.dart';
import 'dart:math' as math;
class BluetoothController extends GetxController {
  BluetoothAdapterState? adapterState;
  List<ScanResult>? scanResults = [];
  bool? isScanning = false;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  String? lastSentMessage;
  List<BluetoothCharacteristic> writableCharacteristics = [];
  bool _autoReconnectEnabled = true;
  Timer? _reconnectionTimer;
  Timer? _heartbeatTimer;
  int _reconnectionAttempts = 0;
  final int _maxReconnectionAttempts = 5;
  BluetoothCharacteristic? readCharacteristic;
  bool get isConnected => connectedDevice?.isConnected ?? false;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _adapterStateSubscription;

  @override
  void onInit() {
    super.onInit();
    _initBluetooth();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  void _cleanup() {
    _connectionSubscription?.cancel();
    _adapterStateSubscription?.cancel();
  }

  void _initBluetooth() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      adapterState = state;
      update();

      // Handle adapter state changes
      if (state == BluetoothAdapterState.off && connectedDevice != null) {
        _handleConnectionLoss('Bluetooth turned off');
      } else if (state == BluetoothAdapterState.on &&
          connectedDevice == null &&
          _autoReconnectEnabled) {}
    });

    // Scan Results
    FlutterBluePlus.scanResults.listen((results) {
      scanResults = results;
      update();
    });

    // Listen to scanning state
    FlutterBluePlus.isScanning.listen((scanning) {
      isScanning = scanning;
      update();
    });

    // Get initial adapter state
    FlutterBluePlus.adapterState.first.then((state) {
      adapterState = state;
      update();
    });
  }

  Future<void> startScan() async {
    try {
      if (isScanning == true) return;

      final isBluetoothOn = await FlutterBluePlus.isOn;

      if (!isBluetoothOn) {
        CustomSnackBars.instance.showFailureSnackbar(
          title: 'Bluetooth Off',
          message: 'Please turn on Bluetooth to scan for devices',
        );
        return;
      }
      await FlutterBluePlus.stopScan();
      isScanning = true;

      // Finding only the specific device. Wont be able to see other bluetooth devices
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [Guid('0000ffe0-0000-1000-8000-00805f9b34fb')],
      );

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          debugPrint('Device found: ${r.device.name} - ${r.device.id}');
        }
      });

      FlutterBluePlus.isScanning.listen((scanning) {
        isScanning = scanning;
      });
    } catch (e) {
      debugPrint('Error starting scan: $e');
      CustomSnackBars.instance.showFailureSnackbar(
        title: 'Scan Error',
        message: 'Failed to start scanning for devices',
      );
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }
// Funtion for sending data to the specific bluetooth device
  Future<void> sendHexData({
    List<int> data = const [0x54, 0x50, 0x02, 0x00, 0x00, 0xA6],
    String? guid = '0000FEE1-0000-1000-8000-00805F9B34FB',
  }) async {
    try {
      if (connectedDevice == null) {
        CustomSnackBars.instance.showFailureSnackbar(
          title: 'Error',
          message: 'No device connected',
        );
        return;
      }

      List<BluetoothService> services = await connectedDevice!
          .discoverServices();

      // Locate characteristic 0xFEE1
      writeCharacteristic = services
          .expand((service) => service.characteristics)
          .firstWhere(
            (c) => c.uuid == Guid('$guid') && c.properties.write,
            orElse: () => throw Exception('Characteristic 0xFEE1 not found'),
          );

      // Hex data
      await writeCharacteristic?.write(data, withoutResponse: true);

      CustomSnackBars.instance.showSuccessSnackbar(
        title: 'Success',
        message: 'Data sent successfully',
      );
    } catch (e) {
      debugPrint('Error sending data: $e');
      CustomSnackBars.instance.showFailureSnackbar(
        title: 'Error',
        message: 'Failed to send data',
      );
    }
  }
  // Function for reading data from the specific device
  Future<void> readFromCharacteristic() async {
    try {
      if (connectedDevice == null) return;

      List<BluetoothService> services = await connectedDevice!
          .discoverServices();

      readCharacteristic = services
          .expand((service) => service.characteristics)
          .firstWhere(
            (c) =>
                c.uuid == Guid('0000FEE2-0000-1000-8000-00805F9B34FB') &&
                (c.properties.read || c.properties.notify),
            orElse: () =>
                throw Exception('Read characteristic 0xFEE2 not found'),
          );

      await readCharacteristic?.setNotifyValue(true);

      readCharacteristic?.lastValueStream.listen((value) {
        debugPrint('Received data from: $value');
      });
    } catch (e) {
      debugPrint('Read Error: $e');
    }
  }

  void _setupConnectionMonitoring(BluetoothDevice device) {
    _connectionSubscription?.cancel();
    _connectionSubscription = device.connectionState.listen((state) {
      debugPrint('Connection state changed: $state');

      if (state == BluetoothConnectionState.disconnected) {
        _handleConnectionLoss('Device disconnected');
      }
      update();
    });
  }

  void _handleConnectionLoss(String reason) {
    debugPrint('Connection lost: $reason');
    connectedDevice = null;
    writeCharacteristic = null;
    lastSentMessage = null;
    _heartbeatTimer?.cancel();
    update();
    CustomSnackBars.instance.showFailureSnackbar(
      title: 'Connection Lost',
      message: reason,
      duration: 2,
    );
  }

  Future<void> _findWritableCharacteristic(
    List<BluetoothService> services,
  ) async {
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write ||
            characteristic.properties.writeWithoutResponse) {
          writeCharacteristic = characteristic;
          debugPrint('Found writable characteristic: ${characteristic.uuid}');
          return;
        }
      }
    }
    debugPrint('No writable characteristic found');
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      _cleanup();

      await device.disconnect();
      connectedDevice = null;
      writeCharacteristic = null;
      lastSentMessage = null;
      _reconnectionAttempts = 0;

      update();
    } catch (e) {
      debugPrint('Disconnect error: $e');
      throw e;
    }
  }

  Future<void> sendDataToDevice(BluetoothCharacteristic characteristic) async {
    try {
      if (!isConnected) {
        throw Exception('Device not connected');
      }

      List<int> dataToSend = [0x54, 0x50, 0x02, 0x00, 0x00, 0xA6];
      await characteristic.write(dataToSend, withoutResponse: false);

      CustomSnackBars.instance.showSuccessSnackbar(
        title: 'Success',
        message: 'Data sent successfully',
        duration: 1,
      );
    } catch (e) {
      debugPrint('Error sending data: $e');
      CustomSnackBars.instance.showFailureSnackbar(
        title: 'Error',
        message: 'Failed to send data: ${e.toString()}',
      );
      if (e.toString().contains('disconnected') ||
          e.toString().contains('not connected')) {
        _handleConnectionLoss('Send data failed - connection lost');
      }
    }
  }
  Future<String?> readDataFromSpecificCharacteristic() async {
    if (connectedDevice == null) {
      throw Exception('No device connected');
    }

    final readCharacteristicUUID = Guid('0000FEE2-0000-1000-8000-00805F9B34FB');

    try {
      List<BluetoothService> services = await connectedDevice!
          .discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid == readCharacteristicUUID &&
              characteristic.properties.read) {
            List<int> value = await characteristic.read();
            return utf8.decode(value);
          }
        }
      }

      throw Exception('Read characteristic 0xFEE2 not found');
    } catch (e) {
      debugPrint('Read data error: $e');
      rethrow;
    }
  }

  Future<String?> readData() async {
    if (connectedDevice == null) {
      throw Exception('No device connected');
    }
    try {
      List<BluetoothService> services = await connectedDevice!
          .discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.read) {
            List<int> value = await characteristic.read();
            return utf8.decode(value);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Read data error: $e');
      throw e;
    }
  }
  void enableAutoReconnect() {
    _autoReconnectEnabled = true;
    _reconnectionAttempts = 0;
  }

  void disableAutoReconnect() {
    _autoReconnectEnabled = false;
    _reconnectionTimer?.cancel();
  }

  bool get isAutoReconnectEnabled => _autoReconnectEnabled;
  Future<void> manualReconnect() async {
    if (connectedDevice == null) {
      _reconnectionAttempts = 0;
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await stopScan();

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
        barrierDismissible: false,
      );

      if (device.isConnected) {
        await device.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }
      await device.connect(timeout: const Duration(seconds: 20));
      // waiting for stable connection
      await Future.delayed(Duration(milliseconds: 1000));

      await device.requestConnectionPriority(
        connectionPriorityRequest: ConnectionPriority.high,
      );
      // waiting for change in priority to change
      await Future.delayed(Duration(milliseconds: 500));

      await _discoverAndSetupCharacteristics(device);

      connectedDevice = device;
      _reconnectionAttempts = 0;

      Get.back();

      // Set up connection monitoring
      _setupConnectionMonitoring(device);

      update();

      // Test data sending after successful connection
      await _testInitialDataSend();

      CustomSnackBars.instance.showSuccessSnackbar(
        title: 'Connected & Ready',
        message:
            'Device connected with ${writeCharacteristic.toString()} writable characteristics found',
      );
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      debugPrint('Connection error: $e');

      if (e.toString().contains('REMOTE_USER_TERMINATED_CONNECTION')) {
        debugPrint('Device terminated connection - attempting recovery');
        await _handleConnectionTermination(device);
      }

      throw e;
    }
  }
  Future<void> _discoverAndSetupCharacteristics(BluetoothDevice device) async {
    try {
      // Discover services with retry mechanism
      List<BluetoothService> services = await _discoverServicesWithRetry(
        device,
      );
      writableCharacteristics.clear();
      writeCharacteristic = null;
      for (int i = 0; i < services.length; i++) {
        log('Service $i: ${services[i].toString()}');
      }
      await _findAllCharacteristics(services);
      if (writableCharacteristics.isEmpty) {
        throw Exception('No writable characteristics found on device');
      }
      _setPrimaryWriteCharacteristic();

      log('Found ${writableCharacteristics.length} writable characteristics');
      log('Primary write characteristic: ${writeCharacteristic?.uuid}');
    } catch (e) {
      debugPrint('Error discovering characteristics: $e');
      throw e;
    }
  }

  Future<List<BluetoothService>> _discoverServicesWithRetry(
    BluetoothDevice device,
  ) async {
    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        List<BluetoothService> services = await device.discoverServices();

        if (services.isEmpty) {
          throw Exception('No services discovered');
        }

        return services;
      } catch (e) {
        retryCount++;
        debugPrint('Service discovery attempt $retryCount failed: $e');

        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 1));
        } else {
          throw Exception(
            'Service discovery failed after $maxRetries attempts: $e',
          );
        }
      }
    }

    throw Exception('Service discovery failed');
  }

  Future<void> _findAllCharacteristics(List<BluetoothService> services) async {
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        // Check if characteristic is writable
        if (characteristic.properties.write ||
            characteristic.properties.writeWithoutResponse) {
          writableCharacteristics.add(characteristic);
          log(
            'Found writable characteristic: ${characteristic.uuid} in service: ${service.uuid}',
          );

          // Set as primary write if it's FFE1 
          if (characteristic.uuid.toString().toUpperCase().contains("FFE1")) {
            writeCharacteristic = characteristic;
            log('Set FFE1 as primary write characteristic');
          }
        }

        // Check if characteristic is readable or has notify/indicate
        if (characteristic.properties.read ||
            characteristic.properties.notify ||
            characteristic.properties.indicate) {
          // Set as read characteristic if it's FFE2 or first readable found
          if (characteristic.uuid.toString().toUpperCase().contains("FFE2")) {
            readCharacteristic = characteristic;
            log('Set read characteristic: ${characteristic.uuid}');

            if (characteristic.properties.notify ||
                characteristic.properties.indicate) {
              try {
                await Future.delayed(Duration(milliseconds: 200));
                await characteristic.setNotifyValue(true);

                // Listen for incoming data
                characteristic.onValueReceived.listen((data) {
                  _handleReceivedData(data);
                });

                log('Enabled notifications for ${characteristic.uuid}');
              } catch (e) {
                debugPrint('Failed to enable notifications: $e');
              }
            }
          }
        }
      }
    }
  }

  void _setPrimaryWriteCharacteristic() {
    if (writeCharacteristic == null && writableCharacteristics.isNotEmpty) {
      // If no FFE1 found, use the first writable characteristic
      writeCharacteristic = writableCharacteristics.first;
      log(
        'Set first writable characteristic as primary: ${writeCharacteristic?.uuid}',
      );
    }
  }

  void _handleReceivedData(List<int> data) {
    try {
      String text = utf8.decode(data);
      log('Received text: $text');
    } catch (e) {
      String hex = data
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      log('Received hex: $hex');
    }
    update();
  }

  // Test sending initial data after connection
  Future<void> _testInitialDataSend() async {
    if (writeCharacteristic != null) {
      try {
        await Future.delayed(Duration(milliseconds: 500));
        await sendHexData();
        log('Initial test data sent successfully');
      } catch (e) {
        debugPrint('Initial test data send failed: $e');
      }
    }
  }

  // Main method to send data to the device
  Future<bool> sendData(String data) async {
    if (!isConnected) {
      CustomSnackBars.instance.showFailureSnackbar(
        title: 'Error',
        message: 'Device not connected',
      );
      return false;
    }

    if (writeCharacteristic == null) {
      CustomSnackBars.instance.showFailureSnackbar(
        title: 'Error',
        message: 'No writable characteristic found',
      );
      return false;
    }

    try {
      List<int> bytes = utf8.encode(data);
      bool success = false;

      // Handle large data by chunking
      if (bytes.length > 20) {
        success = await _sendDataInChunks(bytes);
      } else {
        success = await _sendSinglePacket(bytes);
      }

      // Show success message if data was sent successfully
      if (success) {
        CustomSnackBars.instance.showSuccessSnackbar(
          title: 'Data Sent',
          message: 'Successfully sent: "$data"',
          duration: 2,
        );
      }

      return success;
    } catch (e) {
      debugPrint('Send data error: $e');
      CustomSnackBars.instance.showFailureSnackbar(
        title: 'Send Error',
        message: 'Failed to send data: ${e.toString()}',
        duration: 3,
      );

      // Handle connection termination
      if (e.toString().contains('REMOTE_USER_TERMINATED_CONNECTION')) {
        _handleConnectionTermination(connectedDevice!);
      }

      return false;
    }
  }

  Future<bool> _sendSinglePacket(List<int> bytes) async {
    try {
      await writeCharacteristic!.write(bytes, withoutResponse: false);
      log('Sent data: ${utf8.decode(bytes)}');
      return true;
    } catch (e) {
      // Try without response if regular write fails
      try {
        await writeCharacteristic!.write(bytes, withoutResponse: true);
        log('Sent data (without response): ${utf8.decode(bytes)}');
        return true;
      } catch (e2) {
        throw e2;
      }
    }
  }

  Future<bool> _sendDataInChunks(List<int> bytes) async {
    const int chunkSize = 20;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      int end = math.min(i + chunkSize, bytes.length);
      List<int> chunk = bytes.sublist(i, end);

      await writeCharacteristic!.write(chunk, withoutResponse: true);

      // Small delay between chunks
      if (end < bytes.length) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    }

    log('Sent chunked data: ${utf8.decode(bytes)}');
    return true;
  }

  List<int> _hexStringToBytes(String hex) {
    hex = hex.replaceAll(' ', '').replaceAll('0x', '');
    List<int> bytes = [];

    for (int i = 0; i < hex.length; i += 2) {
      String hexByte = hex.substring(i, math.min(i + 2, hex.length));
      bytes.add(int.parse(hexByte, radix: 16));
    }

    return bytes;
  }

  // Connection monitoring and reconnection logic

  void _handleDisconnection(BluetoothDevice device) {
    connectedDevice = null;
    writeCharacteristic = null;
    readCharacteristic = null;
    writableCharacteristics.clear();

    if (_reconnectionAttempts < _maxReconnectionAttempts) {
      _attemptReconnection(device);
    } else {
      _showConnectionLostSnackbar();
    }

    update();
  }

  Future _attemptReconnection(BluetoothDevice device) async {
    _reconnectionAttempts++;

    try {
      debugPrint(
        'Reconnection attempt $_reconnectionAttempts/$_maxReconnectionAttempts',
      );

      int delaySeconds = math.min(2 * _reconnectionAttempts, 10);
      await Future.delayed(Duration(seconds: delaySeconds));

      await device.connect(timeout: Duration(seconds: 15), autoConnect: true);
      await Future.delayed(Duration(milliseconds: 1000));

      await device.requestConnectionPriority(
        connectionPriorityRequest: ConnectionPriority.high,
      );

      await _discoverAndSetupCharacteristics(device);
      connectedDevice = device;

      CustomSnackBars.instance.showSuccessSnackbar(
        title: 'Reconnected',
        message: 'Successfully reconnected and ready to send data',
      );
    } catch (e) {
      debugPrint('Reconnection failed: $e');
      if (_reconnectionAttempts < _maxReconnectionAttempts) {
        Future.delayed(
          Duration(seconds: 2),
          () => _attemptReconnection(device),
        );
      } else {
        _showConnectionLostSnackbar();
      }
    }
  }

  Future<void> _handleConnectionTermination(BluetoothDevice device) async {
    await Future.delayed(Duration(seconds: 1));
    await device.clearGattCache();
    _attemptReconnection(device);
  }

  void _handleConnectionError(BluetoothDevice device, dynamic error) {
    if (error.toString().contains('REMOTE_USER_TERMINATED_CONNECTION')) {
      _handleConnectionTermination(device);
    } else {
      _handleDisconnection(device);
    }
  }

  void _showConnectionLostSnackbar() {
    CustomSnackBars.instance.showFailureSnackbar(
      title: 'Connection Lost',
      message: 'Unable to reconnect. Please try connecting again.',
      duration: 5,
    );
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _connectionSubscription?.cancel();

    if (connectedDevice != null) {
      connectedDevice!.disconnect();
      connectedDevice = null;
    }

    writeCharacteristic = null;
    readCharacteristic = null;
    writableCharacteristics.clear();

    update();
  }
}
