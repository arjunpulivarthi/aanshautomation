import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_model.dart';
import '../providers/home_provider.dart';
import '../services/crud_service.dart';

class EditDeviceDialog extends StatefulWidget {
  final DeviceModel device;

  const EditDeviceDialog({
    super.key,
    required this.device,
  });

  @override
  State<EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<EditDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _mqttController;
  late final TextEditingController _hardwareController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);
    _mqttController = TextEditingController(text: widget.device.mqttTopic);
    _hardwareController = TextEditingController(text: widget.device.hardwareId ?? '');
  }

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
      await CrudService.updateDevice(
        deviceId: widget.device.id,
        name: _nameController.text.trim(),
        mqttTopic: _mqttController.text.trim(),
        hardwareId: _hardwareController.text.trim().isEmpty
            ? null
            : _hardwareController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete "${widget.device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CrudService.deleteDevice(widget.device.id);
      if (mounted) {
        Navigator.of(context).pop('deleted');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Device'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mqttController,
                decoration: const InputDecoration(labelText: 'MQTT Topic'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hardwareController,
                decoration: const InputDecoration(labelText: 'Hardware ID (Optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _isLoading ? null : _handleDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        const Spacer(),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
