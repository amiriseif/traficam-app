// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum OfficerStatus { onDuty, offDuty, atIncident, onBreak, moving }

enum IncidentSeverity { low, medium, high, critical }

enum OrderPriority { routine, urgent, emergency }

enum OrderStatus { pending, acknowledged, completed, cancelled }

enum RecommendationUrgency { low, medium, urgent }

// ─── Officer ───────────────────────────────────
class Officer {
  final String id;
  final String badgeNumber;
  final String fullName;
  final String phoneNumber;
  final OfficerStatus status;
  final double? latitude;
  final double? longitude;
  final String? currentZone;
  final DateTime lastSeen;

  const Officer({
    required this.id,
    required this.badgeNumber,
    required this.fullName,
    required this.phoneNumber,
    this.status = OfficerStatus.onDuty,
    this.latitude,
    this.longitude,
    this.currentZone,
    required this.lastSeen,
  });

  factory Officer.fromJson(Map<String, dynamic> json) => Officer(
        id: json['id'],
        badgeNumber: json['badge_number'],
        fullName: json['full_name'],
        phoneNumber: json['phone_number'] ?? '',
        status: OfficerStatus.values.firstWhere(
          (e) => e.name == (json['status'] ?? 'onDuty'),
          orElse: () => OfficerStatus.onDuty,
        ),
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        currentZone: json['current_zone'],
        lastSeen: DateTime.tryParse(json['last_seen'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'badge_number': badgeNumber,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'status': status.name,
        'latitude': latitude,
        'longitude': longitude,
        'current_zone': currentZone,
        'last_seen': lastSeen.toIso8601String(),
      };

  String get statusLabel {
    switch (status) {
      case OfficerStatus.onDuty:
        return 'En service';
      case OfficerStatus.offDuty:
        return 'Hors service';
      case OfficerStatus.atIncident:
        return 'Sur incident';
      case OfficerStatus.onBreak:
        return 'En pause';
      case OfficerStatus.moving:
        return 'En déplacement';
    }
  }
}

// ─── Incident ───────────────────────────────────
class Incident {
  final String id;
  final String reportedBy; // officer id
  final String officerName;
  final String officerBadge;
  final DateTime reportedAt;
  final double latitude;
  final double longitude;
  final String locationDescription;
  final String? photoUrl;
  final String aiDescription; // from Azure Vision
  final String? voiceNote; // transcribed text
  final IncidentSeverity severity;

  // Victims
  final int personsAffected;
  final int injured;
  final int confirmedDeaths;

  // Status flags
  final bool medicalAssistanceProvided;
  final bool medicalAssistanceWaiting;
  final bool firePresent;
  final bool otherDanger;
  final String? otherDangerNote;

  // Vehicles involved (free text from AI or officer)
  final List<String> vehiclesInvolved;
  final String? additionalNotes;

  const Incident({
    required this.id,
    required this.reportedBy,
    required this.officerName,
    required this.officerBadge,
    required this.reportedAt,
    required this.latitude,
    required this.longitude,
    required this.locationDescription,
    this.photoUrl,
    this.aiDescription = '',
    this.voiceNote,
    this.severity = IncidentSeverity.medium,
    this.personsAffected = 0,
    this.injured = 0,
    this.confirmedDeaths = 0,
    this.medicalAssistanceProvided = false,
    this.medicalAssistanceWaiting = false,
    this.firePresent = false,
    this.otherDanger = false,
    this.otherDangerNote,
    this.vehiclesInvolved = const [],
    this.additionalNotes,
  });

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: json['id'],
        reportedBy: json['reported_by'],
        officerName: json['officer_name'] ?? '',
        officerBadge: json['officer_badge'] ?? '',
        reportedAt: DateTime.tryParse(json['reported_at'] ?? '') ?? DateTime.now(),
        latitude: (json['latitude'] ?? 0).toDouble(),
        longitude: (json['longitude'] ?? 0).toDouble(),
        locationDescription: json['location_description'] ?? '',
        photoUrl: json['photo_url'],
        aiDescription: json['ai_description'] ?? '',
        voiceNote: json['voice_note'],
        severity: IncidentSeverity.values.firstWhere(
          (e) => e.name == (json['severity'] ?? 'medium'),
          orElse: () => IncidentSeverity.medium,
        ),
        personsAffected: json['persons_affected'] ?? 0,
        injured: json['injured'] ?? 0,
        confirmedDeaths: json['confirmed_deaths'] ?? 0,
        medicalAssistanceProvided: json['medical_assistance_provided'] ?? false,
        medicalAssistanceWaiting: json['medical_assistance_waiting'] ?? false,
        firePresent: json['fire_present'] ?? false,
        otherDanger: json['other_danger'] ?? false,
        otherDangerNote: json['other_danger_note'],
        vehiclesInvolved: List<String>.from(json['vehicles_involved'] ?? []),
        additionalNotes: json['additional_notes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'reported_by': reportedBy,
        'officer_name': officerName,
        'officer_badge': officerBadge,
        'reported_at': reportedAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'location_description': locationDescription,
        'photo_url': photoUrl,
        'ai_description': aiDescription,
        'voice_note': voiceNote,
        'severity': severity.name,
        'persons_affected': personsAffected,
        'injured': injured,
        'confirmed_deaths': confirmedDeaths,
        'medical_assistance_provided': medicalAssistanceProvided,
        'medical_assistance_waiting': medicalAssistanceWaiting,
        'fire_present': firePresent,
        'other_danger': otherDanger,
        'other_danger_note': otherDangerNote,
        'vehicles_involved': vehiclesInvolved,
        'additional_notes': additionalNotes,
      };

  String get severityLabel {
    switch (severity) {
      case IncidentSeverity.low:
        return 'Faible';
      case IncidentSeverity.medium:
        return 'Moyen';
      case IncidentSeverity.high:
        return 'Grave';
      case IncidentSeverity.critical:
        return 'Critique';
    }
  }
}

// ─── Order (from control room) ───────────────────
class ControlOrder {
  final String id;
  final String toOfficerId;
  final String fromControlRoom;
  final String message;
  final String? targetLocation;
  final double? targetLat;
  final double? targetLng;
  final OrderPriority priority;
  final OrderStatus status;
  final DateTime issuedAt;
  final DateTime? acknowledgedAt;

  const ControlOrder({
    required this.id,
    required this.toOfficerId,
    required this.fromControlRoom,
    required this.message,
    this.targetLocation,
    this.targetLat,
    this.targetLng,
    this.priority = OrderPriority.routine,
    this.status = OrderStatus.pending,
    required this.issuedAt,
    this.acknowledgedAt,
  });

  factory ControlOrder.fromJson(Map<String, dynamic> json) => ControlOrder(
        id: json['id'],
        toOfficerId: json['to_officer_id'],
        fromControlRoom: json['from_control_room'] ?? 'Salle de Contrôle',
        message: json['message'],
        targetLocation: json['target_location'],
        targetLat: json['target_lat']?.toDouble(),
        targetLng: json['target_lng']?.toDouble(),
        priority: OrderPriority.values.firstWhere(
          (e) => e.name == (json['priority'] ?? 'routine'),
          orElse: () => OrderPriority.routine,
        ),
        status: OrderStatus.values.firstWhere(
          (e) => e.name == (json['status'] ?? 'pending'),
          orElse: () => OrderStatus.pending,
        ),
        issuedAt: DateTime.tryParse(json['issued_at'] ?? '') ?? DateTime.now(),
        acknowledgedAt: json['acknowledged_at'] != null
            ? DateTime.tryParse(json['acknowledged_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'to_officer_id': toOfficerId,
        'from_control_room': fromControlRoom,
        'message': message,
        'target_location': targetLocation,
        'target_lat': targetLat,
        'target_lng': targetLng,
        'priority': priority.name,
        'status': status.name,
        'issued_at': issuedAt.toIso8601String(),
        'acknowledged_at': acknowledgedAt?.toIso8601String(),
      };
}

// ─── Traffic Zone ─────────────────────────────────
class TrafficZone {
  final String id;
  final String name;
  final String road;
  final int congestionLevel; // 0-100
  final int officersPresent;
  final String recommendation;
  final bool needsReinforcement;

  const TrafficZone({
    required this.id,
    required this.name,
    required this.road,
    required this.congestionLevel,
    required this.officersPresent,
    required this.recommendation,
    this.needsReinforcement = false,
  });

  String get congestionLabel {
    if (congestionLevel < 30) return 'Fluide';
    if (congestionLevel < 60) return 'Modéré';
    if (congestionLevel < 80) return 'Dense';
    return 'Embouteillage';
  }
}

// ─── Placement Recommendation ──────────────────
class PlacementRecommendation {
  final String id;
  final String recommendedZone;
  final String reason;
  final RecommendationUrgency urgency;
  final double estimatedDistanceKm;
  final DateTime generatedAt;

  const PlacementRecommendation({
    required this.id,
    required this.recommendedZone,
    required this.reason,
    required this.urgency,
    this.estimatedDistanceKm = 0.0,
    required this.generatedAt,
  });

  factory PlacementRecommendation.fromJson(Map<String, dynamic> json) =>
      PlacementRecommendation(
        id: json['id'],
        recommendedZone: json['recommended_zone'],
        reason: json['reason'],
        urgency: RecommendationUrgency.values.firstWhere(
          (e) => e.name == (json['urgency'] ?? 'medium'),
          orElse: () => RecommendationUrgency.medium,
        ),
        estimatedDistanceKm: (json['estimated_distance_km'] ?? 0.0).toDouble(),
        generatedAt: DateTime.tryParse(json['generated_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'recommended_zone': recommendedZone,
        'reason': reason,
        'urgency': urgency.name,
        'estimated_distance_km': estimatedDistanceKm,
        'generated_at': generatedAt.toIso8601String(),
      };
}
