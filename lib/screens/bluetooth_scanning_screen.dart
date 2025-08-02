// ignore_for_file: deprecated_member_use, unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:slurvo_task/widget/custom_app_bar_widget.dart';
import '../controllers/bluetooth_controller.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BluetoothController>(
      init: BluetoothController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: logoAppBar(true),
          body: SafeArea(child: _buildBody(controller)),
        );
      },
    );
  }

  Widget _buildBody(BluetoothController controller) {
    // Handle null or undefined adapter state safely
    if (controller.adapterState == null ||
        controller.adapterState != BluetoothAdapterState.on) {
      return _buildBluetoothOffState(controller);
    }

    // Check if we have a connected device
    if (controller.connectedDevice != null) {
      return _buildConnectedDeviceUI(controller);
    }

    return _buildScanningUI(controller);
  }

  Widget _buildConnectedDeviceUI(BluetoothController controller) {
    final device = controller.connectedDevice!;
    final TextEditingController messageController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Connected Device Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.8),
                  Colors.green.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.bluetooth_connected,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Connected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  device.localName.isNotEmpty
                      ? device.localName
                      : 'Unknown Device',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  device.remoteId.str,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message Input Field
                  TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter message to send...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (messageController.text.isNotEmpty) {
                          controller.sendHexData();

                          // _sendDataToDevice(controller, messageController.text, BluetoothCharacteristic(remoteId: DeviceIdentifier("str"), serviceUuid: serviceUuid, characteristicUuid: characteristicUuid));
                          messageController.clear();
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // controller.sendData("Hello world");
                        controller.readFromCharacteristic();

                        // _sendDataToDevice(controller, messageController.text, BluetoothCharacteristic(remoteId: DeviceIdentifier("str"), serviceUuid: serviceUuid, characteristicUuid: characteristicUuid));
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Read Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Quick Send Buttons
                  const Text(
                    'Quick Commands',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickCommandButton('ON', controller),
                      _buildQuickCommandButton('OFF', controller),
                      _buildQuickCommandButton('STATUS', controller),
                      _buildQuickCommandButton('RESET', controller),
                    ],
                  ),

                  const Spacer(),

                  
                  if (controller.lastSentMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Last sent: ${controller.lastSentMessage}',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
                    SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCommandButton(
    String command,
    BluetoothController controller,
  ) {
    return ElevatedButton(
      onPressed: () {
        controller.sendData(command);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(command, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildScanningUI(BluetoothController controller) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildStatusCard(controller),
        ),
        const SizedBox(height: 20),
        _buildScanSection(controller),
        const SizedBox(height: 20),
        Expanded(child: _buildDevicesList(controller)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBluetoothOffState(BluetoothController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 80,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            const Text(
              "Bluetooth is OFF",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Please enable Bluetooth to scan for devices",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => controller.startScan(),
              icon: const Icon(Icons.settings_bluetooth),
              label: const Text("Enable Bluetooth"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BluetoothController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bluetooth_connected,
            color: Colors.blueAccent,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bluetooth is ON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getDeviceCountText(controller),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          if (controller.isScanning == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Scanning...',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getDeviceCountText(BluetoothController controller) {
    final deviceCount = controller.scanResults?.length ?? 0;
    if (deviceCount == 0) {
      return 'No devices found';
    } else if (deviceCount == 1) {
      return '1 device found';
    } else {
      return '$deviceCount devices found';
    }
  }

  Widget _buildScanSection(BluetoothController controller) {
    return Column(
      children: [
        if (controller.isScanning == true)
          Column(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: _buildLottieOrFallback(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Scanning for devices...',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => controller.stopScan(),
                child: const Text(
                  "Stop Scanning",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: () => controller.startScan(),
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text("Scan for Devices"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
          ),
      ],
    );
  }

  Widget _buildLottieOrFallback() {
    return FutureBuilder(
      future: _checkLottieAsset(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == true) {
          return Lottie.asset(
            'assets/scan.json',
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackAnimation();
            },
          );
        }
        return _buildFallbackAnimation();
      },
    );
  }

  Future<bool> _checkLottieAsset() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildFallbackAnimation() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.bluetooth_searching,
        color: Colors.blueAccent,
        size: 40,
      ),
    );
  }

  Widget _buildDevicesList(BluetoothController controller) {
    final scanResults = controller.scanResults ?? [];

    if (scanResults.isEmpty && controller.isScanning != true) {
      return _buildEmptyState();
    }

    if (scanResults.isEmpty && controller.isScanning == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(height: 16),
            Text(
              "Looking for devices...",
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: scanResults.length,
      itemBuilder: (context, index) {
        if (index >= scanResults.length) {
          return const SizedBox.shrink();
        }

        final result = scanResults[index];
        final device = result.device;

        if (device == null) {
          return const SizedBox.shrink();
        }

        return _buildDeviceCard(
          device.localName ?? "",
          device.remoteId.str,
          result.rssi ?? -100,
          () => _connectToDevice(controller, device),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_searching, size: 80, color: Colors.white30),
            SizedBox(height: 20),
            Text(
              "No devices found",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tap 'Scan for Devices' to search for nearby Bluetooth devices",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    String name,
    String id,
    int rssi,
    VoidCallback onConnect,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bluetooth,
              color: Colors.blueAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : "Unknown Device",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  id,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 14,
                      color: _getSignalColor(rssi),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${rssi}dBm",
                      style: TextStyle(
                        color: _getSignalColor(rssi),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(80, 36),
            ),
            child: const Text(
              "Connect",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int rssi) {
    if (rssi > -60) return Colors.green;
    if (rssi > -80) return Colors.orange;
    return Colors.red;
  }

  void _connectToDevice(
    BluetoothController controller,
    BluetoothDevice device,
  ) async {
    try {
      await controller.connectToDevice(device);
    } catch (e) {
      debugPrint('Connection error: $e');
      // Show error to user
      Get.snackbar(
        'Connection Error',
        'Failed to connect to ${device.localName.isNotEmpty ? device.localName : 'device'}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _disconnectDevice(
    BluetoothController controller,
    BluetoothDevice device,
  ) async {
    try {
      await device.disconnect();
      Get.snackbar(
        'Disconnected',
        'Device disconnected successfully',
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Disconnect error: $e');
      Get.snackbar(
        'Disconnect Error',
        'Failed to disconnect device',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _sendDataToDevice(
    BluetoothController controller,
    String data,
    BluetoothCharacteristic device,
  ) async {
    try {
      await controller.sendDataToDevice(device);
      Get.snackbar(
        'Data Sent',
        'Message sent successfully: $data',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Send data error: $e');
      Get.snackbar(
        'Send Error',
        'Failed to send data',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
