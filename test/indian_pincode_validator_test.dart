import 'dart:convert';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:indian_pincode_validator/indian_pincode_validator.dart';

void main() {
  group('IndianPinCodeValidator', () {
    test('isValidFormat works correctly', () {
      expect(IndianPinCodeValidator.isValidFormat('560103'), isTrue);
      expect(IndianPinCodeValidator.isValidFormat('012345'), isFalse);
      expect(IndianPinCodeValidator.isValidFormat('12345'), isFalse);
      expect(IndianPinCodeValidator.isValidFormat('abcdef'), isFalse);
    });

    test('isObviousFake detects patterns', () {
      expect(IndianPinCodeValidator.isObviousFake('111111'), isTrue);
      expect(IndianPinCodeValidator.isObviousFake('123456'), isTrue);
      expect(IndianPinCodeValidator.isObviousFake('101010'), isTrue);
      expect(IndianPinCodeValidator.isObviousFake('560103'), isFalse);
    });

    test('validate returns success for valid PIN from API', () async {
      final mockClient = MockClient((req) async {
        expect(
          req.url.toString(),
          equals('https://api.postalpincode.in/pincode/560103'),
        );

        final body = jsonEncode([
          {
            "Status": "Success",
            "PostOffice": [
              {
                "Name": "Bellandur",
                "District": "Bengaluru",
                "State": "Karnataka",
              },
            ],
          },
        ]);

        return http.Response(body, 200);
      });

      final result = await IndianPinCodeValidator.validate(
        '560103',
        client: mockClient,
      );

      expect(result.isValid, isTrue);
      expect(result.city, equals('Bengaluru'));
      expect(result.state, equals('Karnataka'));
    });

    test('validate returns invalid for API error', () async {
      final mockClient = MockClient((req) async {
        final body = jsonEncode([
          {"Status": "Error", "Message": "No records found"},
        ]);
        return http.Response(body, 200);
      });

      final result = await IndianPinCodeValidator.validate(
        '999999',
        client: mockClient,
      );

      expect(result.isValid, isFalse);
    });

    test('validate handles non-200 HTTP status', () async {
      final mockClient = MockClient((req) async {
        return http.Response('Internal error', 500);
      });

      final result = await IndianPinCodeValidator.validate(
        '560103',
        client: mockClient,
      );

      expect(result.isValid, isFalse);
      expect(result.message, contains('HTTP 500'));
    });
  });
}
