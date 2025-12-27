# Double Extensions 代码讲解

## 概述

`double_extensions.dart` 文件为 Dart 的 `double` 类型提供了实用的扩展方法，主要包括数值精度处理和时长转换功能。这些扩展方法让开发者能够更方便地处理浮点数精度问题和时间相关的计算。

### 主要功能

1. **精度控制**：提供 `toPrecision` 方法用于控制浮点数的小数位数
2. **时长转换**：将 `double` 值转换为 `Duration` 对象，支持毫秒、秒、分钟、小时和天等单位

## 文件结构

该文件包含一个扩展：

- `DoubleExt` - 为 `double` 类型提供扩展方法

## DoubleExt 扩展详解

### 精度处理方法

#### toPrecision

将浮点数四舍五入到指定的小数位数。

```dart 4:7:lib/get_utils/src/extensions/double_extensions.dart
  double toPrecision(int fractionDigits) {
    var mod = pow(10, fractionDigits.toDouble()).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
```

**参数说明**：

- `fractionDigits`：保留的小数位数，必须是非负整数

**返回值**：返回一个保留指定小数位数的 `double` 值，使用四舍五入规则

**实现原理**：

1. 计算 10 的 `fractionDigits` 次方作为模数
2. 将原数乘以模数后四舍五入
3. 将结果除以模数得到最终值

**使用示例**：

```dart
// 保留 2 位小数
final price = 19.999.toPrecision(2); // 返回 20.0

// 保留 3 位小数
final pi = 3.14159265.toPrecision(3); // 返回 3.142

// 保留 0 位小数（取整）
final count = 5.7.toPrecision(0); // 返回 6.0

// 处理负数
final negative = -3.14159.toPrecision(2); // 返回 -3.14
```

**注意事项**：

- 该方法使用四舍五入规则，不是截断
- 由于浮点数精度问题，某些情况下可能无法得到完全精确的结果
- 适用于金额、百分比等需要控制精度的场景

### 时长转换属性

#### milliseconds

将 `double` 值转换为毫秒时长的 `Duration` 对象。

```dart 9:9:lib/get_utils/src/extensions/double_extensions.dart
  Duration get milliseconds => Duration(microseconds: (this * 1000).round());
```

**说明**：将 `double` 值（单位：毫秒）转换为 `Duration` 对象。内部实现是将值乘以 1000 转换为微秒后创建 `Duration`。

**使用示例**：

```dart
// 创建 500 毫秒的时长
final delay = 500.0.milliseconds;
await Future.delayed(delay);

// 创建 1.5 毫秒的时长
final shortDelay = 1.5.milliseconds;
```

#### ms

`milliseconds` 的简写形式。

```dart 11:11:lib/get_utils/src/extensions/double_extensions.dart
  Duration get ms => milliseconds;
```

**说明**：与 `milliseconds` 功能完全相同，提供更简洁的写法。

**使用示例**：

```dart
// 使用简写形式
final delay = 100.0.ms;
await Future.delayed(delay);
```

#### seconds

将 `double` 值转换为秒时长的 `Duration` 对象。

```dart 13:13:lib/get_utils/src/extensions/double_extensions.dart
  Duration get seconds => Duration(milliseconds: (this * 1000).round());
```

**说明**：将 `double` 值（单位：秒）转换为 `Duration` 对象。内部实现是将值乘以 1000 转换为毫秒后创建 `Duration`。

**使用示例**：

```dart
// 创建 3 秒的时长
final threeSeconds = 3.0.seconds;
await Future.delayed(threeSeconds);

// 创建 1.5 秒的时长
final oneAndHalfSeconds = 1.5.seconds;
await Future.delayed(oneAndHalfSeconds);

// 在动画中使用
AnimationController(
  duration: 2.5.seconds,
  vsync: this,
);
```

#### minutes

将 `double` 值转换为分钟时长的 `Duration` 对象。

```dart 15:16:lib/get_utils/src/extensions/double_extensions.dart
  Duration get minutes =>
      Duration(seconds: (this * Duration.secondsPerMinute).round());
```

**说明**：将 `double` 值（单位：分钟）转换为 `Duration` 对象。内部实现是将值乘以 `Duration.secondsPerMinute`（60）转换为秒后创建 `Duration`。

**使用示例**：

```dart
// 创建 5 分钟的时长
final fiveMinutes = 5.0.minutes;
await Future.delayed(fiveMinutes);

// 创建 1.5 分钟的时长（90 秒）
final oneAndHalfMinutes = 1.5.minutes;
```

#### hours

将 `double` 值转换为小时时长的 `Duration` 对象。

```dart 18:19:lib/get_utils/src/extensions/double_extensions.dart
  Duration get hours =>
      Duration(minutes: (this * Duration.minutesPerHour).round());
```

**说明**：将 `double` 值（单位：小时）转换为 `Duration` 对象。内部实现是将值乘以 `Duration.minutesPerHour`（60）转换为分钟后创建 `Duration`。

**使用示例**：

```dart
// 创建 2 小时的时长
final twoHours = 2.0.hours;

// 创建 0.5 小时的时长（30 分钟）
final halfHour = 0.5.hours;
```

#### days

将 `double` 值转换为天时长的 `Duration` 对象。

```dart 21:21:lib/get_utils/src/extensions/double_extensions.dart
  Duration get days => Duration(hours: (this * Duration.hoursPerDay).round());
```

**说明**：将 `double` 值（单位：天）转换为 `Duration` 对象。内部实现是将值乘以 `Duration.hoursPerDay`（24）转换为小时后创建 `Duration`。

**使用示例**：

```dart
// 创建 7 天的时长
final oneWeek = 7.0.days;

// 创建 0.5 天的时长（12 小时）
final halfDay = 0.5.days;
```

## 完整使用示例

### 示例 1：精度控制

```dart
class PriceCalculator {
  // 计算商品总价并保留 2 位小数
  double calculateTotalPrice(List<double> prices) {
    double total = prices.fold(0.0, (sum, price) => sum + price);
    return total.toPrecision(2);
  }

  // 计算折扣后的价格
  double applyDiscount(double originalPrice, double discountPercent) {
    final discount = originalPrice * (discountPercent / 100);
    final finalPrice = originalPrice - discount;
    return finalPrice.toPrecision(2);
  }
}

void main() {
  final calculator = PriceCalculator();
  
  // 计算总价
  final prices = [19.99, 29.99, 39.99];
  final total = calculator.calculateTotalPrice(prices);
  print('总价: $total'); // 输出: 总价: 89.97
  
  // 应用折扣
  final discounted = calculator.applyDiscount(100.0, 15.0);
  print('折扣后价格: $discounted'); // 输出: 折扣后价格: 85.0
}
```

### 示例 2：时长转换

```dart
class TimerService {
  // 延迟执行任务
  Future<void> delayedTask(double seconds) async {
    print('任务将在 ${seconds} 秒后执行');
    await Future.delayed(seconds.seconds);
    print('任务执行完成');
  }

  // 创建动画时长
  Duration getAnimationDuration(double durationInSeconds) {
    return durationInSeconds.seconds;
  }

  // 创建倒计时
  Stream<int> countdown(double totalSeconds) async* {
    for (int i = totalSeconds.toInt(); i >= 0; i--) {
      yield i;
      await Future.delayed(1.0.seconds);
    }
  }
}

void main() async {
  final service = TimerService();
  
  // 延迟执行
  await service.delayedTask(2.5);
  
  // 倒计时
  await for (final count in service.countdown(5.0)) {
    print('倒计时: $count');
  }
}
```

### 示例 3：组合使用

```dart
class GameTimer {
  // 游戏时长（分钟）
  final double gameDuration;
  
  GameTimer(this.gameDuration);
  
  // 获取游戏时长的 Duration 对象
  Duration get duration => gameDuration.minutes;
  
  // 检查是否超时
  bool isTimeout(Duration elapsed) {
    return elapsed >= duration;
  }
  
  // 格式化剩余时间
  String formatRemainingTime(Duration elapsed) {
    final remaining = duration - elapsed;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toPrecision(0)}:${seconds.toString().padLeft(2, '0')}';
  }
}

void main() {
  final timer = GameTimer(5.5); // 5.5 分钟
  final elapsed = Duration(minutes: 3, seconds: 30);
  
  print('游戏时长: ${timer.duration}');
  print('是否超时: ${timer.isTimeout(elapsed)}');
  print('剩余时间: ${timer.formatRemainingTime(elapsed)}');
}
```

## 最佳实践

### 何时使用这些扩展

1. **精度控制**：当需要控制浮点数的小数位数时，使用 `toPrecision` 方法
2. **时长转换**：当需要将数值转换为 `Duration` 对象时，使用时长转换属性
3. **代码可读性**：使用这些扩展可以让代码更加简洁和易读

### 性能注意事项

1. **精度计算**：`toPrecision` 方法涉及乘法和除法运算，在大量计算时需要注意性能
2. **时长转换**：时长转换属性只是简单的数学运算，性能开销很小
3. **浮点数精度**：由于浮点数的精度限制，某些情况下可能无法得到完全精确的结果

### 常见使用场景

1. **金额计算**：使用 `toPrecision(2)` 保留两位小数
2. **动画时长**：使用 `seconds` 或 `milliseconds` 创建动画时长
3. **延迟执行**：使用时长转换属性创建延迟时间
4. **倒计时功能**：使用时长转换属性创建倒计时间隔
5. **游戏计时**：使用 `minutes` 或 `hours` 创建游戏时长

### 注意事项

1. **精度问题**：`toPrecision` 使用四舍五入，不是截断，需要注意边界情况
2. **负数处理**：所有方法都支持负数，行为符合预期
3. **零值处理**：所有方法都能正确处理零值
4. **单位一致性**：使用时长转换属性时，注意数值的单位（秒、分钟、小时等）
5. **舍入误差**：由于浮点数精度限制，某些情况下可能存在微小的舍入误差

## 总结

`double_extensions.dart` 提供了实用的 `double` 类型扩展方法，主要包括：

- **精度控制**：`toPrecision` 方法可以方便地控制浮点数的小数位数
- **时长转换**：提供了从毫秒到天的各种时长转换属性，让代码更加简洁易读

这些扩展方法遵循 Dart 的最佳实践，在保持代码简洁的同时，提供了强大的数值处理能力。通过使用这些扩展，开发者可以更优雅地处理浮点数精度问题和时间相关的计算。
