# ValueBuilder 详解

## 概述

`ValueBuilder` 是一个用于管理局部状态的 `StatefulWidget`。它类似于 `ObxValue`，但使用回调函数而不是响应式变量（Rx）来管理状态。`ValueBuilder` 提供了一个轻量级的状态管理方案，适用于简单的局部状态管理场景，不需要依赖 GetX 的响应式系统。

`ValueBuilder` 通过 `StatefulWidget` 的 `setState` 机制来更新状态，提供了一个 `updater` 回调函数供子组件更新状态。它特别适合管理表单状态、开关状态等简单的局部状态。

## 核心功能

`ValueBuilder` 主要提供以下核心功能：

1. **局部状态管理**：管理 widget 内部的局部状态，不依赖全局状态管理
2. **回调更新机制**：通过 `updater` 回调函数更新状态
3. **自动资源清理**：自动清理 `ChangeNotifier` 和 `StreamController` 等资源
4. **生命周期回调**：支持 `onUpdate` 和 `onDispose` 回调
5. **轻量级设计**：不依赖响应式系统，性能开销小

## 类定义

```dart 26:42:lib/get_state_manager/src/simple/simple_builder.dart
class ValueBuilder<T> extends StatefulWidget {
  final T initialValue;
  final ValueBuilderBuilder<T> builder;
  final void Function()? onDispose;
  final void Function(T)? onUpdate;

  const ValueBuilder({
    super.key,
    required this.initialValue,
    this.onDispose,
    this.onUpdate,
    required this.builder,
  });

  @override
  ValueBuilderState<T> createState() => ValueBuilderState<T>();
}
```

**设计特点**：

- **泛型支持**：支持任意类型的值（`T`）
- **StatefulWidget**：继承自 `StatefulWidget`，管理可变状态
- **常量构造函数**：使用 `const` 构造函数，支持编译时常量
- **类型定义**：

```dart 7:9:lib/get_state_manager/src/simple/simple_builder.dart
typedef ValueBuilderUpdateCallback<T> = void Function(T snapshot);
typedef ValueBuilderBuilder<T> = Widget Function(
    T snapshot, ValueBuilderUpdateCallback<T> updater);
```

## 参数说明

### `initialValue` - 初始值

- **类型**：`T`
- **必需**：是
- **说明**：状态的初始值，在 `initState()` 时设置

### `builder` - 构建函数

- **类型**：`ValueBuilderBuilder<T>`
- **必需**：是
- **说明**：接收当前值和 `updater` 回调函数，返回 widget

```dart
typedef ValueBuilderBuilder<T> = Widget Function(
    T snapshot, ValueBuilderUpdateCallback<T> updater);
```

### `onUpdate` - 更新回调

- **类型**：`void Function(T)?`
- **默认值**：`null`
- **说明**：当状态更新时调用的回调函数，接收新值作为参数

### `onDispose` - 销毁回调

- **类型**：`void Function()?`
- **默认值**：`null`
- **说明**：当 widget 被销毁时调用的回调函数

## ValueBuilderState 详解

```dart 44:74:lib/get_state_manager/src/simple/simple_builder.dart
class ValueBuilderState<T> extends State<ValueBuilder<T>> {
  late T value;
  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.builder(value, updater);

  void updater(T newValue) {
    if (widget.onUpdate != null) {
      widget.onUpdate!(newValue);
    }
    setState(() {
      value = newValue;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.onDispose?.call();
    if (value is ChangeNotifier) {
      (value as ChangeNotifier?)?.dispose();
    } else if (value is StreamController) {
      (value as StreamController?)?.close();
    }
  }
}
```

### `initState()` - 初始化方法

```dart 46:50:lib/get_state_manager/src/simple/simple_builder.dart
  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }
```

**功能说明**：

- 在 widget 初始化时调用
- 将 `widget.initialValue` 赋值给 `value`
- 调用 `super.initState()` 完成父类初始化

### `build()` - 构建方法

```dart 52:53:lib/get_state_manager/src/simple/simple_builder.dart
  @override
  Widget build(BuildContext context) => widget.builder(value, updater);
```

**功能说明**：

- 调用 `widget.builder` 函数，传入当前值（`value`）和更新函数（`updater`）
- 返回构建的 widget

**工作流程**：

1. `build()` 方法被调用
2. 调用 `widget.builder(value, updater)`
3. builder 函数可以使用 `value` 构建 UI
4. builder 函数可以通过 `updater` 回调更新状态
5. 返回构建的 widget

### `updater()` - 更新方法

```dart 55:62:lib/get_state_manager/src/simple/simple_builder.dart
  void updater(T newValue) {
    if (widget.onUpdate != null) {
      widget.onUpdate!(newValue);
    }
    setState(() {
      value = newValue;
    });
  }
```

**功能说明**：

- 接收新值作为参数
- 如果设置了 `onUpdate` 回调，先调用 `onUpdate(newValue)`
- 使用 `setState()` 更新 `value`，触发 widget 重建

**工作流程**：

1. `updater(newValue)` 被调用
2. 如果 `widget.onUpdate` 不为 `null`，调用 `onUpdate(newValue)`
3. 调用 `setState()` 更新 `value`
4. Flutter 框架检测到状态变化，调用 `build()` 方法
5. `build()` 方法重新构建 widget，UI 更新

### `dispose()` - 销毁方法

```dart 64:73:lib/get_state_manager/src/simple/simple_builder.dart
  @override
  void dispose() {
    super.dispose();
    widget.onDispose?.call();
    if (value is ChangeNotifier) {
      (value as ChangeNotifier?)?.dispose();
    } else if (value is StreamController) {
      (value as StreamController?)?.close();
    }
  }
```

**功能说明**：

- 在 widget 被销毁时调用
- 如果设置了 `onDispose` 回调，调用 `onDispose()`
- 如果 `value` 是 `ChangeNotifier`，调用 `dispose()` 释放资源
- 如果 `value` 是 `StreamController`，调用 `close()` 关闭流

**资源清理**：

- **ChangeNotifier**：如果值实现了 `ChangeNotifier`，会自动调用 `dispose()` 释放资源
- **StreamController**：如果值是 `StreamController`，会自动调用 `close()` 关闭流
- **自定义清理**：通过 `onDispose` 回调可以执行自定义清理逻辑

## 与相关组件的关系

### 与 ObxValue 的区别

`ValueBuilder` 和 `ObxValue` 都用于管理局部状态，但实现方式不同：

| 特性 | ValueBuilder | ObxValue |
|------|-------------|----------|
| 状态类型 | 任意类型 `T` | 响应式变量 `Rx<T>` |
| 更新机制 | `setState()` | 响应式变量自动更新 |
| 依赖系统 | 不依赖响应式系统 | 依赖 GetX 响应式系统 |
| 性能 | 轻量级，性能开销小 | 需要响应式追踪，性能开销稍大 |
| 使用场景 | 简单的局部状态 | 需要响应式能力的局部状态 |

**选择建议**：

- 使用 `ValueBuilder`：简单的局部状态管理，不需要响应式能力
- 使用 `ObxValue`：需要响应式能力，或者状态可能被多个地方访问

### 与 StatefulWidget 的关系

`ValueBuilder` 继承自 `StatefulWidget`，使用标准的 Flutter 状态管理机制：

- **状态管理**：通过 `State` 对象管理状态
- **更新机制**：通过 `setState()` 触发更新
- **生命周期**：遵循 Flutter widget 生命周期

**优势**：

- 不依赖 GetX 响应式系统，可以独立使用
- 使用标准的 Flutter 机制，易于理解
- 性能开销小，适合简单的状态管理

### 与 GetBuilder 的区别

`ValueBuilder` 和 `GetBuilder` 都用于状态管理，但适用场景不同：

| 特性 | ValueBuilder | GetBuilder |
|------|-------------|------------|
| 状态范围 | 局部状态 | 全局/局部控制器 |
| 状态类型 | 任意值 | GetxController |
| 更新方式 | 回调函数 | `update()` 方法 |
| 使用场景 | 简单的局部状态 | 需要控制器的复杂状态 |

## 使用场景

### 基本开关示例

```dart
ValueBuilder<bool>(
  initialValue: false,
  builder: (value, update) => Switch(
    value: value,
    onChanged: (flag) {
      update(flag);
    },
  ),
)
```

### 带更新回调的示例

```dart
ValueBuilder<bool>(
  initialValue: false,
  onUpdate: (value) => print("Value updated: $value"),
  builder: (value, update) => Switch(
    value: value,
    onChanged: (flag) {
      update(flag);
    },
  ),
)
```

### 计数器示例

```dart
ValueBuilder<int>(
  initialValue: 0,
  builder: (value, update) => Column(
    children: [
      Text('Count: $value'),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => update(value - 1),
            child: Text('-'),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () => update(value + 1),
            child: Text('+'),
          ),
        ],
      ),
    ],
  ),
)
```

### 表单状态管理

```dart
ValueBuilder<String>(
  initialValue: '',
  onUpdate: (value) => print("Text updated: $value"),
  builder: (value, update) => TextField(
    value: value,
    onChanged: (text) => update(text),
    decoration: InputDecoration(
      labelText: 'Enter text',
    ),
  ),
)
```

## 代码示例

### 基本使用

```dart
ValueBuilder<bool>(
  initialValue: false,
  builder: (value, update) => Switch(
    value: value,
    onChanged: (flag) {
      update(flag);
    },
  ),
)
```

### 多个状态管理

```dart
ValueBuilder<Map<String, dynamic>>(
  initialValue: {
    'name': '',
    'email': '',
    'age': 0,
  },
  builder: (value, update) => Column(
    children: [
      TextField(
        value: value['name'],
        onChanged: (text) => update({...value, 'name': text}),
        decoration: InputDecoration(labelText: 'Name'),
      ),
      TextField(
        value: value['email'],
        onChanged: (text) => update({...value, 'email': text}),
        decoration: InputDecoration(labelText: 'Email'),
      ),
      Slider(
        value: value['age'].toDouble(),
        onChanged: (age) => update({...value, 'age': age.toInt()}),
        min: 0,
        max: 100,
      ),
    ],
  ),
)
```

### 条件渲染

```dart
ValueBuilder<bool>(
  initialValue: false,
  builder: (isVisible, update) => Column(
    children: [
      ElevatedButton(
        onPressed: () => update(!isVisible),
        child: Text(isVisible ? 'Hide' : 'Show'),
      ),
      if (isVisible)
        Container(
          padding: EdgeInsets.all(20),
          child: Text('This is visible'),
        ),
    ],
  ),
)
```

### 资源清理示例

```dart
ValueBuilder<StreamController<int>>(
  initialValue: StreamController<int>(),
  onDispose: () => print('ValueBuilder disposed'),
  builder: (controller, update) {
    return StreamBuilder<int>(
      stream: controller.stream,
      builder: (context, snapshot) {
        return Text('Value: ${snapshot.data ?? 0}');
      },
    );
  },
)

// 当 ValueBuilder 被销毁时，StreamController 会自动关闭
```

### 自定义类型状态

```dart
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  User copyWith({String? name, int? age}) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}

ValueBuilder<User>(
  initialValue: User(name: 'John', age: 30),
  builder: (user, update) => Column(
    children: [
      Text('Name: ${user.name}'),
      Text('Age: ${user.age}'),
      ElevatedButton(
        onPressed: () => update(user.copyWith(age: user.age + 1)),
        child: Text('Increment Age'),
      ),
    ],
  ),
)
```

### 嵌套 ValueBuilder

```dart
ValueBuilder<bool>(
  initialValue: false,
  builder: (outerValue, updateOuter) => Column(
    children: [
      Switch(
        value: outerValue,
        onChanged: updateOuter,
      ),
      ValueBuilder<int>(
        initialValue: 0,
        builder: (innerValue, updateInner) => Column(
          children: [
            Text('Inner Count: $innerValue'),
            ElevatedButton(
              onPressed: () => updateInner(innerValue + 1),
              child: Text('Increment'),
            ),
          ],
        ),
      ),
    ],
  ),
)
```

## 注意事项

### 1. 必须使用 updater 回调更新状态

状态更新必须通过 `updater` 回调函数，不能直接修改 `value`：

```dart
// 正确示例
ValueBuilder<int>(
  initialValue: 0,
  builder: (value, update) => ElevatedButton(
    onPressed: () => update(value + 1), // 使用 updater
    child: Text('$value'),
  ),
)

// 错误示例
ValueBuilder<int>(
  initialValue: 0,
  builder: (value, update) {
    // 错误：不能直接修改 value
    // value = value + 1; // 这不会触发更新
    return ElevatedButton(
      onPressed: () => update(value + 1),
      child: Text('$value'),
    );
  },
)
```

### 2. initialValue 只在初始化时使用

`initialValue` 只在 `initState()` 时设置，后续更新不会使用它：

```dart
// initialValue 只在第一次构建时使用
ValueBuilder<int>(
  initialValue: 0, // 只在初始化时使用
  builder: (value, update) => Text('$value'),
)

// 如果需要在外部重置状态，需要重新创建 widget 或使用 key
ValueBuilder<int>(
  key: ValueKey(resetCounter), // 使用 key 强制重建
  initialValue: 0,
  builder: (value, update) => Text('$value'),
)
```

### 3. 资源清理

`ValueBuilder` 会自动清理 `ChangeNotifier` 和 `StreamController`，但其他资源需要手动清理：

```dart
// 自动清理 ChangeNotifier
ValueBuilder<MyNotifier>(
  initialValue: MyNotifier(),
  builder: (notifier, update) => Text('Value'),
  // MyNotifier.dispose() 会自动调用
)

// 自动清理 StreamController
ValueBuilder<StreamController<int>>(
  initialValue: StreamController<int>(),
  builder: (controller, update) => Text('Value'),
  // StreamController.close() 会自动调用
)

// 其他资源需要手动清理
ValueBuilder<MyResource>(
  initialValue: MyResource(),
  onDispose: () {
    // 手动清理资源
    widget.initialValue.cleanup();
  },
  builder: (resource, update) => Text('Value'),
)
```

### 4. 性能考虑

`ValueBuilder` 使用 `setState()` 更新状态，每次更新都会重建整个 widget 树。对于复杂的 widget 树，考虑使用 `const` widget 或拆分 widget：

```dart
// 性能较差：每次更新都重建整个 Column
ValueBuilder<int>(
  initialValue: 0,
  builder: (value, update) => Column(
    children: [
      ComplexWidget1(), // 每次更新都重建
      ComplexWidget2(), // 每次更新都重建
      Text('$value'), // 只有这个需要更新
    ],
  ),
)

// 性能较好：只重建需要的部分
ValueBuilder<int>(
  initialValue: 0,
  builder: (value, update) => Column(
    children: [
      const ComplexWidget1(), // 使用 const，不会重建
      const ComplexWidget2(), // 使用 const，不会重建
      Text('$value'), // 只有这个会重建
    ],
  ),
)
```

### 5. 与响应式变量的区别

`ValueBuilder` 不依赖响应式系统，状态更新需要显式调用 `updater`：

```dart
// ValueBuilder 方式
ValueBuilder<int>(
  initialValue: 0,
  builder: (value, update) => Text('$value'),
  // 需要显式调用 update() 才能更新
)

// ObxValue 方式（响应式）
ObxValue(
  (value) => Text('$value'),
  0.obs, // 自动响应变化
)
```

### 6. 状态持久化

`ValueBuilder` 的状态不会持久化，widget 被销毁后状态会丢失。如果需要持久化，考虑使用 `GetxController` 或其他状态管理方案：

```dart
// ValueBuilder：状态不持久化
ValueBuilder<int>(
  initialValue: 0,
  builder: (value, update) => Text('$value'),
  // widget 被销毁后，状态丢失
)

// GetxController：状态可以持久化
GetBuilder<CounterController>(
  init: CounterController(),
  builder: (controller) => Text('${controller.count}'),
  // 控制器可以持久化状态
)
```

## 总结

`ValueBuilder` 是 GetX 中用于管理局部状态的轻量级组件。它通过 `StatefulWidget` 和 `setState()` 机制实现状态管理，提供了一个简单而高效的状态管理方案。

`ValueBuilder` 的主要优势在于：

1. **轻量级**：不依赖响应式系统，性能开销小
2. **简单易用**：使用回调函数更新状态，API 简洁
3. **自动资源清理**：自动清理 `ChangeNotifier` 和 `StreamController`
4. **灵活性**：支持任意类型的值，适用于各种场景

`ValueBuilder` 特别适合管理简单的局部状态，如表单状态、开关状态等。对于需要响应式能力或复杂状态管理的场景，建议使用 `ObxValue` 或 `GetBuilder`。

理解 `ValueBuilder` 的工作原理对于选择合适的状态管理方案非常重要。它展示了如何在不依赖响应式系统的情况下实现状态管理，这是 GetX 状态管理系统的重要组成部分。

## 参考资料

- [ObxValue 详解](lib/get_state_manager/src/rx_flutter/rx_obx_widget.dart_obx-value.md)
- [GetBuilder 详解](lib/get_state_manager/src/simple/get_state.dart_get-builder.md)
- [Flutter StatefulWidget 文档](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)
- [Flutter setState 文档](https://api.flutter.dev/flutter/widgets/State/setState.html)
- [GetX 状态管理文档](https://github.com/jonataslaw/getx/blob/master/README.md#state-management)
