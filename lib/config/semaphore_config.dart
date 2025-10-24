class SemaphoreConfig {
  // Replace with your actual Semaphore API key
  // Get your API key from: https://semaphore.co/account
  static const String apiKey = 'c6743576f5f28b8c6d5e429813d8d6ce';

  // Sender name for SMS messages
  static const String senderName = 'ABESO';

  // OTP message template
  static const String otpMessageTemplate =
      'Your FurniStore verification code is: {otp}. Please use it within 5 minutes.';

  // OTP expiry time in minutes
  static const int otpExpiryMinutes = 5;
}
