import 'package:flutter/foundation.dart';
import '../../dashboard/core/models/models.dart';

// ─────────────────────────────────────────────────────────────────
// FEED CONTROLLER — Real-time incident feed logic
// ─────────────────────────────────────────────────────────────────
class FeedController extends ChangeNotifier {
  FeedController() {
    _incidents = _mockIncidents();
    // In production: subscribe to Supabase realtime stream
    // _supabase.incidentsStream().listen((rows) {
    //   _incidents = rows.map(Incident.fromJson).toList();
    //   notifyListeners();
    // });
  }

  List<Incident> _incidents = [];
  String _filter = 'all'; // 'all' | 'critical' | 'high' | 'medium' | 'low'
  bool loading = false;

  List<Incident> get incidents {
    if (_filter == 'all') return _incidents;
    return _incidents.where((i) => i.severity.name == _filter).toList();
  }

  String get activeFilter => _filter;

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> refresh() async {
    loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _incidents = _mockIncidents();
    loading = false;
    notifyListeners();
  }

  int get totalIncidents => _incidents.length;
  int get criticalCount =>
      _incidents.where((i) => i.severity == IncidentSeverity.critical).length;
  int get activeCount =>
      _incidents.where((i) => i.medicalAssistanceWaiting).length;

  static List<Incident> _mockIncidents() {
    final now = DateTime.now();
    return [
      Incident(
        id: '1',
        reportedBy: 'officer1',
        officerName: 'Agent Ben Ali',
        officerBadge: '10234',
        reportedAt: now.subtract(const Duration(minutes: 8)),
        latitude: 36.8190,
        longitude: 10.1658,
        locationDescription: 'Avenue Habib Bourguiba, Tunis Centre',
        aiDescription:
            'Collision entre deux véhicules — voiture rouge et blanche. '
            'Impact frontal. Deux personnes visibles sur la chaussée.',
        severity: IncidentSeverity.high,
        personsAffected: 3,
        injured: 2,
        confirmedDeaths: 0,
        medicalAssistanceWaiting: true,
        vehiclesInvolved: ['Voiture rouge', 'Voiture blanche'],
      ),
      Incident(
        id: '2',
        reportedBy: 'officer2',
        officerName: 'Agent Trabelsi',
        officerBadge: '10456',
        reportedAt: now.subtract(const Duration(minutes: 34)),
        latitude: 36.8400,
        longitude: 10.2100,
        locationDescription: 'Route de La Marsa, Km 12',
        aiDescription:
            'Embouteillage dense — camion en panne bloquant la voie rapide.',
        severity: IncidentSeverity.medium,
        personsAffected: 0,
        vehiclesInvolved: ['Camion'],
      ),
      Incident(
        id: '3',
        reportedBy: 'officer3',
        officerName: 'Agent Mejri',
        officerBadge: '10789',
        reportedAt: now.subtract(const Duration(hours: 1, minutes: 12)),
        latitude: 36.7900,
        longitude: 10.1400,
        locationDescription: 'Bab Alioua, Banlieue Sud',
        aiDescription:
            'Véhicule renversé sur le bord de la route. Fumée légère détectée.',
        severity: IncidentSeverity.critical,
        personsAffected: 2,
        injured: 2,
        confirmedDeaths: 0,
        firePresent: true,
        medicalAssistanceProvided: true,
        vehiclesInvolved: ['Voiture grise'],
      ),
      Incident(
        id: '4',
        reportedBy: 'officer4',
        officerName: 'Agent Chaabane',
        officerBadge: '10321',
        reportedAt: now.subtract(const Duration(hours: 2, minutes: 5)),
        latitude: 36.8300,
        longitude: 10.1500,
        locationDescription: 'Boulevard du 7 Novembre, Ariana',
        aiDescription:
            'Accrochage mineur entre deux véhicules. Pas de blessé apparent.',
        severity: IncidentSeverity.low,
        personsAffected: 0,
        vehiclesInvolved: ['Voiture bleue', 'Moto'],
      ),
    ];
  }
}