# GetUtils 代码讲解文档

## 概述

`GetUtils` 是 GetX 框架中提供的一个工具类，包含大量静态方法，用于数据验证、字符串处理、文件类型检查等常见操作。该类遵循 DRY（Don't Repeat Yourself）原则，将常用的工具方法集中管理，方便在项目中使用。

## 文件位置

```dart 8:662:lib/get_utils/src/get_utils/get_utils.dart
bool? _isEmpty(dynamic value) {
  // ... 代码内容 ...
}
```

## 主要功能

GetUtils 类提供了以下主要功能：

1. **空值检查** - 检查数据是否为 null 或空白
2. **类型验证** - 验证字符串是否为特定类型（数字、字母、布尔值等）
3. **文件类型检查** - 判断文件路径对应的文件类型
4. **格式验证** - 验证邮箱、URL、电话号码等格式
5. **长度检查** - 检查数据的长度是否符合要求
6. **字符串转换** - 提供多种字符串格式化方法
7. **特殊验证** - 回文检查、身份证验证等

## 私有辅助函数

### `_isEmpty()`

检查动态值是否为空。

```dart 8:16:lib/get_utils/src/get_utils/get_utils.dart
bool? _isEmpty(dynamic value) {
  if (value is String) {
    return value.toString().trim().isEmpty;
  }
  if (value is Iterable || value is Map) {
    return value.isEmpty as bool?;
  }
  return false;
}
```

**功能说明：**

- 如果值是字符串，先去除首尾空格再检查是否为空
- 如果值是 `Iterable` 或 `Map`，直接检查 `isEmpty` 属性
- 其他类型返回 `false`

**使用场景：** 内部使用，用于 `isNullOrBlank()` 和 `isBlank()` 方法。

### `_hasLength()`

检查动态值是否具有 `length` 属性。

```dart 23:25:lib/get_utils/src/get_utils/get_utils.dart
bool _hasLength(dynamic value) {
  return value is Iterable || value is String || value is Map;
}
```

**功能说明：**

- 检查值是否为 `Iterable`、`String` 或 `Map` 类型
- 这些类型都具有 `length` 属性

**使用场景：** 内部使用，用于判断是否可以获取长度。

### `_obtainDynamicLength()`

获取动态值的长度。

```dart 37:57:lib/get_utils/src/get_utils/get_utils.dart
int? _obtainDynamicLength(dynamic value) {
  if (value == null) {
    // ignore: avoid_returning_null
    return null;
  }

  if (_hasLength(value)) {
    return value.length as int?;
  }

  if (value is int) {
    return value.toString().length;
  }

  if (value is double) {
    return value.toString().replaceAll('.', '').length;
  }

  // ignore: avoid_returning_null
  return null;
}
```

**功能说明：**

- 如果值为 `null`，返回 `null`
- 如果值有 `length` 属性（通过 `_hasLength()` 判断），返回其长度
- 如果值是 `int`，转换为字符串后返回长度
- 如果值是 `double`，转换为字符串并移除小数点后返回长度
- 其他情况返回 `null`

**注意事项：**

- 该方法可能返回 `null`
- 对于数字类型，返回的是字符串表示的长度，而非数值本身

## GetUtils 类方法详解

### 空值检查方法

#### `isNull()`

检查数据是否为 null。

```dart 63:63:lib/get_utils/src/get_utils/get_utils.dart
static bool isNull(dynamic value) => value == null;
```

**使用示例：**

```dart
GetUtils.isNull(null);        // true
GetUtils.isNull('');          // false
GetUtils.isNull(0);           // false
```

#### `isNullOrBlank()`

检查数据是否为 null 或空白（空字符串或只包含空白字符）。

```dart 74:82:lib/get_utils/src/get_utils/get_utils.dart
static bool? isNullOrBlank(dynamic value) {
  if (isNull(value)) {
    return true;
  }

  // Pretty sure that isNullOrBlank should't be validating
  // iterables... but I'm going to keep this for compatibility.
  return _isEmpty(value);
}
```

**使用示例：**

```dart
GetUtils.isNullOrBlank(null);     // true
GetUtils.isNullOrBlank('');       // true
GetUtils.isNullOrBlank('   ');    // true
GetUtils.isNullOrBlank('text');   // false
GetUtils.isNullOrBlank([]);       // true
GetUtils.isNullOrBlank({});       // true
```

**注意事项：** 该方法也支持检查 `Iterable` 和 `Map`，这是为了保持向后兼容性。

#### `isBlank()`

检查数据是否为空白（不检查 null）。

```dart 85:87:lib/get_utils/src/get_utils/get_utils.dart
static bool? isBlank(dynamic value) {
  return _isEmpty(value);
}
```

**使用示例：**

```dart
GetUtils.isBlank('');        // true
GetUtils.isBlank('   ');     // true
GetUtils.isBlank('text');    // false
GetUtils.isBlank([]);        // true
```

#### `nil()`

兼容性方法，用于 Flutter 1.17 之前的版本。

```dart 71:71:lib/get_utils/src/get_utils/get_utils.dart
static dynamic nil(dynamic s) => s;
```

**功能说明：**

- 在 dart2js（Flutter v1.17）中，变量默认为 undefined
- 此方法用于确保 JSON 转换中的 null 类型
- 方法名 `nil` 来自 Objective-C，用于更简洁的语法

**注意事项：** 仅在 Flutter 版本 < 1.17 时使用。

### 类型验证方法

#### `isNum()`

检查字符串是否为数字（int 或 double）。

```dart 90:96:lib/get_utils/src/get_utils/get_utils.dart
static bool isNum(String value) {
  if (isNull(value)) {
    return false;
  }

  return num.tryParse(value) is num;
}
```

**使用示例：**

```dart
GetUtils.isNum('123');       // true
GetUtils.isNum('12.34');     // true
GetUtils.isNum('abc');       // false
GetUtils.isNum('12.34.56');  // false
```

#### `isNumericOnly()`

检查字符串是否只包含数字（不接受小数点）。

```dart 100:100:lib/get_utils/src/get_utils/get_utils.dart
static bool isNumericOnly(String s) => hasMatch(s, r'^\d+$');
```

**使用示例：**

```dart
GetUtils.isNumericOnly('123');     // true
GetUtils.isNumericOnly('12.34');   // false
GetUtils.isNumericOnly('abc123');  // false
```

#### `isAlphabetOnly()`

检查字符串是否只包含字母（无空格）。

```dart 103:103:lib/get_utils/src/get_utils/get_utils.dart
static bool isAlphabetOnly(String s) => hasMatch(s, r'^[a-zA-Z]+$');
```

**使用示例：**

```dart
GetUtils.isAlphabetOnly('abc');      // true
GetUtils.isAlphabetOnly('ABC');      // true
GetUtils.isAlphabetOnly('abc123');   // false
GetUtils.isAlphabetOnly('abc def');  // false
```

#### `hasCapitalLetter()`

检查字符串是否包含至少一个大写字母。

```dart 106:106:lib/get_utils/src/get_utils/get_utils.dart
static bool hasCapitalLetter(String s) => hasMatch(s, r'[A-Z]');
```

**使用示例：**

```dart
GetUtils.hasCapitalLetter('Hello');  // true
GetUtils.hasCapitalLetter('hello');  // false
GetUtils.hasCapitalLetter('HELLO');  // true
```

#### `isBool()`

检查字符串是否为布尔值。

```dart 109:115:lib/get_utils/src/get_utils/get_utils.dart
static bool isBool(String value) {
  if (isNull(value)) {
    return false;
  }

  return (value == 'true' || value == 'false');
}
```

**使用示例：**

```dart
GetUtils.isBool('true');    // true
GetUtils.isBool('false');   // true
GetUtils.isBool('True');    // false（区分大小写）
GetUtils.isBool('1');       // false
```

### 文件类型检查方法

#### `isVideo()`

检查字符串是否为视频文件路径。

```dart 118:128:lib/get_utils/src/get_utils/get_utils.dart
static bool isVideo(String filePath) {
  var ext = filePath.toLowerCase();

  return ext.endsWith(".mp4") ||
      ext.endsWith(".avi") ||
      ext.endsWith(".wmv") ||
      ext.endsWith(".rmvb") ||
      ext.endsWith(".mpg") ||
      ext.endsWith(".mpeg") ||
      ext.endsWith(".3gp");
}
```

**支持的格式：** mp4, avi, wmv, rmvb, mpg, mpeg, 3gp

**使用示例：**

```dart
GetUtils.isVideo('video.mp4');        // true
GetUtils.isVideo('VIDEO.AVI');        // true（不区分大小写）
GetUtils.isVideo('image.jpg');        // false
```

#### `isImage()`

检查字符串是否为图片文件路径。

```dart 131:139:lib/get_utils/src/get_utils/get_utils.dart
static bool isImage(String filePath) {
  final ext = filePath.toLowerCase();

  return ext.endsWith(".jpg") ||
      ext.endsWith(".jpeg") ||
      ext.endsWith(".png") ||
      ext.endsWith(".gif") ||
      ext.endsWith(".bmp");
}
```

**支持的格式：** jpg, jpeg, png, gif, bmp

#### `isAudio()`

检查字符串是否为音频文件路径。

```dart 142:150:lib/get_utils/src/get_utils/get_utils.dart
static bool isAudio(String filePath) {
  final ext = filePath.toLowerCase();

  return ext.endsWith(".mp3") ||
      ext.endsWith(".wav") ||
      ext.endsWith(".wma") ||
      ext.endsWith(".amr") ||
      ext.endsWith(".ogg");
}
```

**支持的格式：** mp3, wav, wma, amr, ogg

#### `isPPT()`

检查字符串是否为 PowerPoint 文件路径。

```dart 153:157:lib/get_utils/src/get_utils/get_utils.dart
static bool isPPT(String filePath) {
  final ext = filePath.toLowerCase();

  return ext.endsWith(".ppt") || ext.endsWith(".pptx");
}
```

#### `isWord()`

检查字符串是否为 Word 文件路径。

```dart 160:164:lib/get_utils/src/get_utils/get_utils.dart
static bool isWord(String filePath) {
  final ext = filePath.toLowerCase();

  return ext.endsWith(".doc") || ext.endsWith(".docx");
}
```

#### `isExcel()`

检查字符串是否为 Excel 文件路径。

```dart 167:171:lib/get_utils/src/get_utils/get_utils.dart
static bool isExcel(String filePath) {
  final ext = filePath.toLowerCase();

  return ext.endsWith(".xls") || ext.endsWith(".xlsx");
}
```

#### 其他文件类型检查方法

```dart 173:201:lib/get_utils/src/get_utils/get_utils.dart
static bool isAPK(String filePath) {
  return filePath.toLowerCase().endsWith(".apk");
}

/// Checks if string is an pdf file.
static bool isPDF(String filePath) {
  return filePath.toLowerCase().endsWith(".pdf");
}

/// Checks if string is an txt file.
static bool isTxt(String filePath) {
  return filePath.toLowerCase().endsWith(".txt");
}

/// Checks if string is an chm file.
static bool isChm(String filePath) {
  return filePath.toLowerCase().endsWith(".chm");
}

/// Checks if string is a vector file.
static bool isVector(String filePath) {
  return filePath.toLowerCase().endsWith(".svg");
}

/// Checks if string is an html file.
static bool isHTML(String filePath) {
  return filePath.toLowerCase().endsWith(".html");
}
```

**支持的文件类型：**

- `isAPK()` - Android 安装包
- `isPDF()` - PDF 文档
- `isTxt()` - 文本文件
- `isChm()` - 编译的 HTML 帮助文件
- `isVector()` - SVG 矢量图
- `isHTML()` - HTML 文件

### 格式验证方法

#### `isUsername()`

检查字符串是否为有效的用户名。

```dart 204:205:lib/get_utils/src/get_utils/get_utils.dart
static bool isUsername(String s) =>
    hasMatch(s, r'^[a-zA-Z0-9][a-zA-Z0-9_.]+[a-zA-Z0-9]$');
```

**规则：**

- 必须以字母或数字开头
- 可以包含字母、数字、下划线和点
- 必须以字母或数字结尾
- 至少 3 个字符

**使用示例：**

```dart
GetUtils.isUsername('user123');      // true
GetUtils.isUsername('user_name');    // true
GetUtils.isUsername('user.name');    // true
GetUtils.isUsername('_user');        // false（不能以下划线开头）
GetUtils.isUsername('user_');        // false（不能以下划线结尾）
```

#### `isURL()`

检查字符串是否为有效的 URL。

```dart 208:209:lib/get_utils/src/get_utils/get_utils.dart
static bool isURL(String s) => hasMatch(s,
    r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,7}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$");
```

**使用示例：**

```dart
GetUtils.isURL('https://example.com');           // true
GetUtils.isURL('http://www.example.com');        // true
GetUtils.isURL('www.example.com');              // true
GetUtils.isURL('ftp://example.com');             // true
GetUtils.isURL('not a url');                     // false
```

#### `isEmail()`

检查字符串是否为有效的邮箱地址。

```dart 212:213:lib/get_utils/src/get_utils/get_utils.dart
static bool isEmail(String s) => hasMatch(s,
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
```

**使用示例：**

```dart
GetUtils.isEmail('user@example.com');           // true
GetUtils.isEmail('user.name@example.com');      // true
GetUtils.isEmail('user@example.co.uk');         // true
GetUtils.isEmail('invalid.email');              // false
GetUtils.isEmail('@example.com');               // false
```

#### `isPhoneNumber()`

检查字符串是否为有效的电话号码。

```dart 216:219:lib/get_utils/src/get_utils/get_utils.dart
static bool isPhoneNumber(String s) {
  if (s.length > 16 || s.length < 9) return false;
  return hasMatch(s, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
}
```

**规则：**

- 长度必须在 9-16 位之间
- 可以包含 +、()、-、空格、.、/ 等符号

**使用示例：**

```dart
GetUtils.isPhoneNumber('+1234567890');      // true
GetUtils.isPhoneNumber('(123) 456-7890');    // true
GetUtils.isPhoneNumber('123-456-7890');     // true
GetUtils.isPhoneNumber('123456789');        // true
GetUtils.isPhoneNumber('12345');            // false（太短）
```

#### `isDateTime()`

检查字符串是否为有效的日期时间格式（UTC 或 ISO8601）。

```dart 222:223:lib/get_utils/src/get_utils/get_utils.dart
static bool isDateTime(String s) =>
    hasMatch(s, r'^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}.\d{3}Z?$');
```

**格式要求：** `YYYY-MM-DD HH:mm:ss.SSS` 或 `YYYY-MM-DDTHH:mm:ss.SSSZ`

**使用示例：**

```dart
GetUtils.isDateTime('2023-05-20 14:30:00.000');    // true
GetUtils.isDateTime('2023-05-20T14:30:00.000Z');   // true
GetUtils.isDateTime('2023-05-20');                 // false
```

#### 加密哈希验证方法

```dart 225:234:lib/get_utils/src/get_utils/get_utils.dart
/// Checks if string is MD5 hash.
static bool isMD5(String s) => hasMatch(s, r'^[a-f0-9]{32}$');

/// Checks if string is SHA1 hash.
static bool isSHA1(String s) =>
    hasMatch(s, r'(([A-Fa-f0-9]{2}\:){19}[A-Fa-f0-9]{2}|[A-Fa-f0-9]{40})');

/// Checks if string is SHA256 hash.
static bool isSHA256(String s) =>
    hasMatch(s, r'([A-Fa-f0-9]{2}\:){31}[A-Fa-f0-9]{2}|[A-Fa-f0-9]{64}');
```

**支持的哈希格式：**

- `isMD5()` - 32 位十六进制字符串
- `isSHA1()` - 40 位十六进制字符串（支持冒号分隔格式）
- `isSHA256()` - 64 位十六进制字符串（支持冒号分隔格式）

#### 其他格式验证方法

```dart 236:254:lib/get_utils/src/get_utils/get_utils.dart
/// Checks if string is SSN (Social Security Number).
static bool isSSN(String s) => hasMatch(s,
    r'^(?!0{3}|6{3}|9[0-9]{2})[0-9]{3}-?(?!0{2})[0-9]{2}-?(?!0{4})[0-9]{4}$');

/// Checks if string is binary.
static bool isBinary(String s) => hasMatch(s, r'^[0-1]+$');

/// Checks if string is IPv4.
static bool isIPv4(String s) =>
    hasMatch(s, r'^(?:(?:^|\.)(?:2(?:5[0-5]|[0-4]\d)|1?\d?\d)){4}$');

/// Checks if string is IPv6.
static bool isIPv6(String s) => hasMatch(s,
    r'^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(([0-9A-Fa-f]{1,4}:){0,5}:((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(::([0-9A-Fa-f]{1,4}:){0,5}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$');

/// Checks if string is hexadecimal.
/// Example: HexColor => #12F
static bool isHexadecimal(String s) =>
    hasMatch(s, r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
```

**支持的格式：**

- `isSSN()` - 美国社会安全号码
- `isBinary()` - 二进制字符串（只包含 0 和 1）
- `isIPv4()` - IPv4 地址
- `isIPv6()` - IPv6 地址
- `isHexadecimal()` - 十六进制颜色值（如 #12F 或 #123456）

#### `isCurrency()`

检查字符串是否为有效的货币格式。

```dart 309:310:lib/get_utils/src/get_utils/get_utils.dart
static bool isCurrency(String s) => hasMatch(s,
    r'^(S?\$|\₩|Rp|\¥|\€|\₹|\₽|fr|R\$|R)?[ ]?[-]?([0-9]{1,3}[,.]([0-9]{3}[,.])*[0-9]{3}|[0-9]+)([,.][0-9]{1,2})?( ?(USD?|AUD|NZD|CAD|CHF|GBP|CNY|EUR|JPY|IDR|MXN|NOK|KRW|TRY|INR|RUB|BRL|ZAR|SGD|MYR))?$');
```

**支持的货币符号：** $, ₩, Rp, ¥, €, ₹, ₽, fr, R$, R

**支持的货币代码：** USD, AUD, NZD, CAD, CHF, GBP, CNY, EUR, JPY, IDR, MXN, NOK, KRW, TRY, INR, RUB, BRL, ZAR, SGD, MYR

#### `isPassport()`

检查字符串是否为有效的护照号码。

```dart 305:306:lib/get_utils/src/get_utils/get_utils.dart
static bool isPassport(String s) =>
    hasMatch(s, r'^(?!^0+$)[a-zA-Z0-9]{6,9}$');
```

**规则：**

- 长度为 6-9 位
- 可以包含字母和数字
- 不能全为 0

### 特殊验证方法

#### `isPalindrome()`

检查字符串是否为回文。

```dart 257:270:lib/get_utils/src/get_utils/get_utils.dart
static bool isPalindrome(String string) {
  final cleanString = string
      .toLowerCase()
      .replaceAll(RegExp(r"\s+"), '')
      .replaceAll(RegExp(r"[^0-9a-zA-Z]+"), "");

  for (var i = 0; i < cleanString.length; i++) {
    if (cleanString[i] != cleanString[cleanString.length - i - 1]) {
      return false;
    }
  }

  return true;
}
```

**功能说明：**

- 转换为小写
- 移除所有空格和特殊字符
- 检查是否为回文

**使用示例：**

```dart
GetUtils.isPalindrome('racecar');        // true
GetUtils.isPalindrome('A man a plan');   // true（忽略空格和大小写）
GetUtils.isPalindrome('hello');          // false
```

#### `isOneAKind()`

检查所有数据是否具有相同的值。

```dart 274:302:lib/get_utils/src/get_utils/get_utils.dart
static bool isOneAKind(dynamic value) {
  if ((value is String || value is List) && !isNullOrBlank(value)!) {
    final first = value[0];
    final len = value.length as num;

    for (var i = 0; i < len; i++) {
      if (value[i] != first) {
        return false;
      }
    }

    return true;
  }

  if (value is int) {
    final stringValue = value.toString();
    final first = stringValue[0];

    for (var i = 0; i < stringValue.length; i++) {
      if (stringValue[i] != first) {
        return false;
      }
    }

    return true;
  }

  return false;
}
```

**使用示例：**

```dart
GetUtils.isOneAKind('111111');     // true
GetUtils.isOneAKind('wwwww');      // true
GetUtils.isOneAKind([1, 1, 1, 1]); // true
GetUtils.isOneAKind(222);          // true
GetUtils.isOneAKind('123');        // false
```

#### `isCnpj()`

验证巴西 CNPJ（公司注册号）。

```dart 401:447:lib/get_utils/src/get_utils/get_utils.dart
static bool isCnpj(String cnpj) {
  // Get only the numbers from the CNPJ
  final numbers = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

  // Test if the CNPJ has 14 digits
  if (numbers.length != 14) {
    return false;
  }

  // Test if all digits of the CNPJ are the same
  if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) {
    return false;
  }

  // Divide digits
  final digits = numbers.split('').map(int.parse).toList();

  // Calculate the first check digit
  var calcDv1 = 0;
  var j = 0;
  for (var i in Iterable<int>.generate(12, (i) => i < 4 ? 5 - i : 13 - i)) {
    calcDv1 += digits[j++] * i;
  }
  calcDv1 %= 11;
  final dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;

  // Test the first check digit
  if (digits[12] != dv1) {
    return false;
  }

  // Calculate the second check digit
  var calcDv2 = 0;
  j = 0;
  for (var i in Iterable<int>.generate(13, (i) => i < 5 ? 6 - i : 14 - i)) {
    calcDv2 += digits[j++] * i;
  }
  calcDv2 %= 11;
  final dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;

  // Test the second check digit
  if (digits[13] != dv2) {
    return false;
  }

  return true;
}
```

**功能说明：**

- 提取数字部分
- 验证长度为 14 位
- 验证不能所有数字相同
- 计算并验证两个校验位

#### `isCpf()`

验证巴西 CPF（个人税号）。

```dart 450:498:lib/get_utils/src/get_utils/get_utils.dart
static bool isCpf(String cpf) {
  // get only the numbers
  final numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
  // Test if the CPF has 11 digits
  if (numbers.length != 11) {
    return false;
  }
  // Test if all CPF digits are the same
  if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) {
    return false;
  }

  // split the digits
  final digits = numbers.split('').map(int.parse).toList();

  // Calculate the first verifier digit
  var calcDv1 = 0;
  for (var i in Iterable<int>.generate(9, (i) => 10 - i)) {
    calcDv1 += digits[10 - i] * i;
  }
  calcDv1 %= 11;

  final dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;

  // Tests the first verifier digit
  if (digits[9] != dv1) {
    return false;
  }

  // Calculate the second verifier digit
  var calcDv2 = 0;
  for (var i in Iterable<int>.generate(10, (i) => 11 - i)) {
    calcDv2 += digits[11 - i] * i;
  }
  calcDv2 %= 11;

  final dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;

  // Test the second verifier digit
  if (digits[10] != dv2) {
    return false;
  }

  return true;
}
```

**功能说明：**

- 提取数字部分
- 验证长度为 11 位
- 验证不能所有数字相同
- 计算并验证两个校验位

### 长度检查方法

#### `isLengthGreaterThan()`

检查数据长度是否大于指定值。

```dart 313:321:lib/get_utils/src/get_utils/get_utils.dart
static bool isLengthGreaterThan(dynamic value, int maxLength) {
  final length = _obtainDynamicLength(value);

  if (length == null) {
    return false;
  }

  return length > maxLength;
}
```

**使用示例：**

```dart
GetUtils.isLengthGreaterThan('hello', 3);  // true
GetUtils.isLengthGreaterThan('hi', 3);     // false
GetUtils.isLengthGreaterThan([1, 2, 3, 4], 3); // true
```

#### `isLengthGreaterOrEqual()`

检查数据长度是否大于等于指定值。

```dart 324:332:lib/get_utils/src/get_utils/get_utils.dart
static bool isLengthGreaterOrEqual(dynamic value, int maxLength) {
  final length = _obtainDynamicLength(value);

  if (length == null) {
    return false;
  }

  return length >= maxLength;
}
```

#### `isLengthLessThan()`

检查数据长度是否小于指定值。

```dart 335:342:lib/get_utils/src/get_utils/get_utils.dart
static bool isLengthLessThan(dynamic value, int maxLength) {
  final length = _obtainDynamicLength(value);
  if (length == null) {
    return false;
  }

  return length < maxLength;
}
```

#### `isLengthLessOrEqual()`

检查数据长度是否小于等于指定值。

```dart 345:353:lib/get_utils/src/get_utils/get_utils.dart
static bool isLengthLessOrEqual(dynamic value, int maxLength) {
  final length = _obtainDynamicLength(value);

  if (length == null) {
    return false;
  }

  return length <= maxLength;
}
```

#### `isLengthEqualTo()`

检查数据长度是否等于指定值。

```dart 356:364:lib/get_utils/src/get_utils/get_utils.dart
static bool isLengthEqualTo(dynamic value, int otherLength) {
  final length = _obtainDynamicLength(value);

  if (length == null) {
    return false;
  }

  return length == otherLength;
}
```

#### `isLengthBetween()`

检查数据长度是否在指定范围内。

```dart 367:374:lib/get_utils/src/get_utils/get_utils.dart
static bool isLengthBetween(dynamic value, int minLength, int maxLength) {
  if (isNull(value)) {
    return false;
  }

  return isLengthGreaterOrEqual(value, minLength) &&
      isLengthLessOrEqual(value, maxLength);
}
```

**使用示例：**

```dart
GetUtils.isLengthBetween('hello', 3, 10);  // true
GetUtils.isLengthBetween('hi', 3, 10);    // false
GetUtils.isLengthBetween('very long string', 3, 10); // false
```

### 字符串比较方法

#### `isCaseInsensitiveContains()`

检查字符串 a 是否包含字符串 b（不区分大小写）。

```dart 378:380:lib/get_utils/src/get_utils/get_utils.dart
static bool isCaseInsensitiveContains(String a, String b) {
  return a.toLowerCase().contains(b.toLowerCase());
}
```

**使用示例：**

```dart
GetUtils.isCaseInsensitiveContains('Hello World', 'hello');  // true
GetUtils.isCaseInsensitiveContains('Hello World', 'WORLD');  // true
GetUtils.isCaseInsensitiveContains('Hello World', 'test');    // false
```

#### `isCaseInsensitiveContainsAny()`

检查字符串 a 是否包含字符串 b，或字符串 b 是否包含字符串 a（不区分大小写）。

```dart 384:389:lib/get_utils/src/get_utils/get_utils.dart
static bool isCaseInsensitiveContainsAny(String a, String b) {
  final lowA = a.toLowerCase();
  final lowB = b.toLowerCase();

  return lowA.contains(lowB) || lowB.contains(lowA);
}
```

**使用示例：**

```dart
GetUtils.isCaseInsensitiveContainsAny('Hello', 'Hello World');  // true
GetUtils.isCaseInsensitiveContainsAny('Hello World', 'Hello');  // true
GetUtils.isCaseInsensitiveContainsAny('Hello', 'World');         // false
```

#### `isLowerThan()`

检查数字 a 是否小于数字 b。

```dart 392:392:lib/get_utils/src/get_utils/get_utils.dart
static bool isLowerThan(num a, num b) => a < b;
```

#### `isGreaterThan()`

检查数字 a 是否大于数字 b。

```dart 395:395:lib/get_utils/src/get_utils/get_utils.dart
static bool isGreaterThan(num a, num b) => a > b;
```

#### `isEqual()`

检查数字 a 是否等于数字 b。

```dart 398:398:lib/get_utils/src/get_utils/get_utils.dart
static bool isEqual(num a, num b) => a == b;
```

### 字符串转换方法

#### `capitalize()`

将字符串中每个单词的首字母大写。

```dart 502:505:lib/get_utils/src/get_utils/get_utils.dart
static String capitalize(String value) {
  if (isBlank(value)!) return value;
  return value.split(' ').map(capitalizeFirst).join(' ');
}
```

**使用示例：**

```dart
GetUtils.capitalize('your name');        // 'Your Name'
GetUtils.capitalize('hello world');      // 'Hello World'
GetUtils.capitalize('');                 // ''
```

#### `capitalizeFirst()`

将字符串的首字母大写，其余字母小写。

```dart 509:512:lib/get_utils/src/get_utils/get_utils.dart
static String capitalizeFirst(String s) {
  if (isBlank(s)!) return s;
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}
```

**使用示例：**

```dart
GetUtils.capitalizeFirst('hello');       // 'Hello'
GetUtils.capitalizeFirst('HELLO');       // 'Hello'
GetUtils.capitalizeFirst('hELLO');       // 'Hello'
```

#### `removeAllWhitespace()`

移除字符串中的所有空格。

```dart 516:518:lib/get_utils/src/get_utils/get_utils.dart
static String removeAllWhitespace(String value) {
  return value.replaceAll(' ', '');
}
```

**使用示例：**

```dart
GetUtils.removeAllWhitespace('your name');  // 'yourname'
GetUtils.removeAllWhitespace('hello world'); // 'helloworld'
```

#### `camelCase()`

将字符串转换为驼峰命名。

```dart 522:536:lib/get_utils/src/get_utils/get_utils.dart
static String? camelCase(String value) {
  if (isNullOrBlank(value)!) {
    return null;
  }

  final separatedWords =
      value.split(RegExp(r'[!@#<>?":`~;[\]\\|=+)(*&^%-\s_]+'));
  var newString = '';

  for (final word in separatedWords) {
    newString += word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  return newString[0].toLowerCase() + newString.substring(1);
}
```

**使用示例：**

```dart
GetUtils.camelCase('your name');         // 'yourName'
GetUtils.camelCase('hello world');       // 'helloWorld'
GetUtils.camelCase('user_name');         // 'userName'
GetUtils.camelCase('');                  // null
```

#### `snakeCase()`

将字符串转换为蛇形命名。

```dart 565:572:lib/get_utils/src/get_utils/get_utils.dart
static String? snakeCase(String? text, {String separator = '_'}) {
  if (isNullOrBlank(text)!) {
    return null;
  }
  return _groupIntoWords(text!)
      .map((word) => word.toLowerCase())
      .join(separator);
}
```

**使用示例：**

```dart
GetUtils.snakeCase('YourName');          // 'your_name'
GetUtils.snakeCase('helloWorld');       // 'hello_world'
GetUtils.snakeCase('User Name');        // 'user_name'
GetUtils.snakeCase('helloWorld', separator: '-'); // 'hello-world'
```

**内部实现：** 使用 `_groupIntoWords()` 方法将文本分组为单词。

#### `paramCase()`

将字符串转换为参数命名（使用连字符）。

```dart 575:575:lib/get_utils/src/get_utils/get_utils.dart
static String? paramCase(String? text) => snakeCase(text, separator: '-');
```

**使用示例：**

```dart
GetUtils.paramCase('YourName');          // 'your-name'
GetUtils.paramCase('helloWorld');       // 'hello-world'
```

#### `numericOnly()`

从字符串中提取数字。

```dart 581:594:lib/get_utils/src/get_utils/get_utils.dart
static String numericOnly(String s, {bool firstWordOnly = false}) {
  var numericOnlyStr = '';

  for (var i = 0; i < s.length; i++) {
    if (isNumericOnly(s[i])) {
      numericOnlyStr += s[i];
    }
    if (firstWordOnly && numericOnlyStr.isNotEmpty && s[i] == " ") {
      break;
    }
  }

  return numericOnlyStr;
}
```

**使用示例：**

```dart
GetUtils.numericOnly('OTP 12312 27/04/2020');           // '1231227042020'
GetUtils.numericOnly('OTP 12312 27/04/2020', firstWordOnly: true); // '12312'
GetUtils.numericOnly('abc123def456');                   // '123456'
```

#### `capitalizeAllWordsFirstLetter()`

将字符串中每个单词的首字母大写。

```dart 599:632:lib/get_utils/src/get_utils/get_utils.dart
static String capitalizeAllWordsFirstLetter(String s) {
  String lowerCasedString = s.toLowerCase();
  String stringWithoutExtraSpaces = lowerCasedString.trim();

  if (stringWithoutExtraSpaces.isEmpty) {
    return "";
  }
  if (stringWithoutExtraSpaces.length == 1) {
    return stringWithoutExtraSpaces.toUpperCase();
  }

  List<String> stringWordsList = stringWithoutExtraSpaces.split(" ");
  List<String> capitalizedWordsFirstLetter = stringWordsList
      .map(
        (word) {
          if (word.trim().isEmpty) return "";
          return word.trim();
        },
      )
      .where(
        (word) => word != "",
      )
      .map(
        (word) {
          if (word.startsWith(RegExp(r'[\n\t\r]'))) {
            return word;
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        },
      )
      .toList();
  String finalResult = capitalizedWordsFirstLetter.join(" ");
  return finalResult;
}
```

**使用示例：**

```dart
GetUtils.capitalizeAllWordsFirstLetter('getx will make it easy');
// 'Getx Will Make It Easy'

GetUtils.capitalizeAllWordsFirstLetter('this is an example text');
// 'This Is An Example Text'
```

### 工具方法

#### `hasMatch()`

检查字符串是否匹配正则表达式。

```dart 634:636:lib/get_utils/src/get_utils/get_utils.dart
static bool hasMatch(String? value, String pattern) {
  return (value == null) ? false : RegExp(pattern).hasMatch(value);
}
```

**使用示例：**

```dart
GetUtils.hasMatch('hello123', r'\d+');   // true
GetUtils.hasMatch('hello', r'\d+');      // false
GetUtils.hasMatch(null, r'\d+');         // false
```

**注意事项：** 这是内部方法，被其他验证方法广泛使用。

#### `createPath()`

创建路径字符串。

```dart 638:644:lib/get_utils/src/get_utils/get_utils.dart
static String createPath(String path, [Iterable? segments]) {
  if (segments == null || segments.isEmpty) {
    return path;
  }
  final list = segments.map((e) => '/$e');
  return path + list.join();
}
```

**使用示例：**

```dart
GetUtils.createPath('/api', ['users', '123']);  // '/api/users/123'
GetUtils.createPath('/api');                     // '/api'
GetUtils.createPath('/api', []);                 // '/api'
```

#### `printFunction()`

打印函数，用于日志输出。

```dart 646:653:lib/get_utils/src/get_utils/get_utils.dart
static void printFunction(
  String prefix,
  dynamic value,
  String info, {
  bool isError = false,
}) {
  Get.log('$prefix $value $info'.trim(), isError: isError);
}
```

**使用示例：**

```dart
GetUtils.printFunction('[INFO]', 'User', 'logged in');
GetUtils.printFunction('[ERROR]', 'Connection', 'failed', isError: true);
```

## 类型定义

### `PrintFunctionCallback`

打印函数回调类型定义。

```dart 656:661:lib/get_utils/src/get_utils/get_utils.dart
typedef PrintFunctionCallback = void Function(
  String prefix,
  dynamic value,
  String info, {
  bool? isError,
});
```

**功能说明：** 定义了打印函数的回调签名，可以用于自定义日志输出。

## 使用示例

### 综合示例

```dart
import 'package:get/get.dart';

void main() {
  // 空值检查
  print(GetUtils.isNullOrBlank(''));           // true
  print(GetUtils.isNullOrBlank('hello'));      // false

  // 类型验证
  print(GetUtils.isNum('123'));                // true
  print(GetUtils.isEmail('user@example.com')); // true

  // 文件类型检查
  print(GetUtils.isImage('photo.jpg'));        // true
  print(GetUtils.isVideo('movie.mp4'));        // true

  // 格式验证
  print(GetUtils.isURL('https://example.com')); // true
  print(GetUtils.isPhoneNumber('+1234567890')); // true

  // 长度检查
  print(GetUtils.isLengthBetween('hello', 3, 10)); // true

  // 字符串转换
  print(GetUtils.capitalize('hello world'));   // 'Hello World'
  print(GetUtils.camelCase('your name'));      // 'yourName'
  print(GetUtils.snakeCase('YourName'));       // 'your_name'

  // 特殊验证
  print(GetUtils.isPalindrome('racecar'));     // true
  print(GetUtils.isCpf('12345678901'));        // false（无效的 CPF）
}
```

### 表单验证示例

```dart
class FormValidator {
  static String? validateEmail(String? value) {
    if (GetUtils.isNullOrBlank(value)!) {
      return '邮箱不能为空';
    }
    if (!GetUtils.isEmail(value!)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (GetUtils.isNullOrBlank(value)!) {
      return '密码不能为空';
    }
    if (!GetUtils.isLengthGreaterOrEqual(value, 8)) {
      return '密码长度至少为 8 位';
    }
    if (!GetUtils.hasCapitalLetter(value!)) {
      return '密码必须包含至少一个大写字母';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (GetUtils.isNullOrBlank(value)!) {
      return '电话号码不能为空';
    }
    if (!GetUtils.isPhoneNumber(value!)) {
      return '请输入有效的电话号码';
    }
    return null;
  }
}
```

### 文件处理示例

```dart
class FileHandler {
  static String getFileType(String filePath) {
    if (GetUtils.isImage(filePath)) {
      return '图片';
    } else if (GetUtils.isVideo(filePath)) {
      return '视频';
    } else if (GetUtils.isAudio(filePath)) {
      return '音频';
    } else if (GetUtils.isPDF(filePath)) {
      return 'PDF 文档';
    } else if (GetUtils.isWord(filePath)) {
      return 'Word 文档';
    } else if (GetUtils.isExcel(filePath)) {
      return 'Excel 文档';
    } else {
      return '未知类型';
    }
  }

  static bool canPreview(String filePath) {
    return GetUtils.isImage(filePath) ||
        GetUtils.isPDF(filePath) ||
        GetUtils.isTxt(filePath);
  }
}
```

## 注意事项

### 返回值说明

1. **可空返回值：** 部分方法返回 `bool?`，可能为 `null`，使用前需要检查
   - `isNullOrBlank()` - 返回 `bool?`
   - `isBlank()` - 返回 `bool?`

2. **字符串转换方法：** 部分方法可能返回 `null`
   - `camelCase()` - 如果输入为空，返回 `null`
   - `snakeCase()` - 如果输入为空，返回 `null`
   - `paramCase()` - 如果输入为空，返回 `null`

### 特殊行为说明

1. **`_obtainDynamicLength()` 方法：**
   - 对于数字类型，返回的是字符串表示的长度，而非数值本身
   - 例如：`_obtainDynamicLength(123)` 返回 `3`（字符串 "123" 的长度）

2. **`isNullOrBlank()` 方法：**
   - 为了保持向后兼容性，该方法也支持检查 `Iterable` 和 `Map`
   - 注释中说明这可能是设计上的问题，但为了兼容性保留

3. **`nil()` 方法：**
   - 仅在 Flutter 版本 < 1.17 时使用
   - 新版本中不需要使用此方法

### 兼容性说明

1. **`nil()` 方法：** 用于 Flutter 1.17 之前的版本，新版本不需要使用

2. **正则表达式：** 所有正则表达式验证方法都使用 Dart 的 `RegExp` 类，兼容性良好

3. **类型检查：** 使用 Dart 的类型检查机制，在不同 Dart 版本中行为一致

## 总结

`GetUtils` 类提供了丰富的工具方法，涵盖了数据验证、字符串处理、文件类型检查等常见需求。这些方法都是静态方法，可以直接通过类名调用，使用方便。在实际开发中，可以根据具体需求选择合适的方法进行数据验证和处理。
