import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/device_model.dart';
import '../widgets/edit_device_dialog.dart';
import '../theme/app_theme.dart';

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onToggle;
  final Function(double)? onBrightnessChange;
  final Function(double)? onTemperatureChange;
  final bool isLoading;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onToggle,
    this.onBrightnessChange,
    this.onTemperatureChange,
    this.isLoading = false,
  });

  IconData _getDeviceIcon() {
    switch (device.type) {
      case DeviceType.light:
        return Icons.lightbulb;
      case DeviceType.thermostat:
        return Icons.thermostat;
      case DeviceType.lock:
        return Icons.lock;
      case DeviceType.camera:
        return Icons.videocam;
      case DeviceType.sensor:
        return Icons.sensors;
    }
  }

  Color _getStatusColor(BuildContext context) {
    if (!device.isOnline) return Colors.grey;
    
    switch (device.type) {
      case DeviceType.light:
        return device.isOn ? context.colorScheme.primary : Colors.grey;
      case DeviceType.lock:
        return device.isLocked ? Colors.red : Colors.green;
      default:
        return context.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => EditDeviceDialog(device: device),
        );
      },
      child: Container(
        decoration: AppTheme.glassMorphism(
          opacity: device.isOn ? 0.2 : 0.1,
          borderColor: device.isOn
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : null,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDeviceIcon(),
                    color: _getStatusColor(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        device.type.name.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white38,
                            ),
                      ),
                    ],
                  ),
                ),
                if (device.type == DeviceType.light || device.type == DeviceType.lock)
                  Switch(
                    value: device.type == DeviceType.light
                        ? device.isOn
                        : !device.isLocked,
                    onChanged: isLoading ? null : (_) => onToggle(),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            
            // Brightness slider for lights
            if (device.type == DeviceType.light && device.isOn && onBrightnessChange != null) ...[
              const SizedBox(height: 16),
              Text(
                'Brightness: ${device.brightness}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: device.brightness.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: isLoading ? null : onBrightnessChange,
              ),
            ],
            
            // Temperature control for thermostats
            if (device.type == DeviceType.thermostat && onTemperatureChange != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Temperature',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${device.temperature.toStringAsFixed(1)}°C',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              Slider(
                value: device.temperature,
                min: 16,
                max: 30,
                divisions: 28,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: isLoading ? null : onTemperatureChange,
              ),
            ],

            // Status indicator
            if (!device.isOnline) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }
}

extension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
