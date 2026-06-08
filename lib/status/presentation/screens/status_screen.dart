import 'package:flutter/material.dart';
import '../../../dashboard/core/models/models.dart';
import '../../../dashboard/core/theme/app_theme.dart';
import '../../../dashboard/core/utils/widgets.dart';

// ─────────────────────────────────────────────────────────────────
// STATUS SCREEN — Officer status and personal information
// ─────────────────────────────────────────────────────────────────
class StatusScreen extends StatefulWidget {
  final Officer officer;
  const StatusScreen({super.key, required this.officer});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.bgSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy, AppColors.bgSurface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.orangeGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.orange.withOpacity(0.35),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.officer.fullName,
                                    style: AppTextStyles.displayMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Mat. ${widget.officer.badgeNumber}',
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Status overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut Actuel',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.success.withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.officer.statusLabel,
                              style: AppTextStyles.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              _formatLastSeen(widget.officer.lastSeen),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: AppColors.orange, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.officer.currentZone ?? 'Tunis',
                                style: AppTextStyles.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Officer details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations Personnelles',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Numéro de Matricule',
                    value: widget.officer.badgeNumber,
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Téléphone',
                    value: widget.officer.phoneNumber,
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.info_outline,
                    label: 'Statut',
                    value: widget.officer.statusLabel,
                  ),
                ],
              ),
            ),
          ),
          // Coordinates
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Position GPS',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (widget.officer.latitude != null &&
                      widget.officer.longitude != null)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: AppColors.orange, size: 16),
                              const SizedBox(width: 8),
                              const Text('Latitude',
                                  style: AppTextStyles.label),
                              const Spacer(),
                              Text(
                                widget.officer.latitude!
                                    .toStringAsFixed(6),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: AppColors.orange, size: 16),
                              const SizedBox(width: 8),
                              const Text('Longitude',
                                  style: AppTextStyles.label),
                              const Spacer(),
                              Text(
                                widget.officer.longitude!
                                    .toStringAsFixed(6),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      child: Center(
                        child: Text(
                          'Position GPS non disponible',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.orange, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.label),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}