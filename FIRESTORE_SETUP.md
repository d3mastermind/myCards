# Firestore Templates Setup

## Overview
This guide explains how to set up card templates in Firestore for the MyCards app.

## Prerequisites
- Firebase project is configured
- Firestore database is enabled
- App is connected to Firebase

## Setup Steps

### 1. First Time Setup - Populate Templates

To populate Firestore with the initial template data:

1. Open `lib/main.dart`
2. Uncomment the import line:
   ```dart
   import 'package:mycards/utils/populate_templates.dart';
   ```
3. Uncomment the populate line in the `main()` function:
   ```dart
   await TemplatePopulator.populateTemplates();
   ```
4. Run the app once to populate the database
5. **IMPORTANT:** Comment out the populate line again after first run to avoid duplicates

### 2. Firestore Collection Structure

The templates are stored in a collection called `templates` with the following structure:

```
templates/
├── {templateId}/
│   ├── name: "Birthday Celebration"
│   ├── category: "Birthday"
│   ├── ispremium: true
│   ├── price: 10
│   └── frontCover: "assets/images/3.jpg"
```

### 3. Template Fields

- **name**: Display name of the template
- **category**: Category for filtering (Birthday, Wedding, etc.)
- **ispremium**: Boolean indicating if template requires purchase
- **price**: Credit cost (null for free templates)
- **frontCover**: Asset path or URL for template preview image

### 4. Firestore Rules

Make sure your Firestore rules allow reading templates:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to templates for all users
    match /templates/{templateId} {
      allow read: if true;
      allow write: if false; // Only allow through admin functions
    }
  }
}
```

### 5. Management Functions

The `TemplateService` class provides methods for:
- `getAllTemplates()`: Fetch all templates
- `getTemplatesByCategory(category)`: Filter by category
- `searchTemplates(query)`: Search templates
- `addTemplate(template)`: Add new template (admin)
- `updateTemplate(templateId, template)`: Update existing template
- `deleteTemplate(templateId)`: Delete template

### 6. Caching

The service includes automatic caching to improve performance:
- Templates are cached for 30 minutes
- Use `clearCache()` to force refresh
- Pull-to-refresh in the home screen clears cache

### 7. Error Handling

The home screen includes:
- Loading states while fetching templates
- Error states with retry functionality
- Empty states for no templates or search results

## Troubleshooting

### Templates not loading?
1. Check Firebase connection
2. Verify Firestore rules allow read access
3. Ensure internet connectivity
4. Check console for error messages

### Want to reset templates?
Use the utility function:
```dart
await TemplatePopulator.clearAllTemplates();
await TemplatePopulator.populateTemplates();
```

### Adding new templates?
1. Add template data to `lib/data/template_data.dart`
2. Run `TemplatePopulator.populateTemplates()` (it will skip existing templates)
3. Or use `TemplateService.addTemplate()` directly 