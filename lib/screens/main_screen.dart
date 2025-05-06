import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'realizar_denuncia_screen.dart';
import 'gestion_roles_screen.dart';
import 'gest_usuarios.dart';
import 'gestion_clasificacion_denuncias.dart';
import 'edit_user_screen.dart';
import 'lista_denuncias_screen.dart';

import '../models/cluster.dart' as model;
import '../services/cluster_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

String _formatHour12(int hour24) {
  final h = hour24 % 24;
  final period = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '${h12.toString().padLeft(2, '0')}:00 $period';
}

class _MainScreenState extends State<MainScreen> {
  late Future<void> _initFuture;
  late ClusterService _clusterService;
  List<model.Cluster> _clusters = [];
  Map<CircleId, model.Cluster> _circleClusterMap = {};

  String _nombre = '';
  String _email = '';
  String _role = 'usuario';

  double? _userLat;
  double? _userLng;

  bool _permsDenied = false;
  bool _mapReady = false;

  static const LatLng _facaCenter = LatLng(4.60971, -74.08175);

  CameraPosition _initialCamera = const CameraPosition(
    target: _facaCenter,
    zoom: 15,
  );

  late GoogleMapController _mapController;
  late FlutterLocalNotificationsPlugin _localNotif;
  StreamSubscription<Position>? _posSub;
  final Set<String> _notifiedClusters = {};

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    // 1) Pedir permisos
    final locStatus = await Permission.locationWhenInUse.request();
    final notifStatus = await Permission.notification.request();
    _permsDenied = !(locStatus.isGranted && notifStatus.isGranted);

    // 2) Cargar prefs y clusters siempre
    final prefs = await SharedPreferences.getInstance();
    _nombre = prefs.getString('user_nombre')?.trim() ?? '';
    _email = prefs.getString('user_email')?.trim() ?? '';
    _role = prefs.getString('user_rol')?.trim().toLowerCase() ?? 'usuario';

    final token = prefs.getString('jwt_token') ?? '';
    _clusterService = ClusterService(baseUrl: Config.apiBase, token: token);
    await _loadClusters();

    // 3) Si permisos OK, inicializar notifs y posición real
    if (!_permsDenied) {
      _initNotifications();
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        setState(() {
          _userLat = pos.latitude;
          _userLng = pos.longitude;
        });
        if (_mapReady) {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(_userLat!, _userLng!),
              16,
            ),
          );
        }
        _checkProximity();
      });
    }
  }

  Future<void> _loadClusters() async {
    try {
      final list = await _clusterService.fetchClusters(threshold: 3);
      setState(() {
        _clusters = list;
        _buildCircleClusterMap();
      });
    } catch (e) {
      debugPrint('Error al cargar clusters: $e');
    }
  }

  void _buildCircleClusterMap() {
    _circleClusterMap.clear();
    for (var c in _clusters.where((c) => c.cantidad >= 3)) {
      _circleClusterMap[CircleId('${c.lat}-${c.lng}')] = c;
    }
  }

  void _initNotifications() {
    _localNotif = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  void _checkProximity() {
    if (_userLat == null || _userLng == null) return;
    const dangerRadius = 100.0;
    for (var entry in _circleClusterMap.entries) {
      final id = entry.key.value;
      final c = entry.value;
      final dist = Geolocator.distanceBetween(
        _userLat!, _userLng!,
        c.lat, c.lng,
      );
      final inside = dist <= dangerRadius;
      final already = _notifiedClusters.contains(id);

      if (inside && !already) {
        _showNotification(
          title: '¡Zona de peligro!',
          body: 'Estás dentro de una zona con ${c.cantidad} denuncias, ten precaución.',
        );
        _notifiedClusters.add(id);
      } else if (!inside && already) {
        _notifiedClusters.remove(id);
      } else if (dist <= dangerRadius * 2 && !already) {
        _showNotification(
          title: 'Cuidado cerca de zona de peligro',
          body: 'Te estás acercando a una zona con ${c.cantidad} denuncias.',
        );
      }
    }
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'danger_channel',
      'Zonas de Peligro',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotif.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/iniciar', (r) => false);
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2E7D32),
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Builder(
                  builder: (c) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(c).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Mapa de Zonas de Peligro',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          drawer: _buildDrawer(),
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: GoogleMap(
                  initialCameraPosition: _initialCamera,
                  onMapCreated: (ctrl) {
                    _mapController = ctrl;
                    _mapReady = true;
                  },
                  markers: _buildMarkers(),
                  circles: _buildCircles(),
                  myLocationEnabled: !_permsDenied,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildOptionButtons(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (!_permsDenied && _userLat != null && _userLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(_userLat!, _userLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
      ));
    }
    return markers;
  }

  Set<Circle> _buildCircles() => _circleClusterMap.entries.map((e) {
        final c = e.value;
        final isDanger = c.cantidad >= 5;
        return Circle(
          circleId: e.key,
          center: LatLng(c.lat, c.lng),
          radius: 100,
          fillColor: (isDanger ? Colors.red : Colors.yellow).withOpacity(0.3),
          strokeColor: isDanger ? Colors.red : Colors.yellow,
          strokeWidth: 1,
          consumeTapEvents: true,
          onTap: () => _showClusterInfo(c),
        );
      }).toSet();

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 40),
          ),
          accountName: Text(_nombre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          accountEmail: Text(_email, style: const TextStyle(fontSize: 14)),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Inicio'),
          onTap: () async {
            Navigator.pop(context);
            await _loadClusters();
            if (_mapReady) {
              final target = (!_permsDenied && _userLat != null && _userLng != null)
                  ? LatLng(_userLat!, _userLng!)
                  : _facaCenter;
              final zoom = (!_permsDenied && _userLat != null) ? 16.0 : 15.0;
              _mapController.animateCamera(
                CameraUpdate.newLatLngZoom(target, zoom),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Ver mi Perfil'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditUserScreen(esAdmin: false)),
          ),
        ),
        if (_role == 'usuario')
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Mis Denuncias'),
            onTap: () => Navigator.pushNamed(context, '/misDenuncias'),
          ),
        if (_role == 'moderador')
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Aprobar Denuncias'),
            onTap: () => Navigator.pushNamed(context, '/aprobarDenuncias'),
          ),
        if (_role == 'administrador') ...[
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Gestión de Usuarios'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const GestUsuariosScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Gestión de Roles'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const GestionRolesScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Gestión de Clasificación'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const GestionClasificacionDenunciasScreen())),
          ),
        ],
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar Sesión'),
          onTap: _logout,
        ),
      ]),
    );
  }

  List<Widget> _buildOptionButtons() {
    final buttons = <Widget>[
      const Text('Opciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
    ];
    if (_role == 'usuario') {
      buttons.add(_button(Icons.report, 'Reportar un Problema', RealizarDenunciaScreen()));
    } else if (_role == 'moderador') {
      buttons.add(_button(Icons.check_circle, 'Revisar Denuncias', const ListaDenunciasScreen()));
    } else if (_role == 'administrador') {
      buttons.add(_button(Icons.settings, 'Gestión de Roles', GestionRolesScreen()));
      buttons.add(const SizedBox(height: 12));
      buttons.add(_button(Icons.group, 'Gestión de Usuarios', GestUsuariosScreen()));
      buttons.add(const SizedBox(height: 12));
      buttons.add(_button(Icons.flag, 'Gestión de Clasificación', GestionClasificacionDenunciasScreen()));
    } else {
      buttons.add(Center(child: Text('Rol desconocido: $_role')));
    }
    return buttons;
  }

  Widget _button(IconData icon, String label, Widget? screen, {String? routeName}) {
    return ElevatedButton.icon(
      onPressed: () {
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        } else if (routeName != null) {
          Navigator.pushNamed(context, routeName);
        }
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }

  void _showClusterInfo(model.Cluster c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zona de Peligro', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Denuncias totales: ${c.cantidad}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Tipos de delito:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...c.delitos.entries.map((e) => Text('· ${e.key}: ${e.value}')),
            const SizedBox(height: 12),
            Text('Franjas horarias críticas:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (c.dangerSlots.isEmpty)
              const Text('No se detectan franjas críticas.')
            else
              ...c.dangerSlots.map((slot) {
                final startLabel = _formatHour12(slot.start);
                final endHour = slot.end == 0 ? 24 : slot.end;
                final endLabel = _formatHour12(endHour);
                return Text('· $startLabel – $endLabel');
              }),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
