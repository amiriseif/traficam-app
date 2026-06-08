import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'dart:typed_data';

/// ─────────────────────────────────────────────────────────────────
/// SUPABASE SERVICE
/// Replace the URL and ANON KEY with your actual Supabase project values.
/// All methods are ready for production use.
/// ─────────────────────────────────────────────────────────────────
class SupabaseService {
  static const String _supabaseUrl = 'https://nqwldumrmksaiyyomiaz.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_pgCPWbnzXN5dN4U61CDQ7w_WPAPo-jb';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  // ── AUTH ──────────────────────────────────────────────────────────

  /// Sign in with badge number (email) + password
  Future<AuthResponse> signIn({
    required String badgeNumber,
    required String password,
  }) async {
    // Convention: badge@trafficam.tn as email
    final email = '$badgeNumber@trafficam.tn';
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ── OFFICER PROFILE ───────────────────────────────────────────────

  Future<Officer?> getOfficerProfile(String userId) async {
    final response = await client
        .from('officers')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Officer.fromJson(response);
  }

  Future<void> updateOfficerStatus({
    required String officerId,
    required OfficerStatus status,
    double? latitude,
    double? longitude,
    String? currentZone,
  }) async {
    await client.from('officers').update({
      'status': status.name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (currentZone != null) 'current_zone': currentZone,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', officerId);
  }

  // ── INCIDENTS ─────────────────────────────────────────────────────

  Future<String> createIncident(Incident incident) async {
    final response = await client
        .from('incidents')
        .insert(incident.toJson())
        .select('id')
        .single();
    return response['id'];
  }

  Future<List<Incident>> getRecentIncidents({int limit = 20}) async {
    final response = await client
        .from('incidents')
        .select()
        .order('reported_at', ascending: false)
        .limit(limit);
    return (response as List).map((e) => Incident.fromJson(e)).toList();
  }

  /// Real-time stream of all incidents
  Stream<List<Map<String, dynamic>>> incidentsStream() {
    return client
        .from('incidents')
        .stream(primaryKey: ['id'])
        .order('reported_at', ascending: false)
        .limit(30);
  }

  // ── ORDERS ────────────────────────────────────────────────────────

  Future<List<ControlOrder>> getOrdersForOfficer(String officerId) async {
    final response = await client
        .from('orders')
        .select()
        .eq('to_officer_id', officerId)
        .order('issued_at', ascending: false);
    return (response as List).map((e) => ControlOrder.fromJson(e)).toList();
  }

  Future<void> acknowledgeOrder(String orderId) async {
    await client.from('orders').update({
      'status': OrderStatus.acknowledged.name,
      'acknowledged_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  /// Real-time stream of orders for this officer
  Stream<List<Map<String, dynamic>>> ordersStream(String officerId) {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('to_officer_id', officerId)
        .order('issued_at', ascending: false);
  }

  // ── PHOTO UPLOAD ──────────────────────────────────────────────────

  /// Upload incident photo to Supabase Storage and return public URL
  Future<String?> uploadIncidentPhoto({
    required String incidentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final path = 'incidents/$incidentId/$fileName';
    await client.storage.from('incident-photos').uploadBinary(
          path,
          Uint8List.fromList(fileBytes),
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return client.storage.from('incident-photos').getPublicUrl(path);
  }
}
