import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../dashboard/core/models/models.dart';

import '../../../dashboard/core/theme/app_theme.dart';
import '../../../dashboard/core/utils/widgets.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  final List<Incident> _incidents = _mockIncidents();

  // In production: use Supabase realtime stream
  // Stream<List<Map<String, dynamic>>> get _stream =>
  //     _supabase.incidentsStream();

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
            'Collision entre deux véhicules (voiture rouge et blanche). Impact frontal. Deux personnes visibles.',
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
        aiDescription: 'Embouteillage important, véhicule en panne bloquant la voie rapide.',
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
            'Véhicule renversé sur le bord de la route. Fumée légère.',
        severity: IncidentSeverity.critical,
        personsAffected: 2,
        injured: 2,
        confirmedDeaths: 0,
        firePresent: true,
        medicalAssistanceProvided: true,
        vehiclesInvolved: ['Voiture'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text(
          'Fil des Incidents',
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.midnight,
        automaticallyImplyLeading: false,
        actions: const [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: StatusBadge(
                label: 'EN DIRECT',
                color: AppColors.statusGreen,
                pulsing: true,
              ),
            ),
          ),
        ],
      ),
      body: _incidents.isEmpty
          ? const Center(
              child: Text(
                'Aucun incident signalé',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _incidents.length,
              itemBuilder: (context, i) => _IncidentCard(incident: _incidents[i]),
            ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;
  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final color = severityColor(incident.severity.name);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  incident.severityLabel.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  timeago.format(incident.reportedAt, locale: 'fr'),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              incident.aiDescription.isNotEmpty
                  ? incident.aiDescription
                  : incident.locationDescription,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.textMuted, size: 13),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    incident.locationDescription,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.badge_outlined,
                    color: AppColors.textMuted, size: 13),
                const SizedBox(width: 4),
                Text(
                  '${incident.officerName} (${incident.officerBadge})',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                if (incident.personsAffected > 0) ...[
                  const Icon(Icons.people_outline,
                      color: AppColors.textMuted, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    '${incident.personsAffected}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                ],
                if (incident.firePresent)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.local_fire_department,
                        color: AppColors.statusRed, size: 14),
                  ),
                if (incident.medicalAssistanceWaiting)
                  const Icon(Icons.emergency,
                      color: AppColors.statusAmber, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _IncidentDetailSheet(incident: incident),
    );
  }
}

class _IncidentDetailSheet extends StatelessWidget {
  final Incident incident;
  const _IncidentDetailSheet({required this.incident});

  @override
  Widget build(BuildContext context) {
    final color = severityColor(incident.severity.name);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          StatusBadge(
              label: incident.severityLabel.toUpperCase(), color: color),
          const SizedBox(height: 12),
          Text(
            incident.aiDescription.isNotEmpty
                ? incident.aiDescription
                : incident.locationDescription,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.location_on,
              label: incident.locationDescription,
              color: AppColors.accent),
          _DetailRow(
              icon: Icons.badge_outlined,
              label:
                  '${incident.officerName} — Matricule ${incident.officerBadge}',
              color: AppColors.textMuted),
          _DetailRow(
              icon: Icons.access_time,
              label: incident.reportedAt.toString().substring(0, 16),
              color: AppColors.textMuted),
          if (incident.personsAffected > 0) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.surface),
            const SizedBox(height: 8),
            Row(
              children: [
                _Stat(
                    label: 'Touchées',
                    value: '${incident.personsAffected}',
                    color: AppColors.statusBlue),
                _Stat(
                    label: 'Blessés',
                    value: '${incident.injured}',
                    color: AppColors.statusAmber),
                _Stat(
                    label: 'Décès',
                    value: '${incident.confirmedDeaths}',
                    color: AppColors.statusRed),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (incident.firePresent)
            const StatusBadge(
                label: '🔥 Incendie signalé', color: AppColors.statusRed),
          if (incident.medicalAssistanceWaiting)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: StatusBadge(
                  label: '⏳ Assistance médicale en attente',
                  color: AppColors.statusAmber),
            ),
          if (incident.medicalAssistanceProvided)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: StatusBadge(
                  label: '✅ Assistance médicale fournie',
                  color: AppColors.statusGreen),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DetailRow(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
