# EmailJS Setup Guide

This guide will help you set up EmailJS for sending email notifications when sellers are approved or rejected.

## Step 1: Create EmailJS Account

1. Go to [https://www.emailjs.com/](https://www.emailjs.com/)
2. Sign up for a free account
3. Verify your email address

## Step 2: Add Email Service

1. In your EmailJS dashboard, go to **Email Services**
2. Click **Add New Service**
3. Choose your email provider (Gmail, Outlook, etc.)
4. Follow the setup instructions for your chosen provider
5. Note down your **Service ID** (e.g., `service_abc123`)

## Step 3: Create Email Templates

### Approval Email Template

1. Go to **Email Templates** in your dashboard
2. Click **Create New Template**
3. Name it "Seller Approval" and note the **Template ID**
4. Use this template content:

**Subject:** `{{subject}}`

**Content (HTML):**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Approved - FurniStore</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        .container { background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .success-icon { width: 80px; height: 80px; background-color: #28a745; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 20px; }
        .success-icon::before { content: "✓"; color: white; font-size: 40px; font-weight: bold; }
        h1 { color: #28a745; margin: 0; font-size: 28px; }
        .status-badge { background-color: #d4edda; color: #155724; padding: 8px 16px; border-radius: 20px; display: inline-block; margin: 10px 0; font-weight: bold; }
        .content { margin: 30px 0; }
        .highlight-box { background-color: #e3f2fd; border-left: 4px solid #2196f3; padding: 20px; margin: 20px 0; border-radius: 0 5px 5px 0; }
        .help-box { background-color: #e8f5e8; border-left: 4px solid #28a745; padding: 20px; margin: 20px 0; border-radius: 0 5px 5px 0; }
        .cta-button { display: inline-block; background-color: #007bff; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; text-align: center; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; text-align: center; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="success-icon"></div>
            <h1>Application Approved!</h1>
            <div class="status-badge">Status: Approved</div>
        </div>
        
        <div class="content">
            <p>Dear <strong>{{to_name}}</strong>,</p>
            
            <p>Congratulations! Your seller application for <strong>{{store_name}}</strong> has been successfully approved. You can now start selling on FurniStore!</p>
            
            <div class="highlight-box">
                <h3>What now?</h3>
                <ul>
                    <li>Your seller account is now active</li>
                    <li>Head over to your Seller Dashboard to add products and manage your store</li>
                    <li>Make sure to complete your store profile for better visibility</li>
                </ul>
            </div>
            
            <div class="help-box">
                <h3>Need help?</h3>
                <p>Contact our support team at <a href="mailto:furnistoreofficial@gmail.com">furnistoreofficial@gmail.com</a> if you need assistance with your seller account.</p>
            </div>
        </div>
        
        <div class="footer">
            <p>Thank you for choosing FurniStore!</p>
            <p>Best regards,<br>The FurniStore Team</p>
        </div>
    </div>
</body>
</html>
```

### Rejection Email Template

1. Create another template named "Seller Rejection"
2. Note the **Template ID**
3. Use this template content:

**Subject:** `{{subject}}`

**Content (HTML):**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Update - FurniStore</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        .container { background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .info-icon { width: 80px; height: 80px; background-color: #ffc107; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 20px; }
        .info-icon::before { content: "ℹ"; color: white; font-size: 40px; font-weight: bold; }
        h1 { color: #ffc107; margin: 0; font-size: 28px; }
        .status-badge { background-color: #fff3cd; color: #856404; padding: 8px 16px; border-radius: 20px; display: inline-block; margin: 10px 0; font-weight: bold; }
        .content { margin: 30px 0; }
        .reason-box { background-color: #f8d7da; border-left: 4px solid #dc3545; padding: 20px; margin: 20px 0; border-radius: 0 5px 5px 0; }
        .help-box { background-color: #e3f2fd; border-left: 4px solid #2196f3; padding: 20px; margin: 20px 0; border-radius: 0 5px 5px 0; }
        .cta-button { display: inline-block; background-color: #007bff; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; text-align: center; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; text-align: center; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="info-icon"></div>
            <h1>Application Update</h1>
            <div class="status-badge">Status: Rejected</div>
        </div>
        
        <div class="content">
            <p>Dear <strong>{{to_name}}</strong>,</p>
            
            <p>Thank you for your interest in becoming a seller on FurniStore. After careful review, we regret to inform you that your application for <strong>{{store_name}}</strong> has not been approved at this time.</p>
            
            <div class="reason-box">
                <h3>Reason for Rejection:</h3>
                <p>{{rejection_reason}}</p>
            </div>
            
            <div class="help-box">
                <h3>What can you do?</h3>
                <ul>
                    <li>Review the feedback provided above</li>
                    <li>Make necessary improvements to your application</li>
                    <li>Submit a new application when ready</li>
                    <li>Contact our support team for guidance</li>
                </ul>
            </div>
            
            <p>If you have any questions or need clarification, please don't hesitate to contact our support team at <a href="mailto:furnistoreofficial@gmail.com">furnistoreofficial@gmail.com</a>.</p>
        </div>
        
        <div class="footer">
            <p>We appreciate your interest in FurniStore!</p>
            <p>Best regards,<br>The FurniStore Team</p>
        </div>
    </div>
</body>
</html>
```

## Step 4: Get Your API Keys

1. Go to **Account** → **General** in your EmailJS dashboard
2. Find your **Public Key** and **Private Key**
3. Note down your **User ID** (optional)

## Step 5: Update Configuration

1. Open `lib/config/emailjs_config.dart`
2. Replace the placeholder values with your actual EmailJS credentials:

```dart
class EmailJSConfig {
  // Replace with your actual EmailJS Service ID
  static const String serviceId = 'service_your_actual_service_id';
  
  // Replace with your actual Template IDs
  static const String templateIdApproval = 'template_your_approval_template_id';
  static const String templateIdRejection = 'template_your_rejection_template_id';
  
  // Replace with your actual EmailJS keys
  static const String publicKey = 'your_actual_public_key';
  static const String privateKey = 'your_actual_private_key';
  
  // Optional: Replace with your User ID
  static const String userId = 'your_actual_user_id';
}
```

## Step 6: Enable API Requests (Important!)

1. Go to **Account** → **Security** in your EmailJS dashboard
2. Enable **API requests for non-browser applications**
3. This is required for Flutter web applications

## Step 7: Test the Integration

1. Run your Flutter web application
2. Go to the admin dashboard
3. Approve or reject a seller application
4. Check if the email is sent successfully
5. Check the browser console for any error messages

## Troubleshooting

### Common Issues:

1. **"API requests are disabled"** - Make sure you enabled API requests in Account → Security
2. **"Invalid service ID"** - Double-check your service ID in the configuration
3. **"Template not found"** - Verify your template IDs are correct
4. **"Invalid public key"** - Check your public key in the EmailJS dashboard

### Testing:

- Use the browser's developer console to see detailed error messages
- Check the EmailJS dashboard for delivery status
- Test with a real email address to ensure delivery

## Security Notes

- The public key is safe to expose in client-side code
- Keep your private key secure
- Consider using environment variables for production deployments
- Monitor your EmailJS usage to avoid hitting rate limits

## Support

- EmailJS Documentation: [https://www.emailjs.com/docs/](https://www.emailjs.com/docs/)
- EmailJS Support: [https://www.emailjs.com/support/](https://www.emailjs.com/support/)
