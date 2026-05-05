import 'dart:convert';
import 'base_service.dart';

class UserProfileService extends BaseService {
  /// Upload a profile image.
  ///
  /// [bytes]    — raw file bytes (from image_picker)
  /// [filename] — e.g. "avatar.jpg"
  ///
  /// Returns the new image URL on success.
  Future<String> uploadProfileImage({
    required List<int> bytes,
    required String filename,
  }) async {
    final response = await uploadFile(
      '/api/users/me/image',
      bytes,
      filename,
    );

    guard(response); // throws ApiException on non-2xx

    // Try to parse the returned URL from the JSON body.
    // The backend may return: { "imageUrl": "https://..." }
    // or just the raw URL string.
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final url = body['imageUrl'] ?? body['url'] ?? body['image'] ?? '';
        return url.toString();
      }
      // plain string response
      return response.body.trim().replaceAll('"', '');
    } catch (_) {
      return response.body.trim().replaceAll('"', '');
    }
  }
}
