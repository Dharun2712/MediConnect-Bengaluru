import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math' show atan2, cos, pi, sin, sqrt;
import '../config/app_theme.dart';
import '../services/socket_service.dart';

enum SOSStatus {
  pending,
  assigned,
  enRoute,
  arrived,
  pickedUp,
  completed,
}

class SOSActiveScreen extends StatefulWidget {
  final Map<String, dynamic> sosData;

  const SOSActiveScreen({Key? key, required this.sosData}) : super(key: key);

  @override
  State<SOSActiveScreen> createState() => _SOSActiveScreenState();
}

class _SOSActiveScreenState extends State<SOSActiveScreen> with TickerProviderStateMixin {
  final SocketService _socketService = SocketService();
  
  GoogleMapController? _mapController;
  SOSStatus _currentStatus = SOSStatus.pending;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  // Driver tracking data
  Map<String, dynamic>? _driverInfo;
  LatLng? _driverLocation;
  LatLng? _clientLocation;
  String _eta = '--';
  String _distance = '--';
  
  // Animation
  late AnimationController _pulseController;
  Timer? _etaUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _setupPulseAnimation();
    _setupSocketListeners();
    _updateStatusFromData();
    _startEtaUpdates();
  }

  void _initializeLocations() {
    // Client location from SOS data
    final clientLat = widget.sosData['location']?['coordinates']?[1] ?? 
                      widget.sosData['lat'] ?? 0.0;
    final clientLng = widget.sosData['location']?['coordinates']?[0] ?? 
                      widget.sosData['lng'] ?? 0.0;
    _clientLocation = LatLng(clientLat.toDouble(), clientLng.toDouble());
    
    // Check if driver info exists
    if (widget.sosData['driver'] != null) {
      _driverInfo = widget.sosData['driver'];
      final driverLat = _driverInfo!['location']?['coordinates']?[1] ?? 
                        _driverInfo!['lat'] ?? clientLat;
      final driverLng = _driverInfo!['location']?['coordinates']?[0] ?? 
                        _driverInfo!['lng'] ?? clientLng;
      _driverLocation = LatLng(driverLat.toDouble(), driverLng.toDouble());
    }
    
    _setupMarkers();
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _setupSocketListeners() {
    // Listen for driver location updates
    _socketService.socket?.on('driver_location_update', (data) {
      print('[SOSActive] 📍 Driver location update: $data');
      if (mounted && data != null) {
        _handleDriverLocationUpdate(data);
      }
    });

    // Listen for driver accepted
    _socketService.socket?.on('driver_accepted', (data) {
      print('[SOSActive] ✅ Driver accepted: $data');
      if (mounted) {
        _handleDriverAccepted(data);
      }
    });

    // Listen for request assigned
    _socketService.socket?.on('request_assigned', (data) {
      print('[SOSActive] 🚑 Request assigned: $data');
      if (mounted) {
        _handleDriverAccepted(data);
      }
    });

    // Listen for driver arrived
    _socketService.socket?.on('driver_arrived', (data) {
      print('[SOSActive] 🏁 Driver arrived: $data');
      if (mounted) {
        setState(() {
          _currentStatus = SOSStatus.arrived;
          _eta = 'Arrived';
          _distance = '0 m';
        });
      }
    });
    
    // Listen for picked up
    _socketService.socket?.on('picked_up', (data) {
      print('[SOSActive] 🚗 Picked up: $data');
      if (mounted) {
        setState(() {
          _currentStatus = SOSStatus.pickedUp;
        });
      }
    });
  }

  void _handleDriverAccepted(dynamic data) {
    setState(() {
      _currentStatus = SOSStatus.assigned;
      _driverInfo = {
        'name': data['driver_name'] ?? 'Driver',
        'vehicle': data['vehicle'] ?? 'Ambulance',
        'contact': data['contact'] ?? data['driver_contact'] ?? '',
        'eta': data['eta_minutes'] ?? '--',
      };
      _eta = '${data['eta_minutes'] ?? '--'} min';
      
      if (data['lat'] != null && data['lng'] != null) {
        _driverLocation = LatLng(
          (data['lat'] as num).toDouble(),
          (data['lng'] as num).toDouble(),
        );
        _setupMarkers();
        _createRouteLine();
        _animateCameraToShowBoth();
      }
    });
  }

  void _handleDriverLocationUpdate(dynamic data) {
    final lat = data['lat'] ?? data['latitude'] ?? data['location']?['lat'];
    final lng = data['lng'] ?? data['longitude'] ?? data['location']?['lng'];
    
    if (lat != null && lng != null) {
      final newLocation = LatLng((lat as num).toDouble(), (lng as num).toDouble());
      
      setState(() {
        _driverLocation = newLocation;
        if (_currentStatus == SOSStatus.assigned) {
          _currentStatus = SOSStatus.enRoute;
        }
        _setupMarkers();
        _updateRouteProgress();
        _calculateEtaAndDistance();
      });
      
      // Animate camera to follow ambulance
      _animateCameraToDriver();
    }
  }

  void _updateStatusFromData() {
    final status = widget.sosData['status']?.toString().toLowerCase() ?? 'pending';
    
    setState(() {
      if (status == 'pending') {
        _currentStatus = SOSStatus.pending;
      } else if (status == 'accepted' || status == 'assigned') {
        _currentStatus = SOSStatus.assigned;
        _extractDriverInfo();
      } else if (status == 'enroute' || status == 'en_route') {
        _currentStatus = SOSStatus.enRoute;
        _extractDriverInfo();
      } else if (status == 'arrived') {
        _currentStatus = SOSStatus.arrived;
        _extractDriverInfo();
      } else if (status == 'picked_up' || status == 'in_transit') {
        _currentStatus = SOSStatus.pickedUp;
        _extractDriverInfo();
      }
    });
    
    if (_driverLocation != null && _clientLocation != null) {
      _createRouteLine();
      _calculateEtaAndDistance();
    }
  }

  void _extractDriverInfo() {
    if (widget.sosData['driver_name'] != null || widget.sosData['driver'] != null) {
      _driverInfo = {
        'name': widget.sosData['driver_name'] ?? widget.sosData['driver']?['name'] ?? 'Driver',
        'vehicle': widget.sosData['vehicle'] ?? widget.sosData['driver']?['vehicle'] ?? 'Ambulance',
        'contact': widget.sosData['driver_contact'] ?? widget.sosData['driver']?['contact'] ?? '',
      };
    }
    
    // Try to get driver location
    if (widget.sosData['driver_current_location'] != null) {
      final loc = widget.sosData['driver_current_location'];
      _driverLocation = LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      );
    }
  }

  void _setupMarkers() {
    _markers.clear();
    
    // Client marker
    if (_clientLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('client'),
          position: _clientLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: '📍 Your Location'),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    // Ambulance marker
    if (_driverLocation != null && _currentStatus != SOSStatus.pending) {
      _markers.add(
        Marker(
          markerId: const MarkerId('ambulance'),
          position: _driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: '🚑 ${_driverInfo?['name'] ?? 'Ambulance'}',
            snippet: 'ETA: $_eta',
          ),
          anchor: const Offset(0.5, 0.5),
          rotation: _calculateBearing(),
        ),
      );
    }
    
    if (mounted) setState(() {});
  }

  double _calculateBearing() {
    if (_driverLocation == null || _clientLocation == null) return 0;
    
    final lat1 = _driverLocation!.latitude * pi / 180;
    final lat2 = _clientLocation!.latitude * pi / 180;
    final dLng = (_clientLocation!.longitude - _driverLocation!.longitude) * pi / 180;
    
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    
    return atan2(y, x) * 180 / pi;
  }

  void _createRouteLine() {
    if (_driverLocation == null || _clientLocation == null) return;
    
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_driverLocation!, _clientLocation!],
        color: AppTheme.secondary,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
    
    if (mounted) setState(() {});
  }

  void _updateRouteProgress() {
    if (_driverLocation == null || _clientLocation == null) return;
    
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_driverLocation!, _clientLocation!],
        color: AppTheme.secondary,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  void _calculateEtaAndDistance() {
    if (_driverLocation == null || _clientLocation == null) return;
    
    // Calculate distance using Haversine formula
    const earthRadius = 6371.0; // km
    
    final lat1 = _driverLocation!.latitude * pi / 180;
    final lat2 = _clientLocation!.latitude * pi / 180;
    final dLat = (lat2 - lat1);
    final dLng = (_clientLocation!.longitude - _driverLocation!.longitude) * pi / 180;
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c; // in km
    
    // Format distance
    if (distance < 1) {
      _distance = '${(distance * 1000).toInt()} m';
    } else {
      _distance = '${distance.toStringAsFixed(1)} km';
    }
    
    // Calculate ETA (assuming 40 km/h average speed in city)
    final etaMinutes = (distance / 40 * 60).ceil();
    _eta = '$etaMinutes min';
    
    if (mounted) setState(() {});
  }

  void _startEtaUpdates() {
    _etaUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentStatus == SOSStatus.enRoute) {
        _calculateEtaAndDistance();
      }
    });
  }

  void _animateCameraToShowBoth() {
    if (_mapController == null || _clientLocation == null) return;
    
    if (_driverLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _driverLocation!.latitude < _clientLocation!.latitude 
              ? _driverLocation!.latitude : _clientLocation!.latitude,
          _driverLocation!.longitude < _clientLocation!.longitude 
              ? _driverLocation!.longitude : _clientLocation!.longitude,
        ),
        northeast: LatLng(
          _driverLocation!.latitude > _clientLocation!.latitude 
              ? _driverLocation!.latitude : _clientLocation!.latitude,
          _driverLocation!.longitude > _clientLocation!.longitude 
              ? _driverLocation!.longitude : _clientLocation!.longitude,
        ),
      );
      
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } else {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_clientLocation!, 15),
      );
    }
  }

  void _animateCameraToDriver() {
    if (_mapController == null || _driverLocation == null) return;
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(_driverLocation!),
    );
  }

  void _callDriver() {
    final phone = _driverInfo?['contact'] ?? '';
    if (phone.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling $phone...')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver contact not available')),
      );
    }
  }

  void _cancelSOS() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel SOS?'),
        content: const Text('Are you sure you want to cancel the emergency request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      Navigator.pop(context, 'cancelled');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _etaUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _clientLocation ?? const LatLng(0, 0),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _animateCameraToShowBoth();
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top info bar with ETA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ETA Card
                  if (_currentStatus != SOSStatus.pending)
                    _buildEtaCard(),
                  
                  const SizedBox(height: 8),
                  
                  // Status indicator
                  _buildStatusBadge(),
                ],
              ),
            ),
          ),

          // Bottom sheet with details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_shipping, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reaching in $_eta',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$_distance away',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    switch (_currentStatus) {
      case SOSStatus.pending:
        statusText = 'Finding nearest ambulance...';
        statusColor = AppTheme.warning;
        statusIcon = Icons.search;
        break;
      case SOSStatus.assigned:
        statusText = 'Ambulance assigned!';
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        break;
      case SOSStatus.enRoute:
        statusText = 'Ambulance on the way';
        statusColor = AppTheme.secondary;
        statusIcon = Icons.local_shipping;
        break;
      case SOSStatus.arrived:
        statusText = 'Ambulance arrived!';
        statusColor = AppTheme.success;
        statusIcon = Icons.location_on;
        break;
      case SOSStatus.pickedUp:
        statusText = 'Heading to hospital';
        statusColor = AppTheme.primary;
        statusIcon = Icons.local_hospital;
        break;
      case SOSStatus.completed:
        statusText = 'Emergency resolved';
        statusColor = AppTheme.success;
        statusIcon = Icons.done_all;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStatus == SOSStatus.pending)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            )
          else
            Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Driver info or waiting message
          if (_currentStatus == SOSStatus.pending)
            _buildWaitingSection()
          else
            _buildDriverInfoSection(),
          
          const SizedBox(height: 16),
          
          // Action buttons
          _buildActionButtons(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWaitingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.1 + (_pulseController.value * 0.1)),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.emergency,
                      color: AppTheme.primary,
                      size: 32,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Finding nearest ambulance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we connect you with the nearest available ambulance driver.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Live tracking progress
          _buildLiveTrackingProgress(),
          
          const SizedBox(height: 20),
          
          // Driver card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Driver avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Driver details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _driverInfo?['name'] ?? 'Driver',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _driverInfo?['vehicle'] ?? 'Ambulance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Call button
                GestureDetector(
                  onTap: _callDriver,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTrackingProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ETA display
          Text(
            '$_eta Remaining to reach you',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          
          // Progress visualization
          Row(
            children: [
              // Ambulance icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              
              // Progress line
              Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double progress = 0.2;
                          if (_currentStatus == SOSStatus.arrived) {
                            progress = 1.0;
                          } else if (_currentStatus == SOSStatus.enRoute) {
                            progress = 0.5;
                          } else if (_currentStatus == SOSStatus.assigned) {
                            progress = 0.2;
                          }
                          
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              color: AppTheme.secondary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Destination icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Call button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _callDriver,
              icon: const Icon(Icons.call),
              label: const Text('Call Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Cancel button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _cancelSOS,
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
