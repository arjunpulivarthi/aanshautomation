import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';
import '../models/home_model.dart';
import '../models/room_model.dart';
import 'supabase_service.dart';

class DeviceService {
  static final SupabaseClient _client = SupabaseService.client;

  // Fetch homes for current user through home_members join table
  static Future<List<HomeModel>> getUserHomes(String userId) async {
    final response = await _client
        .from('home_members')
        .select('homes(*)')
        .eq('user_id', userId);

    return (response as List)
        .map((row) => HomeModel.fromJson(row['homes']))
        .toList();
  }

  // Create a new home and add current user as owner in home_members
  static Future<HomeModel> createHome({
    required String userId,
    required String name,
    required String address,
    required String wifiSsid,
  }) async {
    // First create the home (without user_id since it doesn't exist in schema)
    final homeResponse = await _client
        .from('homes')
        .insert({
          'name': name,
          'address': address,
          'wifi_ssid': wifiSsid,
        })
        .select()
        .single();

    final home = HomeModel.fromJson(homeResponse);

    // Then add the user as owner in home_members
    await _client.from('home_members').insert({
      'home_id': home.id,
      'user_id': userId,
      'role': 'owner',
    });

    return home;
  }

  // Fetch rooms for a home
  static Future<List<RoomModel>> getHomeRooms(String homeId) async {
    final response = await _client
        .from('rooms')
        .select('*, devices:devices(count)')
        .eq('home_id', homeId)
        .order('created_at', ascending: true);

    return (response as List).map((json) {
      final room = RoomModel.fromJson(json);
      // Extract device count from the aggregation
      if (json['devices'] != null && json['devices'] is List) {
        room.deviceCount = (json['devices'] as List).length;
      }
      return room;
    }).toList();
  }

  // Create a new room
  static Future<RoomModel> createRoom({
    required String homeId,
    required String name,
    required String icon,
  }) async {
    final response = await _client
        .from('rooms')
        .insert({
          'home_id': homeId,
          'name': name,
          'icon': icon,
        })
        .select()
        .single();

    return RoomModel.fromJson(response);
  }

  // Fetch devices for a room
  static Future<List<DeviceModel>> getRoomDevices(String roomId) async {
    final response = await _client
        .from('devices')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => DeviceModel.fromJson(json))
        .toList();
  }

  // Create a new device
  static Future<DeviceModel> createDevice({
    required String roomId,
    required String name,
    required DeviceType type,
    String? mqttTopic,
    String? hardwareId,
  }) async {
    // Initial state based on device type
    Map<String, dynamic> initialState = {};
    switch (type) {
      case DeviceType.light:
        initialState = {'is_on': false, 'brightness': 0};
        break;
      case DeviceType.thermostat:
        initialState = {'temperature': 22.0};
        break;
      case DeviceType.lock:
        initialState = {'is_locked': true};
        break;
      default:
        initialState = {};
    }

    // mqtt_topic is required in schema (NOT NULL), generate default if not provided
    final topic = mqttTopic ?? 'home/room_${roomId.substring(0, 8)}/${type.name}/${name.toLowerCase().replaceAll(' ', '_')}';

    final response = await _client
        .from('devices')
        .insert({
          'room_id': roomId,
          'name': name,
          'type': type.name,
          'mqtt_topic': topic,
          'hardware_id': hardwareId,
          'is_online': true,
          'current_state': initialState,
        })
        .select()
        .single();

    return DeviceModel.fromJson(response);
  }

  // Fetch all devices for a home
  static Future<List<DeviceModel>> getHomeDevices(String homeId) async {
    final response = await _client
        .from('devices')
        .select('*, rooms!inner(home_id)')
        .eq('rooms.home_id', homeId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => DeviceModel.fromJson(json))
        .toList();
  }

  // Update device state
  static Future<void> updateDeviceState({
    required String deviceId,
    required Map<String, dynamic> newState,
    String? action,
  }) async {
    // Update device state
    await _client.from('devices').update({
      'current_state': newState,
    }).eq('id', deviceId);

    // Log the action
    if (action != null) {
      final userId = SupabaseService.currentUser?.id;
      await _client.from('device_logs').insert({
        'device_id': deviceId,
        'user_id': userId,
        'action': action,
        'payload': newState,
      });
    }
  }

  // Toggle device on/off
  static Future<void> toggleDevice({
    required DeviceModel device,
  }) async {
    final currentState = Map<String, dynamic>.from(device.currentState);
    final isOn = currentState['is_on'] as bool? ?? false;
    currentState['is_on'] = !isOn;

    await updateDeviceState(
      deviceId: device.id,
      newState: currentState,
      action: isOn ? 'turned_off' : 'turned_on',
    );
  }

  // Set device brightness (for lights)
  static Future<void> setBrightness({
    required String deviceId,
    required int brightness,
    required Map<String, dynamic> currentState,
  }) async {
    final newState = Map<String, dynamic>.from(currentState);
    newState['brightness'] = brightness;
    newState['is_on'] = brightness > 0;

    await updateDeviceState(
      deviceId: deviceId,
      newState: newState,
      action: 'brightness_changed',
    );
  }

  // Set temperature (for thermostats)
  static Future<void> setTemperature({
    required String deviceId,
    required double temperature,
    required Map<String, dynamic> currentState,
  }) async {
    final newState = Map<String, dynamic>.from(currentState);
    newState['temperature'] = temperature;

    await updateDeviceState(
      deviceId: deviceId,
      newState: newState,
      action: 'temperature_changed',
    );
  }

  // Subscribe to device changes
  static RealtimeChannel subscribeToDevices({
    required String roomId,
    required Function(DeviceModel) onUpdate,
  }) {
    return _client
        .channel('devices:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'devices',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onUpdate(DeviceModel.fromJson(payload.newRecord!));
            }
          },
        )
        .subscribe();
  }
}
