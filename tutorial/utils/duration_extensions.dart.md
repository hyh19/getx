# Duration Extensions 代码讲解

## 概述

`duration_extensions.dart` 文件为 Dart 的 `Duration` 类型提供了实用的扩展方法，主要用于延迟执行回调函数或代码。这个扩展让开发者能够更简洁地实现延迟操作，提高代码的可读性和编写效率。

### 主要功能

1. **延迟执行**：提供 `delay` 方法用于延迟执行回调函数或代码块
2. **异步支持**：支持异步操作，可以与 `await` 关键字配合使用

## 文件结构

该文件包含一个扩展：

- `GetDurationUtils` - 为 `Duration` 类型提供扩展方法

## GetDurationUtils 扩展详解

### 延迟执行方法

#### delay

延迟执行回调函数或代码块。

```dart 18:19:lib/get_utils/src/extensions/duration_extensions.dart
  Future delay([FutureOr Function()? callback]) async =>
      Future.delayed(this, callback);
```

**参数说明**：

- `callback`：可选的回调函数，如果提供则会在延迟后执行，如果不提供则只是延迟等待

**返回值**：返回一个 `Future`，当延迟时间到达时完成。如果提供了回调函数，则会在回调函数执行完成后完成。

**实现原理**：

该方法内部调用 `Future.delayed`，将当前 `Duration` 对象作为延迟时间，将回调函数作为延迟后执行的操作。

**使用示例**：

```dart
// 示例 1：简单延迟等待
void main() async {
  print('开始等待');
  await 3.seconds.delay();
  print('等待完成');
}

// 示例 2：延迟执行回调函数
void main() async {
  print('开始延迟');
  await 2.seconds.delay(() {
    print('延迟回调执行');
  });
  print('延迟完成');
}

// 示例 3：在异步函数中使用
Future<void> fetchData() async {
  print('开始获取数据');
  await 1.seconds.delay();
  print('数据获取完成');
}

// 示例 4：链式延迟
void main() async {
  print('第一步');
  await 1.seconds.delay(() => print('第二步'));
  await 2.seconds.delay(() => print('第三步'));
  print('完成');
}
```

**注意事项**：

- 如果提供了回调函数，`Future` 会在回调函数执行完成后才完成
- 如果回调函数是异步的，需要等待异步操作完成
- 如果不提供回调函数，只是简单地延迟等待

## 完整使用示例

### 示例 1：简单延迟

```dart
class SimpleDelay {
  // 延迟显示消息
  Future<void> showDelayedMessage(String message, Duration delay) async {
    await delay.delay();
    print(message);
  }
}

void main() async {
  final delay = SimpleDelay();
  
  print('开始');
  await delay.showDelayedMessage('3 秒后的消息', 3.seconds);
  print('结束');
}
```

### 示例 2：延迟执行回调

```dart
class DelayedAction {
  // 延迟执行操作
  Future<void> executeAfterDelay(
    Duration delay,
    void Function() action,
  ) async {
    await delay.delay(action);
  }
  
  // 延迟执行异步操作
  Future<T> executeAsyncAfterDelay<T>(
    Duration delay,
    Future<T> Function() action,
  ) async {
    return await delay.delay(() => action());
  }
}

void main() async {
  final delayed = DelayedAction();
  
  // 延迟执行同步操作
  await delayed.executeAfterDelay(2.seconds, () {
    print('延迟执行的操作');
  });
  
  // 延迟执行异步操作
  final result = await delayed.executeAsyncAfterDelay(
    1.seconds,
    () async {
      await Future.delayed(500.milliseconds);
      return '异步操作结果';
    },
  );
  print(result);
}
```

### 示例 3：模拟网络请求

```dart
class NetworkSimulator {
  // 模拟网络延迟
  Future<String> fetchData(String url) async {
    print('开始请求: $url');
    
    // 模拟网络延迟
    await 1.5.seconds.delay();
    
    print('请求完成: $url');
    return '数据内容';
  }
  
  // 带重试的网络请求
  Future<String> fetchWithRetry(
    String url,
    int maxRetries,
  ) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await fetchData(url);
      } catch (e) {
        if (i < maxRetries - 1) {
          print('请求失败，${2.seconds} 后重试...');
          await 2.seconds.delay();
        } else {
          rethrow;
        }
      }
    }
    throw Exception('请求失败');
  }
}

void main() async {
  final network = NetworkSimulator();
  
  try {
    final data = await network.fetchWithRetry('https://api.example.com', 3);
    print('获取到的数据: $data');
  } catch (e) {
    print('错误: $e');
  }
}
```

### 示例 4：动画序列

```dart
class AnimationSequence {
  // 执行动画序列
  Future<void> playSequence(List<Duration> delays) async {
    for (int i = 0; i < delays.length; i++) {
      await delays[i].delay(() {
        print('动画步骤 ${i + 1}');
      });
    }
  }
  
  // 闪烁效果
  Future<void> blink(int times, Duration interval) async {
    for (int i = 0; i < times; i++) {
      print('闪烁 ${i + 1}');
      await interval.delay();
    }
  }
}

void main() async {
  final anim = AnimationSequence();
  
  // 执行动画序列
  await anim.playSequence([
    500.milliseconds,
    1.seconds,
    1.5.seconds,
  ]);
  
  // 闪烁效果
  await anim.blink(5, 300.milliseconds);
}
```

### 示例 5：防抖和节流

```dart
class DebounceThrottle {
  DateTime? _lastCallTime;
  Duration? _lastDelay;
  
  // 防抖：延迟执行，如果再次调用则重新计时
  Future<void> debounce(
    Duration delay,
    void Function() action,
  ) async {
    _lastCallTime = DateTime.now();
    _lastDelay = delay;
    
    await delay.delay(() {
      // 检查是否是最新的调用
      if (_lastCallTime != null &&
          _lastDelay == delay &&
          DateTime.now().difference(_lastCallTime!) >= delay) {
        action();
      }
    });
  }
  
  // 节流：限制执行频率
  Future<void> throttle(
    Duration interval,
    void Function() action,
  ) async {
    final now = DateTime.now();
    if (_lastCallTime == null ||
        now.difference(_lastCallTime!) >= interval) {
      _lastCallTime = now;
      await action();
    }
  }
}

void main() async {
  final controller = DebounceThrottle();
  
  // 防抖示例
  for (int i = 0; i < 5; i++) {
    controller.debounce(1.seconds, () {
      print('防抖执行');
    });
    await 200.milliseconds.delay();
  }
  
  // 等待防抖完成
  await 2.seconds.delay();
}
```

### 示例 6：定时任务

```dart
class ScheduledTask {
  // 定时执行任务
  Future<void> scheduleTask(
    Duration interval,
    int times,
    void Function(int) task,
  ) async {
    for (int i = 0; i < times; i++) {
      await interval.delay(() {
        task(i + 1);
      });
    }
  }
  
  // 周期性任务
  Stream<int> periodicTask(Duration interval) async* {
    int count = 0;
    while (true) {
      await interval.delay();
      yield ++count;
    }
  }
}

void main() async {
  final scheduler = ScheduledTask();
  
  // 定时执行 5 次
  await scheduler.scheduleTask(1.seconds, 5, (index) {
    print('任务 $index 执行');
  });
  
  // 周期性任务（限制次数）
  await for (final count in scheduler.periodicTask(2.seconds)
      .take(3)) {
    print('周期性任务: $count');
  }
}
```

## 最佳实践

### 何时使用这些扩展

1. **延迟执行**：当需要延迟执行某些操作时，使用 `delay` 方法
2. **异步等待**：在异步函数中需要等待一段时间时，使用 `delay` 方法
3. **模拟操作**：在测试或模拟场景中，使用 `delay` 模拟延迟

### 性能注意事项

1. **回调函数**：如果提供了回调函数，确保回调函数不会阻塞太久
2. **异步操作**：如果回调函数是异步的，`Future` 会等待异步操作完成
3. **资源管理**：长时间延迟时，注意资源的使用和管理

### 常见使用场景

1. **网络请求模拟**：模拟网络延迟
2. **动画序列**：创建动画序列效果
3. **防抖节流**：实现防抖和节流功能
4. **定时任务**：创建定时执行的任务
5. **用户交互**：延迟响应用户操作
6. **测试场景**：在测试中模拟异步操作

### 注意事项

1. **回调函数可选**：`callback` 参数是可选的，可以不提供
2. **异步等待**：使用 `await` 关键字等待延迟完成
3. **错误处理**：如果回调函数抛出异常，`Future` 会以错误完成
4. **取消操作**：该方法不支持取消，如果需要取消功能，需要使用 `Timer` 或其他机制
5. **精度问题**：`Duration` 的精度可能受到系统限制

## 与其他扩展的配合使用

### 与 int_extensions 配合

```dart
// 使用 int 扩展创建 Duration，然后使用 delay
await 3.seconds.delay(() {
  print('延迟 3 秒执行');
});
```

### 与 double_extensions 配合

```dart
// 使用 double 扩展创建 Duration，然后使用 delay
await 1.5.seconds.delay(() {
  print('延迟 1.5 秒执行');
});
```

### 与 num_extensions 配合

```dart
// 使用 num 扩展创建延迟，然后使用 delay
await 2.delay(() {
  print('延迟 2 秒执行');
});
```

## 总结

`duration_extensions.dart` 提供了简洁实用的 `Duration` 类型扩展方法：

- **延迟执行**：`delay` 方法可以方便地延迟执行回调函数或代码块
- **异步支持**：完全支持异步操作，可以与 `await` 关键字配合使用
- **代码简洁**：让延迟操作的代码更加简洁易读

这个扩展方法遵循 Dart 的最佳实践，在保持代码简洁的同时，提供了强大的延迟执行能力。通过使用这个扩展，开发者可以更优雅地实现各种延迟操作和异步场景。
