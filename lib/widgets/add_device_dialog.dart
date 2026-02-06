import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_model.dart';
import '../providers/home_provider.dart';

class AddDeviceDialog extends StatefulWidget {
  final String roomId;

  const AddDeviceDialog({
    super.key,
    required this.roomId,
  });

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mqttController = TextEditingController();
  final _hardwareController = TextEditingController();
  DeviceType _selectedType = DeviceType.light;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mqttController.dispose();
    _hardwareController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final homeProvider = context.read<HomeProvider>();

      await homeProvider.createDevice(
        roomId: widget.roomId,
        name: _nameController.text.trim(),
        type: _selectedType,
        mqttTopic: _mqttController.text.trim().isEmpty
            ? null
            : _mqttController.text.trim(),
        hardwareId: _hardwareController.text.trim().isEmpty
            ? null
            : _hardwareController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        _showSuccessDialog('Device created successfully!');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('Failed to create device: ${e.toString()}');
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Device'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  hintText: 'e.g., Main Light',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a device name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Device Type:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DeviceType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return InkWell(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white24,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDeviceIcon(type),
                            size: 20,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            type.name.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mqttController,
                decoration: const InputDecoration(
                  labelText: 'MQTT Topic (Optional)',
                  hintText: 'e.g., home/living/light1',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hardwareController,
                decoration: const InputDecoration(
                  labelText: 'Hardware ID (Optional)',
                  hintText: 'e.g., ESP8266-001',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
