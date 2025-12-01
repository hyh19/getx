# Int Extensions 代码讲解

## 概述

`int_extensions.dart` 文件为 Dart 的 `int` 类型提供了实用的扩展方法，主要用于将整数值转换为 `Duration` 对象。这些扩展方法让开发者能够更简洁、更直观地创建时长对象，提高代码的可读性和编写效率。

### 主要功能

1. **时长转换**：将 `int` 值转换为 `Duration` 对象，支持秒、天、小时、分钟、毫秒和微秒等单位
2. **简写形式**：提供 `ms` 作为 `milliseconds` 的简写形式

## 文件结构

该文件包含一个扩展：

- `DurationExt` - 为 `int` 类型提供时长转换扩展方法

## DurationExt 扩展详解

### 时长转换属性

#### seconds

将 `int` 值转换为秒时长的 `Duration` 对象。

```dart 2:2:lib/get_utils/src/extensions/int_extensions.dart
  Duration get seconds => Duration(seconds: this);
```

**说明**：将 `int` 值（单位：秒）转换为 `Duration` 对象。

**使用示例**：

```dart
// 创建 5 秒的时长
final fiveSeconds = 5.seconds;
await Future.delayed(fiveSeconds);

// 在动画中使用
AnimationController(
  duration: 3.seconds,
  vsync: this,
);

// 创建倒计时
for (int i = 10; i >= 0; i--) {
  print('倒计时: $i');
  await i.seconds.delay();
}
```

#### days

将 `int` 值转换为天时长的 `Duration` 对象。

```dart 4:4:lib/get_utils/src/extensions/int_extensions.dart
  Duration get days => Duration(days: this);
```

**说明**：将 `int` 值（单位：天）转换为 `Duration` 对象。

**使用示例**：

```dart
// 创建 7 天的时长
final oneWeek = 7.days;
await Future.delayed(oneWeek);

// 计算到期时间
final expiryDate = DateTime.now().add(30.days);

// 创建缓存过期时间
final cacheExpiry = 1.days;
```

#### hours

将 `int` 值转换为小时时长的 `Duration` 对象。

```dart 6:6:lib/get_utils/src/extensions/int_extensions.dart
  Duration get hours => Duration(hours: this);
```

**说明**：将 `int` 值（单位：小时）转换为 `Duration` 对象。

**使用示例**：

```dart
// 创建 2 小时的时长
final twoHours = 2.hours;
await Future.delayed(twoHours);

// 计算工作时间
final workDuration = 8.hours;

// 创建会话超时时间
final sessionTimeout = 24.hours;
```

#### minutes

将 `int` 值转换为分钟时长的 `Duration` 对象。

```dart 8:8:lib/get_utils/src/extensions/int_extensions.dart
  Duration get minutes => Duration(minutes: this);
```

**说明**：将 `int` 值（单位：分钟）转换为 `Duration` 对象。

**使用示例**：

```dart
// 创建 30 分钟的时长
final halfHour = 30.minutes;
await Future.delayed(halfHour);

// 创建定时任务间隔
final taskInterval = 15.minutes;

// 创建超时时间
final requestTimeout = 5.minutes;
```

#### milliseconds

将 `int` 值转换为毫秒时长的 `Duration` 对象。

```dart 10:10:lib/get_utils/src/extensions/int_extensions.dart
  Duration get milliseconds => Duration(milliseconds: this);
```

**说明**：将 `int` 值（单位：毫秒）转换为 `Duration` 对象。

**使用示例**：

```dart
// 创建 500 毫秒的时长
final halfSecond = 500.milliseconds;
await Future.delayed(halfSecond);

// 创建动画时长
AnimationController(
  duration: 300.milliseconds,
  vsync: this,
);

// 创建防抖延迟
final debounceDelay = 250.milliseconds;
```

#### microseconds

将 `int` 值转换为微秒时长的 `Duration` 对象。

```dart 12:12:lib/get_utils/src/extensions/int_extensions.dart
  Duration get microseconds => Duration(microseconds: this);
```

**说明**：将 `int` 值（单位：微秒）转换为 `Duration` 对象。

**使用示例**：

```dart
// 创建 1000 微秒的时长（1 毫秒）
final oneMillisecond = 1000.microseconds;

// 创建高精度延迟
final preciseDelay = 500.microseconds;

// 用于性能测试
final testDuration = 10000.microseconds;
```

#### ms

`milliseconds` 的简写形式。

```dart 14:14:lib/get_utils/src/extensions/int_extensions.dart
  Duration get ms => milliseconds;
```

**说明**：与 `milliseconds` 功能完全相同，提供更简洁的写法。

**使用示例**：

```dart
// 使用简写形式
final delay = 100.ms;
await Future.delayed(delay);

// 在动画中使用
AnimationController(
  duration: 200.ms,
  vsync: this,
);

// 创建防抖延迟
final debounce = 300.ms;
```

## 完整使用示例

### 示例 1：定时任务

```dart
class ScheduledTask {
  // 定时执行任务
  Future<void> scheduleTask(int intervalSeconds) async {
    while (true) {
      await intervalSeconds.seconds.delay(() {
        print('定时任务执行');
      });
    }
  }
  
  // 延迟执行
  Future<void> delayedExecution(int delaySeconds) async {
    print('开始等待');
    await delaySeconds.seconds.delay();
    print('等待完成，开始执行');
  }
}

void main() async {
  final task = ScheduledTask();
  
  // 延迟 5 秒执行
  await task.delayedExecution(5);
  
  // 每 10 秒执行一次（示例，实际应使用 Timer）
  // await task.scheduleTask(10);
}
```

### 示例 2：动画控制

```dart
class AnimationController {
  // 创建动画时长
  Duration getAnimationDuration(int seconds) {
    return seconds.seconds;
  }
  
  // 创建过渡动画时长
  Duration getTransitionDuration(int milliseconds) {
    return milliseconds.milliseconds;
  }
  
  // 创建快速动画
  Duration getQuickAnimation() {
    return 200.ms;
  }
  
  // 创建慢速动画
  Duration getSlowAnimation() {
    return 2.seconds;
  }
}

void main() {
  final controller = AnimationController();
  
  // 使用不同的动画时长
  final quickAnim = controller.getQuickAnimation();
  final slowAnim = controller.getSlowAnimation();
  final customAnim = controller.getAnimationDuration(3);
  final transitionAnim = controller.getTransitionDuration(500);
  
  print('快速动画: $quickAnim');
  print('慢速动画: $slowAnim');
  print('自定义动画: $customAnim');
  print('过渡动画: $transitionAnim');
}
```

### 示例 3：缓存管理

```dart
class CacheManager {
  final Map<String, CacheItem> _cache = {};
  
  // 设置缓存过期时间
  void setCache(String key, dynamic value, int expiryDays) {
    final expiryTime = DateTime.now().add(expiryDays.days);
    _cache[key] = CacheItem(value, expiryTime);
  }
  
  // 检查缓存是否过期
  bool isExpired(String key) {
    final item = _cache[key];
    if (item == null) return true;
    return DateTime.now().isAfter(item.expiryTime);
  }
  
  // 获取缓存
  dynamic getCache(String key) {
    if (isExpired(key)) {
      _cache.remove(key);
      return null;
    }
    return _cache[key]?.value;
  }
}

class CacheItem {
  final dynamic value;
  final DateTime expiryTime;
  
  CacheItem(this.value, this.expiryTime);
}

void main() {
  final cache = CacheManager();
  
  // 设置 7 天过期的缓存
  cache.setCache('user_data', {'name': 'John'}, 7);
  
  // 设置 1 天过期的缓存
  cache.setCache('temp_data', 'temporary', 1);
  
  // 获取缓存
  final userData = cache.getCache('user_data');
  print('用户数据: $userData');
}
```

### 示例 4：网络请求超时

```dart
class NetworkClient {
  // 设置请求超时时间
  Future<String> fetchData(String url, int timeoutSeconds) async {
    try {
      return await Future.any([
        _makeRequest(url),
        Future.delayed(
          timeoutSeconds.seconds,
          () => throw TimeoutException('请求超时'),
        ),
      ]);
    } catch (e) {
      print('请求失败: $e');
      rethrow;
    }
  }
  
  Future<String> _makeRequest(String url) async {
    // 模拟网络请求
    await 2.seconds.delay();
    return '响应数据';
  }
}

void main() async {
  final client = NetworkClient();
  
  try {
    // 5 秒超时
    final data = await client.fetchData('https://api.example.com', 5);
    print('数据: $data');
  } catch (e) {
    print('错误: $e');
  }
}
```

### 示例 5：倒计时功能

```dart
class CountdownTimer {
  // 倒计时
  Stream<int> countdown(int totalSeconds) async* {
    for (int i = totalSeconds; i >= 0; i--) {
      yield i;
      if (i > 0) {
        await 1.seconds.delay();
      }
    }
  }
  
  // 格式化时间
  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

void main() async {
  final timer = CountdownTimer();
  
  // 10 秒倒计时
  await for (final count in timer.countdown(10)) {
    print('倒计时: ${timer.formatTime(count)}');
  }
  
  print('倒计时结束');
}
```

### 示例 6：防抖和节流

```dart
class DebounceThrottle {
  DateTime? _lastCallTime;
  
  // 防抖：延迟执行
  Future<void> debounce(int delayMs, void Function() action) async {
    await delayMs.milliseconds.delay(action);
  }
  
  // 节流：限制执行频率
  Future<void> throttle(int intervalMs, void Function() action) async {
    final now = DateTime.now();
    if (_lastCallTime == null ||
        now.difference(_lastCallTime!) >= intervalMs.milliseconds) {
      _lastCallTime = now;
      await action();
    }
  }
}

void main() async {
  final controller = DebounceThrottle();
  
  // 防抖：300 毫秒后执行
  for (int i = 0; i < 5; i++) {
    controller.debounce(300, () {
      print('防抖执行 $i');
    });
    await 100.ms.delay();
  }
  
  // 等待防抖完成
  await 500.ms.delay();
  
  // 节流：每 1 秒最多执行一次
  for (int i = 0; i < 10; i++) {
    controller.throttle(1000, () {
      print('节流执行 $i');
    });
    await 200.ms.delay();
  }
}
```

## 最佳实践

### 何时使用这些扩展

1. **时长创建**：当需要创建 `Duration` 对象时，使用这些扩展方法
2. **代码可读性**：使用这些扩展可以让代码更加简洁和易读
3. **单位转换**：当需要将整数值转换为时长时

### 性能注意事项

1. **属性访问**：这些扩展属性只是简单的属性访问，性能开销很小
2. **对象创建**：每次访问都会创建新的 `Duration` 对象，但 `Duration` 对象很轻量
3. **缓存考虑**：如果需要频繁使用相同的 `Duration`，可以考虑缓存

### 常见使用场景

1. **动画时长**：创建动画和过渡效果的时长
2. **延迟执行**：创建延迟执行的时间间隔
3. **超时设置**：设置网络请求和操作的超时时间
4. **定时任务**：创建定时任务的执行间隔
5. **缓存管理**：设置缓存的过期时间
6. **倒计时功能**：创建倒计时的时间间隔

### 注意事项

1. **单位一致性**：使用时注意数值的单位（秒、分钟、小时等）
2. **负数处理**：这些扩展支持负数，但 `Duration` 对象不支持负数
3. **零值处理**：所有扩展都能正确处理零值
4. **精度问题**：`Duration` 的精度可能受到系统限制
5. **简写形式**：`ms` 是 `milliseconds` 的简写，功能完全相同

## 与其他扩展的配合使用

### 与 duration_extensions 配合

```dart
// 使用 int 扩展创建 Duration，然后使用 delay
await 3.seconds.delay(() {
  print('延迟执行');
});
```

### 与 double_extensions 配合

```dart
// int 和 double 扩展都提供时长转换
// int 扩展用于整数值，double 扩展用于浮点数值
final intDuration = 3.seconds;
final doubleDuration = 3.5.seconds;
```

### 与 num_extensions 配合

```dart
// num 扩展也提供 delay 方法
// 但 int 扩展提供更精确的 Duration 创建
await 2.delay(); // num 扩展
await 2.seconds.delay(); // int 扩展 + duration 扩展
```

## 总结

`int_extensions.dart` 提供了实用的 `int` 类型扩展方法：

- **时长转换**：提供了从微秒到天的各种时长转换属性
- **代码简洁**：让创建 `Duration` 对象的代码更加简洁易读
- **单位支持**：支持秒、分钟、小时、天、毫秒和微秒等多种单位

这些扩展方法遵循 Dart 的最佳实践，在保持代码简洁的同时，提供了强大的时长创建能力。通过使用这些扩展，开发者可以更优雅地处理时间相关的操作，提高代码的可读性和编写效率。
