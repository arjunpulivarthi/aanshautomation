import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/add_home_dialog.dart';
import '../../widgets/edit_home_dialog.dart';
import '../../theme/app_theme.dart';
import '../profile/profile_screen.dart';
import 'home_detail_screen.dart';

class HomeListScreen extends StatefulWidget {
  const HomeListScreen({super.key});

  @override
  State<HomeListScreen> createState() => _HomeListScreenState();
}

class _HomeListScreenState extends State<HomeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final homeProvider = context.read<HomeProvider>();
      if (authProvider.user != null) {
        homeProvider.loadUserHomes(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: homeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : homeProvider.homes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 80,
                          color: Colors.white30,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No homes yet',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a home in your database to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: homeProvider.homes.length,
                    itemBuilder: (context, index) {
                      final home = homeProvider.homes[index];
                      return GestureDetector(
                        onTap: () {
                          homeProvider.selectHome(home);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HomeDetailScreen(),
                            ),
                          );
                        },
                        onLongPress: () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) => EditHomeDialog(home: home),
                          );
                          if (result != null && mounted) {
                            final authProvider = context.read<AuthProvider>();
                            final homeProvider = context.read<HomeProvider>();
                            await homeProvider.loadUserHomes(authProvider.user!.id);
                            if (result == 'deleted') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Home deleted')),
                              );
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: AppTheme.glassMorphism(opacity: 0.15),
                          padding: const EdgeInsets.all(20),
                          child: Row(
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
                                child: const Icon(
                                  Icons.home,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      home.name,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      home.address,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    if (home.wifiSsid.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.wifi,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            home.wifiSsid,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => const AddHomeDialog(),
          );
          if (result == true && mounted) {
            final authProvider = context.read<AuthProvider>();
            final homeProvider = context.read<HomeProvider>();
            await homeProvider.loadUserHomes(authProvider.user!.id);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
