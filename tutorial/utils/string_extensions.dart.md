# String Extensions 代码讲解

## 概述

`string_extensions.dart` 文件为 Dart 的 `String` 类型提供了丰富的扩展方法，主要包括字符串验证、格式转换和路径处理等功能。这些扩展方法让开发者能够更方便地进行字符串验证、格式转换和路径操作。

### 主要功能

1. **字符串验证**：提供多种验证方法，如数字、邮箱、URL、电话号码等
2. **文件类型判断**：判断字符串是否为特定类型的文件名
3. **格式转换**：提供大小写转换、驼峰命名等格式转换方法
4. **路径处理**：提供路径创建和处理方法

## 文件结构

该文件包含一个扩展：

- `GetStringUtils` - 为 `String` 类型提供扩展方法

## GetStringUtils 扩展详解

### 字符串验证属性

#### isNum

判断字符串是否为数字（整数或浮点数）。

```dart 5:5:lib/get_utils/src/extensions/string_extensions.dart
  bool get isNum => GetUtils.isNum(this);
```

**返回值**：如果字符串可以解析为数字则返回 `true`，否则返回 `false`

**使用示例**：

```dart
print('123'.isNum); // 输出: true
print('123.45'.isNum); // 输出: true
print('abc'.isNum); // 输出: false
print('-123'.isNum); // 输出: true
```

#### isNumericOnly

判断字符串是否只包含数字字符。

```dart 8:8:lib/get_utils/src/extensions/string_extensions.dart
  bool get isNumericOnly => GetUtils.isNumericOnly(this);
```

**返回值**：如果字符串只包含数字字符则返回 `true`，否则返回 `false`

**使用示例**：

```dart
print('123'.isNumericOnly); // 输出: true
print('123.45'.isNumericOnly); // 输出: false（包含小数点）
print('abc123'.isNumericOnly); // 输出: false（包含字母）
```

#### numericOnly

提取字符串中的数字字符。

```dart 10:11:lib/get_utils/src/extensions/string_extensions.dart
  String numericOnly({bool firstWordOnly = false}) =>
      GetUtils.numericOnly(this, firstWordOnly: firstWordOnly);
```

**参数说明**：

- `firstWordOnly`：如果为 `true`，只提取第一个单词中的数字；如果为 `false`，提取所有数字

**返回值**：返回只包含数字字符的字符串

**使用示例**：

```dart
print('abc123def456'.numericOnly()); // 输出: 123456
print('abc123 def456'.numericOnly(firstWordOnly: true)); // 输出: 123
```

#### isAlphabetOnly

判断字符串是否只包含字母字符。

```dart 14:14:lib/get_utils/src/extensions/string_extensions.dart
  bool get isAlphabetOnly => GetUtils.isAlphabetOnly(this);
```

**返回值**：如果字符串只包含字母字符则返回 `true`，否则返回 `false`

**使用示例**：

```dart
print('abc'.isAlphabetOnly); // 输出: true
print('abc123'.isAlphabetOnly); // 输出: false
print('ABC'.isAlphabetOnly); // 输出: true
```

#### isBool

判断字符串是否为布尔值。

```dart 17:17:lib/get_utils/src/extensions/string_extensions.dart
  bool get isBool => GetUtils.isBool(this);
```

**返回值**：如果字符串可以解析为布尔值则返回 `true`，否则返回 `false`

**使用示例**：

```dart
print('true'.isBool); // 输出: true
print('false'.isBool); // 输出: true
print('True'.isBool); // 输出: true（可能支持大小写）
print('yes'.isBool); // 输出: false
```

### 文件类型判断属性

#### isVectorFileName

判断字符串是否为矢量文件名。

```dart 20:20:lib/get_utils/src/extensions/string_extensions.dart
  bool get isVectorFileName => GetUtils.isVector(this);
```

**说明**：判断文件名是否为矢量图格式（如 SVG）

#### isImageFileName

判断字符串是否为图片文件名。

```dart 23:23:lib/get_utils/src/extensions/string_extensions.dart
  bool get isImageFileName => GetUtils.isImage(this);
```

**说明**：判断文件名是否为图片格式（如 JPG、PNG、GIF 等）

#### isAudioFileName

判断字符串是否为音频文件名。

```dart 26:26:lib/get_utils/src/extensions/string_extensions.dart
  bool get isAudioFileName => GetUtils.isAudio(this);
```

**说明**：判断文件名是否为音频格式（如 MP3、WAV 等）

#### isVideoFileName

判断字符串是否为视频文件名。

```dart 29:29:lib/get_utils/src/extensions/string_extensions.dart
  bool get isVideoFileName => GetUtils.isVideo(this);
```

**说明**：判断文件名是否为视频格式（如 MP4、AVI 等）

#### isTxtFileName

判断字符串是否为文本文件名。

```dart 32:32:lib/get_utils/src/extensions/string_extensions.dart
  bool get isTxtFileName => GetUtils.isTxt(this);
```

**说明**：判断文件名是否为文本格式（如 TXT）

#### isDocumentFileName

判断字符串是否为 Word 文档文件名。

```dart 35:35:lib/get_utils/src/extensions/string_extensions.dart
  bool get isDocumentFileName => GetUtils.isWord(this);
```

**说明**：判断文件名是否为 Word 文档格式（如 DOC、DOCX）

#### isExcelFileName

判断字符串是否为 Excel 文件名。

```dart 38:38:lib/get_utils/src/extensions/string_extensions.dart
  bool get isExcelFileName => GetUtils.isExcel(this);
```

**说明**：判断文件名是否为 Excel 格式（如 XLS、XLSX）

#### isPPTFileName

判断字符串是否为 PowerPoint 文件名。

```dart 41:41:lib/get_utils/src/extensions/string_extensions.dart
  bool get isPPTFileName => GetUtils.isPPT(this);
```

**说明**：判断文件名是否为 PowerPoint 格式（如 PPT、PPTX）

#### isAPKFileName

判断字符串是否为 APK 文件名。

```dart 44:44:lib/get_utils/src/extensions/string_extensions.dart
  bool get isAPKFileName => GetUtils.isAPK(this);
```

**说明**：判断文件名是否为 APK 格式

#### isPDFFileName

判断字符串是否为 PDF 文件名。

```dart 47:47:lib/get_utils/src/extensions/string_extensions.dart
  bool get isPDFFileName => GetUtils.isPDF(this);
```

**说明**：判断文件名是否为 PDF 格式

#### isHTMLFileName

判断字符串是否为 HTML 文件名。

```dart 50:50:lib/get_utils/src/extensions/string_extensions.dart
  bool get isHTMLFileName => GetUtils.isHTML(this);
```

**说明**：判断文件名是否为 HTML 格式

### 网络和联系方式验证属性

#### isURL

判断字符串是否为有效的 URL。

```dart 53:53:lib/get_utils/src/extensions/string_extensions.dart
  bool get isURL => GetUtils.isURL(this);
```

**返回值**：如果字符串是有效的 URL 则返回 `true`，否则返回 `false`

**使用示例**：

```dart
print('https://example.com'.isURL); // 输出: true
print('http://example.com'.isURL); // 输出: true
print('not a url'.isURL); // 输出: false
```

#### isEmail

判断字符串是否为有效的邮箱地址。

```dart 56:56:lib/get_utils/src/extensions/string_extensions.dart
  bool get isEmail => GetUtils.isEmail(this);
```

**返回值**：如果字符串是有效的邮箱地址则返回 `true`，否则返回 `false`

**使用示例**：

```dart
print('user@example.com'.isEmail); // 输出: true
print('invalid.email'.isEmail); // 输出: false
print('user@domain.co.uk'.isEmail); // 输出: true
```

#### isPhoneNumber

判断字符串是否为有效的电话号码。

```dart 59:59:lib/get_utils/src/extensions/string_extensions.dart
  bool get isPhoneNumber => GetUtils.isPhoneNumber(this);
```

**返回值**：如果字符串是有效的电话号码则返回 `true`，否则返回 `false`

**使用示例**：

```dart
print('+1234567890'.isPhoneNumber); // 输出: true（取决于实现）
print('123-456-7890'.isPhoneNumber); // 输出: true（取决于实现）
```

### 日期和哈希验证属性

#### isDateTime

判断字符串是否为有效的日期时间格式。

```dart 62:62:lib/get_utils/src/extensions/string_extensions.dart
  bool get isDateTime => GetUtils.isDateTime(this);
```

**返回值**：如果字符串可以解析为日期时间则返回 `true`，否则返回 `false`

#### isMD5

判断字符串是否为 MD5 哈希值。

```dart 65:65:lib/get_utils/src/extensions/string_extensions.dart
  bool get isMD5 => GetUtils.isMD5(this);
```

**返回值**：如果字符串是有效的 MD5 哈希值则返回 `true`，否则返回 `false`

#### isSHA1

判断字符串是否为 SHA1 哈希值。

```dart 68:68:lib/get_utils/src/extensions/string_extensions.dart
  bool get isSHA1 => GetUtils.isSHA1(this);
```

**返回值**：如果字符串是有效的 SHA1 哈希值则返回 `true`，否则返回 `false`

#### isSHA256

判断字符串是否为 SHA256 哈希值。

```dart 71:71:lib/get_utils/src/extensions/string_extensions.dart
  bool get isSHA256 => GetUtils.isSHA256(this);
```

**返回值**：如果字符串是有效的 SHA256 哈希值则返回 `true`，否则返回 `false`

### 其他验证属性

#### isBinary

判断字符串是否为二进制值。

```dart 74:74:lib/get_utils/src/extensions/string_extensions.dart
  bool get isBinary => GetUtils.isBinary(this);
```

**返回值**：如果字符串只包含 0 和 1 则返回 `true`，否则返回 `false`

#### isIPv4

判断字符串是否为有效的 IPv4 地址。

```dart 77:77:lib/get_utils/src/extensions/string_extensions.dart
  bool get isIPv4 => GetUtils.isIPv4(this);
```

**返回值**：如果字符串是有效的 IPv4 地址则返回 `true`，否则返回 `false`

#### isIPv6

判断字符串是否为有效的 IPv6 地址。

```dart 79:79:lib/get_utils/src/extensions/string_extensions.dart
  bool get isIPv6 => GetUtils.isIPv6(this);
```

**返回值**：如果字符串是有效的 IPv6 地址则返回 `true`，否则返回 `false`

#### isHexadecimal

判断字符串是否为十六进制值。

```dart 82:82:lib/get_utils/src/extensions/string_extensions.dart
  bool get isHexadecimal => GetUtils.isHexadecimal(this);
```

**返回值**：如果字符串是有效的十六进制值则返回 `true`，否则返回 `false`

#### isPalindrome

判断字符串是否为回文。

```dart 85:85:lib/get_utils/src/extensions/string_extensions.dart
  bool get isPalindrome => GetUtils.isPalindrome(this);
```

**返回值**：如果字符串是回文则返回 `true`，否则返回 `false`

#### isPassport

判断字符串是否为有效的护照号码。

```dart 88:88:lib/get_utils/src/extensions/string_extensions.dart
  bool get isPassport => GetUtils.isPassport(this);
```

**返回值**：如果字符串是有效的护照号码则返回 `true`，否则返回 `false`

#### isCurrency

判断字符串是否为有效的货币格式。

```dart 91:91:lib/get_utils/src/extensions/string_extensions.dart
  bool get isCurrency => GetUtils.isCurrency(this);
```

**返回值**：如果字符串是有效的货币格式则返回 `true`，否则返回 `false`

#### isCpf

判断字符串是否为有效的 CPF（巴西身份证号）。

```dart 94:94:lib/get_utils/src/extensions/string_extensions.dart
  bool get isCpf => GetUtils.isCpf(this);
```

**返回值**：如果字符串是有效的 CPF 则返回 `true`，否则返回 `false`

#### isCnpj

判断字符串是否为有效的 CNPJ（巴西公司注册号）。

```dart 97:97:lib/get_utils/src/extensions/string_extensions.dart
  bool get isCnpj => GetUtils.isCnpj(this);
```

**返回值**：如果字符串是有效的 CNPJ 则返回 `true`，否则返回 `false`

### 字符串匹配方法

#### isCaseInsensitiveContains

判断字符串是否包含另一个字符串（不区分大小写）。

```dart 100:101:lib/get_utils/src/extensions/string_extensions.dart
  bool isCaseInsensitiveContains(String b) =>
      GetUtils.isCaseInsensitiveContains(this, b);
```

**参数说明**：

- `b`：要查找的字符串

**返回值**：如果包含则返回 `true`，否则返回 `false`

**使用示例**：

```dart
print('Hello World'.isCaseInsensitiveContains('hello')); // 输出: true
print('Hello World'.isCaseInsensitiveContains('WORLD')); // 输出: true
```

#### isCaseInsensitiveContainsAny

判断字符串是否包含另一个字符串中的任何字符（不区分大小写）。

```dart 104:105:lib/get_utils/src/extensions/string_extensions.dart
  bool isCaseInsensitiveContainsAny(String b) =>
      GetUtils.isCaseInsensitiveContainsAny(this, b);
```

**参数说明**：

- `b`：要查找的字符串

**返回值**：如果包含任何字符则返回 `true`，否则返回 `false`

### 字符串转换属性

#### capitalize

将字符串首字母大写。

```dart 108:108:lib/get_utils/src/extensions/string_extensions.dart
  String get capitalize => GetUtils.capitalize(this);
```

**返回值**：返回首字母大写的字符串

**使用示例**：

```dart
print('hello'.capitalize); // 输出: Hello
print('HELLO'.capitalize); // 输出: Hello（可能转换为小写后首字母大写）
```

#### capitalizeFirst

将字符串第一个字母大写。

```dart 111:111:lib/get_utils/src/extensions/string_extensions.dart
  String get capitalizeFirst => GetUtils.capitalizeFirst(this);
```

**返回值**：返回第一个字母大写的字符串

#### removeAllWhitespace

移除字符串中的所有空白字符。

```dart 114:114:lib/get_utils/src/extensions/string_extensions.dart
  String get removeAllWhitespace => GetUtils.removeAllWhitespace(this);
```

**返回值**：返回移除所有空白字符后的字符串

**使用示例**：

```dart
print('hello world'.removeAllWhitespace); // 输出: helloworld
print('  hello  world  '.removeAllWhitespace); // 输出: helloworld
```

#### camelCase

将字符串转换为驼峰命名。

```dart 117:117:lib/get_utils/src/extensions/string_extensions.dart
  String? get camelCase => GetUtils.camelCase(this);
```

**返回值**：返回驼峰命名的字符串，如果转换失败则返回 `null`

**使用示例**：

```dart
print('hello world'.camelCase); // 输出: helloWorld
print('hello-world'.camelCase); // 输出: helloWorld
```

#### paramCase

将字符串转换为参数命名（短横线分隔）。

```dart 120:120:lib/get_utils/src/extensions/string_extensions.dart
  String? get paramCase => GetUtils.paramCase(this);
```

**返回值**：返回参数命名的字符串，如果转换失败则返回 `null`

**使用示例**：

```dart
print('Hello World'.paramCase); // 输出: hello-world
print('helloWorld'.paramCase); // 输出: hello-world
```

### 路径处理方法

#### createPath

创建路径，支持添加路径段。

```dart 123:126:lib/get_utils/src/extensions/string_extensions.dart
  String createPath([Iterable? segments]) {
    final path = startsWith('/') ? this : '/$this';
    return GetUtils.createPath(path, segments);
  }
```

**参数说明**：

- `segments`：可选的路径段集合

**返回值**：返回创建后的路径字符串

**使用示例**：

```dart
print('api'.createPath(['users', '123'])); // 输出: /api/users/123
print('/api'.createPath(['users'])); // 输出: /api/users
```

#### capitalizeAllWordsFirstLetter

将字符串中所有单词的首字母大写。

```dart 129:130:lib/get_utils/src/extensions/string_extensions.dart
  String capitalizeAllWordsFirstLetter() =>
      GetUtils.capitalizeAllWordsFirstLetter(this);
```

**返回值**：返回所有单词首字母大写的字符串

**使用示例**：

```dart
print('hello world'.capitalizeAllWordsFirstLetter()); // 输出: Hello World
print('hello-world'.capitalizeAllWordsFirstLetter()); // 输出: Hello-World
```

## 完整使用示例

### 示例 1：表单验证

```dart
class FormValidator {
  // 验证邮箱
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return '邮箱不能为空';
    }
    if (!email.isEmail) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }
  
  // 验证电话号码
  String? validatePhone(String phone) {
    if (phone.isEmpty) {
      return '电话号码不能为空';
    }
    if (!phone.isPhoneNumber) {
      return '请输入有效的电话号码';
    }
    return null;
  }
  
  // 验证 URL
  String? validateURL(String url) {
    if (url.isEmpty) {
      return 'URL 不能为空';
    }
    if (!url.isURL) {
      return '请输入有效的 URL';
    }
    return null;
  }
}

void main() {
  final validator = FormValidator();
  
  // 验证邮箱
  print(validator.validateEmail('user@example.com')); // 输出: null（有效）
  print(validator.validateEmail('invalid.email')); // 输出: 请输入有效的邮箱地址
  
  // 验证电话号码
  print(validator.validatePhone('+1234567890')); // 输出: null（有效）
  
  // 验证 URL
  print(validator.validateURL('https://example.com')); // 输出: null（有效）
}
```

### 示例 2：文件类型处理

```dart
class FileProcessor {
  // 处理不同类型的文件
  void processFile(String fileName) {
    if (fileName.isImageFileName) {
      print('处理图片文件: $fileName');
    } else if (fileName.isVideoFileName) {
      print('处理视频文件: $fileName');
    } else if (fileName.isAudioFileName) {
      print('处理音频文件: $fileName');
    } else if (fileName.isPDFFileName) {
      print('处理 PDF 文件: $fileName');
    } else if (fileName.isDocumentFileName) {
      print('处理文档文件: $fileName');
    } else {
      print('未知文件类型: $fileName');
    }
  }
}

void main() {
  final processor = FileProcessor();
  
  processor.processFile('image.jpg'); // 输出: 处理图片文件: image.jpg
  processor.processFile('video.mp4'); // 输出: 处理视频文件: video.mp4
  processor.processFile('document.pdf'); // 输出: 处理 PDF 文件: document.pdf
}
```

### 示例 3：字符串格式化

```dart
class StringFormatter {
  // 格式化用户输入
  String formatUserInput(String input) {
    return input
        .removeAllWhitespace
        .capitalize;
  }
  
  // 转换为 API 参数格式
  String toApiParam(String input) {
    return input.paramCase ?? input;
  }
  
  // 转换为变量名格式
  String toVariableName(String input) {
    return input.camelCase ?? input;
  }
  
  // 格式化标题
  String formatTitle(String input) {
    return input.capitalizeAllWordsFirstLetter();
  }
}

void main() {
  final formatter = StringFormatter();
  
  // 格式化用户输入
  print(formatter.formatUserInput('  hello world  ')); // 输出: Helloworld
  
  // 转换为 API 参数
  print(formatter.toApiParam('Hello World')); // 输出: hello-world
  
  // 转换为变量名
  print(formatter.toVariableName('hello world')); // 输出: helloWorld
  
  // 格式化标题
  print(formatter.formatTitle('hello world')); // 输出: Hello World
}
```

### 示例 4：路径处理

```dart
class PathBuilder {
  // 构建 API 路径
  String buildApiPath(String base, List<String> segments) {
    return base.createPath(segments);
  }
  
  // 构建资源路径
  String buildResourcePath(String resource, String id) {
    return resource.createPath([id]);
  }
}

void main() {
  final builder = PathBuilder();
  
  // 构建 API 路径
  final apiPath = builder.buildApiPath('api', ['users', '123', 'posts']);
  print(apiPath); // 输出: /api/users/123/posts
  
  // 构建资源路径
  final resourcePath = builder.buildResourcePath('users', '123');
  print(resourcePath); // 输出: /users/123
}
```

## 最佳实践

### 何时使用这些扩展

1. **表单验证**：使用验证属性验证用户输入
2. **文件处理**：使用文件类型判断属性处理不同类型的文件
3. **字符串格式化**：使用转换属性格式化字符串
4. **路径构建**：使用路径处理方法构建路径

### 性能注意事项

1. **正则表达式**：某些验证方法使用正则表达式，可能有性能开销
2. **字符串操作**：字符串转换方法会创建新字符串，注意内存使用
3. **缓存考虑**：频繁使用的转换结果可以考虑缓存

### 常见使用场景

1. **表单验证**：验证用户输入的数据
2. **文件上传**：判断上传文件的类型
3. **数据格式化**：格式化显示的数据
4. **API 路径**：构建 API 请求路径
5. **数据清洗**：清理和规范化数据

### 注意事项

1. **验证精度**：某些验证方法可能不是 100% 准确，需要根据实际需求调整
2. **空值处理**：某些方法可能返回 `null`，使用时需要注意
3. **大小写敏感**：某些方法区分大小写，某些不区分，需要注意
4. **国际化**：某些验证方法可能只适用于特定地区（如 CPF、CNPJ）

## 总结

`string_extensions.dart` 提供了丰富的 `String` 类型扩展方法：

- **字符串验证**：提供了多种验证方法，包括数字、邮箱、URL、电话号码等
- **文件类型判断**：可以判断字符串是否为特定类型的文件名
- **格式转换**：提供了大小写转换、驼峰命名等格式转换方法
- **路径处理**：提供了路径创建和处理方法

这些扩展方法遵循 Dart 的最佳实践，在保持代码简洁的同时，提供了强大的字符串处理能力。通过使用这些扩展，开发者可以更方便地进行字符串验证、格式转换和路径操作，提高代码的可读性和编写效率。
