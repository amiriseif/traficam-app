import 'package:flutter/foundation.dart';
import '../core/models/models.dart';
import '../core/services/traffic_data_service.dart';

// ─────────────────────────────────────────────────────────────────
// DASHBOARD CONTROLLER — Business logic, no UI concerns
// ─────────────────────────────────────────────────────────────────
class DashboardController extends ChangeNotifier {
  DashboardController({required this.officer}) {
    load();
  }

  final Officer officer;
  final _trafficService = TrafficDataService();

  bool loading = true;
  String? error;
  List<TrafficZone> zones = [];
  PlacementRecommendation? recommendation;
  List<ControlOrder> pendingOrders = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _trafficService.getTrafficZones(),
        _trafficService.getPlacementRecommendation(
          lat: officer.latitude ?? 36.8065,
          lng: officer.longitude ?? 10.1815,
          currentZone: officer.currentZone ?? '',
        ),
      ]);

      zones = results[0] as List<TrafficZone>;
      recommendation = results[1] as PlacementRecommendation;
      pendingOrders = _buildMockOrders();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void acknowledgeOrder(String orderId) {
    pendingOrders = pendingOrders
        .where((o) => o.id != orderId)
        .toList();
    notifyListeners();
  }

  List<ControlOrder> _buildMockOrders() => [
        ControlOrder(
          id: 'o1',
          toOfficerId: officer.id,
          fromControlRoom: 'Salle de Contrôle — Tunis',
          message:
              'Se déplacer immédiatement vers Avenue H. Bourguiba — accident signalé',
          targetLocation: 'Avenue Habib Bourguiba, Tunis',
          targetLat: 36.8190,
          targetLng: 10.1658,
          priority: OrderPriority.emergency,
          status: OrderStatus.pending,
          issuedAt:
              DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ];

  int get criticalZones =>
      zones.where((z) => z.congestionLevel >= 80).length;

  int get reinforcementNeeded =>
      zones.where((z) => z.needsReinforcement).length;
}