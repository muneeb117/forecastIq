/// Centralized helper class for validation operations
/// Provides consistent validation methods across the application
class ValidationHelper {
  ValidationHelper._();

  // Regular expressions for validation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^[\+]?[1-9][\d]{0,15}$',
  );

  static final RegExp _nameRegex = RegExp(
    r'^[a-zA-Z\s]+$',
  );

  static final RegExp _numericRegex = RegExp(
    r'^[0-9]+$',
  );

  static final RegExp _alphanumericRegex = RegExp(
    r'^[a-zA-Z0-9]+$',
  );

  /// Validate email address
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    value = value.trim();

    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  /// Validate password with strength requirements
  /// Returns null if valid, error message if invalid
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate confirm password
  /// Returns null if valid, error message if invalid
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate full name
  /// Returns null if valid, error message if invalid
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }

    value = value.trim();

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (!_nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validate phone number
  /// Returns null if valid, error message if invalid
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    value = value.trim().replaceAll(' ', '').replaceAll('-', '');

    if (!_phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate OTP code
  /// Returns null if valid, error message if invalid
  static String? validateOTP(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter the verification code';
    }

    value = value.trim();

    if (value.length != length) {
      return 'Verification code must be $length digits';
    }

    if (!_numericRegex.hasMatch(value)) {
      return 'Verification code can only contain numbers';
    }

    return null;
  }

  /// Validate required field
  /// Returns null if valid, error message if invalid
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /// Validate numeric input
  /// Returns null if valid, error message if invalid
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }

    final numericValue = double.tryParse(value);
    if (numericValue == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  /// Validate positive number
  /// Returns null if valid, error message if invalid
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericValidation = validateNumeric(value, fieldName);
    if (numericValidation != null) return numericValidation;

    final numericValue = double.parse(value!);
    if (numericValue <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  /// Validate minimum length
  /// Returns null if valid, error message if invalid
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  /// Returns null if valid, error message if invalid
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be no more than $maxLength characters';
    }

    return null;
  }

  /// Validate URL
  /// Returns null if valid, error message if invalid
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }

    value = value.trim();

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL (must start with http:// or https://)';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate age
  /// Returns null if valid, error message if invalid
  static String? validateAge(String? value, {int minAge = 13, int maxAge = 120}) {
    final numericValidation = validateNumeric(value, 'age');
    if (numericValidation != null) return numericValidation;

    final age = int.parse(value!);
    if (age < minAge || age > maxAge) {
      return 'Age must be between $minAge and $maxAge';
    }

    return null;
  }

  /// Validate username
  /// Returns null if valid, error message if invalid
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }

    value = value.trim();

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must be no more than 20 characters';
    }

    if (!_alphanumericRegex.hasMatch(value)) {
      return 'Username can only contain letters and numbers';
    }

    return null;
  }

  /// Check password strength
  /// Returns strength score from 0 (weak) to 4 (very strong)
  static int getPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    return score;
  }

  /// Get password strength text
  /// Returns human-readable password strength
  static String getPasswordStrengthText(String password) {
    final strength = getPasswordStrength(password);
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Medium';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return 'Unknown';
    }
  }

  /// Check if email is valid (boolean)
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Check if phone number is valid (boolean)
  static bool isValidPhoneNumber(String phone) {
    return _phoneRegex.hasMatch(phone.trim().replaceAll(' ', '').replaceAll('-', ''));
  }

}