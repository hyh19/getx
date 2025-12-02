---
description: Use when working with GetX internationalization, translations, locale management, .tr extension, trParams, trPlural, or multi-language support
---

# GetX Internationalization Rules

## Overview

GetX provides a simple and powerful internationalization (i18n) system that supports multiple languages without requiring code generation or complex setup. Translations are managed as simple key-value maps, and locale changes are handled reactively.

**Key Principles:**

- Translations are simple key-value dictionary maps
- No code generators required
- Reactive locale changes update UI automatically
- Support for parameters, pluralization, and fallback locales
- Works seamlessly with GetMaterialApp

## Creating Translations

Create a class extending `Translations` to define your translations.

```dart
import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'hello': 'Hello World',
      'welcome': 'Welcome',
      'logged_in': 'logged in as @name with email @email',
    },
    'de_DE': {
      'hello': 'Hallo Welt',
      'welcome': 'Willkommen',
      'logged_in': 'eingeloggt als @name mit E-Mail @email',
    },
    'es_ES': {
      'hello': 'Hola Mundo',
      'welcome': 'Bienvenido',
      'logged_in': 'iniciado sesión como @name con e-mail @email',
    },
  };
}
```

**Reference:** `README.md:349`

### Organizing Translations

For larger applications, split translations into separate files:

```dart
// translations/en_US.dart
const Map<String, String> en_US = {
  'hello': 'Hello World',
  'welcome': 'Welcome',
};

// translations/de_DE.dart
const Map<String, String> de_DE = {
  'hello': 'Hallo Welt',
  'welcome': 'Willkommen',
};

// translations/messages.dart
import 'package:get/get.dart';
import 'en_US.dart';
import 'de_DE.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en_US,
    'de_DE': de_DE,
  };
}
```

**Reference:** `example/lib/lang/translation_service.dart`

## Basic Translation

Use the `.tr` extension on any string key to get the translated value.

```dart
Text('hello'.tr); // Automatically translated based on current locale
```

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:81`

### How Translation Works

The `.tr` extension:

1. Checks the current `Get.locale` value
2. Looks up the translation in `Get.translations`
3. Falls back to `Get.fallbackLocale` if translation not found
4. Returns the key itself if no translation is available

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:81-115`

## Translation with Parameters

### Using Named Parameters (trParams)

Replace placeholders in translations using named parameters with `@` prefix.

```dart
// In translations
'en_US': {
  'logged_in': 'logged in as @name with email @email',
  'user_info': 'User: @name, Age: @age',
}

// Usage
Text('logged_in'.trParams({
  'name': 'John',
  'email': 'john@example.com',
}));

Text('user_info'.trParams({
  'name': 'John',
  'age': '30',
}));
```

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:131`

### Using Positional Arguments (trArgs)

Replace `%s` placeholders using positional arguments.

```dart
// In translations
'en_US': {
  'greeting': 'Hello, %s!',
  'message': 'You have %s new messages',
}

// Usage
Text('greeting'.trArgs(['John'])); // "Hello, John!"
Text('message'.trArgs(['5'])); // "You have 5 new messages"
```

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:117`

## Pluralization

Handle singular and plural forms using `trPlural`.

```dart
// In translations
'en_US': {
  'item': 'item',
  'items': 'items',
  'message': 'You have @count message',
  'messages': 'You have @count messages',
}

// Usage
var count = 1;
Text('item'.trPlural('items', count)); // "item"

var count = 5;
Text('item'.trPlural('items', count)); // "items"

// With parameters
Text('message'.trPlural('messages', count, ['$count']));
// Or with trParams
Text('message'.trPlural('messages', count).trParams({'count': '$count'}));
```

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:127`

### Pluralization with Parameters

Combine pluralization with parameters:

```dart
// In translations
'en_US': {
  'item_count': 'You have @count item',
  'items_count': 'You have @count items',
}

// Usage
final count = 5;
Text('item_count'.trPlural('items_count', count).trParams({
  'count': '$count',
})); // "You have 5 items"
```

## Configuration

Configure translations and locale in `GetMaterialApp`.

### Basic Configuration

```dart
GetMaterialApp(
  translations: Messages(), // Your Translations class
  locale: Locale('en', 'US'), // Current locale
  fallbackLocale: Locale('en', 'UK'), // Fallback if translation missing
  // ... other properties
);
```

**Reference:** `README.md:390`

### Using System Locale

Use the device's system locale:

```dart
GetMaterialApp(
  translations: Messages(),
  locale: Get.deviceLocale, // System locale
  fallbackLocale: Locale('en', 'US'),
);
```

**Reference:** `README.md:392`

### Complete Example

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      translations: Messages(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en', 'US'),
      home: HomePage(),
    );
  }
}
```

## Dynamic Locale Changes

Change the locale at runtime using `Get.updateLocale()`.

### Changing Locale

```dart
// Change to German
Get.updateLocale(Locale('de', 'DE'));

// Change to Spanish
Get.updateLocale(Locale('es', 'ES'));

// Change to English
Get.updateLocale(Locale('en', 'US'));
```

**Reference:** `README.md:391`

### Locale Change Example

```dart
class LanguageController extends GetxController {
  void changeLanguage(String languageCode, String countryCode) {
    Get.updateLocale(Locale(languageCode, countryCode));
  }
}

// In UI
ElevatedButton(
  onPressed: () => Get.find<LanguageController>().changeLanguage('de', 'DE'),
  child: Text('Switch to German'),
)
```

The UI will automatically update when the locale changes because GetX widgets are reactive.

## Locale Management

### Getting Current Locale

```dart
final currentLocale = Get.locale; // Current Locale object
final languageCode = Get.locale?.languageCode; // e.g., 'en'
final countryCode = Get.locale?.countryCode; // e.g., 'US'
```

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:26`

### Setting Fallback Locale

```dart
Get.fallbackLocale = Locale('en', 'US');
```

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:28`

### Adding Translations Dynamically

```dart
// Add translations at runtime
Get.addTranslations({
  'fr_FR': {
    'hello': 'Bonjour',
  },
});

// Append to existing translations
Get.appendTranslations({
  'en_US': {
    'new_key': 'New Value',
  },
});
```

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:36`

### Clearing Translations

```dart
Get.clearTranslations(); // Remove all translations
```

**Reference:** `lib/get_utils/src/extensions/internacionalization.dart:40`

## Best Practices

### Translation Organization

- Split large translation files into separate files per language
- Use descriptive keys that indicate context (e.g., `home_welcome` instead of `welcome`)
- Group related translations together in the same file

### Managing Locales

- Always provide a `fallbackLocale` in `GetMaterialApp`
- Use `Get.deviceLocale` to respect user's system language
- Store user's language preference and restore on app start

### Using Parameters

- Use `trParams` for named parameters (more readable)
- Use `trArgs` for simple positional arguments
- Keep parameter names consistent across languages

### Handling Pluralization

- Always provide both singular and plural forms
- Use consistent naming (e.g., `item` and `items`, not `item` and `item_plural`)
- Consider languages with different plural rules

### Performance

- Load translations at app startup, not on-demand
- Use const maps for static translations when possible
- Avoid dynamic translation loading in hot paths

### Common Mistakes

**❌ DON'T:** Forget to provide `fallbackLocale` → **✅ DO:** Always set `fallbackLocale` in `GetMaterialApp`

**❌ DON'T:** Use hardcoded strings in UI → **✅ DO:** Use `.tr` extension for all user-facing text

**❌ DON'T:** Mix translation keys with direct strings → **✅ DO:** Use consistent translation keys throughout the app

**❌ DON'T:** Forget to update all language files → **✅ DO:** Keep all translation files synchronized

**❌ DON'T:** Use complex logic in translation values → **✅ DO:** Keep translations simple and use parameters for dynamic content

## Advanced Usage

### Nested Translation Keys

While GetX doesn't support nested keys directly, you can use dot notation in your keys:

```dart
'en_US': {
  'home.title': 'Home',
  'home.welcome': 'Welcome',
  'settings.title': 'Settings',
  'settings.theme': 'Theme',
}

// Usage
Text('home.title'.tr); // "Home"
Text('settings.theme'.tr); // "Theme"
```

### Translation with Context

For context-specific translations, include context in the key:

```dart
'en_US': {
  'button.save': 'Save',
  'button.cancel': 'Cancel',
  'dialog.confirm': 'Confirm',
  'dialog.cancel': 'Cancel',
}
```

### Conditional Translations

Combine translations with conditional logic:

```dart
Text(count == 0 
  ? 'no_items'.tr 
  : 'item'.trPlural('items', count).trParams({'count': '$count'}));
```

## Reference Files

- Translation extension: `lib/get_utils/src/extensions/internacionalization.dart`
- Translation service example: `example/lib/lang/translation_service.dart`
- Official documentation: `README.md:339`
