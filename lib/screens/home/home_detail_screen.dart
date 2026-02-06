import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/room_card.dart';
import '../../widgets/add_room_dialog.dart';
import '../room/room_detail_screen.dart';

class HomeDetailScreen extends StatelessWidget {
  const HomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final home = homeProvider.selectedHome;

    if (home == null) {
      return const Scaffold(
        body: Center(child: Text('No home selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(home.name),
      ),
      body: GradientBackground(
        child: homeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : homeProvider.rooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 80,
                          color: Colors.white30,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No rooms yet',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add rooms to your home in the database',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: homeProvider.rooms.length,
                    itemBuilder: (context, index) {
                      final room = homeProvider.rooms[index];
                      return RoomCard(
                        room: room,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RoomDetailScreen(room: room),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
      floatingActionButton: home != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => AddRoomDialog(homeId: home.id),
                );
                if (result == true) {
                  final homeProvider = context.read<HomeProvider>();
                  await homeProvider.selectHome(home);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Room'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}
