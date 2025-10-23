# Meshy AI Integration Setup

This document explains how to set up the Meshy AI integration for 3D model generation in the FurniStore application, based on the [official Meshy AI API documentation](https://docs.meshy.ai/en).

## Prerequisites

1. A Meshy AI account
2. Meshy AI API key

## Setup Instructions

### 1. Get Your Meshy AI API Key

1. Visit [Meshy AI](https://www.meshy.ai/)
2. Sign up for an account
3. Navigate to your API settings
4. Generate a new API key
5. Copy the API key

### 2. Configure the API Key

1. Open `lib/services/meshy_ai_service.dart`
2. Replace the API key with your actual API key:

```dart
static const String _apiKey = 'your_actual_api_key_here';
```

**Note**: The API key is already configured in the service file. Make sure to keep it secure in production environments.

### 3. API Usage

The integration automatically:
- Generates 3D models from product images using the latest Meshy-5 AI model
- Uses the correct API endpoint: `https://api.meshy.ai/openapi/v1/image-to-3d`
- Enables Physically Based Rendering (PBR) for better quality
- Enables remeshing and texturing for high-quality models
- Polls for completion every 3 seconds for better UX
- Stores the generated 3D model URLs in the product data

### 4. Features

- **Automatic 3D Generation**: Upload a product image and click "Generate 3D Model"
- **Real-time Progress**: Shows progress percentage during generation
- **Multiple Formats**: Supports GLB, OBJ, and other 3D model formats
- **Thumbnail Preview**: Generates thumbnail images for quick preview
- **Error Handling**: Displays user-friendly error messages with detailed information
- **Success Notifications**: Shows available formats and features when complete

### 5. API Configuration

The service is configured with the following parameters based on the [official API documentation](https://docs.meshy.ai/en):

```dart
final Map<String, dynamic> body = {
  'image_url': 'data:image/jpeg;base64,$base64Image',
  'ai_model': 'meshy-5', // Latest AI model
  'enable_pbr': true, // Enable Physically Based Rendering
  'should_remesh': true, // Enable remeshing
  'should_texture': true, // Enable texturing
};
```

### 6. API Modes

- **Preview Mode**: Faster generation, lower cost, good quality
- **Premium Mode**: Higher quality, more expensive, longer generation time

To change modes, modify the `mode` parameter in `meshy_ai_service.dart`.

### 7. Supported Features

Based on the [Meshy AI documentation](https://docs.meshy.ai/en), the integration supports:

- **Image to 3D**: Convert 2D images to 3D models
- **Multiple Output Formats**: GLB, OBJ, and other formats
- **PBR Materials**: Physically Based Rendering for realistic materials
- **Thumbnail Generation**: Automatic thumbnail creation
- **Progress Tracking**: Real-time progress updates

### 8. Cost Considerations

- Preview mode: Faster and cheaper
- Premium mode: Higher quality but more expensive
- Check [Meshy AI pricing](https://docs.meshy.ai/en/pricing) for current rates

## Troubleshooting

### Common Issues

1. **API Key Invalid**: Ensure your API key is correct and active
2. **Generation Failed**: Check image quality and format
3. **Timeout**: Large images may take longer to process
4. **Rate Limits**: Check if you've exceeded API rate limits

### Error Messages

- "Failed to start 3D generation": API key or request format issue
- "3D generation failed": Image processing failed with specific error details
- "Failed to check status": Network or API issue

### Debug Information

The service provides detailed error information including:
- HTTP status codes
- API response messages
- Progress tracking
- Generation status updates

## API Reference

For detailed API information, refer to the [official Meshy AI documentation](https://docs.meshy.ai/en):
- [Image to 3D API](https://docs.meshy.ai/en/api/image-to-3d)
- [Authentication](https://docs.meshy.ai/en/api/authentication)
- [Rate Limits](https://docs.meshy.ai/en/rate-limits)
- [Pricing](https://docs.meshy.ai/en/pricing)

## Support

For Meshy AI specific issues, refer to their [documentation](https://docs.meshy.ai/en) or contact their support team.
