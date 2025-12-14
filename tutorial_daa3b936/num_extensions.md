# Num Extensions 代码讲解

## 概述

`num_extensions.dart` 文件为 Dart 的 `num` 类型（包括 `int` 和 `double`）提供了实用的扩展方法，主要包括数值比较和延迟执行功能。这些扩展方法让开发者能够更方便地进行数值比较和创建延迟操作。

### 主要功能

1. **数值比较**：提供 `isLowerThan`、`isGreaterThan` 和 `isEqual` 方法用于数值比较
2. **延迟执行**：提供 `delay` 方法用于延迟执行回调函数或代码块

## 文件结构

该文件包含一个扩展：

- `GetNumUtils` - 为 `num` 类型提供扩展方法

## GetNumUtils 扩展详解

### 数值比较方法

#### isLowerThan

判断当前值是否小于另一个值。

```dart 6:6:lib/get_utils/src/extensions/num_extensions.dart
  bool isLowerThan(num b) => GetUtils.isLowerThan(this, b);
```

**参数说明**：

- `b`：要比较的另一个数值

**返回值**：如果当前值小于 `b` 则返回 `true`，否则返回 `false`

**使用示例**：

```dart
// 整数比较
print(5.isLowerThan(10)); // 输出: true
print(10.isLowerThan(5)); // 输出: false

// 浮点数比较
print(3.14.isLowerThan(3.15)); // 输出: true
print(3.15.isLowerThan(3.14)); // 输出: false

// 混合类型比较
print(5.isLowerThan(5.1)); // 输出: true
print(5.1.isLowerThan(5)); // 输出: false
```

#### isGreaterThan

判断当前值是否大于另一个值。

```dart 8:8:lib/get_utils/src/extensions/num_extensions.dart
  bool isGreaterThan(num b) => GetUtils.isGreaterThan(this, b);
```

**参数说明**：

- `b`：要比较的另一个数值

**返回值**：如果当前值大于 `b` 则返回 `true`，否则返回 `false`

**使用示例**：

```dart
// 整数比较
print(10.isGreaterThan(5)); // 输出: true
print(5.isGreaterThan(10)); // 输出: false

// 浮点数比较
print(3.15.isGreaterThan(3.14)); // 输出: true
print(3.14.isGreaterThan(3.15)); // 输出: false

// 混合类型比较
print(5.1.isGreaterThan(5)); // 输出: true
print(5.isGreaterThan(5.1)); // 输出: false
```

#### isEqual

判断当前值是否等于另一个值。

```dart 10:10:lib/get_utils/src/extensions/num_extensions.dart
  bool isEqual(num b) => GetUtils.isEqual(this, b);
```

**参数说明**：

- `b`：要比较的另一个数值

**返回值**：如果当前值等于 `b` 则返回 `true`，否则返回 `false`

**注意事项**：

- 对于浮点数，`isEqual` 方法可能会考虑浮点数精度问题
- 具体实现取决于 `GetUtils.isEqual` 的实现

**使用示例**：

```dart
// 整数比较
print(5.isEqual(5)); // 输出: true
print(5.isEqual(10)); // 输出: false

// 浮点数比较
print(3.14.isEqual(3.14)); // 输出: true
print(3.14.isEqual(3.15)); // 输出: false

// 混合类型比较
print(5.isEqual(5.0)); // 输出: true（取决于实现）
```

### 延迟执行方法

#### delay

延迟执行回调函数或代码块。

```dart 27:30:lib/get_utils/src/extensions/num_extensions.dart
  Future delay([FutureOr Function()? callback]) async => Future.delayed(
        Duration(milliseconds: (this * 1000).round()),
        callback,
      );
```

**参数说明**：

- `callback`：可选的回调函数，如果提供则会在延迟后执行，如果不提供则只是延迟等待

**返回值**：返回一个 `Future`，当延迟时间到达时完成

**实现原理**：

1. 将当前 `num` 值乘以 1000 转换为毫秒
2. 使用 `round()` 方法四舍五入
3. 调用 `Future.delayed` 创建延迟
4. 如果提供了回调函数，则在延迟后执行

**注意事项**：

- `num` 值被视为秒数，会转换为毫秒
- 使用 `round()` 方法进行四舍五入
- 支持整数和浮点数

**使用示例**：

```dart
// 延迟 2 秒
void main() async {
  print('开始');
  await 2.delay();
  print('2 秒后');
}

// 延迟执行回调
void main() async {
  print('开始');
  await 2.delay(() {
    print('延迟回调执行');
  });
  print('完成');
}

// 使用浮点数
void main() async {
  print('开始');
  await 1.5.delay(); // 延迟 1.5 秒（1500 毫秒）
  print('1.5 秒后');
}

// 在异步函数中使用
Future<void> fetchData() async {
  print('开始获取数据');
  await 3.delay();
  print('数据获取完成');
}
```

## 完整使用示例

### 示例 1：数值比较

```dart
class NumberComparator {
  // 比较两个数的大小
  String compareNumbers(num a, num b) {
    if (a.isEqual(b)) {
      return '$a 等于 $b';
    } else if (a.isGreaterThan(b)) {
      return '$a 大于 $b';
    } else if (a.isLowerThan(b)) {
      return '$a 小于 $b';
    }
    return '无法比较';
  }
  
  // 检查值是否在范围内
  bool isInRange(num value, num min, num max) {
    return value.isGreaterThan(min) && value.isLowerThan(max);
  }
  
  // 检查值是否在范围内（包含边界）
  bool isInRangeInclusive(num value, num min, num max) {
    return (value.isGreaterThan(min) || value.isEqual(min)) &&
        (value.isLowerThan(max) || value.isEqual(max));
  }
}

void main() {
  final comparator = NumberComparator();
  
  // 比较数字
  print(comparator.compareNumbers(5, 10)); // 输出: 5 小于 10
  print(comparator.compareNumbers(10, 5)); // 输出: 10 大于 5
  print(comparator.compareNumbers(5, 5)); // 输出: 5 等于 5
  
  // 检查范围
  print(comparator.isInRange(5, 1, 10)); // 输出: true
  print(comparator.isInRange(1, 1, 10)); // 输出: false（不包含边界）
  print(comparator.isInRangeInclusive(1, 1, 10)); // 输出: true（包含边界）
}
```

### 示例 2：延迟执行

```dart
class DelayedExecutor {
  // 延迟执行任务
  Future<void> executeAfterDelay(num seconds, void Function() task) async {
    print('将在 $seconds 秒后执行任务');
    await seconds.delay(task);
  }
  
  // 延迟执行异步任务
  Future<T> executeAsyncAfterDelay<T>(
    num seconds,
    Future<T> Function() task,
  ) async {
    await seconds.delay();
    return await task();
  }
  
  // 创建倒计时
  Future<void> countdown(num totalSeconds) async {
    for (int i = totalSeconds.toInt(); i >= 0; i--) {
      print('倒计时: $i');
      if (i > 0) {
        await 1.delay();
      }
    }
  }
}

void main() async {
  final executor = DelayedExecutor();
  
  // 延迟执行
  await executor.executeAfterDelay(2, () {
    print('任务执行');
  });
  
  // 延迟执行异步任务
  final result = await executor.executeAsyncAfterDelay(1.5, () async {
    await Future.delayed(500.milliseconds);
    return '异步任务结果';
  });
  print('结果: $result');
  
  // 倒计时
  await executor.countdown(5);
}
```

### 示例 3：数值验证

```dart
class NumberValidator {
  // 验证数值是否在有效范围内
  bool validateRange(num value, num min, num max) {
    if (value.isLowerThan(min)) {
      print('错误: $value 小于最小值 $min');
      return false;
    }
    if (value.isGreaterThan(max)) {
      print('错误: $value 大于最大值 $max');
      return false;
    }
    return true;
  }
  
  // 验证数值是否等于期望值
  bool validateEqual(num value, num expected) {
    if (!value.isEqual(expected)) {
      print('错误: $value 不等于期望值 $expected');
      return false;
    }
    return true;
  }
  
  // 验证数值是否大于阈值
  bool validateMinimum(num value, num minimum) {
    if (value.isLowerThan(minimum) || value.isEqual(minimum)) {
      print('错误: $value 必须大于 $minimum');
      return false;
    }
    return true;
  }
}

void main() {
  final validator = NumberValidator();
  
  // 验证范围
  print(validator.validateRange(5, 1, 10)); // 输出: true
  print(validator.validateRange(0, 1, 10)); // 输出: false
  
  // 验证相等
  print(validator.validateEqual(5, 5)); // 输出: true
  print(validator.validateEqual(5, 10)); // 输出: false
  
  // 验证最小值
  print(validator.validateMinimum(5, 1)); // 输出: true
  print(validator.validateMinimum(1, 1)); // 输出: false
}
```

### 示例 4：定时任务

```dart
class ScheduledTask {
  // 定时执行任务
  Future<void> scheduleTask(num intervalSeconds, int times) async {
    for (int i = 0; i < times; i++) {
      await intervalSeconds.delay(() {
        print('任务 ${i + 1} 执行');
      });
    }
  }
  
  // 创建间隔任务
  Stream<int> periodicTask(num intervalSeconds) async* {
    int count = 0;
    while (true) {
      await intervalSeconds.delay();
      yield ++count;
    }
  }
}

void main() async {
  final task = ScheduledTask();
  
  // 定时执行 5 次，每次间隔 2 秒
  await task.scheduleTask(2, 5);
  
  // 周期性任务（限制次数）
  await for (final count in task.periodicTask(1.5).take(3)) {
    print('周期性任务: $count');
  }
}
```

### 示例 5：数值排序和筛选

```dart
class NumberProcessor {
  // 筛选大于阈值的数
  List<num> filterGreaterThan(List<num> numbers, num threshold) {
    return numbers.where((n) => n.isGreaterThan(threshold)).toList();
  }
  
  // 筛选小于阈值的数
  List<num> filterLowerThan(List<num> numbers, num threshold) {
    return numbers.where((n) => n.isLowerThan(threshold)).toList();
  }
  
  // 筛选等于特定值的数
  List<num> filterEqual(List<num> numbers, num value) {
    return numbers.where((n) => n.isEqual(value)).toList();
  }
  
  // 排序（使用比较方法）
  List<num> sortNumbers(List<num> numbers) {
    return numbers..sort((a, b) {
        if (a.isLowerThan(b)) return -1;
        if (a.isGreaterThan(b)) return 1;
        return 0;
      });
  }
}

void main() {
  final processor = NumberProcessor();
  
  final numbers = [5, 2, 8, 1, 9, 3, 7, 4, 6];
  
  // 筛选大于 5 的数
  final greater = processor.filterGreaterThan(numbers, 5);
  print('大于 5: $greater'); // 输出: 大于 5: [8, 9, 7, 6]
  
  // 筛选小于 5 的数
  final lower = processor.filterLowerThan(numbers, 5);
  print('小于 5: $lower'); // 输出: 小于 5: [2, 1, 3, 4]
  
  // 筛选等于 5 的数
  final equal = processor.filterEqual(numbers, 5);
  print('等于 5: $equal'); // 输出: 等于 5: [5]
  
  // 排序
  final sorted = processor.sortNumbers(numbers);
  print('排序后: $sorted'); // 输出: 排序后: [1, 2, 3, 4, 5, 6, 7, 8, 9]
}
```

## 最佳实践

### 何时使用这些扩展

1. **数值比较**：当需要进行数值比较时，使用 `isLowerThan`、`isGreaterThan` 和 `isEqual`
2. **延迟执行**：当需要延迟执行操作时，使用 `delay` 方法
3. **代码可读性**：使用这些扩展可以让代码更加简洁和易读

### 性能注意事项

1. **比较方法**：比较方法内部调用 `GetUtils` 的方法，性能开销很小
2. **延迟执行**：`delay` 方法会创建 `Future` 和 `Duration` 对象，但开销很小
3. **浮点数精度**：比较浮点数时需要注意精度问题

### 常见使用场景

1. **数值验证**：验证数值是否在有效范围内
2. **条件判断**：在条件语句中使用比较方法
3. **延迟操作**：创建延迟执行的操作
4. **定时任务**：创建定时执行的任务
5. **数据筛选**：根据数值条件筛选数据

### 注意事项

1. **浮点数精度**：比较浮点数时，`isEqual` 方法可能会考虑精度问题
2. **类型转换**：`num` 类型包括 `int` 和 `double`，可以混合比较
3. **延迟单位**：`delay` 方法将 `num` 值视为秒数，会转换为毫秒
4. **四舍五入**：`delay` 方法使用 `round()` 进行四舍五入
5. **回调函数**：`delay` 方法的回调函数是可选的

## 与其他扩展的配合使用

### 与 int_extensions 配合

```dart
// int 扩展提供更精确的 Duration 创建
// num 扩展提供延迟执行
await 2.delay(); // num 扩展
await 2.seconds.delay(); // int 扩展 + duration 扩展
```

### 与 double_extensions 配合

```dart
// double 扩展也提供时长转换
// num 扩展提供延迟执行
await 1.5.delay(); // num 扩展
await 1.5.seconds.delay(); // double 扩展 + duration 扩展
```

### 与 duration_extensions 配合

```dart
// 可以结合使用
await 2.delay(() {
  print('延迟执行');
});
```

## 总结

`num_extensions.dart` 提供了实用的 `num` 类型扩展方法：

- **数值比较**：提供了 `isLowerThan`、`isGreaterThan` 和 `isEqual` 方法用于数值比较
- **延迟执行**：提供了 `delay` 方法用于延迟执行回调函数或代码块
- **代码简洁**：让数值比较和延迟操作的代码更加简洁易读

这些扩展方法遵循 Dart 的最佳实践，在保持代码简洁的同时，提供了强大的数值处理能力。通过使用这些扩展，开发者可以更方便地进行数值比较和创建延迟操作，提高代码的可读性和编写效率。
