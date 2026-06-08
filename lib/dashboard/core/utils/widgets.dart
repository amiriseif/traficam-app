import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────
// SHARED WIDGETS — Production-grade, overflow-safe, responsive
// ─────────────────────────────────────────────────────────────────

// ── Staggered Fade-Slide entrance ────────────────────────────────
class StaggeredEntry extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDuration;

  const StaggeredEntry({
    super.key,
    required this.child,
    required this.index,
    this.baseDuration = const Duration(milliseconds: 60),
  });

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.baseDuration * widget.index, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ── Orange gradient CTA button ────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              height: 52,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                gradient: loading
                    ? null
                    : AppColors.orangeGradient,
                color: loading ? AppColors.bgCard : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: loading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.30),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Barlow',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Ghost/outline secondary button ───────────────────────────────
class GhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;

  const GhostButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.orange;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withOpacity(0.5)),
            color: c.withOpacity(0.06),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: c, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Barlow',
                  color: c,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Accent gradient button (login/primary action) ─────────────────
class AccentGradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;

  const AccentGradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              height: 52,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                gradient: loading
                    ? null
                    : AppColors.accentGradient,
                color: loading ? AppColors.bgCard : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: loading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.30),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Barlow',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Futuristic card with optional glow border ─────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? glowColor;
  final bool elevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glowColor,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasGlow = glowColor != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: elevated ? AppColors.bgCardHigh : AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasGlow
                  ? glowColor!.withOpacity(0.4)
                  : AppColors.border,
              width: hasGlow ? 1.5 : 1,
            ),
            boxShadow: [
              if (elevated)
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              if (hasGlow)
                BoxShadow(
                  color: glowColor!.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Section header with left accent line ──────────────────────────
class SectionLabel extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionLabel({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Status pill badge ──────────────────────────────────────────────
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
                ],
              ),
            ),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Barlow',
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated traffic congestion bar ───────────────────────────────
class CongestionBar extends StatefulWidget {
  final int level;
  final double height;

  const CongestionBar({super.key, required this.level, this.height = 5});

  @override
  State<CongestionBar> createState() => _CongestionBarState();
}

class _CongestionBarState extends State<CongestionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _barColor {
    if (widget.level < 30) return AppColors.success;
    if (widget.level < 60) return AppColors.warning;
    if (widget.level < 80) return AppColors.orange;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(widget.height),
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final w = constraints.maxWidth * (widget.level / 100) * _anim.value;
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: w.clamp(0.0, constraints.maxWidth),
                  decoration: BoxDecoration(
                    color: _barColor,
                    borderRadius: BorderRadius.circular(widget.height),
                    boxShadow: [
                      BoxShadow(
                        color: _barColor.withOpacity(0.4),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Pulsing microphone button ─────────────────────────────────────
class MicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onToggle;

  const MicButton({
    super.key,
    required this.isListening,
    required this.onToggle,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ring = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant MicButton old) {
    super.didUpdateWidget(old);
    if (widget.isListening) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final col = widget.isListening ? AppColors.danger : AppColors.orange;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              if (widget.isListening)
                Opacity(
                  opacity: 1 - _ring.value,
                  child: Transform.scale(
                    scale: 1 + _ring.value * 0.4,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: col.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              // Core button
              Transform.scale(
                scale: widget.isListening ? _scale.value : 1.0,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.isListening
                          ? [AppColors.danger, const Color(0xFFFF6B8A)]
                          : [AppColors.orangeDim, AppColors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: col.withOpacity(0.45),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Severity color helper ─────────────────────────────────────────
Color severityColor(String severity) {
  switch (severity) {
    case 'low':    return AppColors.success;
    case 'medium': return AppColors.warning;
    case 'high':   return AppColors.orange;
    case 'critical': return AppColors.danger;
    default:       return AppColors.textMuted;
  }
}

// ── Thin divider with label ────────────────────────────────────────
class LabeledDivider extends StatelessWidget {
  final String label;
  const LabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border, endIndent: 12)),
          Text(label, style: AppTextStyles.label),
          const Expanded(child: Divider(color: AppColors.border, indent: 12)),
        ],
      ),
    );
  }
}

// ── Status badge with optional pulsing animation ────────────────
class StatusBadge extends StatefulWidget {
  final String label;
  final Color color;
  final bool pulsing;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.pulsing = false,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.pulsing) {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);
      _pulse = Tween<double>(begin: 1.0, end: 1.15)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    if (widget.pulsing) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.15),
        border: Border.all(color: widget.color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.pulsing)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Barlow',
              color: widget.color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (widget.pulsing) {
      return ScaleTransition(scale: _pulse, child: badge);
    }
    return badge;
  }
}