import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/widgets.dart';
import '../../controllers/dashboard_controller.dart';

// ─────────────────────────────────────────────────────────────────
// DASHBOARD SCREEN — VIEW ONLY, delegates logic to controller
// ─────────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  final Officer officer;
  final VoidCallback onReportIncident;

  const DashboardScreen({
    super.key,
    required this.officer,
    required this.onReportIncident,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = DashboardController(officer: widget.officer)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          return _ctrl.loading
              ? const _LoadingState()
              : RefreshIndicator(
                  onRefresh: _ctrl.load,
                  color: AppColors.orange,
                  backgroundColor: AppColors.bgCard,
                  child: CustomScrollView(
                    slivers: [
                      _DashboardHeader(
                        officer: widget.officer,
                        isTablet: isTablet,
                        onReport: widget.onReportIncident,
                      ),
                      // Stats row
                      SliverToBoxAdapter(
                        child: StaggeredEntry(
                          index: 0,
                          child: _StatsRow(controller: _ctrl),
                        ),
                      ),
                      // Urgent order
                      if (_ctrl.pendingOrders.isNotEmpty)
                        SliverToBoxAdapter(
                          child: StaggeredEntry(
                            index: 1,
                            child: _UrgentOrderBanner(
                              order: _ctrl.pendingOrders.first,
                              onAcknowledge: () {
                                _ctrl.acknowledgeOrder(
                                    _ctrl.pendingOrders.first.id);
                              },
                            ),
                          ),
                        ),
                      // Placement recommendation
                      if (_ctrl.recommendation != null)
                        SliverToBoxAdapter(
                          child: StaggeredEntry(
                            index: 2,
                            child: _PlacementCard(
                                rec: _ctrl.recommendation!),
                          ),
                        ),
                      // Zones
                      SliverToBoxAdapter(
                        child: SectionLabel(
                          title: 'Zones de trafic',
                          trailing: Text(
                            '${_ctrl.zones.length} zones',
                            style: AppTextStyles.label,
                          ),
                        ),
                      ),
                      SliverList.separated(
                        itemCount: _ctrl.zones.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 0),
                        itemBuilder: (context, i) => StaggeredEntry(
                          index: i + 3,
                          child: _ZoneCard(zone: _ctrl.zones[i]),
                        ),
                      ),
                      const SliverToBoxAdapter(
                          child: SizedBox(height: 100)),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

// ── Loading skeleton ───────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.orange,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16),
          Text('Chargement...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ── App bar ────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final Officer officer;
  final bool isTablet;
  final VoidCallback onReport;

  const _DashboardHeader({
    required this.officer,
    required this.isTablet,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: isTablet ? 140 : 120,
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
                      // Logo mark
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: AppColors.orangeGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.orange.withOpacity(0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.local_police_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, ${officer.fullName.split(' ').first}',
                              style: AppTextStyles.displayMedium.copyWith(
                                fontSize: isTablet ? 22 : 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mat. ${officer.badgeNumber}  ·  ${officer.currentZone ?? "Tunis"}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: officer.statusLabel,
                        color: AppColors.success,
                        dot: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stats summary row ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final DashboardController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemW = (constraints.maxWidth - 24) / 3;
          return Row(
            children: [
              _StatChip(
                width: itemW,
                label: 'Zones',
                value: '${controller.zones.length}',
                color: AppColors.cobalt,
                icon: Icons.map_outlined,
              ),
              const SizedBox(width: 8),
              _StatChip(
                width: itemW,
                label: 'Critiques',
                value: '${controller.criticalZones}',
                color: AppColors.danger,
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(width: 8),
              _StatChip(
                width: itemW,
                label: 'Renforts',
                value: '${controller.reinforcementNeeded}',
                color: AppColors.orange,
                icon: Icons.person_add_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.width,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.numeric.copyWith(
                  color: color, fontSize: 22)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.label.copyWith(fontSize: 10),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Urgent order banner ───────────────────────────────────────────
class _UrgentOrderBanner extends StatelessWidget {
  final ControlOrder order;
  final VoidCallback onAcknowledge;

  const _UrgentOrderBanner({
    required this.order,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      glowColor: AppColors.danger,
      elevated: true,
      onTap: () => _showDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notification_important_rounded,
                        color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'ORDRE URGENT',
                      style: TextStyle(
                        fontFamily: 'Barlow',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${DateTime.now().difference(order.issuedAt).inMinutes} min',
                style: AppTextStyles.label,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(order.message, style: AppTextStyles.bodyLarge),
          const SizedBox(height: 4),
          if (order.targetLocation != null)
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.orange, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    order.targetLocation!,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAcknowledge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success.withOpacity(0.15),
                foregroundColor: AppColors.success,
                side: const BorderSide(color: AppColors.success, width: 1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Accuser réception — En route',
                style: TextStyle(
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderSheet(order: order, onAck: onAcknowledge),
    );
  }
}

class _OrderSheet extends StatelessWidget {
  final ControlOrder order;
  final VoidCallback onAck;
  const _OrderSheet({required this.order, required this.onAck});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('ORDRE DE MISSION', style: AppTextStyles.label),
          const SizedBox(height: 12),
          Text(order.message, style: AppTextStyles.bodyLarge),
          if (order.targetLocation != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.location_on,
                  color: AppColors.orange, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(order.targetLocation!,
                    style: AppTextStyles.bodyMedium),
              ),
            ]),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(label: 'En route', icon: Icons.near_me_rounded, onTap: () {
              Navigator.pop(context);
              onAck();
            }),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Placement recommendation card ────────────────────────────────
class _PlacementCard extends StatelessWidget {
  final PlacementRecommendation rec;
  const _PlacementCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final urgencyColor = switch (rec.urgency) {
      RecommendationUrgency.urgent => AppColors.danger,
      RecommendationUrgency.medium => AppColors.orange,
      RecommendationUrgency.low    => AppColors.success,
    };

    final urgencyLabel = switch (rec.urgency) {
      RecommendationUrgency.urgent => 'URGENT',
      RecommendationUrgency.medium => 'RECOMMANDÉ',
      RecommendationUrgency.low    => 'MAINTENIR',
    };

    return AppCard(
      glowColor: urgencyColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: urgencyColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.near_me_rounded,
                color: urgencyColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('PLACEMENT', style: AppTextStyles.label),
                    const SizedBox(width: 8),
                    StatusPill(label: urgencyLabel, color: urgencyColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(rec.recommendedZone, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(rec.reason, style: AppTextStyles.bodyMedium),
                if (rec.estimatedDistanceKm > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    '≈ ${rec.estimatedDistanceKm.toStringAsFixed(1)} km',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Zone card ─────────────────────────────────────────────────────
class _ZoneCard extends StatelessWidget {
  final TrafficZone zone;
  const _ZoneCard({required this.zone});

  Color get _congColor {
    final l = zone.congestionLevel;
    if (l < 30) return AppColors.success;
    if (l < 60) return AppColors.warning;
    if (l < 80) return AppColors.orange;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      glowColor: zone.needsReinforcement ? AppColors.danger : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(zone.name, style: AppTextStyles.titleLarge,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(
                '${zone.congestionLevel}%',
                style: AppTextStyles.titleMedium.copyWith(color: _congColor),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(zone.road, style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          CongestionBar(level: zone.congestionLevel),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text('${zone.officersPresent} agent(s)',
                  style: AppTextStyles.label),
              const Spacer(),
              StatusPill(label: zone.congestionLabel, color: _congColor),
            ],
          ),
          if (zone.needsReinforcement) ...[
            const SizedBox(height: 8),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.orange, size: 14),
                const SizedBox(width: 6),
                Text('Renfort recommandé',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }
}