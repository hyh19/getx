---
description: Use when working with GetX theme management, Get.changeTheme(), Get.isDarkMode, context theme extensions, or custom theme creation
alwaysApply: false
---

# GetX Theme Management Rules

## Overview

GetX provides a simple and powerful theme management system that allows you to change themes dynamically without creating a ThemeProvider widget. Theme changes are handled reactively and update the UI automatically.

**Key Principles:**

- No ThemeProvider widget required
- Simple API for changing themes
- Reactive theme updates
- Context extensions for easy theme access
- Support for custom themes

## Context Extensions for Theme

GetX provides convenient extensions on `BuildContext` to access theme information.

### Accessing Theme Data

```dart
context.theme; // ThemeData - Full theme data
context.textTheme; // TextTheme - Text styles
context.iconColor; // Color? - Icon theme color
context.isDarkMode; // bool - Check if dark theme is active
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:57`

### Using Theme Data

```dart
// Get primary color
final primaryColor = context.theme.colorScheme.primary;

// Get text styles
final headlineStyle = context.theme.textTheme.headlineLarge;
final bodyStyle = context.theme.textTheme.bodyMedium;

// Get icon color
Icon(
  Icons.star,
  color: context.iconColor,
)

// Conditional rendering based on theme
if (context.isDarkMode) {
  return DarkModeWidget();
} else {
  return LightModeWidget();
}
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:57-66`

## Changing Theme

Use `Get.changeTheme()` to change the app theme dynamically.

### Basic Theme Change

```dart
// Change to light theme
Get.changeTheme(ThemeData.light());

// Change to dark theme
Get.changeTheme(ThemeData.dark());
```

**Reference:** `README.md:436`

### Important Note

Do not use any higher level widget than `GetMaterialApp` to update the theme. This can trigger duplicate keys. Creating a ThemeProvider widget is not necessary with GetX.

**Reference:** `README.md:431`

## Toggling Theme

Toggle between light and dark themes using `Get.isDarkMode`.

### Simple Toggle

```dart
Get.changeTheme(
  Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
);
```

**Reference:** `README.md:445`

### Toggle Button Example

```dart
ElevatedButton(
  onPressed: () {
    Get.changeTheme(
      Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
    );
  },
  child: Text(Get.isDarkMode ? 'Switch to Light' : 'Switch to Dark'),
)
```

When dark mode is activated, it will switch to the light theme, and when the light theme becomes active, it will change to dark theme.

**Reference:** `README.md:448`

## Checking Current Theme

Check the current theme state using `Get.isDarkMode`.

### Basic Check

```dart
Get.isDarkMode; // Returns true if dark theme is active
```

**Reference:** `lib/get_navigation/src/extension_navigation.dart:1300`

### Using in Widgets

```dart
// Conditional widget rendering
Widget build(BuildContext context) {
  return Get.isDarkMode
    ? DarkModeIcon()
    : LightModeIcon();
}

// Conditional styling
Container(
  color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Get.isDarkMode ? Colors.white : Colors.black,
    ),
  ),
)
```

### Platform Dark Mode Check

Check if the platform is in dark mode (Android Q+):

```dart
Get.isPlatformDarkMode; // Checks system platform brightness
```

**Reference:** `lib/get_navigation/src/extension_navigation.dart:1303`

## Custom Themes

Create and use custom themes with GetX.

### Creating Custom Themes

```dart
// Light theme
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.green,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  ),
);

// Dark theme
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blue[700],
  colorScheme: ColorScheme.dark(
    primary: Colors.blue[700]!,
    secondary: Colors.green[700]!,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  ),
);
```

### Using Custom Themes

```dart
// Set initial theme in GetMaterialApp
GetMaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system, // or ThemeMode.light, ThemeMode.dark
  // ... other properties
);

// Change to custom theme
Get.changeTheme(lightTheme);
Get.changeTheme(darkTheme);
```

### Theme Controller Example

```dart
class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  
  bool get isDarkMode => _isDarkMode.value;
  
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeTheme(
      _isDarkMode.value ? darkTheme : lightTheme,
    );
  }
}

// Usage
final themeController = Get.put(ThemeController());

Obx(() => Switch(
  value: themeController.isDarkMode,
  onChanged: (_) => themeController.toggleTheme(),
))
```

## Theme Persistence

Store theme preference and restore on app start.

### Using SharedPreferences

```dart
class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  static Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
  
  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}

// On app start
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isDark = await ThemeService.getThemeMode();
  Get.changeTheme(isDark ? ThemeData.dark() : ThemeData.light());
  runApp(MyApp());
}

// When theme changes
void toggleTheme() {
  final isDark = !Get.isDarkMode;
  Get.changeTheme(isDark ? ThemeData.dark() : ThemeData.light());
  ThemeService.saveThemeMode(isDark);
}
```

## Best Practices

### Theme Management

- Use `Get.changeTheme()` directly instead of creating ThemeProvider widgets
- Store theme preference for persistence across app restarts
- Use context extensions (`context.theme`, `context.isDarkMode`) for theme-aware widgets
- Create custom themes for brand consistency

### Context Extensions

- Use `context.theme` to access full theme data
- Use `context.isDarkMode` for conditional rendering
- Use `context.textTheme` for consistent text styling
- Use `context.iconColor` for icon theming

### Creating and Using Custom Themes

- Define themes as constants for reusability
- Use `ColorScheme` for consistent color management
- Create separate light and dark theme variants
- Test themes on different screen sizes

### Performance

- Avoid changing themes frequently in hot paths
- Cache theme-dependent values when possible
- Use `Obx` or `GetBuilder` for reactive theme updates

### Common Mistakes

**❌ DON'T:** Create ThemeProvider widget → **✅ DO:** Use `Get.changeTheme()` directly

**❌ DON'T:** Wrap GetMaterialApp with ThemeProvider → **✅ DO:** Use `Get.changeTheme()` without wrapper widgets

**❌ DON'T:** Use `Theme.of(context)` directly when context extensions available → **✅ DO:** Use `context.theme` for cleaner code

**❌ DON'T:** Forget to persist theme preference → **✅ DO:** Save theme choice and restore on app start

**❌ DON'T:** Hardcode colors based on theme → **✅ DO:** Use theme color scheme for consistency

## Advanced Usage

### Multiple Theme Variants

Create multiple theme variants for different app sections:

```dart
final blueTheme = ThemeData(
  colorScheme: ColorScheme.light(primary: Colors.blue),
);

final greenTheme = ThemeData(
  colorScheme: ColorScheme.light(primary: Colors.green),
);

final redTheme = ThemeData(
  colorScheme: ColorScheme.light(primary: Colors.red),
);

// Switch between themes
Get.changeTheme(blueTheme);
Get.changeTheme(greenTheme);
Get.changeTheme(redTheme);
```

### Theme-Aware Widgets

Create widgets that automatically adapt to theme changes:

```dart
class ThemeAwareContainer extends StatelessWidget {
  final Widget child;
  
  const ThemeAwareContainer({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
      child: child,
    ));
  }
}
```

### Dynamic Theme Updates

Update theme properties dynamically:

```dart
// Get current theme
final currentTheme = Get.theme;

// Create new theme based on current
final newTheme = currentTheme.copyWith(
  primaryColor: Colors.purple,
  colorScheme: currentTheme.colorScheme.copyWith(
    primary: Colors.purple,
  ),
);

// Apply new theme
Get.changeTheme(newTheme);
```

## Reference Files

- Context extensions: `lib/get_utils/src/extensions/context_extensions.dart:57-66`
- Global theme access: `lib/get_navigation/src/extension_navigation.dart:1253-1307`
- Official documentation: `README.md:429`
