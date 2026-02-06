import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';

class AddRoomDialog extends StatefulWidget {
  final String homeId;

  const AddRoomDialog({
    super.key,
    required this.homeId,
  });

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = 'bed';
  bool _isLoading = false;

  final Map<String, IconData> _iconOptions = {
    'bed': Icons.bed,
    'living_room': Icons.weekend,
    'kitchen': Icons.kitchen,
    'bathroom': Icons.bathtub,
    'garage': Icons.garage,
    'office': Icons.computer,
    'dining': Icons.dining,
    'garden': Icons.local_florist,
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final homeProvider = context.read<HomeProvider>();

      await homeProvider.createRoom(
        homeId: widget.homeId,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        _showSuccessDialog('Room created successfully!');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('Failed to create room: ${e.toString()}');
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Room'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'e.g., Living Room',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Icon:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _iconOptions.entries.map((entry) {
                  final isSelected = _selectedIcon == entry.key;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = entry.key),
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
                      child: Icon(
                        entry.value,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white70,
                      ),
                    ),
                  );
                }).toList(),
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
