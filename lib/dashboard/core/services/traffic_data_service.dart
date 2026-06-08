import '../models/models.dart';

/// ─────────────────────────────────────────────────────────────────
/// MOCK TRAFFIC DATA SERVICE
/// Provides realistic fake data for Tunis traffic zones.
/// Replace with real traffic API (e.g., HERE, TomTom, or custom)
/// by implementing the same interface.
/// ─────────────────────────────────────────────────────────────────
class TrafficDataService {
  static const bool _useMock = false;

  /// Get current zone congestion data
  Future<List<TrafficZone>> getTrafficZones() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockZones;
    }
    // TODO: call real API
    throw UnimplementedError('Real API not configured');
  }

  /// Get placement recommendation for this officer based on current data
  Future<PlacementRecommendation> getPlacementRecommendation({
    required double lat,
    required double lng,
    required String currentZone,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockRecommendation(currentZone);
    }
    throw UnimplementedError('Real API not configured');
  }

  // ── MOCK DATA ─────────────────────────────────────────────────────

  static final List<TrafficZone> _mockZones = [
    const TrafficZone(
      id: 'z1',
      name: 'Avenue Habib Bourguiba',
      road: 'GP1 - Centre Ville',
      congestionLevel: 87,
      officersPresent: 1,
      recommendation: 'Renfort urgent nécessaire — embouteillage critique',
      needsReinforcement: true,
    ),
    const TrafficZone(
      id: 'z2',
      name: 'Route de La Marsa',
      road: 'GP9 - Direction Marsa',
      congestionLevel: 54,
      officersPresent: 2,
      recommendation: 'Trafic modéré, couvrir le carrefour de La Soukra',
      needsReinforcement: false,
    ),
    const TrafficZone(
      id: 'z3',
      name: 'Route de Bizerte',
      road: 'GP7 - Direction Nord',
      congestionLevel: 23,
      officersPresent: 1,
      recommendation: 'Trafic fluide — maintenir la position actuelle',
      needsReinforcement: false,
    ),
    const TrafficZone(
      id: 'z4',
      name: 'Boulevard du 7 Novembre',
      road: 'RR58 - Ariana',
      congestionLevel: 71,
      officersPresent: 0,
      recommendation: 'Zone sans agent — déploiement recommandé',
      needsReinforcement: true,
    ),
    const TrafficZone(
      id: 'z5',
      name: 'Carrefour Bab Saadoun',
      road: 'GP1/GP7 - Intersection',
      congestionLevel: 65,
      officersPresent: 1,
      recommendation: 'Surveiller le flux vers La Manouba',
      needsReinforcement: false,
    ),
  ];

  PlacementRecommendation _mockRecommendation(String currentZone) {
    final critical = _mockZones.where((z) => z.needsReinforcement).toList();
    if (critical.isEmpty) {
      return PlacementRecommendation(
        id: 'rec-1',
        recommendedZone: 'Maintenir la position actuelle',
        reason: 'Toutes les zones sont couvertes.',
        urgency: RecommendationUrgency.low,
        estimatedDistanceKm: 0,
        generatedAt: DateTime.now(),
      );
    }
    final top = critical.first;
    return PlacementRecommendation(
      id: 'rec-${DateTime.now().millisecondsSinceEpoch}',
      recommendedZone: top.name,
      reason: top.recommendation,
      urgency: top.congestionLevel > 80
          ? RecommendationUrgency.urgent
          : RecommendationUrgency.medium,
      estimatedDistanceKm: 2.4,
      generatedAt: DateTime.now(),
    );
  }
}
