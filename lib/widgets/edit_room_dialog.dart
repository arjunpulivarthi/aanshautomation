import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../providers/home_provider.dart';
import '../services/crud_service.dart';

class EditRoomDialog extends StatefulWidget {
  final RoomModel room;

  const EditRoomDialog({
    super.key,
    required this.room,
  });

  @override
  State<EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<EditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedIcon;
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _selectedIcon = widget.room.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await CrudService.updateRoom(
        roomId: widget.room.id,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room updated successfully')),
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
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete "${widget.room.name}"? This will also delete all devices in this room.'),
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
      await CrudService.deleteRoom(widget.room.id);
      if (mounted) {
        Navigator.of(context).pop('deleted');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room deleted')),
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
      title: const Text('Edit Room'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Icon:'),
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
