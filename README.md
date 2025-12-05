## Demo

![Demo](example/demo.gif)

# indian_pincode_validator

A lightweight and easy-to-use Dart/Flutter package to validate **Indian PIN Codes**.  
It checks **length**, **format**, detects **fake patterns**, verifies **real PIN codes** using the official Postal API, and returns **city & state** information.

Perfect for Flutter forms, address validation, KYC screens, and signup flows.

---

## Features

✔ Validate Indian PIN code structure (6 digits, cannot start with 0)  
✔ Detect invalid or obvious fake patterns (`111111`, `123456`, `101010`, etc.)  
✔ Verify real PIN codes via the Indian Postal API  
✔ Fetch and return **city** and **state**  
✔ Simple and clean API  
✔ Works in both **Dart** & **Flutter** apps  
✔ Optional: Pass your own HTTP client for testing  
✔ Fully typed result model (`PincodeValidationResult`)

---

## Getting started


Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  indian_pincode_validator: ^0.0.1
```  
``` Then run
   dart pub get 
```
``` Import the package:
   import 'package:indian_pincode_validator/indian_pincode_validator.dart';
```
   

## Usage

final result = await IndianPincodeValidator.validate('560103');

```dart
const like = 'sample';
```

## Additional information

🛠 Contributing

Contributions are welcome!
Feel free to open issues or submit pull requests for:

new features

bug fixes

performance improvements

🐞 Reporting issues

If you encounter any issues, please file them on the GitHub issue tracker.

❤️ Support

If this package saved you time, consider giving it a ⭐ on GitHub or sharing it with others!
