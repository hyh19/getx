# GetX Utils Rules

## Overview

GetX provides a comprehensive set of utility classes, extensions, and helpers that make Flutter development easier and more productive. This rule file guides proper usage patterns based on the official source code and documentation.

**Key Principles:**

- Utility methods for common operations (validation, type checking, etc.)
- Context extensions for responsive design and media queries
- String, number, and duration extensions for cleaner code
- Platform detection for cross-platform development
- Internationalization support
- Theme management

## GetUtils

Static utility class for common operations.

### Null and Empty Checks

```dart
GetUtils.isNull(value); // Check if value is null
GetUtils.isNullOrBlank(value); // Check if null or blank
GetUtils.isBlank(value); // Check if blank (empty or whitespace)
```

**Reference:** `lib/get_utils/src/get_utils/get_utils.dart:63`

### Type Validation

```dart
GetUtils.isNum('123'); // Check if string is a number
GetUtils.isNumericOnly('123'); // Check if string contains only digits
GetUtils.isAlphabetOnly('abc'); // Check if string contains only letters
GetUtils.isBool('true'); // Check if string is a boolean
```

**Reference:** `lib/get_utils/src/get_utils/get_utils.dart:90`

### File and Format Validation

```dart
// File types
GetUtils.isImage('image.png');
GetUtils.isAudio('audio.mp3');
GetUtils.isVideo('video.mp4');
GetUtils.isPDF('document.pdf');
GetUtils.isURL('https://example.com');
GetUtils.isEmail('user@example.com');
GetUtils.isPhoneNumber('+1234567890');
GetUtils.isUsername('user_name'); // Valid username format

// Security and network
GetUtils.isMD5('...');
GetUtils.isSHA1('...');
GetUtils.isSHA256('...');
GetUtils.isIPv4('192.168.1.1');
GetUtils.isIPv6('2001:0db8:...');
GetUtils.isSSN('123-45-6789'); // Social Security Number

// String manipulation
GetUtils.numericOnly('abc123');
GetUtils.capitalize('hello');
GetUtils.capitalizeFirst('hello world');
GetUtils.removeAllWhitespace('hello world');
GetUtils.camelCase('hello world'); // 'helloWorld'
GetUtils.paramCase('hello world'); // 'hello-world'
```

**Reference:** `lib/get_utils/src/get_utils/get_utils.dart`

### Length Validation

```dart
GetUtils.isLengthGreaterThan('text', 5); // length > 5
GetUtils.isLengthLessThan('text', 10); // length < 10
GetUtils.isLengthBetween('text', 3, 8); // length between 3-8
GetUtils.isLengthEqualTo('text', 4); // length == 4
GetUtils.isLengthGreaterOrEqual('text', 4); // length >= 4
GetUtils.isLengthLessOrEqual('text', 10); // length <= 10
// Works with String, List, Map, etc.
```

**Reference:** `lib/get_utils/src/get_utils/get_utils.dart:312`

### Additional Validations

```dart
GetUtils.isOneAKind('111111'); // true - all same characters
GetUtils.isCpf('123.456.789-00'); // Brazilian CPF validation
GetUtils.isCnpj('12.345.678/0001-90'); // Brazilian CNPJ validation
GetUtils.isPassport('A1234567'); // Passport number validation
GetUtils.isCurrency('$100.00'); // Currency format validation
```

**Reference:** `lib/get_utils/src/get_utils/get_utils.dart`

## Context Extensions

Powerful extensions on `BuildContext` for responsive design and media queries.

### Basic Size Access

```dart
context.width; // Screen width
context.height; // Screen height
context.mediaQuerySize; // Size object
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:10`

### Responsive Transformers

```dart
// Get portion of height
context.heightTransformer(dividedBy: 2); // Half of height
context.heightTransformer(dividedBy: 3, reducedBy: 20.0); // Third minus 20%

// Get portion of width
context.widthTransformer(dividedBy: 2); // Half of width
context.widthTransformer(dividedBy: 4, reducedBy: 10.0); // Quarter minus 10%

// Get aspect ratio
context.ratio(dividedBy: 1, reducedByW: 0.0, reducedByH: 0.0);
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:26`

### Media Query Access

```dart
context.mediaQuery; // Full MediaQueryData
context.mediaQueryPadding; // EdgeInsets padding
context.mediaQueryViewPadding; // EdgeInsets view padding
context.mediaQueryViewInsets; // EdgeInsets view insets
context.devicePixelRatio; // Device pixel ratio
context.textScaleFactor; // Text scale factor
context.orientation; // Orientation (portrait/landscape)
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:69`

### Orientation Checks

```dart
context.isLandscape; // Check if landscape
context.isPortrait; // Check if portrait
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:84`

### Device Type Detection

```dart
context.isPhone; // Shortest side < 600
context.isSmallTablet; // Shortest side >= 600
context.isLargeTablet; // Shortest side >= 720
context.isTablet; // isSmallTablet || isLargeTablet
context.isDesktop; // Width <= 1200
context.showNavbar; // Width > 800
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:108`

### Responsive Values

Return different values based on screen size:

```dart
context.responsiveValue<T>(
  watch: value, // Shortest side < 300
  mobile: value, // Shortest side < 600
  tablet: value, // Shortest side < 1200
  desktop: value, // Width >= 1200
);
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:146`

### Theme Access

```dart
context.theme; // ThemeData
context.isDarkMode; // Check if dark theme
context.iconColor; // Icon theme color
context.textTheme; // TextTheme
```

**Reference:** `lib/get_utils/src/extensions/context_extensions.dart:57`

## String Extensions

Convenient extensions on `String` for validation and manipulation.

```dart
// Validation
'123'.isNum; '123'.isNumericOnly; 'abc'.isAlphabetOnly; 'true'.isBool;
'image.png'.isImageFileName; 'user@example.com'.isEmail;
'https://example.com'.isURL; '+1234567890'.isPhoneNumber; '192.168.1.1'.isIPv4;

// Manipulation
'abc123'.numericOnly(); 'hello world'.capitalize; 'hello world'.capitalizeFirst;
'hello world'.removeAllWhitespace; 'hello'.isCaseInsensitiveContains('HELLO');
```

**Reference:** `lib/get_utils/src/extensions/string_extensions.dart`

## Number Extensions

Extensions on `int` and `num` for duration creation and comparisons.

### Duration Extensions

```dart
5.seconds; // Duration(seconds: 5)
3.minutes; // Duration(minutes: 3)
2.hours; // Duration(hours: 2)
1.days; // Duration(days: 1)
500.milliseconds; // Duration(milliseconds: 500)
100.microseconds; // Duration(microseconds: 100)
500.ms; // Alias for milliseconds
```

**Reference:** `lib/get_utils/src/extensions/int_extensions.dart`

### Duration Utilities

```dart
final delay = 3.seconds;
await delay.delay(); // Wait for 3 seconds

await 0.7.seconds.delay(() {
  print('Callback executed after 700ms');
});
```

**Reference:** `lib/get_utils/src/extensions/duration_extensions.dart`

### Number Comparisons

```dart
5.isLowerThan(10); // true
10.isGreaterThan(5); // true
5.isEqual(5); // true

// Works with both int and double
3.14.isLowerThan(3.15); // true
5.isGreaterThan(4.9); // true
```

**Reference:** `lib/get_utils/src/extensions/num_extensions.dart`

### Num Delay

```dart
await 2.delay(); // Wait 2 seconds (works on num, not just int)
await 1.5.delay(() => print('1.5 seconds passed'));
```

**Reference:** `lib/get_utils/src/extensions/num_extensions.dart:27`

## Double Extensions

Extensions on `double` for precision control and duration creation.

### Precision Control

```dart
19.999.toPrecision(2); // 20.0
3.14159265.toPrecision(3); // 3.142
5.7.toPrecision(0); // 6.0
```

**Reference:** `lib/get_utils/src/extensions/double_extensions.dart:4`

### Duration from Double

```dart
1.5.seconds; // Duration(milliseconds: 1500)
2.5.minutes; // Duration(seconds: 150)
0.5.hours; // Duration(minutes: 30)
1.5.days; // Duration(hours: 36)
500.5.milliseconds; // Duration(microseconds: 500500)
500.5.ms; // Alias for milliseconds
```

**Reference:** `lib/get_utils/src/extensions/double_extensions.dart:9`

## Dynamic Extensions

Extensions on `dynamic` for blank checking and debugging.

### Blank Check and Debug Printing

```dart
value.isBlank; // Check if blank (null, empty, or whitespace)
// Works with String, List, Map, etc.

error.printError(); // Print error with type info
error.printError(info: 'Custom message');
data.printInfo(); // Print info for debugging
```

**Reference:** `lib/get_utils/src/extensions/dynamic_extensions.dart`

## Iterable Extensions

Extensions on `Iterable` for mapping and flattening.

### Map and Flatten

```dart
final nested = [[1, 2], [3, 4], [5]];
final flattened = nested.mapMany((list) => list); // [1, 2, 3, 4, 5]
// Useful for nested collections: people.mapMany((p) => p.hobbies)
```

**Reference:** `lib/get_utils/src/extensions/iterable_extensions.dart:2`

## Widget Extensions

Extensions on `Widget` for padding, margin, and sliver conversion.

### Padding and Margin Extensions

```dart
// Padding
Text('Hello').paddingAll(16.0);
Text('Hello').paddingSymmetric(horizontal: 16.0, vertical: 8.0);
Text('Hello').paddingOnly(left: 16.0, top: 8.0);
Text('Hello').paddingZero;

// Margin
Text('Hello').marginAll(16.0);
Text('Hello').marginSymmetric(horizontal: 16.0, vertical: 8.0);
Text('Hello').marginOnly(left: 16.0, top: 8.0);
Text('Hello').marginZero;
```

**Reference:** `lib/get_utils/src/extensions/widget_extensions.dart`

### Sliver Conversion

```dart
Text('Hello').sliverBox; // Converts to SliverToBoxAdapter
CustomScrollView(slivers: [Text('Header').sliverBox, Image.network('url').sliverBox])
```

**Reference:** `lib/get_utils/src/extensions/widget_extensions.dart:54`

## Platform Detection

Detect the current platform without importing `dart:io`.

```dart
// Platform checks
GetPlatform.isWeb; GetPlatform.isAndroid; GetPlatform.isIOS;
GetPlatform.isMacOS; GetPlatform.isWindows; GetPlatform.isLinux; GetPlatform.isFuchsia;

// Device type
GetPlatform.isMobile; // isIOS || isAndroid
GetPlatform.isDesktop; // isMacOS || isWindows || isLinux
```

**Reference:** `lib/get_utils/src/platform/platform.dart`

## Internationalization

```dart
// Create translations
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {'hello': 'Hello World'},
    'de_DE': {'hello': 'Hallo Welt'},
  };
}

// Usage
Text('hello'.tr); // Auto-translated
Text('logged_in'.trParams({'name': 'John', 'email': 'john@example.com'}));
Text('singularKey'.trPlural('pluralKey', products.length));

// Configuration
GetMaterialApp(translations: Messages(), locale: Locale('en', 'US'), fallbackLocale: Locale('en', 'UK'));
Get.updateLocale(Locale('de', 'DE')); // Change locale
GetMaterialApp(locale: Get.deviceLocale); // System locale
```

**Reference:** `lib/get_navigation/src/root/internacionalization.dart`

## Theme Management

Change theme without creating a ThemeProvider widget.

### Change Theme

```dart
Get.changeTheme(ThemeData.light());
Get.changeTheme(ThemeData.dark());
```

### Toggle Theme

```dart
Get.changeTheme(
  Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
);
```

### Check Current Theme

```dart
Get.isDarkMode; // Check if dark theme is active
```

**Reference:** `README.md:429`

## Global Get Utilities

```dart
Get.height; // Screen height (immutable)
Get.width; // Screen width (immutable)
Get.context; // Current Navigator context
Get.contextOverlay; // Context for snackbar/dialog/bottomsheet
```

**Note:** For responsive values that change with window resizing, use `context.height` and `context.width` instead.

## Best Practices

### Using Context Extensions

- Use `context.width` and `context.height` for responsive layouts
- Use `context.responsiveValue()` for different values per screen size
- Prefer context extensions over direct MediaQuery when possible

### Using String Extensions

- Use validation extensions for user input validation
- Chain extensions for complex operations
- Use file type extensions for file upload validation

### Using Number and Duration Extensions

- Use `.seconds`, `.minutes`, etc. for cleaner duration code
- Use `.delay()` for async delays with optional callbacks
- Use comparison methods (`isLowerThan`, `isGreaterThan`) for readable number comparisons
- Use `toPrecision()` for double precision control

### Using Platform Detection

- Use `GetPlatform` instead of `dart:io` Platform for better web compatibility
- Check platform before platform-specific code

### Using Internationalization

- Create translation classes extending `Translations`
- Use `.tr` for simple translations
- Use `.trParams()` for translations with variables
- Always provide a `fallbackLocale`

### Using Widget Extensions

- Use padding/margin extensions for cleaner widget code
- Chain extensions: `Text('Hello').paddingAll(16).marginOnly(bottom: 8)`
- Use `sliverBox` to convert widgets for CustomScrollView

### Using Dynamic and Iterable Extensions

- Use `isBlank` for flexible null/empty checking
- Use `printError()` and `printInfo()` for debugging
- Use `mapMany()` to flatten nested collections

### Common Mistakes

**❌ DON'T:** Use `Get.height` for responsive layouts → **✅ DO:** Use `context.height` (updates on resize)

**❌ DON'T:** Import `dart:io` for platform checks → **✅ DO:** Use `GetPlatform` (web compatible)

**❌ DON'T:** Create ThemeProvider widget → **✅ DO:** Use `Get.changeTheme()` directly

**❌ DON'T:** Hardcode durations → **✅ DO:** Use extensions like `3.seconds`

**❌ DON'T:** Forget fallback locale → **✅ DO:** Always provide `fallbackLocale` in GetMaterialApp
