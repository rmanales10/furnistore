# Phone OTP Verification Setup

## Overview
This implementation replaces email verification with phone number OTP verification using the Semaphore SMS service.

## Setup Instructions

### 1. Get Semaphore API Key
1. Visit [Semaphore.co](https://semaphore.co)
2. Sign up for an account
3. Go to your account settings to get your API key
4. Replace `YOUR_SEMAPHORE_API_KEY` in `lib/config/semaphore_config.dart`

### 2. Configure Phone Number Format
The system expects Philippine phone numbers in the format:
- **Input**: 9xxxxxxxxx (10 digits starting with 9)
- **Display**: +63 9xxxxxxxxx
- **API**: 639xxxxxxxxx (11 digits with country code)

### 3. Features Implemented

#### Registration Flow
1. User fills registration form with phone number validation
2. Phone number must start with "9" and be exactly 10 digits
3. After successful registration, user is redirected to OTP verification

#### OTP Verification Screen
- 6-digit OTP input with individual digit fields
- Auto-focus navigation between fields
- Resend OTP functionality with 60-second cooldown
- Real-time validation and error handling
- Clean, modern UI design

#### Semaphore Integration
- Uses Semaphore OTP endpoint for reliable delivery
- Custom OTP code generation
- Proper error handling and user feedback
- Rate limiting compliance

### 4. API Endpoints Used

#### Send OTP
```
POST https://api.semaphore.co/api/v4/otp
```
- **Rate Limit**: No limit (dedicated OTP route)
- **Cost**: 2 credits per SMS
- **Features**: Auto-generated or custom OTP codes

#### Send Regular SMS
```
POST https://api.semaphore.co/api/v4/messages
```
- **Rate Limit**: 120 calls per minute
- **Cost**: 1 credit per SMS

### 5. Database Changes
- Added `phoneVerified` field to user documents
- Removed email verification requirement
- Phone verification status tracking

### 6. Security Features
- OTP expiry (5 minutes)
- Rate limiting on resend
- Input validation and sanitization
- Secure OTP generation

## Usage

### For Developers
1. Update API key in `lib/config/semaphore_config.dart`
2. Test with valid Philippine phone numbers
3. Monitor Semaphore dashboard for delivery status

### For Users
1. Enter phone number starting with "9" (e.g., 9123456789)
2. Receive OTP via SMS
3. Enter 6-digit code to verify
4. Resend if needed (60-second cooldown)

## Troubleshooting

### Common Issues
1. **OTP not received**: Check API key and phone number format
2. **Invalid phone number**: Ensure it starts with "9" and is 10 digits
3. **API errors**: Check Semaphore account balance and rate limits

### Testing
- Use test phone numbers provided by Semaphore
- Check Semaphore dashboard for delivery logs
- Monitor app logs for API responses

## Cost Considerations
- OTP messages: 2 credits each
- Regular SMS: 1 credit each
- Monitor usage in Semaphore dashboard
- Consider bulk pricing for high volume
