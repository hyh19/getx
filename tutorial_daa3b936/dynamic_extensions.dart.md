# Dynamic Extensions 代码讲解

## 概述

`dynamic_extensions.dart` 文件为 Dart 的 `dynamic` 类型提供了实用的扩展方法，主要包括空白值检查和日志输出功能。这些扩展方法让开发者能够更方便地处理动态类型的数据验证和调试输出。

### 主要功能

1. **空白值检查**：提供 `isBlank` 属性用于检查值是否为空或空白
2. **错误日志**：提供 `printError` 方法用于输出错误日志
3. **信息日志**：提供 `printInfo` 方法用于输出信息日志

## 文件结构

该文件包含一个扩展：

- `GetDynamicUtils` - 为 `dynamic` 类型提供扩展方法

## GetDynamicUtils 扩展详解

### 空白值检查属性

#### isBlank

检查值是否为空或空白。

```dart 4:4:lib/get_utils/src/extensions/dynamic_extensions.dart
  bool? get isBlank => GetUtils.isBlank(this);
```

**返回值**：返回 `bool?` 类型，如果值为空或空白则返回 `true`，否则返回 `false`。如果无法判断则返回 `null`。

**实现原理**：

该方法内部调用 `GetUtils.isBlank` 方法，该方法会检查各种类型的值是否为空或空白，包括：

- `null` 值
- 空字符串
- 只包含空白字符的字符串
- 空的集合（List、Map、Set 等）

**使用示例**：

```dart
// 检查字符串
String? name;
print(name.isBlank); // 输出: true

String empty = '';
print(empty.isBlank); // 输出: true

String whitespace = '   ';
print(whitespace.isBlank); // 输出: true

String text = 'Hello';
print(text.isBlank); // 输出: false

// 检查集合
List<int>? list;
print(list.isBlank); // 输出: true

List<int> emptyList = [];
print(emptyList.isBlank); // 输出: true

List<int> numbers = [1, 2, 3];
print(numbers.isBlank); // 输出: false

// 检查 Map
Map<String, int>? map;
print(map.isBlank); // 输出: true

Map<String, int> emptyMap = {};
print(emptyMap.isBlank); // 输出: true

Map<String, int> data = {'a': 1};
print(data.isBlank); // 输出: false
```

**注意事项**：

- 该方法返回 `bool?`，在使用时需要注意空值处理
- 对于不同类型的值，判断逻辑可能不同
- 建议在需要检查值是否为空时使用此属性

### 错误日志方法

#### printError

输出错误日志信息。

```dart 6:9:lib/get_utils/src/extensions/dynamic_extensions.dart
  void printError(
          {String info = '', Function logFunction = GetUtils.printFunction}) =>
      // ignore: unnecessary_this
      logFunction('Error: ${this.runtimeType}', this, info, isError: true);
```

**参数说明**：

- `info`：可选的附加信息字符串，默认为空字符串
- `logFunction`：可选的日志输出函数，默认为 `GetUtils.printFunction`

**返回值**：无返回值（`void`）

**实现原理**：

该方法内部调用指定的日志函数（默认为 `GetUtils.printFunction`），输出以下信息：

- 错误类型：`Error: ${this.runtimeType}`
- 错误对象：`this`
- 附加信息：`info`
- 错误标志：`isError: true`

**使用示例**：

```dart
// 基本用法
try {
  throw Exception('发生错误');
} catch (e) {
  e.printError();
  // 输出: Error: Exception, 异常对象, 空字符串, isError: true
}

// 带附加信息
try {
  throw FormatException('格式错误');
} catch (e) {
  e.printError(info: '在解析 JSON 时发生错误');
  // 输出: Error: FormatException, 异常对象, '在解析 JSON 时发生错误', isError: true
}

// 自定义日志函数
void customLog(String type, dynamic obj, String info, {bool isError = false}) {
  print('[$type] $info: $obj');
}

try {
  throw ArgumentError('参数错误');
} catch (e) {
  e.printError(
    info: '参数验证失败',
    logFunction: customLog,
  );
}
```

**注意事项**：

- 默认使用 `GetUtils.printFunction` 作为日志输出函数
- 可以通过 `logFunction` 参数自定义日志输出方式
- 建议在捕获异常时使用此方法输出错误信息

### 信息日志方法

#### printInfo

输出信息日志。

```dart 11:15:lib/get_utils/src/extensions/dynamic_extensions.dart
  void printInfo(
          {String info = '',
          Function printFunction = GetUtils.printFunction}) =>
      // ignore: unnecessary_this
      printFunction('Info: ${this.runtimeType}', this, info);
```

**参数说明**：

- `info`：可选的附加信息字符串，默认为空字符串
- `printFunction`：可选的日志输出函数，默认为 `GetUtils.printFunction`

**返回值**：无返回值（`void`）

**实现原理**：

该方法内部调用指定的日志函数（默认为 `GetUtils.printFunction`），输出以下信息：

- 信息类型：`Info: ${this.runtimeType}`
- 信息对象：`this`
- 附加信息：`info`

**使用示例**：

```dart
// 基本用法
final user = {'name': 'John', 'age': 30};
user.printInfo();
// 输出: Info: _InternalLinkedHashMap<String, Object>, 对象, 空字符串

// 带附加信息
final data = [1, 2, 3, 4, 5];
data.printInfo(info: '用户数据列表');
// 输出: Info: List<int>, 对象, '用户数据列表'

// 自定义日志函数
void customPrint(String type, dynamic obj, String info) {
  print('[$type] $info: $obj');
}

final result = {'status': 'success', 'data': 'some data'};
result.printInfo(
  info: 'API 响应',
  printFunction: customPrint,
);
```

**注意事项**：

- 默认使用 `GetUtils.printFunction` 作为日志输出函数
- 可以通过 `printFunction` 参数自定义日志输出方式
- 建议在需要输出调试信息时使用此方法

## 完整使用示例

### 示例 1：数据验证

```dart
class DataValidator {
  // 验证用户输入
  bool validateUserInput(dynamic input) {
    if (input.isBlank == true) {
      input.printError(info: '用户输入为空');
      return false;
    }
    
    input.printInfo(info: '用户输入验证通过');
    return true;
  }
  
  // 验证多个字段
  bool validateFields(Map<String, dynamic> fields) {
    bool isValid = true;
    
    fields.forEach((key, value) {
      if (value.isBlank == true) {
        value.printError(info: '字段 $key 为空');
        isValid = false;
      } else {
        value.printInfo(info: '字段 $key 验证通过');
      }
    });
    
    return isValid;
  }
}

void main() {
  final validator = DataValidator();
  
  // 验证单个输入
  validator.validateUserInput(''); // 输出错误
  validator.validateUserInput('Hello'); // 输出信息
  
  // 验证多个字段
  final userData = {
    'name': 'John',
    'email': '',
    'age': 30,
  };
  validator.validateFields(userData);
}
```

### 示例 2：异常处理

```dart
class ErrorHandler {
  // 处理异常
  void handleError(dynamic error, {String? context}) {
    error.printError(
      info: context ?? '未知上下文',
    );
  }
  
  // 处理多个异常
  void handleErrors(List<dynamic> errors) {
    for (final error in errors) {
      if (error.isBlank != true) {
        error.printError(info: '批量处理中的错误');
      }
    }
  }
}

void main() {
  final handler = ErrorHandler();
  
  try {
    throw FormatException('格式错误');
  } catch (e) {
    handler.handleError(e, context: 'JSON 解析');
  }
  
  try {
    throw ArgumentError('参数错误');
  } catch (e) {
    handler.handleError(e, context: '函数调用');
  }
}
```

### 示例 3：调试输出

```dart
class DebugLogger {
  // 输出调试信息
  void logData(dynamic data, {String? description}) {
    if (data.isBlank != true) {
      data.printInfo(info: description ?? '调试数据');
    } else {
      data.printError(info: '数据为空');
    }
  }
  
  // 输出对象信息
  void logObject(dynamic obj) {
    obj.printInfo(info: '对象信息');
  }
  
  // 输出集合信息
  void logCollection(dynamic collection) {
    if (collection.isBlank == true) {
      collection.printError(info: '集合为空');
    } else {
      collection.printInfo(info: '集合内容');
    }
  }
}

void main() {
  final logger = DebugLogger();
  
  // 输出各种数据
  logger.logData('测试数据', description: '字符串数据');
  logger.logData([1, 2, 3], description: '数字列表');
  logger.logData(null, description: '空值');
  
  // 输出对象
  final user = {'name': 'John', 'age': 30};
  logger.logObject(user);
  
  // 输出集合
  logger.logCollection([1, 2, 3]);
  logger.logCollection([]);
}
```

### 示例 4：API 响应处理

```dart
class ApiResponseHandler {
  // 处理 API 响应
  void handleResponse(dynamic response) {
    if (response.isBlank == true) {
      response.printError(info: 'API 响应为空');
      return;
    }
    
    response.printInfo(info: 'API 响应成功');
    
    // 处理响应数据
    if (response is Map) {
      final data = response['data'];
      if (data != null) {
        data.printInfo(info: '响应数据');
      } else {
        'data'.printError(info: '响应中缺少 data 字段');
      }
    }
  }
  
  // 处理错误响应
  void handleErrorResponse(dynamic error) {
    error.printError(info: 'API 错误响应');
  }
}

void main() {
  final handler = ApiResponseHandler();
  
  // 处理成功响应
  final successResponse = {
    'status': 'success',
    'data': {'id': 1, 'name': 'Test'},
  };
  handler.handleResponse(successResponse);
  
  // 处理错误响应
  final errorResponse = {
    'status': 'error',
    'message': '请求失败',
  };
  handler.handleErrorResponse(errorResponse);
  
  // 处理空响应
  handler.handleResponse(null);
}
```

## 最佳实践

### 何时使用这些扩展

1. **数据验证**：使用 `isBlank` 检查值是否为空或空白
2. **错误处理**：使用 `printError` 输出错误日志
3. **调试输出**：使用 `printInfo` 输出调试信息

### 性能注意事项

1. **isBlank 检查**：`isBlank` 属性会调用 `GetUtils.isBlank`，对于复杂对象可能有性能开销
2. **日志输出**：日志输出可能影响性能，建议在生产环境中禁用或使用条件编译
3. **空值处理**：`isBlank` 返回 `bool?`，使用时需要注意空值处理

### 常见使用场景

1. **表单验证**：检查用户输入是否为空
2. **数据验证**：验证 API 响应数据
3. **异常处理**：输出异常信息
4. **调试输出**：输出调试信息
5. **日志记录**：记录操作日志

### 注意事项

1. **空值处理**：`isBlank` 返回 `bool?`，使用时需要处理可能的 `null` 值
2. **类型安全**：`dynamic` 类型缺乏类型安全，使用时需要注意
3. **日志函数**：可以自定义日志输出函数，但需要确保函数签名匹配
4. **生产环境**：在生产环境中，建议禁用或限制日志输出
5. **性能影响**：频繁的日志输出可能影响性能，需要权衡使用

## 与其他扩展的配合使用

### 与 string_extensions 配合

```dart
// 先检查是否为空，再进行字符串操作
String? input = getUserInput();
if (input.isBlank != true) {
  final processed = input!.capitalize;
  processed.printInfo(info: '处理后的输入');
}
```

### 与 GetUtils 配合

```dart
// GetDynamicUtils 内部使用 GetUtils 的方法
// 可以配合使用 GetUtils 的其他功能
if (value.isBlank == true) {
  // 使用 GetUtils 的其他方法
}
```

## 总结

`dynamic_extensions.dart` 提供了实用的 `dynamic` 类型扩展方法：

- **空白值检查**：`isBlank` 属性可以方便地检查值是否为空或空白
- **错误日志**：`printError` 方法可以输出格式化的错误日志
- **信息日志**：`printInfo` 方法可以输出格式化的信息日志

这些扩展方法遵循 Dart 的最佳实践，在保持代码简洁的同时，提供了强大的数据验证和日志输出能力。通过使用这些扩展，开发者可以更方便地处理动态类型的数据验证和调试输出。
