# Clean Architecture Implementation Guide

This document explains how to use the clean architecture implementation in the MyCards app.

## Architecture Overview

The app now follows clean architecture principles with three main layers:

```
lib/
├── core/                    # Shared utilities and abstractions
│   ├── error/              # Error handling and failures
│   ├── usecases/           # Base usecase interfaces
│   └── utils/              # Common utilities
├── features/               # Feature-based organization
│   ├── templates/          # Template management feature
│   │   ├── data/           # Data layer
│   │   │   ├── models/     # Data models with serialization
│   │   │   ├── datasources/# Remote and local data sources
│   │   │   └── repositories/# Repository implementations
│   │   ├── domain/         # Business logic layer
│   │   │   ├── entities/   # Business objects
│   │   │   ├── repositories/# Repository abstractions
│   │   │   └── usecases/   # Business use cases
│   │   └── presentation/   # UI layer
│   │       ├── providers/  # State management (Riverpod)
│   │       ├── screens/    # UI screens
│   │       └── widgets/    # Reusable widgets
│   ├── cards/              # Card management feature
│   └── auth/               # Authentication feature
```

## Layer Responsibilities

### 1. Domain Layer (Business Logic)
- **Entities**: Pure business objects with no dependencies
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Single-purpose business logic operations

### 2. Data Layer (Data Access)
- **Models**: Data transfer objects that extend entities and add serialization
- **Data Sources**: Handle external data (Firebase, local storage)
- **Repository Implementations**: Concrete implementations of domain repositories

### 3. Presentation Layer (UI)
- **StateNotifiers**: ViewModels that manage UI state
- **Providers**: Dependency injection using Riverpod
- **Screens & Widgets**: Flutter UI components

## How to Use

### 1. Using Templates Feature

#### In your UI (e.g., HomeScreen):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/templates/presentation/providers/template_providers.dart';
import '../features/templates/presentation/providers/template_state.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateState = ref.watch(templateViewModelProvider);
    
    return Scaffold(
      body: templateState.when(
        initial: () => const Center(child: Text('Welcome')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (templates) => ListView.builder(
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return ListTile(
              title: Text(template.name),
              subtitle: Text(template.category),
              trailing: template.isPremium 
                ? Text('\$${template.price}')
                : const Text('Free'),
            );
          },
        ),
        error: (message) => Center(child: Text('Error: $message')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Load templates
          ref.read(templateViewModelProvider.notifier).loadAllTemplates();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

#### Template State Management:

```dart
// Load all templates
ref.read(templateViewModelProvider.notifier).loadAllTemplates();

// Load templates by category
ref.read(templateViewModelProvider.notifier).loadTemplatesByCategory('birthday');

// Search templates
ref.read(templateViewModelProvider.notifier).searchTemplates('wedding');

// Reset state
ref.read(templateViewModelProvider.notifier).reset();
```

### 2. Adding State Extension

To handle different states more elegantly, you can add extensions:

```dart
extension TemplateStateX on TemplateState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<TemplateEntity> templates) loaded,
    required T Function(String message) error,
  }) {
    if (this is TemplateInitial) return initial();
    if (this is TemplateLoading) return loading();
    if (this is TemplateLoaded) return loaded((this as TemplateLoaded).templates);
    if (this is TemplateError) return error((this as TemplateError).message);
    throw Exception('Unknown state: $this');
  }
}
```

### 3. Creating New Features

To add a new feature (e.g., `credits`), follow this structure:

```
lib/features/credits/
├── data/
│   ├── models/
│   │   └── credit_model.dart
│   ├── datasources/
│   │   ├── credit_remote_datasource.dart
│   │   └── credit_local_datasource.dart
│   └── repositories/
│       └── credit_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── credit_entity.dart
│   ├── repositories/
│   │   └── credit_repository.dart
│   └── usecases/
│       ├── get_user_credits.dart
│       └── purchase_credits.dart
└── presentation/
    ├── providers/
    │   ├── credit_state.dart
    │   ├── credit_viewmodel.dart
    │   └── credit_providers.dart
    ├── screens/
    │   └── credits_screen.dart
    └── widgets/
        └── credit_card_widget.dart
```

## Migration from Current Code

### 1. Replace Direct Service Calls

**Before:**
```dart
final templates = await TemplateService().getAllTemplates();
```

**After:**
```dart
final templateState = ref.watch(templateViewModelProvider);
// Use state-based approach instead of direct calls
```

### 2. Replace Direct Data Access

**Before:**
```dart
final cardData = CardDataNotifier(initialCard);
```

**After:**
```dart
final cardState = ref.watch(cardViewModelProvider);
ref.read(cardViewModelProvider.notifier).updateCard(newCard);
```

## Benefits

1. **Separation of Concerns**: Each layer has clear responsibilities
2. **Testability**: Easy to mock dependencies and test business logic
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features following the same pattern
5. **Error Handling**: Centralized error handling with Result types
6. **Caching**: Automatic caching with local data sources

## Error Handling

The architecture uses a `Result<T>` type for error handling:

```dart
final result = await getAllTemplates(NoParams());
if (result is Success) {
  // Handle success: result.data
} else if (result is Error) {
  // Handle error: result.failure.message
}
```

## Next Steps

1. Migrate existing screens to use the new template providers
2. Implement the cards feature following the same pattern
3. Add authentication feature with clean architecture
4. Implement proper error handling throughout the app
5. Add unit tests for use cases and repositories

## Testing

With clean architecture, you can easily test:

```dart
// Test use cases
test('should get all templates', () async {
  // Arrange
  final mockRepo = MockTemplateRepository();
  final usecase = GetAllTemplates(mockRepo);
  
  // Act
  final result = await usecase(NoParams());
  
  // Assert
  expect(result, isA<Success>());
});

// Test ViewModels
test('should emit loading then loaded states', () async {
  // Arrange
  final mockUsecase = MockGetAllTemplates();
  final viewModel = TemplateViewModel(getAllTemplates: mockUsecase);
  
  // Act
  viewModel.loadAllTemplates();
  
  // Assert
  expect(viewModel.state, isA<TemplateLoading>());
  // ... test state changes
});
```

This clean architecture implementation provides a solid foundation for building scalable, maintainable, and testable Flutter applications. 