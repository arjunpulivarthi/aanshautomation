import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';
import '../models/home_model.dart';
import '../models/room_model.dart';
import 'supabase_service.dart';

/// Service for update and delete operations
class CrudService {
  static final SupabaseClient _client = SupabaseService.client;

  // ============ HOME OPERATIONS ============
  
  static Future<void> updateHome({
    required String homeId,
    required String name,
    required String address,
    required String wifiSsid,
  }) async {
    await _client.from('homes').update({
      'name': name,
      'address': address,
      'wifi_ssid': wifiSsid,
    }).eq('id', homeId);
  }

  static Future<void> deleteHome(String homeId) async {
    // Delete associated home_members first
    await _client.from('home_members').delete().eq('home_id', homeId);
    // Then delete the home (rooms and devices will cascade)
    await _client.from('homes').delete().eq('id', homeId);
  }

  // ============ ROOM OPERATIONS ============
  
  static Future<void> updateRoom({
    required String roomId,
    required String name,
    required String icon,
  }) async {
    await _client.from('rooms').update({
      'name': name,
      'icon': icon,
    }).eq('id', roomId);
  }

  static Future<void> deleteRoom(String roomId) async {
    // Devices will cascade delete
    await _client.from('rooms').delete().eq('id', roomId);
  }

  // ============ DEVICE OPERATIONS ============
  
  static Future<void> updateDevice({
    required String deviceId,
    required String name,
    String? mqttTopic,
    String? hardwareId,
  }) async {
    final updates = <String, dynamic>{
      'name': name,
    };
    
    if (mqttTopic != null) updates['mqtt_topic'] = mqttTopic;
    if (hardwareId != null) updates['hardware_id'] = hardwareId;

    await _client.from('devices').update(updates).eq('id', deviceId);
  }

  static Future<void> deleteDevice(String deviceId) async {
    await _client.from('devices').delete().eq('id', deviceId);
  }
}
