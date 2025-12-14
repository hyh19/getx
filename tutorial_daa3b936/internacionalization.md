# Internacionalization Extensions 代码讲解

## 概述

`internacionalization.dart` 文件为 GetX 提供了国际化（i18n）支持，包括语言环境管理、翻译管理和字符串翻译扩展。这个文件让开发者能够轻松实现多语言支持，为应用添加国际化功能。

### 主要功能

1. **语言环境管理**：管理当前语言环境和回退语言环境
2. **翻译管理**：管理多语言翻译数据
3. **字符串翻译**：为 `String` 类型提供翻译扩展方法
4. **列表扩展**：为 `List` 类型提供 `firstWhereOrNull` 扩展方法

## 文件结构

该文件包含以下组件：

- `_IntlHost` - 内部类，存储国际化相关的数据
- `FirstWhereExt` - 为 `List<T>` 提供 `firstWhereOrNull` 扩展方法
- `LocalesIntl` - 为 `GetInterface` 提供语言环境和翻译管理扩展
- `Trans` - 为 `String` 类型提供翻译扩展方法

## _IntlHost 内部类

### 类定义

```dart 5:11:lib/get_utils/src/extensions/internacionalization.dart
class _IntlHost {
  Locale? locale;

  Locale? fallbackLocale;

  Map<String, Map<String, String>> translations = {};
}
```

**说明**：这是一个内部类，用于存储国际化相关的数据，包括当前语言环境、回退语言环境和翻译数据。

**字段说明**：

- `locale`：当前语言环境
- `fallbackLocale`：回退语言环境，当找不到翻译时使用
- `translations`：翻译数据，键为语言代码，值为翻译键值对

## FirstWhereExt 扩展详解

### firstWhereOrNull

安全地获取列表中满足条件的第一个元素。

```dart 13:21:lib/get_utils/src/extensions/internacionalization.dart
extension FirstWhereExt<T> on List<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
```

**参数说明**：

- `test`：测试函数，用于判断元素是否满足条件

**返回值**：返回满足条件的第一个元素，如果没有找到则返回 `null`

**使用示例**：

```dart
final numbers = [1, 2, 3, 4, 5];
final even = numbers.firstWhereOrNull((n) => n % 2 == 0); // 返回 2

final empty = <int>[].firstWhereOrNull((n) => n > 10); // 返回 null
```

## LocalesIntl 扩展详解

### locale

获取或设置当前语言环境。

```dart 26:30:lib/get_utils/src/extensions/internacionalization.dart
  Locale? get locale => _intlHost.locale;

  set locale(Locale? newLocale) => _intlHost.locale = newLocale;
```

**说明**：获取或设置当前的语言环境。语言环境决定了使用哪套翻译数据。

**使用示例**：

```dart
// 设置语言环境
Get.locale = Locale('zh', 'CN');

// 获取当前语言环境
final currentLocale = Get.locale;
print('当前语言: ${currentLocale?.languageCode}');
```

### fallbackLocale

获取或设置回退语言环境。

```dart 28:32:lib/get_utils/src/extensions/internacionalization.dart
  Locale? get fallbackLocale => _intlHost.fallbackLocale;

  set fallbackLocale(Locale? newLocale) => _intlHost.fallbackLocale = newLocale;
```

**说明**：获取或设置回退语言环境。当找不到当前语言环境的翻译时，会使用回退语言环境的翻译。

**使用示例**：

```dart
// 设置回退语言环境
Get.fallbackLocale = Locale('en', 'US');

// 获取回退语言环境
final fallback = Get.fallbackLocale;
```

### translations

获取翻译数据。

```dart 34:34:lib/get_utils/src/extensions/internacionalization.dart
  Map<String, Map<String, String>> get translations => _intlHost.translations;
```

**说明**：获取所有翻译数据。返回一个 Map，键为语言代码（如 `'zh_CN'` 或 `'en'`），值为翻译键值对。

**使用示例**：

```dart
// 获取所有翻译
final allTranslations = Get.translations;
print('支持的语言: ${allTranslations.keys}');
```

### addTranslations

添加翻译数据。

```dart 36:38:lib/get_utils/src/extensions/internacionalization.dart
  void addTranslations(Map<String, Map<String, String>> tr) {
    translations.addAll(tr);
  }
```

**参数说明**：

- `tr`：要添加的翻译数据，格式为 `Map<String, Map<String, String>>`

**说明**：将新的翻译数据添加到现有翻译中。如果语言代码已存在，会覆盖该语言的翻译。

**使用示例**：

```dart
// 添加中文翻译
Get.addTranslations({
  'zh_CN': {
    'hello': '你好',
    'world': '世界',
  },
  'en_US': {
    'hello': 'Hello',
    'world': 'World',
  },
});
```

### clearTranslations

清空所有翻译数据。

```dart 40:42:lib/get_utils/src/extensions/internacionalization.dart
  void clearTranslations() {
    translations.clear();
  }
```

**说明**：清空所有已添加的翻译数据。

**使用示例**：

```dart
// 清空所有翻译
Get.clearTranslations();
```

### appendTranslations

追加翻译数据。

```dart 44:52:lib/get_utils/src/extensions/internacionalization.dart
  void appendTranslations(Map<String, Map<String, String>> tr) {
    tr.forEach((key, map) {
      if (translations.containsKey(key)) {
        translations[key]!.addAll(map);
      } else {
        translations[key] = map;
      }
    });
  }
```

**参数说明**：

- `tr`：要追加的翻译数据

**说明**：追加翻译数据到现有翻译中。如果语言代码已存在，会将新翻译合并到现有翻译中；如果不存在，则创建新的语言翻译。

**使用示例**：

```dart
// 初始翻译
Get.addTranslations({
  'zh_CN': {
    'hello': '你好',
  },
});

// 追加翻译
Get.appendTranslations({
  'zh_CN': {
    'world': '世界', // 追加到现有翻译
    'goodbye': '再见', // 追加新键
  },
});
```

## Trans 扩展详解

### tr

获取翻译后的字符串。

```dart 81:115:lib/get_utils/src/extensions/internacionalization.dart
  String get tr {
    // print('language');
    // print(Get.locale!.languageCode);
    // print('contains');
    // print(Get.translations.containsKey(Get.locale!.languageCode));
    // print(Get.translations.keys);
    // Returns the key if locale is null.
    if (Get.locale?.languageCode == null) return this;

    if (_fullLocaleAndKey) {
      return Get.translations[
          "${Get.locale!.languageCode}_${Get.locale!.countryCode}"]![this]!;
    }
    final similarTranslation = _getSimilarLanguageTranslation;
    if (similarTranslation != null && similarTranslation.containsKey(this)) {
      return similarTranslation[this]!;
      // If there is no corresponding language or corresponding key, return
      // the key.
    } else if (Get.fallbackLocale != null) {
      final fallback = Get.fallbackLocale!;
      final key = "${fallback.languageCode}_${fallback.countryCode}";

      if (Get.translations.containsKey(key) &&
          Get.translations[key]!.containsKey(this)) {
        return Get.translations[key]![this]!;
      }
      if (Get.translations.containsKey(fallback.languageCode) &&
          Get.translations[fallback.languageCode]!.containsKey(this)) {
        return Get.translations[fallback.languageCode]![this]!;
      }
      return this;
    } else {
      return this;
    }
  }
```

**返回值**：返回翻译后的字符串，如果找不到翻译则返回原始键

**翻译查找顺序**：

1. 检查完整语言环境（语言代码_国家代码）和键是否存在
2. 检查相似语言（只有语言代码）的翻译
3. 如果设置了回退语言环境，检查回退语言环境的翻译
4. 如果都找不到，返回原始键

**使用示例**：

```dart
// 基本用法
Get.locale = Locale('zh', 'CN');
Get.addTranslations({
  'zh_CN': {
    'hello': '你好',
  },
});

final greeting = 'hello'.tr; // 返回 '你好'

// 如果找不到翻译，返回原始键
final unknown = 'unknown_key'.tr; // 返回 'unknown_key'
```

### trArgs

使用参数替换翻译中的占位符。

```dart 117:125:lib/get_utils/src/extensions/internacionalization.dart
  String trArgs([List<String> args = const []]) {
    var key = tr;
    if (args.isNotEmpty) {
      for (final arg in args) {
        key = key.replaceFirst(RegExp(r'%s'), arg.toString());
      }
    }
    return key;
  }
```

**参数说明**：

- `args`：参数列表，用于替换翻译中的 `%s` 占位符

**返回值**：返回替换参数后的翻译字符串

**使用示例**：

```dart
Get.addTranslations({
  'zh_CN': {
    'welcome': '欢迎，%s！',
    'message': '你有 %s 条新消息',
  },
});

Get.locale = Locale('zh', 'CN');

// 使用参数
final welcome = 'welcome'.trArgs(['John']); // 返回 '欢迎，John！'
final message = 'message'.trArgs(['5']); // 返回 '你有 5 条新消息'
```

### trPlural

根据数量选择单数或复数翻译。

```dart 127:129:lib/get_utils/src/extensions/internacionalization.dart
  String trPlural([String? pluralKey, int? i, List<String> args = const []]) {
    return i == 1 ? trArgs(args) : pluralKey!.trArgs(args);
  }
```

**参数说明**：

- `pluralKey`：复数形式的翻译键
- `i`：数量，如果为 1 则使用单数形式，否则使用复数形式
- `args`：参数列表

**返回值**：根据数量返回单数或复数形式的翻译

**使用示例**：

```dart
Get.addTranslations({
  'en_US': {
    'item': 'item',
    'items': 'items',
  },
});

Get.locale = Locale('en', 'US');

// 单数形式
final single = 'item'.trPlural('items', 1); // 返回 'item'

// 复数形式
final plural = 'item'.trPlural('items', 5); // 返回 'items'
```

### trParams

使用命名参数替换翻译中的占位符。

```dart 131:139:lib/get_utils/src/extensions/internacionalization.dart
  String trParams([Map<String, String> params = const {}]) {
    var trans = tr;
    if (params.isNotEmpty) {
      params.forEach((key, value) {
        trans = trans.replaceAll('@$key', value);
      });
    }
    return trans;
  }
```

**参数说明**：

- `params`：参数 Map，键为参数名，值为参数值

**返回值**：返回替换参数后的翻译字符串

**使用示例**：

```dart
Get.addTranslations({
  'zh_CN': {
    'greeting': '你好，@name！今天是 @date',
  },
});

Get.locale = Locale('zh', 'CN');

// 使用命名参数
final greeting = 'greeting'.trParams({
  'name': 'John',
  'date': '2023-01-01',
}); // 返回 '你好，John！今天是 2023-01-01'
```

### trPluralParams

根据数量选择单数或复数翻译，并使用命名参数。

```dart 141:144:lib/get_utils/src/extensions/internacionalization.dart
  String trPluralParams(
      [String? pluralKey, int? i, Map<String, String> params = const {}]) {
    return i == 1 ? trParams(params) : pluralKey!.trParams(params);
  }
```

**参数说明**：

- `pluralKey`：复数形式的翻译键
- `i`：数量
- `params`：命名参数 Map

**返回值**：根据数量返回单数或复数形式的翻译，并替换参数

**使用示例**：

```dart
Get.addTranslations({
  'en_US': {
    'message': 'You have @count message',
    'messages': 'You have @count messages',
  },
});

Get.locale = Locale('en', 'US');

// 单数形式
final single = 'message'.trPluralParams('messages', 1, {
  'count': '1',
}); // 返回 'You have 1 message'

// 复数形式
final plural = 'message'.trPluralParams('messages', 5, {
  'count': '5',
}); // 返回 'You have 5 messages'
```

## 完整使用示例

### 示例 1：基本国际化设置

```dart
void main() {
  // 设置语言环境
  Get.locale = Locale('zh', 'CN');
  Get.fallbackLocale = Locale('en', 'US');
  
  // 添加翻译
  Get.addTranslations({
    'zh_CN': {
      'hello': '你好',
      'world': '世界',
      'welcome': '欢迎',
    },
    'en_US': {
      'hello': 'Hello',
      'world': 'World',
      'welcome': 'Welcome',
    },
  });
  
  // 使用翻译
  print('hello'.tr); // 输出: 你好
  print('world'.tr); // 输出: 世界
  
  // 切换语言
  Get.locale = Locale('en', 'US');
  print('hello'.tr); // 输出: Hello
  print('world'.tr); // 输出: World
}
```

### 示例 2：带参数的翻译

```dart
void setupTranslations() {
  Get.addTranslations({
    'zh_CN': {
      'greeting': '你好，%s！',
      'message': '你有 %s 条新消息',
      'user_info': '用户：@name，年龄：@age',
    },
    'en_US': {
      'greeting': 'Hello, %s!',
      'message': 'You have %s new messages',
      'user_info': 'User: @name, Age: @age',
    },
  });
}

void main() {
  Get.locale = Locale('zh', 'CN');
  setupTranslations();
  
  // 使用位置参数
  print('greeting'.trArgs(['John'])); // 输出: 你好，John！
  print('message'.trArgs(['5'])); // 输出: 你有 5 条新消息
  
  // 使用命名参数
  print('user_info'.trParams({
    'name': 'John',
    'age': '30',
  })); // 输出: 用户：John，年龄：30
}
```

### 示例 3：单复数形式

```dart
void setupTranslations() {
  Get.addTranslations({
    'en_US': {
      'item': 'item',
      'items': 'items',
      'message': 'You have @count message',
      'messages': 'You have @count messages',
    },
  });
}

void main() {
  Get.locale = Locale('en', 'US');
  setupTranslations();
  
  // 单数形式
  print('item'.trPlural('items', 1)); // 输出: item
  print('message'.trPluralParams('messages', 1, {
    'count': '1',
  })); // 输出: You have 1 message
  
  // 复数形式
  print('item'.trPlural('items', 5)); // 输出: items
  print('message'.trPluralParams('messages', 5, {
    'count': '5',
  })); // 输出: You have 5 messages
}
```

### 示例 4：动态语言切换

```dart
class LanguageService {
  // 支持的语言列表
  final List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
    Locale('ja', 'JP'),
  ];
  
  // 切换语言
  void changeLanguage(Locale locale) {
    if (supportedLocales.contains(locale)) {
      Get.locale = locale;
    } else {
      print('不支持的语言: $locale');
    }
  }
  
  // 获取当前语言
  String getCurrentLanguage() {
    return Get.locale?.languageCode ?? 'unknown';
  }
}

void main() {
  final langService = LanguageService();
  
  // 设置翻译
  Get.addTranslations({
    'zh_CN': {'hello': '你好'},
    'en_US': {'hello': 'Hello'},
    'ja_JP': {'hello': 'こんにちは'},
  });
  
  // 切换语言
  for (final locale in langService.supportedLocales) {
    langService.changeLanguage(locale);
    print('${locale.languageCode}: ${'hello'.tr}');
  }
}
```

## 最佳实践

### 何时使用这些扩展

1. **多语言支持**：当应用需要支持多种语言时
2. **动态翻译**：当需要根据用户设置动态切换语言时
3. **参数化翻译**：当翻译文本需要包含动态内容时

### 性能注意事项

1. **翻译查找**：翻译查找会遍历多个 Map，对于大量翻译可能有性能开销
2. **缓存考虑**：频繁使用的翻译可以考虑缓存
3. **初始化**：翻译数据应该在应用启动时初始化

### 常见使用场景

1. **应用国际化**：为应用添加多语言支持
2. **用户界面**：翻译用户界面文本
3. **错误消息**：翻译错误和提示消息
4. **内容本地化**：本地化应用内容

### 注意事项

1. **翻译键**：确保翻译键在所有语言中都存在
2. **回退语言**：设置回退语言环境以避免找不到翻译
3. **参数格式**：使用 `trArgs` 时，确保翻译文本包含 `%s` 占位符
4. **命名参数**：使用 `trParams` 时，确保翻译文本包含 `@key` 格式的占位符
5. **语言代码**：使用标准的语言代码格式（如 `'zh_CN'` 或 `'en'`）

## 总结

`internacionalization.dart` 提供了完整的国际化支持：

- **语言环境管理**：可以设置和获取当前语言环境和回退语言环境
- **翻译管理**：提供了添加、清空和追加翻译数据的方法
- **字符串翻译**：为字符串提供了多种翻译方法，支持参数和单复数形式
- **灵活查找**：翻译查找支持完整语言环境、相似语言和回退语言环境

这些扩展方法遵循 GetX 的最佳实践，在保持代码简洁的同时，提供了强大的国际化能力。通过使用这些扩展，开发者可以轻松实现多语言支持，为应用添加国际化功能。
