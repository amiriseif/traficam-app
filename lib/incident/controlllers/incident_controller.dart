import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../dashboard/core/models/models.dart';
import '../../dashboard/core/services/azure_vision_service.dart';
import '../../dashboard/core/services/speech_service.dart';
import '../../dashboard/core/services/location_service.dart';
import '../../dashboard/core/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────────────────────────
// INCIDENT CONTROLLER — All logic for incident report screen
// ─────────────────────────────────────────────────────────────────
class IncidentController extends ChangeNotifier {
  IncidentController({required this.officer}) {
    _loadLocation();
    speechService.initialize();
  }

  final Officer officer;
  final _vision    = AzureVisionService();
  final speechService = SpeechService();
  final _location  = LocationService();
  final _supabase  = SupabaseService();

  // ── State ───────────────────────────────────────────────────────
  File? photo;
  AzureVisionResult? visionResult;
  bool analyzingPhoto = false;

  bool isListening = false;
  String voiceText = '';
  SpeechLocale speechLocale = SpeechLocale.french;

  int personsAffected = 0;
  int injured = 0;
  int confirmedDeaths = 0;
  bool medicalProvided = false;
  bool medicalWaiting  = false;
  bool firePresent     = false;
  bool otherDanger     = false;
  IncidentSeverity severity = IncidentSeverity.medium;

  String locationDescription = 'Récupération en cours...';
  Position? _position;
  bool loadingLocation = false;
  bool submitting = false;
  String? submitError;
  bool submitted = false;

  // ── Location ────────────────────────────────────────────────────
  Future<void> _loadLocation() async {
    loadingLocation = true;
    notifyListeners();
    _position = await _location.getCurrentPosition();
    if (_position != null) {
      locationDescription = await _location.getAddressFromCoords(
          _position!.latitude, _position!.longitude);
    } else {
      locationDescription = 'Localisation indisponible';
    }
    loadingLocation = false;
    notifyListeners();
  }

  Future<void> refreshLocation() => _loadLocation();

  // ── Photo + Vision ──────────────────────────────────────────────
  Future<void> setPhoto(File file) async {    developer.log('🎬📸 PHOTO SELECTED: ${file.path}');    photo = file;
    visionResult = null;
    analyzingPhoto = true;
    notifyListeners();
    try {
      developer.log('🖼️  Starting vision analysis...');
      visionResult = await _vision.analyzeIncidentPhoto(file);
      developer.log('✅ Vision result: ${visionResult?.generatedDescription}');
      if (visionResult!.smokeFire)      firePresent = true;
      if (visionResult!.likelyAccident) severity = IncidentSeverity.high;
    } catch (e) {
      developer.log('❌ Vision error: $e', error: e);
      visionResult = null;
    }
    analyzingPhoto = false;
    notifyListeners();
  }

  // ── Speech ──────────────────────────────────────────────────────
  Future<void> toggleListening() async {
    if (isListening) {
      await speechService.stopListening(
          onStatusChange: (v) { isListening = v; notifyListeners(); });
    } else {
      await speechService.setLocale(speechLocale);
      await speechService.startListening(
        onResult: (t) { voiceText = t; notifyListeners(); },
        onStatusChange: (v) { isListening = v; notifyListeners(); },
      );
    }
  }

  void setSpeechLocale(SpeechLocale l) {
    speechLocale = l;
    notifyListeners();
  }

  void clearVoice() { voiceText = ''; notifyListeners(); }

  // ── Setters (counters / flags) ──────────────────────────────────
  void setPersonsAffected(int v) { personsAffected = v; notifyListeners(); }
  void setInjured(int v)         { injured = v;         notifyListeners(); }
  void setDeaths(int v)          { confirmedDeaths = v; notifyListeners(); }

  void toggleMedicalProvided() {
    medicalProvided = !medicalProvided;
    if (medicalProvided) medicalWaiting = false;
    notifyListeners();
  }

  void toggleMedicalWaiting() {
    medicalWaiting = !medicalWaiting;
    if (medicalWaiting) medicalProvided = false;
    notifyListeners();
  }

  void toggleFire()        { firePresent  = !firePresent;  notifyListeners(); }
  void toggleOtherDanger() { otherDanger  = !otherDanger;  notifyListeners(); }

  void setSeverity(IncidentSeverity s) { severity = s; notifyListeners(); }

  // ── Submit ──────────────────────────────────────────────────────
  Future<void> submit() async {
    submitting = true;
    submitError = null;
    notifyListeners();

    final pos = await _location.getCurrentPosition();
    final incident = Incident(
      id: const Uuid().v4(),
      reportedBy: officer.id,
      officerName: officer.fullName,
      officerBadge: officer.badgeNumber,
      reportedAt: DateTime.now(),
      latitude: pos?.latitude ?? 36.8065,
      longitude: pos?.longitude ?? 10.1815,
      locationDescription: locationDescription,
      aiDescription: visionResult?.generatedDescription ?? '',
      voiceNote: voiceText.isNotEmpty ? voiceText : null,
      severity: severity,
      personsAffected: personsAffected,
      injured: injured,
      confirmedDeaths: confirmedDeaths,
      medicalAssistanceProvided: medicalProvided,
      medicalAssistanceWaiting: medicalWaiting,
      firePresent: firePresent,
      otherDanger: otherDanger,
      vehiclesInvolved: visionResult?.detectedVehicles ?? [],
    );

    try {
      await _supabase.createIncident(incident);
      submitted = true;
    } catch (e) {
      submitError = 'Erreur lors de l\'envoi: $e';
    }
    submitting = false;
    notifyListeners();
  }
}