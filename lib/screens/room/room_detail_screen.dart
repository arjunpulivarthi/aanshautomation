import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room_model.dart';
import '../../providers/home_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/device_card.dart';
import '../../widgets/add_device_dialog.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomModel room;

  const RoomDetailScreen({
    super.key,
    required this.room,
  });

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      homeProvider.loadRoomDevices(widget.room.id);
      homeProvider.subscribeToRoomDevices(widget.room.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final devices = homeProvider.devicesByRoom[widget.room.id] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
      ),
      body: GradientBackground(
        child: devices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.devices_outlined,
                      size: 80,
                      color: Colors.white30,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No devices yet',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add devices to this room in the database',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DeviceCard(
                      device: device,
                      onToggle: () {
                        homeProvider.toggleDevice(device);
                      },
                      onBrightnessChange: device.type.name == 'light'
                          ? (value) {
                              homeProvider.setBrightness(device, value.toInt());
                            }
                          : null,
                      onTemperatureChange: device.type.name == 'thermostat'
                          ? (value) {
                              homeProvider.setTemperature(device, value);
                            }
                          : null,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => AddDeviceDialog(roomId: widget.room.id),
          );
          if (result == true && mounted) {
            final homeProvider = context.read<HomeProvider>();
            await homeProvider.loadRoomDevices(widget.room.id);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
