# Google Play In-App Purchase Setup Guide

## Overview
This guide will help you set up in-app purchases for your MyCards app in Google Play Console. You'll need to configure products, set pricing, and test the purchase flow.

## Prerequisites
- Google Play Console account
- App uploaded to Google Play Console (at least as internal testing)
- Google Play Console Developer account ($25 one-time fee)

## Step 1: Upload Your App to Google Play Console

1. **Create App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

2. **Upload to Google Play Console**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create a new app or select existing app
   - Upload the app bundle to Internal Testing track

## Step 2: Configure In-App Products

### 2.1 Enable In-App Purchases
1. Go to **Monetize** → **Products** → **In-app products**
2. Click **Create product**

### 2.2 Create Products
Create these products with the exact IDs used in the code:

#### Product 1: 10 Credits
- **Product ID**: `credits_10`
- **Name**: 10 Credits
- **Description**: Get 10 credits for your MyCards account
- **Price**: $0.99 (or equivalent in your currency)

#### Product 2: 50 Credits
- **Product ID**: `credits_50`
- **Name**: 50 Credits
- **Description**: Get 50 credits for your MyCards account
- **Price**: $4.99 (or equivalent in your currency)

#### Product 3: 100 Credits (Popular)
- **Product ID**: `credits_100`
- **Name**: 100 Credits
- **Description**: Get 100 credits for your MyCards account - Best Value!
- **Price**: $9.99 (or equivalent in your currency)

#### Product 4: 500 Credits
- **Product ID**: `credits_500`
- **Name**: 500 Credits
- **Description**: Get 500 credits for your MyCards account
- **Price**: $39.99 (or equivalent in your currency)

#### Product 5: 1000 Credits
- **Product ID**: `credits_1000`
- **Name**: 1000 Credits
- **Description**: Get 1000 credits for your MyCards account - Maximum Value!
- **Price**: $79.99 (or equivalent in your currency)

### 2.3 Product Configuration Details
For each product:
1. **Product ID**: Must match exactly what's in the code
2. **Product Type**: Managed product (consumable)
3. **Name**: User-friendly name
4. **Description**: Clear description of what user gets
5. **Default price**: Set appropriate pricing
6. **Status**: Active

## Step 3: Set Up Testing

### 3.1 Create Test Tracks
1. Go to **Release** → **Testing** → **Internal testing**
2. Create a new release with your app bundle
3. Add test users (email addresses)

### 3.2 Configure License Testing
1. Go to **Setup** → **License testing**
2. Add test accounts (Gmail addresses)
3. Set license response to **LICENSED**

### 3.3 Test Purchase Flow
1. Install app from Play Store (internal testing link)
2. Sign in with test account
3. Try purchasing credits
4. Verify purchase flow works

## Step 4: Configure App Signing

### 4.1 Upload Key (if not using Play App Signing)
1. Go to **Setup** → **App signing**
2. Upload your upload certificate
3. Note the SHA-1 fingerprint for Firebase

### 4.2 Play App Signing (Recommended)
1. Let Google manage your app signing key
2. Download the upload certificate
3. Use upload certificate for Firebase configuration

## Step 5: Android Manifest Configuration

Ensure your `android/app/src/main/AndroidManifest.xml` includes:

```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

## Step 6: Firebase Configuration

### 6.1 Add SHA-1 to Firebase
1. Go to Firebase Console → Project Settings
2. Add the SHA-1 fingerprint from Play Console
3. Download updated `google-services.json`
4. Replace the file in `android/app/`

### 6.2 Enable Firebase Authentication
Make sure Firebase Auth is properly configured with Google Sign-In.

## Step 7: Testing Checklist

### 7.1 Test Account Setup
- [ ] Test account added to Google Play Console
- [ ] Test account has access to internal testing
- [ ] Test account is signed in on test device

### 7.2 Purchase Flow Testing
- [ ] App loads IAP products correctly
- [ ] Purchase dialog shows real prices
- [ ] Purchase completes successfully
- [ ] Credits are awarded to user account
- [ ] Transaction appears in Firestore
- [ ] Purchase is recorded in Google Play Console

### 7.3 Error Handling
- [ ] Handle network errors gracefully
- [ ] Handle cancelled purchases
- [ ] Handle failed purchases
- [ ] Show appropriate error messages

## Step 8: Production Deployment

### 8.1 App Review
1. Submit app for review in Google Play Console
2. Ensure all policies are followed
3. Wait for approval

### 8.2 Gradual Rollout
1. Start with small percentage rollout
2. Monitor for issues
3. Increase rollout percentage gradually

## Troubleshooting

### Common Issues

#### 1. "No products found" error
- **Cause**: Products not configured or app not published
- **Solution**: Ensure products are active and app is in testing track

#### 2. Purchase fails with authentication error
- **Cause**: Test account not properly configured
- **Solution**: Add test account to license testing

#### 3. Credits not awarded after purchase
- **Cause**: Firestore rules or service issue
- **Solution**: Check Firestore rules and server logs

#### 4. "Item not available for purchase" error
- **Cause**: Product ID mismatch or product not active
- **Solution**: Verify product IDs match code exactly

### Debug Commands

```bash
# Check app bundle
flutter build appbundle --release --verbose

# Check signing
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey

# Check Firebase connection
flutter packages get
flutter clean
flutter build appbundle
```

## Security Considerations

### 1. Server-Side Verification (Recommended)
- Implement server-side purchase verification
- Validate purchase tokens with Google Play API
- Prevent fraudulent purchases

### 2. Firestore Security
- Ensure only authenticated users can modify their credits
- Validate purchase data before awarding credits
- Log all transactions for audit

### 3. Error Handling
- Never award credits without verified purchase
- Handle edge cases (network failures, etc.)
- Implement retry mechanisms

## Monitoring and Analytics

### 1. Google Play Console
- Monitor purchase conversion rates
- Track revenue and user engagement
- Analyze crash reports

### 2. Firebase Analytics
- Track purchase events
- Monitor user behavior
- Set up conversion funnels

### 3. Custom Logging
- Log purchase attempts
- Track success/failure rates
- Monitor credit balance changes

## Next Steps

1. **Complete Google Play Console setup**
2. **Test with real test accounts**
3. **Implement server-side verification** (optional but recommended)
4. **Set up monitoring and analytics**
5. **Submit for app review**
6. **Launch to production**

## Support Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [In-App Purchase Documentation](https://developer.android.com/google/play/billing)
- [Flutter In-App Purchase Plugin](https://pub.dev/packages/in_app_purchase)
- [Firebase Documentation](https://firebase.google.com/docs)

Remember to test thoroughly before releasing to production! 