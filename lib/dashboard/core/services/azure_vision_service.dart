import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// ─────────────────────────────────────────────────────────────────
/// GOOGLE GEMINI VISION SERVICE (REPLACING AZURE SEAMLESSLY)
/// ─────────────────────────────────────────────────────────────────
class AzureVisionService {
  static const String _apiKey = 'AIzaSyBTkuTpqFPCDdbNHzL9q7wH1PiBfjBrrV0';
  static const bool _useMock = false; 

  /// Analyzes image bytes and returns a structured incident description.
  Future<AzureVisionResult> analyzeIncidentPhoto(dynamic imageData) async {
    developer.log('📷 analyzeIncidentPhoto called with: $imageData');
    if (_useMock) {
      developer.log('🎭 Using MOCK analysis (not real API)');
      return _mockAnalysis();
    }
    
    developer.log('🌐 Using REAL API analysis');
    Uint8List bytes;
    if (imageData is File) {
      bytes = await imageData.readAsBytes();
    } else if (imageData is Uint8List) {
      bytes = imageData;
    } else {
      throw AzureVisionException('Invalid image data type');
    }
    
    return await _realAnalysis(bytes);
  }

  // ── REAL IMPLEMENTATION (Google Gemini 2.5 Flash) ──────────────────────
  Future<AzureVisionResult> _realAnalysis(Uint8List imageBytes) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
    );

    final base64Image = base64Encode(imageBytes);

    // Enforcing strict application/json configuration via generationConfig
    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": "Analyze this traffic accident image. You must return a JSON object matching this exact structure: "
                    "{"
                    "\"description\": \"Detailed description of the situation in French\","
                    "\"vehicles\": [\"vehicle 1\", \"vehicle 2\"],"
                    "\"is_accident\": true,"
                    "\"has_fire_smoke\": false,"
                    "\"has_people\": true"
                    "}"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": base64Image,
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json" // Forces pure JSON string output without backticks
      }
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw AzureVisionException(
          'Google Gemini API error: ${response.statusCode} ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    
    // Safely extract text payload
    String candidateText = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '{}';
    developer.log('📝 Raw API output: $candidateText');
    
    // Fallback cleanup (just in case edge cases bypass responseMimeType)
    if (candidateText.contains('```')) {
      candidateText = candidateText.replaceAll('```json', '').replaceAll('```', '').trim();
    }
    
    try {
      final Map<String, dynamic> structuredData = jsonDecode(candidateText) as Map<String, dynamic>;
      developer.log('✨ Parsed data successfully: $structuredData');

      return AzureVisionResult(
        rawCaption: structuredData['description'] ?? '',
        generatedDescription: structuredData['description'] ?? '',
        detectedVehicles: List<String>.from(structuredData['vehicles'] ?? []),
        likelyAccident: structuredData['is_accident'] ?? false,
        smokeFire: structuredData['has_fire_smoke'] ?? false,
        personsDetected: structuredData['has_people'] ?? false, 
        rawTags: [],
      );
    } catch (e) {
      developer.log('❌ Failed to parse JSON payload: $e');
      
      // Return a structured result safely embedding the error details inside rawCaption
      return AzureVisionResult(
        rawCaption: 'Error processing payload: $e',
        generatedDescription: 'Failed to process structure payload from AI model.',
        detectedVehicles: [],
        likelyAccident: false,
        smokeFire: false,
        personsDetected: false,
        rawTags: [],
      );
    }
  }

  // ── MOCK DATA ───────────────────────────────────────────────────────────
  AzureVisionResult _mockAnalysis() {
    final scenarios = [
      AzureVisionResult(
        rawCaption: 'Two vehicles collided at an intersection',
        generatedDescription:
            'Collision entre deux véhicules (voiture rouge et voiture blanche) '
            'détectée sur la route. Impact frontal apparent. '
            'Deux personnes visibles à proximité des véhicules.',
        detectedVehicles: ['Voiture rouge', 'Voiture blanche'],
        likelyAccident: true,
        smokeFire: false,
        personsDetected: true,
        rawTags: ['car', 'vehicle', 'accident', 'person', 'road'],
      ),
    ];

    final idx = Random().nextInt(scenarios.length);
    return scenarios[idx];
  }
}

// ── MODELS ───────────────────────────────────────────────────────────────
class AzureVisionResult {
  final String rawCaption;
  final String generatedDescription;
  final List<String> detectedVehicles;
  final bool likelyAccident;
  final bool smokeFire;
  final bool personsDetected;
  final List<String> rawTags;

  const AzureVisionResult({
    required this.rawCaption,
    required this.generatedDescription,
    required this.detectedVehicles,
    required this.likelyAccident,
    required this.smokeFire,
    required this.personsDetected,
    required this.rawTags,
  });
}

class AzureVisionException implements Exception {
  final String message;
  AzureVisionException(this.message);
  @override
  String toString() => 'AzureVisionException: $message';
}