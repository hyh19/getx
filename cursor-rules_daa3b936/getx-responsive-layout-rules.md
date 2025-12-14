---
description: Use when working with GetX responsive layouts, GetResponsiveView, GetResponsiveWidget, ResponsiveScreen, screen breakpoints, or adaptive UI design
alwaysApply: false
---

# GetX Responsive Layout Rules

## Overview

GetX provides powerful responsive layout widgets that automatically adapt UI based on screen size. This rule file guides proper usage patterns based on the official source code and documentation.

**Key Principles:**

- Build different layouts for desktop, tablet, phone, and watch without manual screen size checks
- Automatic fallback chain ensures content is always displayed
- Platform-aware width detection (desktop uses width, mobile uses shortest side)
- Two flexible building patterns: single builder method or separate methods per screen type
- Customizable breakpoints for different device categories

## GetResponsiveView

Extends `GetView<T>` with responsive capabilities. Provides access to controller and screen information.

### Basic Usage with Specific Methods

Override `desktop()`, `tablet()`, `phone()`, and `watch()` methods. Set `alwaysUseBuilder: false`:

```dart
class HomeView extends GetResponsiveView<HomeController> {
  HomeView({super.key}) : super(alwaysUseBuilder: false);

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

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:55-67`

### Usage with Builder Method

Use a single `builder()` method with conditional logic. Set `alwaysUseBuilder: true`:

```dart
class HomeView extends GetResponsiveView<HomeController> {
  HomeView({super.key}) : super(alwaysUseBuilder: true);

  @override
  Widget? builder() {
    if (screen.isDesktop) {
      return DesktopLayout();
    } else if (screen.isTablet) {
      return TabletLayout();
    } else if (screen.isPhone) {
      return PhoneLayout();
    } else {
      return WatchLayout();
    }
  }
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:32`

### Fallback Behavior

When using specific methods, GetX automatically falls back to larger screen types if a method returns `null`:

- Desktop → Tablet → Phone → Watch
- Tablet → Desktop (if tablet returns null)
- Phone → Tablet → Desktop (if phone returns null)
- Watch → Phone → Tablet → Desktop → Builder (if watch returns null)

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:17-29`

### Accessing Controller

Since `GetResponsiveView` extends `GetView<T>`, you have direct access to the controller:

```dart
class HomeView extends GetResponsiveView<HomeController> {
  HomeView({super.key}) : super(alwaysUseBuilder: false);

  @override
  Widget? desktop() {
    return Scaffold(
      body: Text(controller.title), // Direct controller access
    );
  }
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:55`

## GetResponsiveWidget

Extends `GetWidget<T>` with responsive capabilities. Use when you need controller caching, typically with `Get.create()`.

### Basic Usage

```dart
class TodoItem extends GetResponsiveWidget<TodoController> {
  TodoItem({super.key}) : super(alwaysUseBuilder: false);

  @override
  Widget? desktop() => DesktopTodoItem();

  @override
  Widget? phone() => PhoneTodoItem();
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:69-82`

### Use Case: Multiple Instances

`GetResponsiveWidget` is useful when using `Get.create()` for list items:

```dart
// Create multiple controller instances
Get.create(() => TodoController(id: '1'));
Get.create(() => TodoController(id: '2'));

// Each widget uses its own controller instance
class TodoListItem extends GetResponsiveWidget<TodoController> {
  TodoListItem({super.key}) : super(alwaysUseBuilder: false);

  @override
  Widget? phone() {
    return ListTile(
      title: Text(controller.title), // Each instance has its own controller
    );
  }
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:69-82`

## ResponsiveScreen

The `screen` property provides screen information and responsive utilities.

### Screen Information

```dart
class MyView extends GetResponsiveView<MyController> {
  @override
  Widget? builder() {
    // Screen dimensions
    final width = screen.width;
    final height = screen.height;

    // Screen type checks
    if (screen.isDesktop) { /* ... */ }
    if (screen.isTablet) { /* ... */ }
    if (screen.isPhone) { /* ... */ }
    if (screen.isWatch) { /* ... */ }

    // Screen type enum
    final type = screen.screenType; // ScreenType.desktop, etc.

    return Container();
  }
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:107-144`

### Platform-Aware Width Detection

GetX automatically uses the appropriate width measurement:

- **Desktop platforms**: Uses `context.width` (full screen width)
- **Mobile platforms**: Uses `context.mediaQueryShortestSide` (shortest side for orientation)

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:131-136`

### Responsive Value Selection

Use `responsiveValue<T>()` to return different values based on screen type:

```dart
class MyView extends GetResponsiveView<MyController> {
  @override
  Widget? builder() {
    final padding = screen.responsiveValue<double>(
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      watch: 8.0,
    );

    final columns = screen.responsiveValue<int>(
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return Container(
      padding: EdgeInsets.all(padding ?? 16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns ?? 1,
        ),
        itemBuilder: (context, index) => ItemWidget(),
      ),
    );
  }
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:152-162`

### Responsive Value Fallback

The `responsiveValue()` method follows the same fallback chain:

- Desktop → Tablet → Phone → Watch
- Returns `null` if no value is provided for any screen type

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:152-162`

## ResponsiveScreenSettings

Configure custom breakpoints for screen type detection.

### Default Breakpoints

```dart
const ResponsiveScreenSettings(
  desktopChangePoint: 1200,  // Width >= 1200: Desktop
  tabletChangePoint: 600,      // Width >= 600: Tablet
  watchChangePoint: 300,       // Width < 300: Watch
);
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:84-105`

### Custom Breakpoints

```dart
class CustomResponsiveView extends GetResponsiveView<MyController> {
  CustomResponsiveView({super.key})
      : super(
          settings: ResponsiveScreenSettings(
            desktopChangePoint: 1440,  // Large desktop screens
            tabletChangePoint: 768,     // iPad size
            watchChangePoint: 320,      // Small phones
          ),
        );

  @override
  Widget? desktop() => DesktopLayout();
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:84-105`

### Screen Type Logic

Screen types are determined by width thresholds:

- **Desktop**: `width >= desktopChangePoint` (default: 1200)
- **Tablet**: `width >= tabletChangePoint && width < desktopChangePoint` (default: 600-1199)
- **Phone**: `width >= watchChangePoint && width < tabletChangePoint` (default: 300-599)
- **Watch**: `width < watchChangePoint` (default: < 300)

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:138-144`

## ScreenType Enum

Enum representing different screen types:

```dart
enum ScreenType {
  watch,
  phone,
  tablet,
  desktop,
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:165-170`

### Using ScreenType

```dart
class MyView extends GetResponsiveView<MyController> {
  @override
  Widget? builder() {
    switch (screen.screenType) {
      case ScreenType.desktop:
        return DesktopLayout();
      case ScreenType.tablet:
        return TabletLayout();
      case ScreenType.phone:
        return PhoneLayout();
      case ScreenType.watch:
        return WatchLayout();
    }
  }
}
```

**Reference:** `lib/get_state_manager/src/simple/get_responsive.dart:165-170`

## Building Patterns

### Pattern 1: Specific Methods (Recommended for Clear Separation)

Use when different screen types have significantly different layouts:

```dart
class HomeView extends GetResponsiveView<HomeController> {
  HomeView({super.key}) : super(alwaysUseBuilder: false);

  @override
  Widget? desktop() => DesktopHomeLayout();

  @override
  Widget? tablet() => TabletHomeLayout();

  @override
  Widget? phone() => PhoneHomeLayout();

  @override
  Widget? watch() => WatchHomeLayout();
}
```

**Advantages:**

- Clear separation of concerns
- Easy to maintain different layouts
- Automatic fallback handling

### Pattern 2: Builder Method (Recommended for Shared Logic)

Use when layouts share most of the code with minor variations:

```dart
class HomeView extends GetResponsiveView<HomeController> {
  HomeView({super.key}) : super(alwaysUseBuilder: true);

  @override
  Widget? builder() {
    final columns = screen.responsiveValue<int>(
      mobile: 1,
      tablet: 2,
      desktop: 4,
    ) ?? 1;

    final padding = screen.isDesktop ? 32.0 : 16.0;

    return Scaffold(
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
        ),
        itemBuilder: (context, index) => ItemCard(),
      ),
    );
  }
}
```

**Advantages:**

- Shared logic in one place
- Easy to maintain consistency
- Good for layouts with minor variations

## Best Practices

### Choosing the Right Widget

- **Use `GetResponsiveView`**: For most cases, when using standard dependency injection
- **Use `GetResponsiveWidget`**: Only when using `Get.create()` for multiple controller instances

### Building Pattern Selection

- **Use specific methods**: When layouts are significantly different across screen types
- **Use builder method**: When layouts share most code with minor variations

### Breakpoint Configuration

- Set breakpoints based on your target devices and user base
- Test breakpoints on actual devices when possible
- Consider common device sizes (iPhone, iPad, Android tablets, desktop)

### Fallback Strategy

- Always provide at least one non-null return value
- Test the fallback chain to ensure content is always displayed
- Consider providing watch layout even if minimal

### Performance

- Avoid heavy computations in build methods
- Use `responsiveValue()` for simple value selection
- Consider extracting layout widgets to separate classes

### Code Organization

- Extract layout widgets to separate files for better organization
- Use consistent naming: `DesktopLayout`, `TabletLayout`, etc.
- Group responsive views in a dedicated folder structure

## Common Mistakes

**❌ DON'T:** Set `alwaysUseBuilder: false` but only override `builder()` → **✅ DO:** Override specific methods (`desktop()`, `tablet()`, etc.) when `alwaysUseBuilder: false`

**❌ DON'T:** Return `null` from all methods → **✅ DO:** Always provide at least one non-null return value

**❌ DON'T:** Use `GetResponsiveWidget` without `Get.create()` → **✅ DO:** Use `GetResponsiveView` for standard dependency injection

**❌ DON'T:** Hardcode screen size checks → **✅ DO:** Use `screen.isDesktop`, `screen.isTablet`, etc.

**❌ DON'T:** Forget to set `alwaysUseBuilder` correctly → **✅ DO:** Set `alwaysUseBuilder: false` when using specific methods, `true` when using builder

**❌ DON'T:** Ignore fallback behavior → **✅ DO:** Understand and test the fallback chain (desktop → tablet → phone → watch)

**❌ DON'T:** Use desktop width logic on mobile → **✅ DO:** Let GetX handle platform-aware width detection automatically

## Integration with Context Extensions

GetX also provides context extensions for responsive design (see `getx-utils-rules.md`):

```dart
// Context extensions (from getx-utils-rules.md)
context.width; // Screen width
context.height; // Screen height
context.isPhone; // Shortest side < 600
context.isTablet; // Shortest side >= 600
context.isDesktop; // Width <= 1200

// ResponsiveScreen (this rule)
screen.width; // Same as context.width
screen.isPhone; // Based on ResponsiveScreenSettings
screen.isDesktop; // Based on ResponsiveScreenSettings
```

**Note:** `ResponsiveScreen` uses `ResponsiveScreenSettings` for breakpoints, while context extensions use fixed breakpoints. Use `ResponsiveScreen` when you need customizable breakpoints.

## Reference Files

- Source code: `lib/get_state_manager/src/simple/get_responsive.dart`
- Related: `cursor-rules/getx-state-management-rules.md` (GetView, GetWidget)
- Related: `cursor-rules/getx-utils-rules.md` (Context extensions for responsive design)
