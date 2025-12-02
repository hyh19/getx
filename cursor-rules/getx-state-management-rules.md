---
description: Use when working with GetX state management, reactive variables (.obs), GetX/Obx widgets, GetBuilder, GetxController lifecycle, StateMixin, or workers
---

# GetX State Management Rules

## Overview

GetX provides two state management approaches: **Reactive State Manager** (GetX/Obx) and **Simple State Manager** (GetBuilder). This rule file guides proper usage patterns based on the official source code and documentation.

**Key Principles:**

- GetX does not use Streams or ChangeNotifier for better performance
- Reactive programming is as simple as using `setState`
- No code generators required
- Controllers are automatically managed and disposed when not in use

## Reactive State Manager

### Creating Observable Variables

Three ways to create reactive variables (`.obs` is preferred):

```dart
// Method 1: Rx{Type} constructors
final name = RxString('');
final count = RxInt(0);

// Method 2: Rx<Type> with generics
final name = Rx<String>('');
final user = Rx<User>();

// Method 3: .obs extension (Preferred)
final name = ''.obs;
final count = 0.obs;
final items = <String>[].obs;
final user = User().obs;
```

**Reference:** `lib/get_rx/src/rx_types/rx_types.dart`

### Using Reactive Variables in UI

Wrap widgets with `Obx()`, `GetX<Controller>()`, or `ObxValue()`:

```dart
// Obx (Simplest)
final count = 0.obs;
Obx(() => Text('${count.value}'))

// GetX (Type-safe)
GetX<Controller>(
  builder: (controller) => Text('${controller.count.value}'),
)

// ObxValue (Local state)
ObxValue((data) => Switch(
  value: data.value,
  onChanged: (flag) => data.value = flag,
), false.obs)
```

**Reference:** `lib/get_state_manager/src/rx_flutter/rx_obx_widget.dart`

### Accessing Values

**Primitive types require `.value`:**

```dart
final name = 'GetX'.obs;
name.value = 'New Value';
```

**Lists/Maps: Direct access (no `.value` needed):**

```dart
final items = <String>[].obs;
items.add('item');
```

**Custom classes: Use `.value` or `.update()`:**

```dart
final user = User().obs;
user.value.name = 'New Name';
user.refresh(); // Or use:
user.update((value) {
  value.name = 'New Name';
  value.age = 25;
});
```

**Reference:** `lib/get_rx/src/rx_types/rx_core/rx_impl.dart`

**Notes:** Always initialize Rx variables. Lists are fully observable. GetX only rebuilds when value actually changes. First rebuild always triggers (for boolean compatibility).

## Simple State Manager

### Creating Controllers

Extend `GetxController` and use `update()` to notify listeners:

```dart
class CounterController extends GetxController {
  int counter = 0;
  
  void increment() {
    counter++;
    update(); // Triggers UI update
  }
}
```

**Reference:** `lib/get_state_manager/src/simple/get_controllers.dart`

### Using GetBuilder

Wrap widgets with `GetBuilder<Controller>`. Only use `init` the first time:

```dart
// First usage
GetBuilder<CounterController>(
  init: CounterController(),
  builder: (controller) => Text('${controller.counter}'),
)

// Later usage (omit init)
GetBuilder<CounterController>(
  builder: (controller) => Text('${controller.counter}'),
)
```

**Reference:** `lib/get_state_manager/src/simple/get_state.dart`

### Granular Updates with Unique IDs

```dart
GetBuilder<Controller>(
  id: 'counter',
  builder: (controller) => Text('${controller.counter}'),
)
// In controller: update(['counter']);
// With condition: update(['counter'], counter < 10);
```

## Controllers and Lifecycle

### GetxController (Base Controller)

Base controller with lifecycle methods:

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Called when controller is created
  }

  @override
  void onReady() {
    super.onReady();
    // Called after widget is rendered
  }

  @override
  void onClose() {
    // Cleanup: close streams, cancel timers
    super.onClose();
  }
}
```

**Important:** DO NOT use constructors for initialization - use `onInit()` instead. DO NOT override `dispose()` - use `onClose()` instead.

**Reference:** `lib/get_state_manager/src/simple/get_controllers.dart`

### GetNotifier (State + Lifecycle)

Combines `StateMixin<T>` with lifecycle. Use for controllers needing both:

```dart
class UserController extends GetNotifier<User?> {
  UserController() : super(null);
  
  void loadUser() async {
    setLoading();
    try {
      setSuccess(await fetchUser());
    } catch (e) {
      setError(e.toString());
    }
  }
}
```

**Reference:** `lib/get_state_manager/src/rx_flutter/rx_notifier.dart`

### RxController (Lightweight Reactive)

For controllers with only reactive variables (no `update()` needed):

```dart
class UserController extends RxController {
  final name = 'John'.obs;
  final age = 30.obs;
}
```

### StateController (Async Operations)

`GetxController` + `StateMixin<T>` for async operations:

```dart
class UserController extends StateController<User> {
  Future<void> fetchUser() async {
    change(null, status: RxStatus.loading());
    try {
      change(await userRepository.getUser(), status: RxStatus.success());
    } catch (e) {
      change(state, status: RxStatus.error(e.toString()));
    }
  }
}
```

### FullLifeCycleController (App Lifecycle)

Observes app lifecycle (resumed, paused, etc.):

```dart
class HomeController extends FullLifeCycleController with FullLifeCycleMixin {
  @override
  void onResumed() => refreshData();
  @override
  void onPaused() => pauseRequests();
}
```

### SuperController (Full Lifecycle + State)

Combines `FullLifeCycleController` + `StateMixin<T>`:

```dart
class HomeController extends SuperController<HomeState> {
  @override
  void onResumed() => fetchData();
  
  Future<void> fetchData() async {
    setLoading();
    try {
      setSuccess(HomeState(data: await repository.getData()));
    } catch (e) {
      setError(e.toString());
    }
  }
}
```

**Reference:** `lib/get_state_manager/src/simple/get_controllers.dart`

### GetxService (Persistent Services)

For services that persist throughout app lifetime:

```dart
class ApiService extends GetxService {
  @override
  void onInit() {
    super.onInit();
    // Initialize service
  }
}

void main() async {
  await Get.putAsync(() => ApiService().init());
  runApp(MyApp());
}
```

## Workers

Workers listen to reactive variable changes and execute callbacks. Always initialize workers in `onInit()`:

**ever()** - Called every time variable changes:

```dart
worker = ever(count, (value) => print('Changed: $value'),
  condition: () => count.value > 5);
```

**once()** - Called only first time:

```dart
worker = once(count, (value) => print('Reached: $value'));
```

**debounce()** - Anti-DDoS for search (waits for user to stop typing):

```dart
debounce(searchText, (value) => searchAPI(value),
  time: Duration(seconds: 1));
```

**interval()** - Rate limiting (ignores changes within period):

```dart
interval(clicks, (value) => processClick(value),
  time: Duration(seconds: 1));
```

**Always initialize workers in `onInit()` and dispose in `onClose()`.**

**Reference:** `lib/get_rx/src/rx_workers/rx_workers.dart`

## StateMixin

Use `StateMixin<T>` for async operations with loading/error states:

```dart
class UserController extends GetxController with StateMixin<User> {
  void loadUser() async {
    change(null, status: RxStatus.loading());
    try {
      final user = await fetchUser();
      change(user, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}

// UI Usage
controller.obx(
  (user) => Text(user.name),
  onLoading: CircularProgressIndicator(),
  onEmpty: Text('No user found'),
  onError: (error) => Text('Error: $error'),
)
```

**RxStatus:** `RxStatus.loading()`, `RxStatus.success()`, `RxStatus.empty()`, `RxStatus.error('message')`

**Reference:** `lib/get_state_manager/src/rx_flutter/rx_notifier.dart`

## Best Practices

### When to Use Each Approach

**Reactive (GetX/Obx):** Granular control, complex flows, automatic dependency tracking
**Simple (GetBuilder):** Multiple widgets, minimal memory, simple state changes

**Performance:** GetX rebuilds only when value changes. GetBuilder is more memory efficient. Obx is lighter than GetX. Avoid 30+ streams.

### Common Mistakes

**❌ DON'T:** Use constructor for initialization → **✅ DO:** Use `onInit()`
**❌ DON'T:** Override `dispose()` → **✅ DO:** Use `onClose()`
**❌ DON'T:** `list.value.add()` → **✅ DO:** `list.add()` (direct access)
**❌ DON'T:** Initialize controller multiple times → **✅ DO:** Only init once

### Controller Selection Guide

- **GetxController**: Basic controller with `update()` method
- **RxController**: Only reactive variables, no `update()`
- **StateController**: Async operations with StateMixin
- **GetNotifier**: StateMixin + lifecycle, native status/state
- **FullLifeCycleController**: App lifecycle awareness
- **SuperController**: Full lifecycle + StateMixin (most complete)

### Accessing Controllers

**Static getter (Recommended):**

```dart
class Controller extends GetxController {
  static Controller get to => Get.find();
}
Controller.to.increment();
```

**Get.find():**

```dart
final controller = Get.find<Controller>();
```

**GetView (For widget classes):**

```dart
class MyView extends GetView<Controller> {
  @override
  Widget build(BuildContext context) => Text('${controller.counter}');
}
```

## Widget Helpers

### GetView (Quick Controller Access)

Stateless widget with direct controller access:

```dart
class MyView extends GetView<MyController> {
  @override
  Widget build(BuildContext context) => Text('${controller.title}');
}
```

### GetWidget (Cached Controller)

Caches controller instance. Use with `Get.create()` for multiple instances:

```dart
class TodoItem extends GetWidget<TodoController> {
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(controller.title),
  );
}
```

**Reference:** `lib/get_state_manager/src/simple/get_view.dart`

## Responsive Widgets

### GetResponsiveView / GetResponsiveWidget

Responsive layouts based on screen size:

```dart
class HomeView extends GetResponsiveView<HomeController> {
  HomeView() : super(alwaysUseBuilder: false);
  
  @override
  Widget? desktop() => DesktopLayout();
  @override
  Widget? tablet() => TabletLayout();
  @override
  Widget? phone() => PhoneLayout();
  @override
  Widget? watch() => WatchLayout();
}
```

**Screen Types:** `screen.isDesktop`, `screen.isTablet`, `screen.isPhone`, `screen.isWatch`

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart`

## Mixing State Managers

You can mix both approaches in the same controller:

```dart
class MixedController extends GetxController {
  // Reactive
  final count = 0.obs;
  
  // Simple
  String name = '';
  
  void updateName(String newName) {
    name = newName;
    update(); // Simple state update
  }
  
  void increment() {
    count.value++; // Reactive update
  }
}
```

Use `MixinBuilder` if you need both reactive and simple updates in the same widget (note: highest resource consumption).
