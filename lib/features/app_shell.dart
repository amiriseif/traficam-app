import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dashboard/core/models/models.dart';
import '../dashboard/core/theme/app_theme.dart';
import '../dashboard/presentation/screens/dashboard_screen.dart';
import '../feed/presentation/screens/feed_screen.dart';
import '../incident/presentation/screens/incident_report_screen.dart';
import '../status/presentation/screens/status_screen.dart';

// ─────────────────────────────────────────────────────────────────
// APP SHELL — Bottom nav container with futuristic nav bar design
// ─────────────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  final Officer officer;
  const AppShell({super.key, required this.officer});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  void _openIncidentReport() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) =>
            IncidentReportScreen(officer: widget.officer),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardScreen(
        officer: widget.officer,
        onReportIncident: _openIncidentReport,
      ),
      const FeedScreen(),
      StatusScreen(officer: widget.officer),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _tab, children: screens),
      // ── FAB — centered incident report shortcut ──────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _IncidentFab(onTap: _openIncidentReport),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // ── Bottom Navigation Bar ─────────────────────────────────────
      bottomNavigationBar: _AppBottomBar(
        currentIndex: _tab,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tab = i);
        },
      ),
    );
  }
}

// ── Custom bottom bar with subtle top border glow ─────────────────
class _AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AppBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                iconOutlined: Icons.dashboard_outlined,
                label: 'Tableau',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              // Center spacer for FAB
              const Expanded(child: SizedBox()),
              _NavItem(
                icon: Icons.feed_rounded,
                iconOutlined: Icons.feed_outlined,
                label: 'Fil',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                iconOutlined: Icons.person_outline_rounded,
                label: 'Statut',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: selected
                  ? BoxDecoration(
                      color: AppColors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : null,
              child: Icon(
                selected ? icon : iconOutlined,
                color: selected ? AppColors.orange : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Barlow',
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
                color: selected ? AppColors.orange : AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating incident report button ───────────────────────────────
class _IncidentFab extends StatefulWidget {
  final VoidCallback onTap;
  const _IncidentFab({required this.onTap});

  @override
  State<_IncidentFab> createState() => _IncidentFabState();
}

class _IncidentFabState extends State<_IncidentFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 300), _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.orangeGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(0.50),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}