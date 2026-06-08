import 'package:flutter/foundation.dart';
import '../../dashboard/core/models/models.dart';
import '../../dashboard/core/services/supabase_service.dart';
import '../../dashboard/core/services/location_service.dart';

// ─────────────────────────────────────────────────────────────────
// STATUS CONTROLLER — Manages officer status broadcast logic
// ─────────────────────────────────────────────────────────────────
class StatusController extends ChangeNotifier {
  StatusController({required this.officer}) {
    selectedStatus = officer.status;
    _loadLocation();
  }

  final Officer officer;
  final _supabase  = SupabaseService();
  final _location  = LocationService();

  OfficerStatus selectedStatus = OfficerStatus.onDuty;
  String currentAddress = 'Récupération...';
  bool loadingLocation = false;
  bool updating = false;
  bool updated  = false;
  String? error;

  Future<void> _loadLocation() async {
    loadingLocation = true;
    notifyListeners();
    final pos = await _location.getCurrentPosition();
    if (pos != null) {
      currentAddress = await _location.getAddressFromCoords(
          pos.latitude, pos.longitude);
    } else {
      currentAddress = 'Localisation indisponible';
    }
    loadingLocation = false;
    notifyListeners();
  }

  Future<void> refreshLocation() => _loadLocation();

  void setStatus(OfficerStatus s) {
    selectedStatus = s;
    notifyListeners();
  }

  Future<void> broadcast() async {
    updating = true;
    updated  = false;
    error    = null;
    notifyListeners();

    final pos = await _location.getCurrentPosition();
    try {
      await _supabase.updateOfficerStatus(
        officerId: officer.id,
        status: selectedStatus,
        latitude: pos?.latitude,
        longitude: pos?.longitude,
        currentZone: currentAddress,
      );
      updated = true;
    } catch (e) {
      error = 'Erreur: $e';
    }
    updating = false;
    notifyListeners();
  }

  String statusLabel(OfficerStatus s) {
    switch (s) {
      case OfficerStatus.onDuty:    return 'En service';
      case OfficerStatus.offDuty:   return 'Hors service';
      case OfficerStatus.atIncident: return 'Sur incident';
      case OfficerStatus.onBreak:   return 'En pause';
      case OfficerStatus.moving:    return 'En déplacement';
    }
  }

  String statusDescription(OfficerStatus s) {
    switch (s) {
      case OfficerStatus.onDuty:    return 'Disponible et en patrouille';
      case OfficerStatus.offDuty:   return 'Fin de service';
      case OfficerStatus.atIncident: return 'Intervention en cours';
      case OfficerStatus.onBreak:   return 'Pause temporaire';
      case OfficerStatus.moving:    return 'En déplacement vers une zone';
    }
  }
}