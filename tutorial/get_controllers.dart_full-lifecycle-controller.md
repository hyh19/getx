# FullLifeCycleController 详解

## 概述

`FullLifeCycleController` 是 GetX 框架中用于观察完整应用生命周期的控制器基类。它通过继承 `GetxController` 和混入 `WidgetsBindingObserver`，为控制器提供了应用生命周期观察能力，能够响应应用的前台/后台切换、内存压力事件和可访问性变化等系统级事件。

`FullLifeCycleController` 特别适用于需要根据应用生命周期状态调整行为的场景，例如在应用进入后台时暂停网络请求、在内存压力时清理缓存、或者根据可访问性设置调整 UI 等。

## 核心功能

`FullLifeCycleController` 主要提供以下核心功能：

1. **应用生命周期观察**：通过 `WidgetsBindingObserver` 观察应用的生命周期状态变化
2. **生命周期管理**：通过继承 `GetxController` 获得完整的生命周期管理能力
3. **状态管理**：通过继承 `GetxController` 获得 `update()` 方法和监听器管理能力
4. **系统事件响应**：可以响应内存压力、可访问性变化等系统级事件
5. **资源管理**：在应用生命周期变化时自动管理资源

## 类定义

### 类声明

```dart 222:225:lib/get_state_manager/src/simple/get_controllers.dart
abstract class FullLifeCycleController extends GetxController
    with
        // ignore: prefer_mixin
        WidgetsBindingObserver {}
```

**设计说明**：

- `abstract`：抽象类，不能直接实例化，必须通过子类继承使用
- `extends GetxController`：继承 `GetxController`，获得生命周期管理和状态管理能力
- `with WidgetsBindingObserver`：混入 `WidgetsBindingObserver`，获得应用生命周期观察能力

**继承关系**：

- `GetxController`：提供 `update()` 方法和生命周期管理
- `ListNotifier`：提供监听器管理功能（通过 `GetxController` 继承）
- `GetLifeCycleMixin`：提供生命周期管理功能（通过 `GetxController` 混入）
- `WidgetsBindingObserver`：提供应用生命周期观察功能

**为什么使用抽象类**：

- 强制开发者创建子类，确保每个控制器都有明确的业务逻辑
- 提供统一的接口和默认实现，减少重复代码
- 防止直接实例化，确保控制器通过依赖注入系统管理

**为什么继承 GetxController**：

- 生命周期管理：获得 `onInit()`、`onReady()`、`onClose()` 等生命周期方法
- 状态管理：获得 `update()` 方法和监听器注册机制
- 统一接口：与其他控制器保持一致的接口

**为什么混入 WidgetsBindingObserver**：

- 应用生命周期观察：获得 `didChangeAppLifecycleState()` 方法
- 内存压力监听：获得 `didHaveMemoryPressure()` 方法
- 可访问性变化监听：获得 `didChangeAccessibilityFeatures()` 方法

## 与 GetxController 的关系

### 继承关系

`FullLifeCycleController` 继承自 `GetxController`，获得了以下能力：

1. **update() 方法**：可以手动调用 `update()` 方法通知 UI 更新
2. **生命周期管理**：`onInit()`、`onReady()`、`onClose()` 等生命周期方法
3. **监听器管理**：通过 `ListNotifier` 获得监听器注册和通知机制
4. **选择性更新**：支持通过 ID 更新特定的 widget

### 使用对比

**GetxController 方式**：

```dart
class UserController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    fetchUser();
  }

  Future<void> fetchUser() async {
    // 无法响应应用生命周期变化
  }
}
```

**FullLifeCycleController 方式**：

```dart
class UserController extends FullLifeCycleController {
  @override
  void onReady() {
    super.onReady();
    fetchUser();
  }

  @override
  void onPaused() {
    // 应用进入后台时暂停请求
    cancelRequests();
  }

  @override
  void onResumed() {
    // 应用回到前台时恢复请求
    fetchUser();
  }
}
```

**优势**：

- 应用生命周期感知：可以响应应用的前台/后台切换
- 资源管理：可以在应用生命周期变化时自动管理资源
- 系统事件响应：可以响应内存压力、可访问性变化等系统级事件

## 与 WidgetsBindingObserver 的关系

### 混入关系

`FullLifeCycleController` 通过混入 `WidgetsBindingObserver` 获得应用生命周期观察能力：

1. **didChangeAppLifecycleState()**：应用生命周期状态变化时调用
2. **didHaveMemoryPressure()**：系统内存压力时调用
3. **didChangeAccessibilityFeatures()**：可访问性设置变化时调用

### 观察者注册

`FullLifeCycleController` 本身只是混入了 `WidgetsBindingObserver`，但实际的观察者注册需要在 `FullLifeCycleMixin` 中完成：

```dart 247:252:lib/get_state_manager/src/simple/get_controllers.dart
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    Engine.instance.addObserver(this);
  }
```

**工作原理**：

1. `FullLifeCycleController` 混入 `WidgetsBindingObserver`，具备了观察者的能力
2. `FullLifeCycleMixin` 在 `onInit()` 中通过 `Engine.instance.addObserver(this)` 注册观察者
3. 当应用生命周期变化时，Flutter 框架会调用 `didChangeAppLifecycleState()` 等方法
4. `FullLifeCycleMixin` 将这些方法转换为更友好的回调方法（如 `onResumed()`、`onPaused()` 等）

## 与 FullLifeCycleMixin 的关系

`FullLifeCycleController` 通常与 `FullLifeCycleMixin` 一起使用：

```dart
class MyController extends FullLifeCycleController with FullLifeCycleMixin {
  @override
  void onResumed() {
    // 应用回到前台
  }

  @override
  void onPaused() {
    // 应用进入后台
  }
}
```

**为什么需要 FullLifeCycleMixin**：

- `FullLifeCycleController` 只提供了观察者的能力，但没有提供便捷的回调方法
- `FullLifeCycleMixin` 将 `WidgetsBindingObserver` 的方法转换为更友好的回调方法
- `FullLifeCycleMixin` 负责观察者的注册和注销

详细说明请参考 [FullLifeCycleMixin 详解](lib/get_state_manager/src/simple/get_controllers.dart_full-lifecycle-mixin.md)。

## 使用场景

### 基本生命周期观察示例

```dart
class HomeController extends FullLifeCycleController with FullLifeCycleMixin {
  Timer? _timer;
  int _counter = 0;

  @override
  void onReady() {
    super.onReady();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _counter++;
      update();
    });
  }

  @override
  void onPaused() {
    // 应用进入后台时暂停计时器
    _timer?.cancel();
  }

  @override
  void onResumed() {
    // 应用回到前台时恢复计时器
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  int get counter => _counter;
}
```

### 网络请求管理示例

```dart
class DataController extends FullLifeCycleController with FullLifeCycleMixin {
  CancelToken? _cancelToken;
  List<Data> _data = [];

  @override
  void onReady() {
    super.onReady();
    fetchData();
  }

  Future<void> fetchData() async {
    _cancelToken = CancelToken();
    try {
      final response = await apiService.getData(cancelToken: _cancelToken);
      _data = response.data;
      update();
    } catch (e) {
      if (e is CancelException) {
        // 请求被取消，不处理错误
        return;
      }
      // 处理其他错误
    }
  }

  @override
  void onPaused() {
    // 应用进入后台时取消正在进行的请求
    _cancelToken?.cancel('应用进入后台');
  }

  @override
  void onResumed() {
    // 应用回到前台时重新获取数据
    fetchData();
  }

  @override
  void onClose() {
    _cancelToken?.cancel('控制器销毁');
    super.onClose();
  }
}
```

### 内存压力处理示例

```dart
class CacheController extends FullLifeCycleController with FullLifeCycleMixin {
  final Map<String, CachedData> _cache = {};

  void cacheData(String key, CachedData data) {
    _cache[key] = data;
  }

  CachedData? getCachedData(String key) {
    return _cache[key];
  }

  @override
  void onMemoryPressure() {
    // 系统内存压力时清理缓存
    _cache.clear();
    update();
  }

  @override
  void onClose() {
    _cache.clear();
    super.onClose();
  }
}
```

### 可访问性响应示例

```dart
class AccessibilityController extends FullLifeCycleController with FullLifeCycleMixin {
  bool _isHighContrast = false;
  bool _isBoldText = false;

  @override
  void onInit() {
    super.onInit();
    _updateAccessibilitySettings();
  }

  void _updateAccessibilitySettings() {
    final binding = WidgetsBinding.instance;
    _isHighContrast = binding.accessibilityFeatures.highContrast;
    _isBoldText = binding.accessibilityFeatures.boldText;
    update();
  }

  @override
  void onAccessibilityChanged() {
    // 可访问性设置变化时更新
    _updateAccessibilitySettings();
  }

  bool get isHighContrast => _isHighContrast;
  bool get isBoldText => _isBoldText;
}
```

### 复杂场景示例

```dart
class MediaController extends FullLifeCycleController with FullLifeCycleMixin {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void onReady() {
    super.onReady();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network('video_url');
    await _videoController!.initialize();
    update();
  }

  void play() {
    _videoController?.play();
    _isPlaying = true;
    update();
  }

  void pause() {
    _videoController?.pause();
    _isPlaying = false;
    update();
  }

  @override
  void onPaused() {
    // 应用进入后台时暂停播放
    if (_isPlaying) {
      pause();
    }
  }

  @override
  void onResumed() {
    // 应用回到前台时可以选择恢复播放
    // 这里不自动恢复，由用户决定
  }

  @override
  void onMemoryPressure() {
    // 内存压力时释放视频资源
    _videoController?.dispose();
    _videoController = null;
    update();
  }

  @override
  void onClose() {
    _videoController?.dispose();
    super.onClose();
  }
}
```

## 与其他控制器的对比

### FullLifeCycleController vs GetxController

| 特性 | FullLifeCycleController | GetxController |
|------|------------------------|----------------|
| 应用生命周期观察 | 支持 | 不支持 |
| 内存压力监听 | 支持 | 不支持 |
| 可访问性变化监听 | 支持 | 不支持 |
| 状态管理 | 支持 | 支持 |
| 生命周期管理 | 支持 | 支持 |
| 使用场景 | 需要响应应用生命周期 | 普通状态管理 |

**选择建议**：

- 使用 `FullLifeCycleController`：需要响应应用生命周期变化（如暂停/恢复网络请求、清理缓存等）
- 使用 `GetxController`：普通状态管理，不需要响应应用生命周期

### FullLifeCycleController vs StateController

| 特性 | FullLifeCycleController | StateController |
|------|------------------------|-----------------|
| 应用生命周期观察 | 支持 | 不支持 |
| 状态管理 | 手动管理（update()） | 标准化状态管理（loading/success/error/empty） |
| 使用场景 | 需要响应应用生命周期 | 异步操作需要管理加载/错误状态 |

**选择建议**：

- 使用 `FullLifeCycleController`：需要响应应用生命周期，且状态管理较简单
- 使用 `StateController`：异步操作需要管理加载/错误状态，不需要响应应用生命周期

### FullLifeCycleController vs SuperController

`SuperController` 继承自 `FullLifeCycleController` 并混入 `StateMixin`：

```dart 188:189:lib/get_state_manager/src/simple/get_controllers.dart
abstract class SuperController<T> extends FullLifeCycleController
    with FullLifeCycleMixin, StateMixin<T> {}
```

| 特性 | FullLifeCycleController | SuperController |
|------|------------------------|-----------------|
| 应用生命周期观察 | 支持 | 支持 |
| 状态管理 | 手动管理（update()） | 标准化状态管理（loading/success/error/empty） |
| 使用场景 | 需要响应应用生命周期，状态管理简单 | 需要响应应用生命周期 + 异步操作状态管理 |

**选择建议**：

- 使用 `FullLifeCycleController`：需要响应应用生命周期，状态管理较简单
- 使用 `SuperController`：需要响应应用生命周期，且需要管理异步操作的加载/错误状态

## 注意事项

### 1. 必须与 FullLifeCycleMixin 一起使用

`FullLifeCycleController` 本身只提供了观察者的能力，但不会自动注册观察者。必须与 `FullLifeCycleMixin` 一起使用才能正常工作：

```dart
// 正确示例
class MyController extends FullLifeCycleController with FullLifeCycleMixin {
  @override
  void onResumed() {
    // 可以正常响应生命周期变化
  }
}

// 错误示例
class MyController extends FullLifeCycleController {
  @override
  void onResumed() {
    // 不会被调用，因为没有注册观察者
  }
}
```

### 2. 生命周期方法的调用

重写生命周期方法时，必须调用 `super` 方法：

```dart
@override
void onInit() {
  super.onInit(); // 必须调用
  // 你的初始化代码
}

@override
void onReady() {
  super.onReady(); // 必须调用
  // 你的就绪代码
}

@override
void onClose() {
  // 你的清理代码
  super.onClose(); // 建议调用
}
```

### 3. 观察者的注册和注销

`FullLifeCycleMixin` 会在 `onInit()` 中注册观察者，在 `onClose()` 中注销观察者。如果直接使用 `FullLifeCycleController` 而不使用 `FullLifeCycleMixin`，需要手动管理观察者：

```dart
class MyController extends FullLifeCycleController {
  @override
  void onInit() {
    super.onInit();
    Engine.instance.addObserver(this); // 手动注册
  }

  @override
  void onClose() {
    Engine.instance.removeObserver(this); // 手动注销
    super.onClose();
  }
}
```

### 4. 应用生命周期状态

`AppLifecycleState` 包含以下状态：

- `resumed`：应用可见且可交互（前台）
- `inactive`：应用处于非活动状态，不接收用户输入
- `paused`：应用不可见，在后台运行
- `detached`：应用即将被销毁
- `hidden`：应用被隐藏（如设备锁屏）

### 5. 内存压力处理

`onMemoryPressure()` 在系统内存压力时调用，应该在此方法中释放非关键资源：

```dart
@override
void onMemoryPressure() {
  // 清理缓存
  _cache.clear();
  // 释放图片资源
  _imageCache.clear();
  // 取消非关键请求
  _cancelNonCriticalRequests();
}
```

### 6. 可访问性变化处理

`onAccessibilityChanged()` 在系统可访问性设置变化时调用，应该在此方法中更新 UI：

```dart
@override
void onAccessibilityChanged() {
  final binding = WidgetsBinding.instance;
  _isHighContrast = binding.accessibilityFeatures.highContrast;
  _isBoldText = binding.accessibilityFeatures.boldText;
  update(); // 更新 UI
}
```

### 7. 避免在生命周期回调中执行耗时操作

生命周期回调应该快速执行，避免阻塞主线程：

```dart
// 不推荐
@override
void onResumed() {
  // 耗时操作
  processLargeData();
}

// 推荐
@override
void onResumed() {
  // 快速标记状态
  _shouldRefresh = true;
  // 在下一帧执行耗时操作
  WidgetsBinding.instance.addPostFrameCallback((_) {
    processLargeData();
  });
}
```

### 8. 与 GetxController 的兼容性

`FullLifeCycleController` 完全兼容 `GetxController` 的所有功能，可以正常使用 `update()` 方法、`GetBuilder` widget 等：

```dart
class MyController extends FullLifeCycleController with FullLifeCycleMixin {
  int count = 0;

  void increment() {
    count++;
    update(); // 正常使用 update() 方法
  }
}

// 在 widget 中使用
GetBuilder<MyController>(
  builder: (controller) => Text('${controller.count}'),
)
```

## 总结

`FullLifeCycleController` 是 GetX 框架中用于观察完整应用生命周期的控制器基类。它通过继承 `GetxController` 和混入 `WidgetsBindingObserver`，为控制器提供了应用生命周期观察能力，能够响应应用的前台/后台切换、内存压力事件和可访问性变化等系统级事件。

理解 `FullLifeCycleController` 的工作原理对于正确使用 GetX 框架的应用生命周期管理功能非常重要，特别是与 `FullLifeCycleMixin` 的配合使用、生命周期回调方法的实现、以及资源管理的最佳实践。这些知识将帮助你编写更加健壮、响应式的 Flutter 应用。

## 参考资料

- [FullLifeCycleMixin 详解](lib/get_state_manager/src/simple/get_controllers.dart_full-lifecycle-mixin.md)
- [GetxController 详解](lib/get_state_manager/src/simple/get_controllers.dart_getx-controller.md)
- [StateController 详解](lib/get_state_manager/src/simple/get_controllers.dart_state-controller.md)
- [GetLifeCycleMixin 详解](lib/get_instance/src/lifecycle.dart_get-lifecycle-mixin.md)
- [GetX 状态管理文档](https://github.com/jonataslaw/getx/blob/master/README.md)
- [FullLifeCycleController 源码](lib/get_state_manager/src/simple/get_controllers.dart)
