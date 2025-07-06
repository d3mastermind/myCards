# User Document Creation Test Guide

## Overview
This guide helps you test that user documents are automatically created in Firestore when users sign up.

## Test Steps

### 1. Deploy Firestore Rules
First, deploy the Firestore security rules:

```bash
firebase deploy --only firestore:rules
```

### 2. Test Email Signup
1. Open the app
2. Go to email signup screen
3. Enter a new email and password
4. Complete the signup process
5. Verify email (if required)

### 3. Check Firestore Console
1. Go to Firebase Console
2. Navigate to Firestore Database
3. Look for a `users` collection
4. Verify that a document was created with the user's UID
5. Check that the document contains:
   - email: user's email
   - phoneNumber: null (for email signup)
   - name: null (for email signup)
   - creditBalance: 10
   - purchasedCards: []
   - likedCards: []
   - receivedCards: []
   - createdAt: timestamp
   - updatedAt: timestamp

### 4. Test Google Signup
1. Sign out of the app
2. Go to signup screen
3. Choose "Sign Up With Google"
4. Complete Google authentication
5. Check Firestore console for new user document

### 5. Test Phone Signup
1. Sign out of the app
2. Go to phone signup screen
3. Enter phone number and complete OTP verification
4. Check Firestore console for new user document

### 6. Test Account Screen
1. Navigate to the Account screen
2. Verify that:
   - User name/email is displayed
   - Credit balance shows 10
   - No errors in console

## Expected Results

### Firestore Document Structure
```json
{
  "email": "user@example.com",
  "phoneNumber": null,
  "name": null,
  "creditBalance": 10,
  "purchasedCards": [],
  "likedCards": [],
  "receivedCards": [],
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### Security Rules
- Users can only read/write their own documents
- Templates are readable by all authenticated users
- All other collections are protected

## Troubleshooting

### User document not created?
1. Check console logs for errors
2. Verify Firebase connection
3. Check Firestore rules
4. Ensure user is authenticated

### Permission denied errors?
1. Deploy updated Firestore rules
2. Check that user is authenticated
3. Verify document path matches user UID

### Account screen not showing data?
1. Check that providers are properly initialized
2. Verify user document exists in Firestore
3. Check for network connectivity issues

## Next Steps

After successful testing:
1. Implement credit purchase functionality
2. Add card purchase logic
3. Implement like/unlike functionality
4. Add received cards tracking
5. Create admin panel for user management 