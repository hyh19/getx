---
description: Use when working with GetX dependency injection, Get.put/lazyPut/putAsync/create, Bindings, SmartManagement, or dependency lifecycle management
---

# GetX Dependency Management Rules

## Overview

GetX provides a simple and powerful dependency injection system that allows you to retrieve classes with just one line of code, without Provider context or InheritedWidget. This rule file guides proper usage patterns based on the official source code and documentation.

**Key Principles:**

- No context needed - inject and retrieve dependencies from anywhere
- Automatic memory management - unused dependencies are cleaned up
- Lazy loading support for performance optimization
- Bindings integrate routes, state, and dependencies
- SmartManagement controls automatic disposal behavior

## Instancing Methods

### Get.put()

The most common way to insert a dependency. Good for controllers of your views.

```dart
Get.put<SomeClass>(SomeClass());
Get.put<LoginController>(LoginController(), permanent: true);
Get.put<ListItemController>(ListItemController(), tag: "unique-string");
```

**Parameters:**

- `dependency` (required): The class instance to register
- `tag` (optional): Unique string for multiple instances of the same type
- `permanent` (optional, default: false): Keep instance alive throughout app

**Reference:** `lib/get_instance/src/extension_instance.dart:73`

### Get.lazyPut()

Lazy load a dependency - instantiated only when first used. Useful for expensive classes or when setting up multiple classes in one place.

```dart
// ApiMock will only be created when Get.find<ApiMock>() is first called
Get.lazyPut<ApiMock>(() => ApiMock());

Get.lazyPut<FirebaseAuth>(
  () {
    // ... some logic if needed
    return FirebaseAuth();
  },
  tag: Math.random().toString(),
  fenix: true,
);
```

**Parameters:**

- `builder` (required): Function that returns the instance
- `tag` (optional): Unique string for multiple instances
- `fenix` (optional, default: false): Recreate instance if removed (similar to SmartManagement.keepFactory)
- `permanent` (optional, default: false): Keep instance alive

**Reference:** `lib/get_instance/src/extension_instance.dart:108`

**Note:** `fenix: true` keeps the factory in memory, allowing recreation after disposal. This is useful when combined with GetxController lifecycle methods.

### Get.putAsync()

Register an asynchronous instance:

```dart
Get.putAsync<SharedPreferences>(() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('counter', 12345);
  return prefs;
});

Get.putAsync<YourAsyncClass>(() async => await YourAsyncClass());
```

**Parameters:**

- `builder` (required): Async function that returns the instance
- `tag` (optional): Unique string for multiple instances
- `permanent` (optional, default: false): Keep instance alive

**Reference:** `lib/get_instance/src/extension_instance.dart`

### Get.create()

Creates a new instance every time `Get.find()` is called. Use with `GetWidget` for list items that need unique controllers.

```dart
Get.create<SomeClass>(() => SomeClass());
Get.create<LoginController>(() => LoginController());
```

**Parameters:**

- `builder` (required): Function that returns a new instance
- `name` (optional): Unique string (note: uses `name` not `tag`)
- `permanent` (optional, default: true): Keep factory alive

**Important:** `Get.create()` has `permanent: true` by default. It's designed for non-shared instances that shouldn't be disposed, like buttons in a ListView.

**Reference:** `lib/get_instance/src/extension_instance.dart`

## Using Instantiated Classes

### Get.find()

Retrieve a registered dependency:

```dart
final controller = Get.find<Controller>();
// OR
Controller controller = Get.find();
```

**With tag:**

```dart
final controller = Get.find<Controller>(tag: "unique-string");
```

**Reference:** `lib/get_instance/src/extension_instance.dart:278`

### Get.findOrNull()

Safely retrieve a dependency (returns null if not found):

```dart
final controller = Get.findOrNull<Controller>();
if (controller != null) {
  controller.doSomething();
}
```

**Reference:** `lib/get_instance/src/extension_instance.dart:303`

### Get.call()

Shortcut for `Get.find()`:

```dart
final controller = Get.call<Controller>();
// Equivalent to: Get.find<Controller>()
```

**Reference:** `lib/get_instance/src/extension_instance.dart:49`

## Specifying Alternate Instances

### Get.replace()

Replace an existing instance with a new one:

```dart
abstract class BaseClass {}
class ParentClass extends BaseClass {}
class ChildClass extends ParentClass {
  bool isChild = true;
}

Get.put<BaseClass>(ParentClass());
Get.replace<BaseClass>(ChildClass());

final instance = Get.find<BaseClass>();
print(instance is ChildClass); // true
```

**Reference:** `lib/get_instance/src/extension_instance.dart:313`

### Get.lazyReplace()

Replace with a lazy instance:

```dart
Get.lazyReplace<BaseClass>(() => OtherClass());

final instance = Get.find<BaseClass>();
print(instance is OtherClass); // true
```

**Reference:** `lib/get_instance/src/extension_instance.dart:327`

## Differences Between Methods

### permanent vs fenix

**permanent:** Instance stays in memory throughout the app lifetime. Use for services like SharedPreferences, API clients, etc.

```dart
Get.put<ApiService>(ApiService(), permanent: true);
```

**fenix:** Instance is disposed when not used, but factory remains. When needed again, a new instance is created from the factory. Similar to `SmartManagement.keepFactory`.

```dart
Get.lazyPut<Controller>(() => Controller(), fenix: true);
```

**Reference:** `lib/get_instance/src/extension_instance.dart:108`

### Method Comparison

| Method | When Created | Singleton | Permanent Default | Use Case |
|--------|--------------|-----------|-------------------|----------|
| `Get.put()` | Immediately | Yes | false | Controllers, services |
| `Get.lazyPut()` | On first `find()` | Yes | false | Expensive classes, optional dependencies |
| `Get.putAsync()` | After async completes | Yes | false | Async initialization (SharedPreferences, etc.) |
| `Get.create()` | Every `find()` call | No | true | List items, unique instances |

**Reference:** `lib/get_instance/src/extension_instance.dart`

## Bindings

Bindings integrate routes, state management, and dependency injection. They automatically dispose dependencies when routes are removed.

### Bindings Class

Create a class that implements `Bindings`:

```dart
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.put<Service>(Api());
  }
}

class DetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailsController>(() => DetailsController());
  }
}
```

**Reference:** `lib/get_instance/src/bindings_interface.dart`

### Using Bindings with Named Routes

```dart
getPages: [
  GetPage(
    name: '/',
    page: () => HomeView(),
    binding: HomeBinding(),
  ),
  GetPage(
    name: '/details',
    page: () => DetailsView(),
    binding: DetailsBinding(),
  ),
];
```

### Using Bindings with Direct Navigation

```dart
Get.to(() => HomeView(), binding: HomeBinding());
Get.to(() => DetailsView(), binding: DetailsBinding());
```

### Initial Binding

Register dependencies that should be available app-wide:

```dart
GetMaterialApp(
  initialBinding: SampleBind(),
  home: Home(),
);
```

### BindingsBuilder

Use a callback function instead of creating a class:

```dart
getPages: [
  GetPage(
    name: '/',
    page: () => HomeView(),
    binding: BindingsBuilder(() {
      Get.lazyPut<ControllerX>(() => ControllerX());
      Get.put<Service>(Api());
    }),
  ),
];
```

**Note:** The `BindingsBuilder` class is deprecated in favor of using a function directly. Use the callback pattern shown above.

**Reference:** `lib/get_instance/src/bindings_interface.dart:68`

## SmartManagement

SmartManagement controls how GetX automatically disposes unused dependencies.

### How to Change

Configure in `GetMaterialApp`:

```dart
void main() {
  runApp(
    GetMaterialApp(
      smartManagement: SmartManagement.onlyBuilder,
      home: Home(),
    ),
  );
}
```

**Reference:** `lib/get_core/src/smart_management.dart`

### SmartManagement.full (Default)

Disposes classes that are not being used and were not set to be permanent. This is the recommended setting for most cases.

**Behavior:**

- Disposes unused dependencies automatically
- Respects `permanent: true` flag
- Works with all instancing methods

**Reference:** `lib/get_core/src/smart_management.dart:4`

### SmartManagement.onlyBuilder

Only controllers started in `init:` or loaded into a Binding with `Get.lazyPut()` will be disposed.

**Behavior:**

- Only disposes dependencies from `init:` or `Bindings` with `lazyPut()`
- `Get.put()` and `Get.putAsync()` instances are NOT automatically disposed
- Use when you want manual control over most dependencies

**Reference:** `lib/get_core/src/smart_management.dart:8`

### SmartManagement.keepFactory

Just like `SmartManagement.full`, but keeps the factory. This means dependencies are removed when not used, but can be recreated if needed again.

**Behavior:**

- Disposes unused dependencies (like `full`)
- Keeps factory in memory for recreation
- Similar to `fenix: true` in `lazyPut()`

**Important:** DO NOT use `SmartManagement.keepFactory` if you are using multiple Bindings. It's designed for use without Bindings or with a single Binding in `initialBinding`.

**Reference:** `lib/get_core/src/smart_management.dart:14`

## How Bindings Work Under the Hood

Bindings create transitory factories that are:

- Created when you navigate to a screen
- Destroyed as soon as the screen-changing animation happens
- Recreated when you navigate to the screen again

This happens so fast that analyzers can't register it. Factories take up little memory - they don't hold instances, just a function with the "shape" of the class.

**Reference:** `documentation/en_US/dependency_management.md:397`

## Removing Instances

### Get.delete()

Manually remove an instance:

```dart
Get.delete<Controller>();
// Usually not needed - GetX automatically deletes unused controllers
```

**With tag:**

```dart
Get.delete<Controller>(tag: "unique-string");
```

### Get.resetInstance()

Clear all registered instances (useful for testing):

```dart
Get.resetInstance(clearRouteBindings: true);
```

**Reference:** `lib/get_instance/src/extension_instance.dart:30`

## Instance Information

### Get.isRegistered()

Check if a dependency is registered:

```dart
if (Get.isRegistered<Controller>()) {
  final controller = Get.find<Controller>();
}
```

### Get.getInstanceInfo()

Get information about a registered instance:

```dart
final info = Get.getInstanceInfo<Controller>();
print(info.isPermanent); // bool?
print(info.isSingleton); // bool?
print(info.isRegistered); // bool
```

**Reference:** `lib/get_instance/src/extension_instance.dart`

## Best Practices

### When to Use Each Method

- **Get.put()**: Controllers, services that are always needed
- **Get.lazyPut()**: Expensive classes, optional dependencies, services loaded in Bindings
- **Get.putAsync()**: Classes requiring async initialization (SharedPreferences, databases)
- **Get.create()**: List items needing unique controllers (use with GetWidget)

### Memory Management

- Use `permanent: true` only for app-wide services (API clients, storage, etc.)
- Use `fenix: true` when you want automatic recreation after disposal
- Let SmartManagement handle cleanup - avoid manual `delete()` unless necessary

### Bindings Organization

- Create one Binding per route for better organization
- Use `initialBinding` for app-wide dependencies
- Prefer `lazyPut()` in Bindings for better performance

### Common Mistakes

**❌ DON'T:** Use constructor for initialization → **✅ DO:** Use `onInit()` in controllers

**❌ DON'T:** Call `Get.put()` multiple times → **✅ DO:** Use `Get.find()` after first `put()`

**❌ DON'T:** Use `Get.create()` without `GetWidget` → **✅ DO:** Use `GetWidget` to cache controller

**❌ DON'T:** Use `SmartManagement.keepFactory` with multiple Bindings → **✅ DO:** Use `full` or `onlyBuilder`

**❌ DON'T:** Forget to use Bindings → **✅ DO:** Use Bindings for automatic cleanup

**❌ DON'T:** Use `permanent: true` for route-specific controllers → **✅ DO:** Use `permanent: true` only for app-wide services

## Integration with State Management

When using GetX State Manager, Bindings make it easier to connect views to controllers:

```dart
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

// In route
GetPage(
  name: '/home',
  page: () => HomeView(),
  binding: HomeBinding(),
)

// In view - controller is automatically available
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Text(controller.title);
  }
}
```

**Reference:** `lib/get_instance/src/bindings_interface.dart`
