import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/match.dart';

/// Provider for MatchApiRepository
final matchApiRepositoryProvider = Provider<MatchApiRepository>((ref) {
  return MatchApiRepository();
});

/// Repository for Match endpoints on NestJS backend
/// Note: Matches can be stored in backend, but messages are in Firebase
class MatchApiRepository {
  final ApiService _apiService;

  MatchApiRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Record a swipe action
  Future<void> recordSwipe({
    required String targetPetId,
    required String action, // 'like', 'pass', 'superLike'
  }) async {
    await _apiService.post(
      '/swipes',
      body: {
        'targetPetId': targetPetId,
        'action': action,
      },
    );
  }

  /// Get all matches for current user
  Future<List<Match>> getMatches() async {
    final response = await _apiService.get('/matches');
    return (response as List).map((json) => Match.fromJson(json)).toList();
  }

  /// Get a specific match
  Future<Match> getMatch(String matchId) async {
    final response = await _apiService.get('/matches/$matchId');
    return Match.fromJson(response);
  }

  /// Check if a swipe resulted in a match
  Future<Match?> checkMatch(String targetPetId) async {
    final response = await _apiService.get('/matches/check/$targetPetId');
    return response != null ? Match.fromJson(response) : null;
  }

  /// Unmatch (deactivate match)
  Future<void> unmatch(String matchId) async {
    await _apiService.delete('/matches/$matchId');
  }

  /// Get swipe history
  Future<List<dynamic>> getSwipeHistory() async {
    final response = await _apiService.get('/swipes/history');
    return response as List;
  }
}
