import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result returned by [IndianPincodeValidator.validate]
class PincodeValidationResult {
  /// Whether the pinCode is valid (format + real)
  final bool isValid;

  /// City / District name (if valid)
  final String? city;

  /// State name (if valid)
  final String? state;

  /// Optional human-readable message (error / info)
  final String? message;

  const PincodeValidationResult({
    required this.isValid,
    this.city,
    this.state,
    this.message,
  });

  @override
  String toString() =>
      'PincodeValidationResult(isValid: $isValid, city: $city, state: $state, message: $message)';
}

/// Main utility class for Indian PIN code validation
///
/// Usage:
/// ```dart
/// final result = await IndianPincodeValidator.validate('560103');
/// if (result.isValid) {
///   print(result.city);
///   print(result.state);
/// }
/// ```
class IndianPinCodeValidator {
  // 6 digits, cannot start with 0
  static final RegExp _formatRegex = RegExp(r'^[1-9][0-9]{5}$');

  /// Checks only the **format** (local check, no API call):
  /// - exactly 6 digits
  /// - cannot start with 0
  static bool isValidFormat(String pin) {
    return _formatRegex.hasMatch(pin);
  }

  /// Optional: detect very obvious fake PINs.
  ///
  /// Examples rejected:
  /// - 111111, 222222 (all same digit)
  /// - 123456, 654321 (strict sequences)
  /// - 101010, 121212 (repeating pairs)
  static bool isObviousFake(String pin) {
    if (pin.length != 6) return true;

    // all same digit
    if (RegExp(r'^(\d)\1{5}$').hasMatch(pin)) return true;

    // strictly ascending or descending sequence
    bool asc = true;
    bool desc = true;
    for (var i = 1; i < pin.length; i++) {
      final prev = int.parse(pin[i - 1]);
      final cur = int.parse(pin[i]);
      if (cur != prev + 1) asc = false;
      if (cur != prev - 1) desc = false;
    }
    if (asc || desc) return true;

    // ABABAB pattern (e.g. 101010, 121212)
    if (RegExp(r'^(.)(.)\1\2\1\2$').hasMatch(pin)) return true;

    return false;
  }

  /// Fully validates an Indian pincode:
  ///
  /// 1. Checks format (6 digits, not starting with 0)
  /// 2. Optionally rejects obvious fake patterns
  /// 3. Calls public Postal API to verify it exists
  /// 4. If valid, returns [PinCodeValidationResult] with `city` & `state`
  ///
  /// Uses: https://api.postalpincode.in/pincode/{pin}
  static Future<PincodeValidationResult> validate(
    String pin, {
    http.Client? client,
    bool rejectObviousFakes = true,
  }) async {
    final trimmed = pin.trim();

    // 1) Basic format check
    if (!isValidFormat(trimmed)) {
      return const PincodeValidationResult(
        isValid: false,
        message: 'PIN should be 6 digits and not start with 0.',
      );
    }

    // 2) Obvious fake check (optional)
    if (rejectObviousFakes && isObviousFake(trimmed)) {
      return const PincodeValidationResult(
        isValid: false,
        message: 'This looks like an invalid PIN pattern.',
      );
    }

    // 3) API lookup
    client ??= http.Client();
    try {
      final uri = Uri.parse('https://api.postalpincode.in/pincode/$trimmed');
      final resp = await client.get(uri);

      if (resp.statusCode != 200) {
        return PincodeValidationResult(
          isValid: false,
          message: 'Failed to validate PIN (HTTP ${resp.statusCode}).',
        );
      }

      final body = jsonDecode(resp.body);
      if (body is! List || body.isEmpty) {
        return const PincodeValidationResult(
          isValid: false,
          message: 'Unexpected response from server.',
        );
      }

      final first = body[0];
      if (first is! Map<String, dynamic>) {
        return const PincodeValidationResult(
          isValid: false,
          message: 'Unexpected response format.',
        );
      }

      final status = (first['Status'] ?? '').toString().toLowerCase();
      if (status != 'success') {
        // API says invalid PIN
        return PincodeValidationResult(
          isValid: false,
          message: first['Message']?.toString() ?? 'Invalid PIN code.',
        );
      }

      final postOffices = first['PostOffice'];
      if (postOffices is! List || postOffices.isEmpty) {
        return const PincodeValidationResult(
          isValid: false,
          message: 'No location information found for this PIN.',
        );
      }

      final po = postOffices[0];
      if (po is! Map<String, dynamic>) {
        return const PincodeValidationResult(
          isValid: false,
          message: 'Invalid Post Office data.',
        );
      }

      final city =
          (po['District'] ?? po['Block'] ?? po['Name'] ?? '').toString();
      final state = (po['State'] ?? '').toString();

      if (city.isEmpty && state.isEmpty) {
        return const PincodeValidationResult(
          isValid: false,
          message: 'Location data not available for this PIN.',
        );
      }

      // ✅ Valid pincode
      return PincodeValidationResult(
        isValid: true,
        city: city,
        state: state,
        message: 'Valid PIN code.',
      );
    } catch (e) {
      return PincodeValidationResult(
        isValid: false,
        message: 'Error validating PIN: $e',
      );
    } finally {
      // Do NOT close `client` if it was passed from outside
      // if (client is http.Client) {
      //   client.close();
      //   // if you really want to auto-close only when created internally,
      //   // you can track that with a flag instead.
      // }
    }
  }
}
