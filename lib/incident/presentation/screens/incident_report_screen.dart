import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../dashboard/core/models/models.dart';
import '../../../dashboard/core/services/azure_vision_service.dart';
import '../../../dashboard/core/services/speech_service.dart';

import '../../../dashboard/core/theme/app_theme.dart';
import '../../../dashboard/core/utils/widgets.dart';
import '../../../incident/controlllers/incident_controller.dart';

// ─────────────────────────────────────────────────────────────────
// INCIDENT REPORT SCREEN — VIEW only, logic in IncidentController
// ─────────────────────────────────────────────────────────────────
class IncidentReportScreen extends StatefulWidget {
  final Officer officer;
  const IncidentReportScreen({super.key, required this.officer});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  late final IncidentController _ctrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _ctrl = IncidentController(officer: widget.officer)
      ..addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    
    if (_ctrl.submitted) {
      _showSuccessDialog();
      return;
    }
    
    if (_ctrl.submitError != null) {
      _showErrorDialog(_ctrl.submitError!);
    }
    
    setState(() {});
  }

  // Pop-up en cas de succès
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // L'utilisateur doit obligatoirement cliquer sur le bouton
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
              SizedBox(width: 10),
              Text(
                'Succès',
                style: TextStyle(
                  fontFamily: 'Barlow',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Incident signalé avec succès.',
            style: TextStyle(fontFamily: 'Barlow', color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Ferme le pop-up
                Navigator.pop(context);       // Quitte l'écran de rapport
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Barlow',
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Pop-up en cas d'erreur
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_rounded, color: AppColors.danger, size: 24),
              SizedBox(width: 10),
              Text(
                'Erreur',
                style: TextStyle(
                  fontFamily: 'Barlow',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(fontFamily: 'Barlow', color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Ferme juste le pop-up
              child: const Text(
                'Fermer',
                style: TextStyle(
                  fontFamily: 'Barlow',
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _ctrl
      ..removeListener(_onControllerUpdate)
      ..dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final xf = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 85, maxWidth: 1280);
    if (xf == null) return;
    await _ctrl.setPhoto(File(xf.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Signaler un Incident',
            style: AppTextStyles.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _ctrl.submitting ? null : _ctrl.submit,
              child: _ctrl.submitting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: AppColors.orange, strokeWidth: 2))
                  : const Text('Envoyer',
                      style: TextStyle(
                        fontFamily: 'Barlow',
                        color: AppColors.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      )),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              StaggeredEntry(index: 0, child: _PhotoSection(
                  ctrl: _ctrl, onPickPhoto: _pickPhoto)),
              if (_ctrl.visionResult != null)
                StaggeredEntry(index: 1,
                    child: _VisionResultCard(result: _ctrl.visionResult!)),
              StaggeredEntry(index: 2,
                  child: _LocationSection(ctrl: _ctrl)),
              StaggeredEntry(index: 3,
                  child: _VoiceSection(ctrl: _ctrl)),
              StaggeredEntry(index: 4,
                  child: _SeveritySection(ctrl: _ctrl)),
              StaggeredEntry(index: 5,
                  child: _VictimsSection(ctrl: _ctrl)),
              StaggeredEntry(index: 6,
                  child: _FlagsSection(ctrl: _ctrl)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: PrimaryButton(
                  label: 'Envoyer le rapport',
                  icon: Icons.send_rounded,
                  loading: _ctrl.submitting,
                  onTap: _ctrl.submit,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Photo capture section ─────────────────────────────────────────
class _PhotoSection extends StatelessWidget {
  final IncidentController ctrl;
  final VoidCallback onPickPhoto;
  const _PhotoSection({required this.ctrl, required this.onPickPhoto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: onPickPhoto,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: ctrl.photo != null ? 210 : 150,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ctrl.photo != null
                  ? AppColors.orange.withOpacity(0.45)
                  : AppColors.border,
              width: ctrl.photo != null ? 1.5 : 1,
            ),
          ),
          child: ctrl.photo != null
              ? Stack(fit: StackFit.expand, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: kIsWeb
                        ? Container(
                            color: AppColors.bgCard,
                            child: const Center(
                              child: Text(
                                'Image capturée\n(affichage web)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Image.file(ctrl.photo!, fit: BoxFit.cover),
                  ),
                  if (ctrl.analyzingPhoto)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: AppColors.orange, strokeWidth: 2.5),
                          SizedBox(height: 14),
                          Text('Analyse IA en cours...',
                              style: AppTextStyles.titleMedium),
                        ],
                      ),
                    ),
                  Positioned(
                    bottom: 10, right: 10,
                    child: GestureDetector(
                      onTap: onPickPhoto,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.bg.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                color: AppColors.orange, size: 13),
                            SizedBox(width: 5),
                            Text('Reprendre',
                                style: TextStyle(
                                  fontFamily: 'Barlow',
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ])
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withOpacity(0.3),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 12),
                    const Text('Photographier l\'incident',
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    const Text('L\'IA analysera automatiquement',
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── AI Vision result card ─────────────────────────────────────────
class _VisionResultCard extends StatelessWidget {
  final AzureVisionResult result;
  const _VisionResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      glowColor: AppColors.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.info, size: 15),
              const SizedBox(width: 7),
              Text('ANALYSE AZURE VISION',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.info, letterSpacing: 1.2)),
              const Spacer(),
              if (result.likelyAccident)
                StatusPill(label: 'Accident', color: AppColors.danger),
            ],
          ),
          const SizedBox(height: 10),
          Text(result.generatedDescription, style: AppTextStyles.bodyLarge),
          if (result.detectedVehicles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: result.detectedVehicles
                  .map((v) => Chip(
                        label: Text(v),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          if (result.smokeFire) ...[
            const SizedBox(height: 10),
            StatusPill(
              label: '⚠  Fumée / Feu détecté',
              color: AppColors.danger,
              dot: true,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Location section ─────────────────────────────────────────────
class _LocationSection extends StatelessWidget {
  final IncidentController ctrl;
  const _LocationSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.orange, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ctrl.loadingLocation
                ? Row(children: [
                    const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                            color: AppColors.orange, strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Text('Localisation...', style: AppTextStyles.bodyMedium),
                  ])
                : Text(ctrl.locationDescription, style: AppTextStyles.bodyLarge),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textMuted, size: 18),
            onPressed: ctrl.refreshLocation,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ── Voice dictation section ───────────────────────────────────────
class _VoiceSection extends StatelessWidget {
  final IncidentController ctrl;
  const _VoiceSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DESCRIPTION VOCALE', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: SpeechLocale.values.map((loc) {
              final sel = ctrl.speechLocale == loc;
              return GestureDetector(
                onTap: () => ctrl.setSpeechLocale(loc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.orange.withOpacity(0.15)
                        : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel
                            ? AppColors.orange.withOpacity(0.5)
                            : AppColors.border),
                  ),
                  child: Text(
                    loc.label,
                    style: TextStyle(
                      fontFamily: 'Barlow',
                      color: sel
                          ? AppColors.orange
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MicButton(
                isListening: ctrl.isListening,
                onToggle: ctrl.toggleListening,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(minHeight: 54),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ctrl.isListening
                          ? AppColors.danger.withOpacity(0.4)
                          : AppColors.border,
                    ),
                  ),
                  child: ctrl.voiceText.isEmpty
                      ? Text(
                          ctrl.isListening
                              ? 'Écoute en cours...'
                              : 'Appuyer sur le micro pour dicter',
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic),
                        )
                      : Text(ctrl.voiceText, style: AppTextStyles.bodyLarge),
                ),
              ),
            ],
          ),
          if (ctrl.voiceText.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: ctrl.clearVoice,
              child: Text('Effacer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    decoration: TextDecoration.underline,
                    color: AppColors.textMuted,
                  )),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Severity selector ─────────────────────────────────────────────
class _SeveritySection extends StatelessWidget {
  final IncidentController ctrl;
  const _SeveritySection({required this.ctrl});

  static const _labels = {
    IncidentSeverity.low: 'Faible',
    IncidentSeverity.medium: 'Moyen',
    IncidentSeverity.high: 'Grave',
    IncidentSeverity.critical: 'Critique',
  };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GRAVITÉ', style: AppTextStyles.label),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final w = (constraints.maxWidth - 12) / 4;
              return Row(
                children: IncidentSeverity.values.map((s) {
                  final sel = ctrl.severity == s;
                  final col = severityColor(s.name);
                  return Padding(
                    padding: EdgeInsets.only(
                        right: s != IncidentSeverity.critical ? 4 : 0),
                    child: GestureDetector(
                      onTap: () => ctrl.setSeverity(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: w,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? col.withOpacity(0.15)
                              : AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel ? col : AppColors.border,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          _labels[s]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Barlow',
                            color: sel ? col : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Victims counters ──────────────────────────────────────────────
class _VictimsSection extends StatelessWidget {
  final IncidentController ctrl;
  const _VictimsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PERSONNES IMPLIQUÉES', style: AppTextStyles.label),
          const SizedBox(height: 14),
          _Counter(
            label: 'Personnes touchées',
            icon: Icons.people_outline_rounded,
            color: AppColors.info,
            value: ctrl.personsAffected,
            onChanged: ctrl.setPersonsAffected,
          ),
          const SizedBox(height: 10),
          _Counter(
            label: 'Blessés',
            icon: Icons.local_hospital_outlined,
            color: AppColors.warning,
            value: ctrl.injured,
            onChanged: ctrl.setInjured,
          ),
          const SizedBox(height: 10),
          _Counter(
            label: 'Décès confirmés',
            icon: Icons.dangerous_outlined,
            color: AppColors.danger,
            value: ctrl.confirmedDeaths,
            onChanged: ctrl.setDeaths,
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  const _Counter({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyLarge),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepBtn(
                icon: Icons.remove_rounded,
                active: value > 0,
                onTap: () => onChanged((value - 1).clamp(0, 99)),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(color: color),
                ),
              ),
              _StepBtn(
                icon: Icons.add_rounded,
                active: true,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active
              ? AppColors.bgCardHigh
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon,
            color: active ? AppColors.textPrimary : AppColors.textMuted,
            size: 16),
      ),
    );
  }
}

// ── Situation flags ────────────────────────────────────────────────
class _FlagsSection extends StatelessWidget {
  final IncidentController ctrl;
  const _FlagsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SITUATION', style: AppTextStyles.label),
          const SizedBox(height: 10),
          _Flag(
            label: 'Assistance médicale fournie',
            icon: Icons.medical_services_outlined,
            color: AppColors.success,
            active: ctrl.medicalProvided,
            onTap: ctrl.toggleMedicalProvided,
          ),
          _Flag(
            label: 'Assistance médicale en attente',
            icon: Icons.emergency_rounded,
            color: AppColors.warning,
            active: ctrl.medicalWaiting,
            onTap: ctrl.toggleMedicalWaiting,
          ),
          _Flag(
            label: 'Incendie / Fumée présents',
            icon: Icons.local_fire_department_outlined,
            color: AppColors.danger,
            active: ctrl.firePresent,
            onTap: ctrl.toggleFire,
          ),
          _Flag(
            label: 'Autre danger (gaz, glissement…)',
            icon: Icons.warning_amber_rounded,
            color: AppColors.orange,
            active: ctrl.otherDanger,
            onTap: ctrl.toggleOtherDanger,
          ),
        ],
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _Flag({
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color.withOpacity(0.35) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: active ? color : AppColors.textMuted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: active ? color : AppColors.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? color : AppColors.border,
                ),
              ),
              child: active
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}