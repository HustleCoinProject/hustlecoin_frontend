import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/auth_tokens.dart';
import '../models/user.dart';
import '../models/level_status.dart';
import '../models/inventory_item.dart';
import '../models/task.dart';
import '../models/shop_item.dart';
import '../models/leaderboard_entry.dart';
import '../models/quiz_question.dart';
import '../models/land_tile_info.dart';
import '../models/my_land_tiles.dart';
import '../models/land_claim_status.dart';
import '../models/land_claim_response.dart';
import '../models/tap_response.dart';

// This class handles all communication with your backend API.

class ApiRepository {
  final String _baseUrl =
      "http://10.147.59.235:8000"; // "https://hustlecoin-backend.fly.dev";
  String? _accessToken;
  String? _refreshToken;

  // Callback function to notify when tokens are refreshed
  Function(AuthTokens)? _onTokensRefreshed;

  void setTokens(String? accessToken, String? refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void setOnTokensRefreshed(Function(AuthTokens)? callback) {
    _onTokensRefreshed = callback;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // Helper method to make authenticated requests with automatic token refresh
  Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function() requestFunction,
  ) async {
    try {
      final response = await requestFunction();

      // If we get a 401 and have a refresh token, try to refresh
      if (response.statusCode == 401 && _refreshToken != null) {
        print("DEBUG: Access token expired, attempting refresh...");

        try {
          // Attempt to refresh the token
          final newTokens = await _refreshAccessToken();

          // Update tokens
          setTokens(newTokens.accessToken, newTokens.refreshToken);

          // Notify the auth controller about the new tokens
          if (_onTokensRefreshed != null) {
            _onTokensRefreshed!(newTokens);
          }

          // Retry the original request with the new token
          print("DEBUG: Token refreshed successfully, retrying request...");
          return await requestFunction();
        } catch (refreshError) {
          print("DEBUG: Token refresh failed: $refreshError");
          // If refresh fails, the token is invalid, so rethrow the original 401
          throw Exception('Authentication failed: ${response.body}');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // --- Auth ---
  Future<AuthTokens> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return AuthTokens.fromJson(responseData);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<AuthTokens> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return AuthTokens.fromJson(responseData);
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  Future<User> register(
    String email,
    String password,
    String username,
    String hustleKey, // This should be the English key
    String lang,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/register'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
        'username': username,
        'current_hustle': hustleKey, // Send the key (English name)
        'language': lang,
      }),
    );
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // --- User ---
  Future<User> getMe() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(Uri.parse('$_baseUrl/api/users/me'), headers: _headers),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user data: ${response.body}');
    }
  }

  Future<void> updateProfile({
    String? email,
    String? currentPassword,
    String? newPassword,
    String? language,
    String? currentHustle,
  }) async {
    final Map<String, dynamic> body = {};

    if (email != null) body['email'] = email;
    if (currentPassword != null) body['current_password'] = currentPassword;
    if (newPassword != null) body['new_password'] = newPassword;
    if (language != null) body['language'] = language;
    if (currentHustle != null)
      body['current_hustle'] = currentHustle; // This should be the key

    final response = await _makeAuthenticatedRequest(
      () => http.put(
        Uri.parse('$_baseUrl/api/users/profile'),
        headers: _headers,
        body: json.encode(body),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<List<InventoryItem>> getInventory() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/users/inventory'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => InventoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch inventory');
    }
  }

  // --- Hustles & Levels ---
  Future<Map<String, Map<String, String>>> getAllHustles() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/hustles/all'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map(
        (key, value) => MapEntry(
          key,
          Map<String, String>.from(value as Map<String, dynamic>),
        ),
      );
    } else {
      throw Exception('Failed to fetch hustles');
    }
  }

  Future<Map<String, String>> getAvailableHustles() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/hustles/available'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Map<String, String>.from(data);
    } else {
      throw Exception('Failed to fetch available hustles');
    }
  }

  Future<LevelStatus> getLevelStatus() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/hustles/level-status'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      return LevelStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch level status');
    }
  }

  // Level upgrade API
  Future<Map<String, dynamic>> levelUpgrade() async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/hustles/level-upgrade'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to upgrade level: ${response.body}');
    }
  }

  // Select new hustle API
  Future<void> selectHustle(String hustleKey) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/hustles/select'),
        headers: _headers,
        body: json.encode({
          'hustle_name': hustleKey,
        }), // Send the key (English name)
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to select hustle: ${response.body}');
    }
  }

  // --- Tasks & Shop ---
  Future<List<Task>> getAllTasks() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(Uri.parse('$_baseUrl/api/tasks/all'), headers: _headers),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Task.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  Future<void> completeTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    final Map<String, dynamic> body = {'task_id': taskId};
    if (payload != null) {
      body['payload'] = payload;
    }
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/tasks/complete'),
        headers: _headers,
        body: json.encode(body),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to complete task: ${response.body}');
    }
  }

  Future<List<ShopItem>> getShopItems() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(Uri.parse('$_baseUrl/api/shop/items'), headers: _headers),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ShopItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch shop items');
    }
  }

  Future<void> purchaseItem(String itemId, int quantity) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/shop/purchase'),
        headers: _headers,
        body: json.encode({'item_id': itemId, 'quantity': quantity}),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to purchase item: ${response.body}');
    }
  }

  // --- Server Time ---
  Future<DateTime> getServerTime() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(Uri.parse('$_baseUrl/api/timestamp'), headers: _headers),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DateTime.parse(data['timestamp']);
    } else {
      throw Exception('Failed to fetch server time: ${response.body}');
    }
  }

  // --- Leaderboard ---
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/leaderboard'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => LeaderboardEntry.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch leaderboard');
    }
  }

  Future<QuizQuestion> fetchQuizQuestion() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/tasks/quiz/fetch'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      return QuizQuestion.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch quiz question: ${response.body}');
    }
  }

  // --- Land System ---
  Future<List<LandTileInfo>> getTilesInBbox(String bbox) async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/land/tiles?bbox=$bbox'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => LandTileInfo.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch land tiles: ${response.body}');
    }
  }

  Future<List<MyLandTile>> getMyLands() async {
    final response = await _makeAuthenticatedRequest(
      () =>
          http.get(Uri.parse('$_baseUrl/api/land/my-lands'), headers: _headers),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => MyLandTile.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch my lands: ${response.body}');
    }
  }

  Future<void> buyLandTile(String h3Index) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/land/buy/$h3Index'),
        headers: _headers,
      ),
    );
    // Backend returns 201 CREATED on successful purchase
    if (response.statusCode != 201) {
      throw Exception('Failed to buy land tile: ${response.body}');
    }
  }

  Future<void> sellLandTile(String h3Index) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/land/sell/$h3Index'),
        headers: _headers,
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to sell land tile: ${response.body}');
    }
  }

  // --- Land Income Claim System ---
  Future<LandClaimStatus> getLandClaimStatus() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/land/claim-status'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      return LandClaimStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch land claim status: ${response.body}');
    }
  }

  Future<LandClaimResponse> claimLandIncome() async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/land/claim-income'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      return LandClaimResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 429) {
      // Cooldown active
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ??
            'Land income can only be claimed once every 24 hours',
      );
    } else if (response.statusCode == 404) {
      // No land owned
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'You don\'t own any land tiles');
    } else if (response.statusCode == 400) {
      // No income available
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'No income available to claim');
    } else {
      throw Exception('Failed to claim land income: ${response.body}');
    }
  }

  // --- Tapping System ---
  Future<TapResponse> submitTaps(int tapCount) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/tapping/tap'),
        headers: _headers,
        body: json.encode({'tap_count': tapCount}),
      ),
    );

    if (response.statusCode == 200) {
      return TapResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 429) {
      // Daily limit reached
      return TapResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to submit taps: ${response.body}');
    }
  }
}
