# indian_pincode_validator
Indian Pincode Validator – Flutter/Dart Package

A lightweight and easy-to-use Flutter/Dart package to validate Indian PIN codes with proper formatting, length checks, and real-time verification.
The package also returns city and state information for valid PIN codes.

✅ Features

Validate pincode length (6 digits)

Validate format (numeric only)

Check whether the pincode actually exists

Get city and state for valid pincodes

Simple API → easy to integrate into all Flutter forms

🧪 Example
final result = await IndianPincodeValidator.validate("500062");

if (result.isValid) {
  print("City: ${result.city}");
  print("State: ${result.state}");
} else {
  print("Invalid pincode");
}

📍 Coming Soon

Offline pincode database

Pincode auto-suggestions

District lookup
