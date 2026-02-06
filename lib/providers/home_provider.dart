import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';
import '../models/home_model.dart';
import '../models/room_model.dart';
import '../services/device_service.dart';

class HomeProvider extends ChangeNotifier {
  List<HomeModel> _homes = [];
  HomeModel? _selectedHome;
  List<RoomModel> _rooms = [];
  Map<String, List<DeviceModel>> _devicesByRoom = {};
  bool _isLoading = false;
  RealtimeChannel? _deviceChannel;

  List<HomeModel> get homes => _homes;
  HomeModel? get selectedHome => _selectedHome;
  List<RoomModel> get rooms => _rooms;
  Map<String, List<DeviceModel>> get devicesByRoom => _devicesByRoom;
  bool get isLoading => _isLoading;

  Future<void> loadUserHomes(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _homes = await DeviceService.getUserHomes(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading homes: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createHome({
    required String userId,
    required String name,
    required String address,
    required String wifiSsid,
  }) async {
    final home = await DeviceService.createHome(
      userId: userId,
      name: name,
      address: address,
      wifiSsid: wifiSsid,
    );
    _homes.insert(0, home);
    notifyListeners();
  }

  Future<void> selectHome(HomeModel home) async {
    _selectedHome = home;
    _rooms = [];
    _devicesByRoom = {};
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      _rooms = await DeviceService.getHomeRooms(home.id);

      // Load devices for each room
      for (final room in _rooms) {
        final devices = await DeviceService.getRoomDevices(room.id);
        _devicesByRoom[room.id] = devices;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading rooms: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRoom({
    required String homeId,
    required String name,
    required String icon,
  }) async {
    final room = await DeviceService.createRoom(
      homeId: homeId,
      name: name,
      icon: icon,
    );
    _rooms.add(room);
    _devicesByRoom[room.id] = [];
    notifyListeners();
  }

  Future<void> loadRoomDevices(String roomId) async {
    try {
      final devices = await DeviceService.getRoomDevices(roomId);
      _devicesByRoom[roomId] = devices;
      notifyListeners();
    } catch (e) {
      print('Error loading room devices: $e');
    }
  }

  Future<void> createDevice({
    required String roomId,
    required String name,
    required DeviceType type,
    String? mqttTopic,
    String? hardwareId,
  }) async {
    final device = await DeviceService.createDevice(
      roomId: roomId,
      name: name,
      type: type,
      mqttTopic: mqttTopic,
      hardwareId: hardwareId,
    );
    _devicesByRoom[roomId]?.add(device);
    notifyListeners();
  }

  Future<void> toggleDevice(DeviceModel device) async {
    try {
      await DeviceService.toggleDevice(device: device);
      // Reload devices for the room
      await loadRoomDevices(device.roomId);
    } catch (e) {
      print('Error toggling device: $e');
    }
  }

  Future<void> setBrightness(DeviceModel device, int brightness) async {
    try {
      await DeviceService.setBrightness(
        deviceId: device.id,
        brightness: brightness,
        currentState: device.currentState,
      );
      // Reload devices for the room
      await loadRoomDevices(device.roomId);
    } catch (e) {
      print('Error setting brightness: $e');
    }
  }

  Future<void> setTemperature(DeviceModel device, double temperature) async {
    try {
      await DeviceService.setTemperature(
        deviceId: device.id,
        temperature: temperature,
        currentState: device.currentState,
      );
      // Reload devices for the room
      await loadRoomDevices(device.roomId);
    } catch (e) {
      print('Error setting temperature: $e');
    }
  }

  void subscribeToRoomDevices(String roomId) {
    _deviceChannel?.unsubscribe();
    _deviceChannel = DeviceService.subscribeToDevices(
      roomId: roomId,
      onUpdate: (device) {
        // Update the device in the list
        final devices = _devicesByRoom[roomId];
        if (devices != null) {
          final index = devices.indexWhere((d) => d.id == device.id);
          if (index != -1) {
            devices[index] = device;
            notifyListeners();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _deviceChannel?.unsubscribe();
    super.dispose();
  }
}
