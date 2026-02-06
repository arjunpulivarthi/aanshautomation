import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/home_model.dart';
import '../providers/home_provider.dart';
import '../services/crud_service.dart';

class EditHomeDialog extends StatefulWidget {
  final HomeModel home;

  const EditHomeDialog({
    super.key,
    required this.home,
  });

  @override
  State<EditHomeDialog> createState() => _EditHomeDialogState();
}

class _EditHomeDialogState extends State<EditHomeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _wifiController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.home.name);
    _addressController = TextEditingController(text: widget.home.address);
    _wifiController = TextEditingController(text: widget.home.wifiSsid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _wifiController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await CrudService.updateHome(
        homeId: widget.home.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        wifiSsid: _wifiController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home updated successfully')),
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
        title: const Text('Delete Home'),
        content: Text('Are you sure you want to delete "${widget.home.name}"? This will also delete all rooms and devices.'),
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
      await CrudService.deleteHome(widget.home.id);
      if (mounted) {
        Navigator.of(context).pop('deleted');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home deleted')),
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
      title: const Text('Edit Home'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Home Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wifiController,
                decoration: const InputDecoration(labelText: 'WiFi SSID'),
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
