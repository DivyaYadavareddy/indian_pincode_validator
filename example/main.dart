import 'package:indian_pincode_validator/indian_pincode_validator.dart';

Future<void> main() async {
  const pin = '500062'; // try with a valid PIN

  final result = await IndianPinCodeValidator.validate(pin);

  if (result.isValid) {
    print('✅ Valid PIN');
    print('City: ${result.city}');
    print('State: ${result.state}');
  } else {
    print('❌ Invalid PIN: ${result.message}');
  }
}
