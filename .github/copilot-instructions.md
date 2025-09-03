# QuranKu - AI Coding Instructions

## Architecture Overview

This is a Flutter app using **Clean Architecture** with feature-based organization. Each feature follows the pattern:

```
lib/features/{feature}/
├── data/ (DataSources, Models, Repositories)
├── domain/ (Entities, Repositories, UseCases)
├── presentation/ (Blocs, Screens, Components)
```

## Core Technologies & Patterns

### State Management & Code Generation

- **BLoC Pattern**: All state management uses `flutter_bloc` with events/states
- **Freezed**: ALL data classes use `@freezed` with `.codegen.dart` extension
- **Injectable**: Dependency injection with `@injectable` annotations
- **Build Runner**: Generate code with `flutter pub run build_runner build`

### Key Commands

```bash
# Code generation (run after changes to freezed/injectable classes)
flutter pub run build_runner build

# Localization generation
flutter pub run easy_localization:generate -f keys -o locale_keys.g.dart --source-dir assets/translations

# Create new feature structure
make create_structure FEATURE_NAME=your_feature
```

### Essential Patterns

**1. BLoC Structure**: Every bloc extends `Bloc<Event, State>` with freezed events/states:

```dart
@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final UseCase _useCase;
  FeatureBloc(this._useCase) : super(FeatureState.initial()) {
    on<EventName>(_onEventName);
  }
}
```

**2. Dependency Injection**: Use `sl<Type>()` (service locator) to access dependencies:

```dart
import 'package:quranku/injection.dart';

final myService = sl<MyService>();
```

**3. Navigation**: Use GoRouter with typed routes and BlocProvider.value:

```dart
context.push('/route', extra: data);
// In router.dart, wrap with BlocProvider.value for state access
```

**4. Localization**: Use `LocaleKeys.keyName.tr()` pattern:

```dart
Text(LocaleKeys.searchKajianHint.tr())
```

### Essential Extensions

- `context.locale` - current locale
- `context.theme` - theme data
- `context.textTheme` - text theme
- `value.orEmpty()` - null safety for strings
- `state.status.isLoading/isFailure/isSuccess` - Formz status checks

### File Naming Conventions

- Entities: `{name}.codegen.dart`
- Blocs: `{name}_bloc.dart` with `{name}_event.dart`, `{name}_state.dart`
- Screens: `{name}_screen.dart`
- Components: `{name}_tile.dart` or descriptive names

### Development Workflow

1. Create feature structure with makefile
2. Define entities with Freezed in domain/entities/
3. Create repository interface in domain/repositories/
4. Implement data layer with models and datasources
5. Create use cases in domain/usecases/
6. Build BLoC with events/states in presentation/blocs/
7. Create UI in presentation/screens/ and components/
8. Register dependencies with @injectable
9. Run build_runner to generate code

### API Integration & Data Layer

**Error Handling**: All network responses use Either<Failure, Success> pattern:

```dart
Future<Either<Failure, Model>> getData() async {
  try {
    final response = await _dio.get(endpoint);
    return right(Model.fromJson(response.data));
  } on Exception catch (e) {
    return left(ServerException(e));
  }
}
```

**Repository Pattern**: Abstract repository in domain, implementation in data:

```dart
// Domain
abstract class Repository {
  Future<Either<Failure, Entity>> getData();
}

// Data implementation with @LazySingleton
@LazySingleton(as: Repository)
class RepositoryImpl implements Repository {
  final RemoteDataSource _remote;
  RepositoryImpl(this._remote);
}
```

### UI Patterns & Components

**Material Theme**: Use `context.theme` and `context.textTheme` for consistent styling
**Component Structure**:

- Shared components across features → create in `core/components/`
- Feature-specific components → create in `feature/presentation/components/`
- Single-use widgets → inline in screen files

**Common UI Patterns**:

```dart
// Filter chips with consistent styling
FilterChip(
  label: Text(label),
  selected: selected,
  onSelected: onSelected,
)

// Error screens with refresh functionality
ErrorScreen(
  message: LocaleKeys.errorMessage.tr(),
  onRefresh: () => bloc.add(RefreshEvent()),
)
```

### Performance Optimizations

**Critical Patterns**:

- Use `const` constructors everywhere possible
- `ListView.builder` for dynamic lists with pagination
- `CachedNetworkImage` for network images
- `buildWhen` in BlocBuilder to prevent unnecessary rebuilds
- Pagination with scroll notification for infinite loading
- `Key` widgets for list items to maintain state during rebuilds

**List Performance**:

```dart
ListView.builder(
  itemCount: isLoading ? items.length + 1 : items.length,
  itemBuilder: (context, index) {
    if (isLoading && index == items.length) {
      return const LinearProgressIndicator();
    }
    return ItemWidget(
      key: Key(index.toString()), // Important for performance
      item: items[index],
    );
  },
)
```

### Testing Patterns

- Use **mocktail** for mocking dependencies
- Tests follow same feature structure in `test/`
- GitHub Actions handles CI/CD with Fastlane
- Use FVM for Flutter version management (`.fvm/fvm_config.json`)

### Common Gotchas

- Always run build_runner after changing freezed classes
- BlocProvider.value needed when navigating with existing blocs
- Use service locator `sl<>()` in constructors, not build methods
- Formz for form validation and loading states
- All network responses should be wrapped in Either<Failure, Success>
- Use `const` constructors to improve performance
- Add `Key` to list items for proper widget recycling
