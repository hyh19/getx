---
description: Overview and navigation guide for all GetX rule files. Use this file to understand which GetX rule to reference for specific tasks and how the rules work together.
alwaysApply: true
---

# GetX

## Overview

This file serves as an index and navigation guide for all GetX-related cursor rules. GetX is a powerful Flutter framework that provides state management, dependency injection, route management, internationalization, theme management, responsive layouts, and utilities in a simple, performant package.

**Purpose of This File:**

- Quick reference to find the right rule file for your task
- Understanding how different GetX features work together
- Best practices for combining multiple GetX features
- Common patterns and examples

## GetX Rule Files

The GetX framework is organized into 7 specialized rule files, each covering a specific aspect of the framework:

### 1. Dependency Management

**File:** `getx-dependency-management-rules.mdc`

**When to Use:** Working with dependency injection, `Get.put()`/`Get.lazyPut()`/`Get.putAsync()`/`Get.create()`, Bindings, SmartManagement, or dependency lifecycle management.

**Key Topics:**

- Instancing methods (`Get.put()`, `Get.lazyPut()`, `Get.putAsync()`, `Get.create()`)
- Using dependencies (`Get.find()`, `Get.findOrNull()`)
- Bindings for route-based dependency injection
- SmartManagement configuration
- Memory management and disposal

**Reference:** Use this rule when you need to inject controllers, services, or any dependencies into your app.

### 2. State Management

**File:** `getx-state-management-rules.mdc`

**When to Use:** Working with GetX state management, reactive variables (`.obs`), `GetX`/`Obx` widgets, `GetBuilder`, `GetxController` lifecycle, `StateMixin`, or workers.

**Key Topics:**

- Reactive State Manager (`.obs`, `Obx`, `GetX`)
- Simple State Manager (`GetBuilder`, `update()`)
- Controller lifecycle (`onInit()`, `onReady()`, `onClose()`)
- Workers (`ever()`, `once()`, `debounce()`, `interval()`)
- `StateMixin` for async operations
- Controller types (`GetxController`, `RxController`, `StateController`, etc.)

**Reference:** Use this rule when managing application state, creating controllers, or working with reactive variables.

### 3. Route Management

**File:** `getx-route-management-rules.mdc`

**When to Use:** Working with GetX navigation, routes, `Get.to()`/`Get.toNamed()`, route middleware, context-free dialogs/snackbars, or route transitions.

**Key Topics:**

- Navigation without context (`Get.to()`, `Get.back()`, `Get.off()`)
- Named routes (`Get.toNamed()`, route configuration)
- Dynamic URLs and parameters
- Route middleware
- Context-free dialogs, snackbars, and bottom sheets
- Route transitions

**Reference:** Use this rule when implementing navigation, showing dialogs/snackbars, or working with routes.

### 4. Internationalization

**File:** `getx-internationalization-rules.mdc`

**When to Use:** Working with GetX internationalization, translations, locale management, `.tr` extension, `trParams`, `trPlural`, or multi-language support.

**Key Topics:**

- Creating translations (`Translations` class)
- Basic translation (`.tr` extension)
- Translation with parameters (`trParams`, `trArgs`)
- Pluralization (`trPlural`)
- Dynamic locale changes (`Get.updateLocale()`)
- Locale management

**Reference:** Use this rule when implementing multi-language support or managing translations.

### 5. Theme Management

**File:** `getx-theme-rules.mdc`

**When to Use:** Working with GetX theme management, `Get.changeTheme()`, `Get.isDarkMode`, context theme extensions, or custom theme creation.

**Key Topics:**

- Context extensions for theme (`context.theme`, `context.isDarkMode`)
- Changing theme (`Get.changeTheme()`)
- Toggling theme
- Custom themes
- Theme persistence

**Reference:** Use this rule when implementing theme switching, dark mode, or custom themes.

### 6. Utilities

**File:** `getx-utils-rules.mdc`

**When to Use:** Working with GetX utilities, `GetUtils` validation, context extensions, string/number extensions, or platform detection.

**Key Topics:**

- `GetUtils` validation methods
- Context extensions (responsive design, media queries)
- String, number, and duration extensions
- Platform detection (`GetPlatform`)
- Widget extensions (padding, margin, sliver conversion)
- Event loop extensions

**Reference:** Use this rule when you need validation, responsive design helpers, or utility functions.

### 7. Responsive Layout

**File:** `getx-responsive-layout-rules.mdc`

**When to Use:** Working with GetX responsive layouts, `GetResponsiveView`, `GetResponsiveWidget`, `ResponsiveScreen`, screen breakpoints, or adaptive UI design.

**Key Topics:**

- `GetResponsiveView` and `GetResponsiveWidget` for adaptive layouts
- Building patterns (builder method vs specific methods)
- `ResponsiveScreen` for screen information and utilities
- `ResponsiveScreenSettings` for custom breakpoints
- Screen type detection (desktop, tablet, phone, watch)
- Fallback behavior and responsive value selection

**Reference:** Use this rule when building responsive layouts that adapt to different screen sizes (desktop, tablet, phone, watch).

## Quick Decision Guide

### What are you trying to do?

**Inject a controller or service?**
→ Use `getx-dependency-management-rules.mdc`

**Manage application state?**
→ Use `getx-state-management-rules.mdc`

**Navigate to a new screen or show a dialog?**
→ Use `getx-route-management-rules.mdc`

**Add multi-language support?**
→ Use `getx-internationalization-rules.mdc`

**Implement theme switching or dark mode?**
→ Use `getx-theme-rules.mdc`

**Build responsive layouts for different screen sizes?**
→ Use `getx-responsive-layout-rules.mdc`

**Need validation, responsive helpers, or utilities?**
→ Use `getx-utils-rules.mdc`

## Common Scenarios

### Scenario 1: Creating a New Page

**Required Rules:**

1. `getx-route-management-rules.mdc` - Define route and navigation
2. `getx-dependency-management-rules.mdc` - Create Binding for controller
3. `getx-state-management-rules.mdc` - Create controller with state

**Example Flow:**

```dart
// 1. Create controller (State Management)
class HomeController extends GetxController {
  final count = 0.obs;
}

// 2. Create binding (Dependency Management)
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

// 3. Define route (Route Management)
GetPage(
  name: '/home',
  page: () => HomeView(),
  binding: HomeBinding(),
)
```

### Scenario 2: Theme Switching with Internationalization

**Required Rules:**

1. `getx-theme-rules.mdc` - Theme management
2. `getx-internationalization-rules.mdc` - Translation strings

**Example:**

```dart
// Theme toggle button with translation
ElevatedButton(
  onPressed: () {
    Get.changeTheme(
      Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
    );
  },
  child: Text('theme_toggle'.tr), // Translation
)
```

### Scenario 3: Form Validation with Responsive Layout

**Required Rules:**

1. `getx-utils-rules.mdc` - Validation and responsive helpers
2. `getx-state-management-rules.mdc` - Form state
3. `getx-responsive-layout-rules.mdc` - Responsive layout (optional, for complex layouts)

**Example:**

```dart
// Responsive form with validation
class FormController extends GetxController {
  final email = ''.obs;
  
  bool validateEmail() {
    return GetUtils.isEmail(email.value);
  }
}

// In widget (using context extensions from utils)
Container(
  width: context.isPhone ? context.width : 400,
  child: TextField(
    onChanged: (value) => controller.email.value = value,
  ),
)

// Or using GetResponsiveView for complex responsive layouts
class FormView extends GetResponsiveView<FormController> {
  FormView({super.key}) : super(alwaysUseBuilder: false);
  
  @override
  Widget? desktop() => DesktopFormLayout();
  
  @override
  Widget? phone() => PhoneFormLayout();
}
```

### Scenario 4: Responsive Layout with State Management

**Required Rules:**

1. `getx-responsive-layout-rules.mdc` - Responsive layout widgets
2. `getx-state-management-rules.mdc` - Controller with state
3. `getx-dependency-management-rules.mdc` - Binding for controller

**Example:**

```dart
// 1. Create controller (State Management)
class HomeController extends GetxController {
  final items = <String>[].obs;
}

// 2. Create binding (Dependency Management)
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

// 3. Create responsive view (Responsive Layout)
class HomeView extends GetResponsiveView<HomeController> {
  HomeView({super.key}) : super(alwaysUseBuilder: false);
  
  @override
  Widget? desktop() {
    return DesktopLayout(
      items: controller.items,
    );
  }
  
  @override
  Widget? tablet() {
    return TabletLayout(
      items: controller.items,
    );
  }
  
  @override
  Widget? phone() {
    return PhoneLayout(
      items: controller.items,
    );
  }
}
```

## How Rules Work Together

### Typical App Structure

Most GetX applications combine multiple features:

1. **Routes** define navigation structure
2. **Bindings** inject dependencies when routes are accessed
3. **Controllers** manage state for each route
4. **Translations** provide multi-language support
5. **Themes** control app appearance
6. **Responsive Layouts** adapt UI to different screen sizes
7. **Utils** provide validation and helpers

### Integration Example

```dart
// Complete example combining multiple features

// 1. Translations (Internationalization)
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'welcome': 'Welcome',
      'theme': 'Theme',
    },
  };
}

// 2. Controller (State Management)
class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(
      isDarkMode.value ? ThemeData.dark() : ThemeData.light(),
    );
  }
}

// 3. Binding (Dependency Management)
class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}

// 4. Route (Route Management)
GetPage(
  name: '/settings',
  page: () => SettingsView(),
  binding: SettingsBinding(),
)

// 5. View with responsive design (Utils)
class SettingsView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: Container(
        padding: EdgeInsets.all(context.isPhone ? 16 : 24),
        child: Obx(() => Switch(
          value: controller.isDarkMode.value,
          onChanged: (_) => controller.toggleTheme(),
        )),
      ),
    );
  }
}
```

## Best Practices

### Combining Rules

1. **Use Bindings for Route Dependencies**
   - Always use Bindings with routes to ensure proper cleanup
   - Prefer `Get.lazyPut()` in Bindings for better performance

2. **Controllers Should Extend GetxController**
   - Use lifecycle methods (`onInit()`, `onReady()`, `onClose()`)
   - Don't use constructors for initialization

3. **Use Context Extensions When Available**
   - Prefer `context.theme` over `Theme.of(context)`
   - Use `context.width`/`context.height` for responsive design

4. **Keep Translations Organized**
   - Split large translation files by language
   - Use descriptive keys (e.g., `home_welcome` not just `welcome`)

5. **Theme Management**
   - Store theme preference for persistence
   - Use `Get.changeTheme()` directly, don't create ThemeProvider

### Common Mistakes to Avoid

**❌ DON'T:** Mix context-based navigation with GetX navigation
**✅ DO:** Use `Get.to()` or `Get.toNamed()` consistently

**❌ DON'T:** Initialize controllers in constructors
**✅ DO:** Use `onInit()` for initialization

**❌ DON'T:** Use `Get.put()` multiple times for the same controller
**✅ DO:** Use `Get.find()` after the first `put()`

**❌ DON'T:** Forget to use Bindings with routes
**✅ DO:** Always use Bindings for automatic cleanup

**❌ DON'T:** Use `Get.height` for responsive layouts
**✅ DO:** Use `context.height` (updates on resize)

**❌ DON'T:** Create ThemeProvider widgets
**✅ DO:** Use `Get.changeTheme()` directly

### Performance Considerations

1. **Use `lazyPut()` in Bindings** - Controllers are only created when needed
2. **Prefer `Obx` over `GetX`** - `Obx` is lighter for simple cases
3. **Use `GetBuilder` for multiple widgets** - More memory efficient than reactive
4. **Avoid 30+ reactive streams** - Can impact performance
5. **Use `permanent: true` sparingly** - Only for app-wide services

## Quick Reference

| Task | Rule File | Key Method/Class |
|------|-----------|------------------|
| Inject dependency | `getx-dependency-management-rules.mdc` | `Get.put()`, `Get.lazyPut()` |
| Find dependency | `getx-dependency-management-rules.mdc` | `Get.find()` |
| Create reactive variable | `getx-state-management-rules.mdc` | `.obs` extension |
| Update UI reactively | `getx-state-management-rules.mdc` | `Obx()`, `GetX()` |
| Navigate to screen | `getx-route-management-rules.mdc` | `Get.to()`, `Get.toNamed()` |
| Show dialog | `getx-route-management-rules.mdc` | `Get.dialog()` |
| Show snackbar | `getx-route-management-rules.mdc` | `Get.snackbar()` |
| Translate text | `getx-internationalization-rules.mdc` | `.tr` extension |
| Change locale | `getx-internationalization-rules.mdc` | `Get.updateLocale()` |
| Change theme | `getx-theme-rules.mdc` | `Get.changeTheme()` |
| Check dark mode | `getx-theme-rules.mdc` | `Get.isDarkMode` |
| Validate email | `getx-utils-rules.mdc` | `GetUtils.isEmail()` |
| Responsive width | `getx-utils-rules.mdc` | `context.width` |
| Platform check | `getx-utils-rules.mdc` | `GetPlatform.isAndroid` |
| Build responsive view | `getx-responsive-layout-rules.mdc` | `GetResponsiveView` |
| Custom breakpoints | `getx-responsive-layout-rules.mdc` | `ResponsiveScreenSettings` |
| Screen type check | `getx-responsive-layout-rules.mdc` | `screen.isDesktop`, `screen.isTablet` |

## Getting Started

If you're new to GetX, follow this order:

1. **Start with Route Management** - Set up navigation structure
2. **Add Dependency Management** - Create Bindings for your routes
3. **Implement State Management** - Create controllers for your pages
4. **Add Utilities** - Use validation and responsive helpers as needed
5. **Enhance with Responsive Layouts** - Build adaptive UIs for different screen sizes
6. **Enhance with Internationalization** - Add multi-language support
7. **Polish with Theme Management** - Implement theme switching

For specific implementation details, refer to the individual rule files listed above.
