import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/room_model.dart';
import '../widgets/edit_room_dialog.dart';
import '../theme/app_theme.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  IconData _getIconData() {
    switch (room.icon) {
      case 'bed':
        return Icons.bed;
      case 'living_room':
        return Icons.weekend;
      case 'kitchen':
        return Icons.kitchen;
      case 'bathroom':
        return Icons.bathtub;
      case 'garage':
        return Icons.garage;
      default:
        return Icons.room;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => EditRoomDialog(room: room),
        );
      },
      child: Container(
        decoration: AppTheme.glassMorphism(opacity: 0.15),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(),
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              room.name,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${room.deviceCount} ${room.deviceCount == 1 ? 'device' : 'devices'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(delay: 100.ms);
  }
}
