import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'realizar_denuncia_screen.dart';
import 'gestion_roles_screen.dart';
import 'gest_usuarios.dart';
import 'gestion_clasificacion_denuncias.dart';
import 'edit_user_screen.dart';

import '../models/cluster.dart' as model;
import '../services/cluster_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
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

  CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(4.8176, -74.3542),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar datos de usuario
    _nombre = prefs.getString('user_nombre')?.trim() ?? '';
    _email = prefs.getString('user_email')?.trim() ?? '';
    _role = prefs.getString('user_rol')?.trim().toLowerCase() ?? 'usuario';
    _userLat = prefs.getDouble('user_latitud');
    _userLng = prefs.getDouble('user_longitud');

    if (_userLat != null && _userLng != null) {
      _initialCamera = CameraPosition(
        target: LatLng(_userLat!, _userLng!),
        zoom: 16,
      );
    }

    // Inicializar servicio de clusters
    final token = prefs.getString('jwt_token') ?? '';
    _clusterService = ClusterService(
      baseUrl: Config.apiBase,
      token: token,
    );

    // Cargar clusters (umbral mínimo 3)
    await _loadClusters();
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
      final id = CircleId('${c.lat}-${c.lng}');
      _circleClusterMap[id] = c;
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/iniciar', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF2E7D32),
            title: Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Mapa de Zonas de Peligro', style: TextStyle(color: Colors.white)),
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
                  markers: _buildMarkers(),
                  circles: _buildCircles(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (ctrl) {
                    if (_userLat != null && _userLng != null) {
                      ctrl.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(_userLat!, _userLng!),
                          15,
                        ),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
    if (_userLat != null && _userLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userLat!, _userLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
        ),
      );
    }
    return markers;
  }

  Set<Circle> _buildCircles() {
    return _circleClusterMap.entries.map((entry) {
      final id = entry.key;
      final c = entry.value;
      final bool isDanger = c.cantidad >= 5;
      final Color fill = isDanger
          ? Colors.red.withOpacity(0.3)
          : const Color.fromARGB(255, 247, 210, 4).withOpacity(0.3);
      final Color stroke = isDanger ? Colors.red : Colors.yellow;
      return Circle(
        circleId: id,
        center: LatLng(c.lat, c.lng),
        radius: 100.0,
        fillColor: fill,
        strokeColor: stroke,
        strokeWidth: 1,
        consumeTapEvents: true,
        onTap: () => _showClusterInfo(c),
      );
    }).toSet();
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
            Text(
              'Zona de Peligro',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                final start = slot.start.toString().padLeft(2, '0');
                final end   = (slot.end == 0 ? 24 : slot.end).toString().padLeft(2, '0');
                return Text('· $start:00 – $end:00');
              }),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionButtons() {
    final List<Widget> buttons = [];
    buttons.add(const Text('Opciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
    buttons.add(const SizedBox(height: 16));

    if (_role == 'usuario') {
      buttons.add(_button(Icons.report, 'Reportar un Problema', RealizarDenunciaScreen()));
    } else if (_role == 'moderador') {
      buttons.add(_button(Icons.admin_panel_settings, 'Vista Moderador', null, routeName: '/vistaModerador'));
    } else if (_role == 'administrador') {
      buttons.add(_button(Icons.admin_panel_settings, 'Vista Administrador', null, routeName: '/vistaAdministrador'));
      buttons.add(const SizedBox(height: 12));
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 40),
            ),
            accountName: Text(_nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: Text(_email, style: const TextStyle(fontSize: 14)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Ver mi Perfil'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditUserScreen(esAdmin: false))),
          ),
          if (_role == 'usuario' || _role == 'administrador')
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Mis Denuncias'),
              onTap: () => Navigator.pushNamed(context, '/misDenuncias'),
            ),
          if (_role == 'moderador' || _role == 'administrador')
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Aprobar Denuncias'),
              onTap: () => Navigator.pushNamed(context, '/aprobarDenuncias'),
            ),
          if (_role == 'administrador') ...[
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Gestión de Usuarios'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestUsuariosScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Gestión de Roles'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionRolesScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Gestión de Clasificación'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionClasificacionDenunciasScreen())),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
