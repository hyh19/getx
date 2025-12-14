# _FactoryBind 详解

## 概述

`_FactoryBind` 是 `Bind` 抽象类的具体实现类，用于在 widget 树中提供控制器实例。它是 GetX 状态管理系统中依赖注入的核心实现，所有 `Bind` 的静态方法（如 `put`、`lazyPut`、`create`、`spawn`）和工厂方法 `Bind.builder()` 都返回 `_FactoryBind` 实例。

`_FactoryBind` 通过实现 `build()` 方法创建 `Binder<T>` widget，将控制器注入到 widget 树中。它还实现了 `_copyWithChild()` 方法，用于在 `Binds` 中嵌套多个 `Bind` 实例时替换子 widget。

## 核心功能

`_FactoryBind` 主要提供以下核心功能：

1. **Binder 创建**：实现 `build()` 方法，返回 `Binder<T>` widget
2. **子 widget 替换**：实现 `_copyWithChild()` 方法，用于嵌套组合
3. **控制器注入**：通过 `Binder` 在 widget 树中注入控制器
4. **生命周期管理**：支持控制器的创建、订阅和销毁的完整生命周期管理

## 类定义

```dart 270:353:lib/get_state_manager/src/simple/get_state.dart
class _FactoryBind<T> extends Bind<T> {
  @override
  final InitBuilder<T>? init;

  final InstanceCreateBuilderCallback<T>? create;

  @override
  final bool global;
  @override
  final Object? id;
  @override
  final String? tag;
  @override
  final bool autoRemove;
  @override
  final bool assignId;
  @override
  final Object Function(T value)? filter;

  @override
  final void Function(BindElement<T> state)? initState,
      dispose,
      didChangeDependencies;
  @override
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
      didUpdateWidget;

  @override
  final Widget? child;

  const _FactoryBind({
    super.key,
    this.child,
    this.init,
    this.create,
    this.global = true,
    this.autoRemove = true,
    this.assignId = false,
    this.initState,
    this.filter,
    this.tag,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  }) : super(child: child);

  @override
  Bind<T> _copyWithChild(Widget child) {
    return Bind<T>.builder(
      init: init,
      create: create,
      global: global,
      autoRemove: autoRemove,
      assignId: assignId,
      initState: initState,
      filter: filter,
      tag: tag,
      dispose: dispose,
      id: id,
      didChangeDependencies: didChangeDependencies,
      didUpdateWidget: didUpdateWidget,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Binder<T>(
      create: create,
      global: global,
      autoRemove: autoRemove,
      assignId: assignId,
      initState: initState,
      filter: filter,
      tag: tag,
      dispose: dispose,
      id: id,
      didChangeDependencies: didChangeDependencies,
      didUpdateWidget: didUpdateWidget,
      child: child!,
    );
  }
}
```

**设计特点**：

- **具体实现类**：`_FactoryBind` 是 `Bind` 的唯一具体实现类
- **私有类**：使用下划线前缀，表示这是一个内部实现类
- **常量构造函数**：使用 `const` 构造函数，支持编译时常量
- **Binder 创建**：`build()` 方法返回 `Binder<T>` widget

## 参数说明

`_FactoryBind` 的参数与 `Bind` 完全相同，所有参数都使用 `@override` 注解：

### `init` - 初始化函数

- **类型**：`InitBuilder<T>?`
- **默认值**：`null`
- **说明**：用于创建控制器实例的函数

### `create` - 创建函数

- **类型**：`InstanceCreateBuilderCallback<T>?`
- **默认值**：`null`
- **说明**：接收 `BuildContext` 作为参数，用于创建控制器实例的函数。与 `init` 的区别是 `create` 可以访问 `BuildContext`

```dart
typedef InstanceCreateBuilderCallback<S> = S Function(BuildContext _);
```

### `global` - 全局控制器

- **类型**：`bool`
- **默认值**：`true`
- **说明**：是否使用全局控制器

### `autoRemove` - 自动移除

- **类型**：`bool`
- **默认值**：`true`
- **说明**：当 widget 被销毁时，是否自动移除控制器

### `assignId` - 分配 ID

- **类型**：`bool`
- **默认值**：`false`
- **说明**：是否为控制器分配 ID

### `id` - Widget ID

- **类型**：`Object?`
- **默认值**：`null`
- **说明**：用于选择性更新的 widget ID

### `tag` - 控制器标签

- **类型**：`String?`
- **默认值**：`null`
- **说明**：用于区分同一类型的多个控制器实例

### `filter` - 过滤函数

- **类型**：`Object Function(T value)?`
- **默认值**：`null`
- **说明**：用于过滤更新条件的函数

### 生命周期回调

- **`initState`**：在 `BindElement` 初始化时调用
- **`dispose`**：在 `BindElement` 销毁时调用
- **`didChangeDependencies`**：在依赖变化时调用
- **`didUpdateWidget`**：在 widget 更新时调用

### `child` - 子 widget

- **类型**：`Widget?`
- **默认值**：`null`
- **说明**：`_FactoryBind` widget 的子 widget（在 `build()` 中使用 `child!`，必须非空）

## 方法详解

### `build()` - 构建方法

```dart 336:352:lib/get_state_manager/src/simple/get_state.dart
  @override
  Widget build(BuildContext context) {
    return Binder<T>(
      create: create,
      global: global,
      autoRemove: autoRemove,
      assignId: assignId,
      initState: initState,
      filter: filter,
      tag: tag,
      dispose: dispose,
      id: id,
      didChangeDependencies: didChangeDependencies,
      didUpdateWidget: didUpdateWidget,
      child: child!,
    );
  }
```

**功能说明**：

- 创建 `Binder<T>` widget，将控制器注入到 widget 树中
- 将所有参数传递给 `Binder`（注意：`init` 参数不传递给 `Binder`，只传递 `create`）
- 使用 `child!` 作为 `Binder` 的子 widget（必须非空）

**工作流程**：

1. `_FactoryBind.build()` 被调用
2. 创建 `Binder<T>` widget，传入所有配置参数
3. `Binder` 创建 `BindElement`，负责控制器的创建和管理
4. 返回 `Binder` widget

**设计考虑**：

- 只传递 `create` 参数给 `Binder`，不传递 `init`。这是因为 `Binder` 优先使用 `create`，如果 `create` 为 `null`，才使用 `init`
- 使用 `child!` 强制非空，因为 `_FactoryBind` 的 `child` 在 `build()` 时必须存在

### `_copyWithChild()` - 复制并替换子 widget

```dart 317:334:lib/get_state_manager/src/simple/get_state.dart
  @override
  Bind<T> _copyWithChild(Widget child) {
    return Bind<T>.builder(
      init: init,
      create: create,
      global: global,
      autoRemove: autoRemove,
      assignId: assignId,
      initState: initState,
      filter: filter,
      tag: tag,
      dispose: dispose,
      id: id,
      didChangeDependencies: didChangeDependencies,
      didUpdateWidget: didUpdateWidget,
      child: child,
    );
  }
```

**功能说明**：

- 复制当前 `_FactoryBind` 实例的所有参数，但替换 `child` 参数
- 返回新的 `_FactoryBind<T>` 实例（通过 `Bind.builder()` 工厂方法创建）
- 主要用于 `Binds` 类中嵌套多个 `Bind` 实例

**工作流程**：

1. `_copyWithChild(child)` 被调用
2. 调用 `Bind.builder()` 工厂方法，传入所有当前参数和新 `child`
3. `Bind.builder()` 返回新的 `_FactoryBind<T>` 实例
4. 返回新实例

**使用场景**：

在 `Binds` 中使用 `fold` 方法嵌套多个 `Bind` 实例：

```dart
binds.reversed.fold(child, (widget, e) => e._copyWithChild(widget))
```

## 与相关组件的关系

### 与 Bind 的关系

- `_FactoryBind` 是 `Bind` 的唯一具体实现类
- 所有 `Bind` 的静态方法都返回 `_FactoryBind` 实例
- `Bind.builder()` 工厂方法也返回 `_FactoryBind` 实例

### 与 Binder 的关系

- `_FactoryBind.build()` 返回 `Binder<T>` widget
- `Binder` 是 `InheritedWidget`，在 widget 树中提供控制器
- `_FactoryBind` 是 `Binder` 的创建者

### 与 Binds 的关系

- `Binds` 使用 `_FactoryBind._copyWithChild()` 方法嵌套多个 `Bind` 实例
- `Binds` 通过 `fold` 方法将多个 `_FactoryBind` 组合成嵌套的 widget 树

### 与 BindElement 的关系

- `_FactoryBind` 创建 `Binder` widget
- `Binder` 创建 `BindElement` 管理控制器的生命周期
- `BindElement` 负责控制器的创建、订阅和销毁

## 创建方式

### 通过静态方法创建

所有 `Bind` 的静态方法都返回 `_FactoryBind` 实例：

```dart
// put 方法
Bind.put<UserController>(UserController()) // 返回 _FactoryBind<UserController>

// lazyPut 方法
Bind.lazyPut<HeavyController>(() => HeavyController()) // 返回 _FactoryBind<HeavyController>

// create 方法
Bind.create<LocalController>((context) => LocalController(context)) // 返回 _FactoryBind<LocalController>

// spawn 方法
Bind.spawn<OrderController>(() => OrderController()) // 返回 _FactoryBind<OrderController>
```

### 通过工厂方法创建

`Bind.builder()` 工厂方法也返回 `_FactoryBind` 实例：

```dart
Bind.builder<UserController>(
  init: () => UserController(),
  child: MyWidget(),
) // 返回 _FactoryBind<UserController>
```

## 使用场景

### 在 widget 树中直接使用

```dart
Bind.put<UserController>(
  UserController(),
  child: MyWidget(),
)
```

### 在 Binds 中使用

```dart
Binds(
  binds: [
    Bind.put<UserController>(UserController()),
    Bind.put<CartController>(CartController()),
  ],
  child: MyWidget(),
)
```

### 使用工厂方法创建

```dart
Bind.builder<UserController>(
  init: () => UserController(),
  global: true,
  autoRemove: true,
  child: MyWidget(),
)
```

## 代码示例

### 基本使用

```dart
// 通过静态方法创建
Bind.put<UserController>(
  UserController(),
  tag: 'user',
  permanent: true,
  child: Builder(
    builder: (context) {
      final controller = Bind.of<UserController>(context, tag: 'user');
      return Text(controller.name);
    },
  ),
)
```

### 懒加载使用

```dart
// 懒加载注册
Bind.lazyPut<HeavyController>(
  () => HeavyController(),
  tag: 'heavy',
  fenix: true,
  onClose: () => print('Controller disposed'),
  child: MyWidget(),
)
```

### 局部控制器使用

```dart
// 创建局部控制器
Bind.create<LocalController>(
  (context) => LocalController(context),
  tag: 'local',
  global: false,
  child: MyWidget(),
)
```

### 使用工厂方法

```dart
Bind.builder<UserController>(
  init: () => UserController(),
  global: true,
  autoRemove: true,
  filter: (controller) => controller.name,
  initState: (state) {
    print('Controller initialized');
  },
  dispose: (state) {
    print('Controller disposed');
  },
  child: MyWidget(),
)
```

### 在 Binds 中嵌套

```dart
Binds(
  binds: [
    Bind.put<UserController>(UserController()),
    Bind.put<CartController>(CartController()),
    Bind.lazyPut<OrderController>(() => OrderController()),
  ],
  child: MyWidget(),
)
```

### 生命周期回调

```dart
Bind.builder<MyController>(
  init: () => MyController(),
  initState: (state) {
    print('Controller initialized');
  },
  dispose: (state) {
    print('Controller disposed');
  },
  didChangeDependencies: (state) {
    print('Dependencies changed');
  },
  didUpdateWidget: (oldWidget, state) {
    print('Widget updated');
  },
  child: MyWidget(),
)
```

## 注意事项

### 1. _FactoryBind 是私有类

`_FactoryBind` 使用下划线前缀，表示这是一个内部实现类。虽然可以直接使用，但推荐通过 `Bind` 的静态方法或工厂方法创建：

```dart
// 不推荐：直接使用 _FactoryBind
_FactoryBind<UserController>(
  init: () => UserController(),
  child: MyWidget(),
)

// 推荐：使用 Bind 的方法
Bind.builder<UserController>(
  init: () => UserController(),
  child: MyWidget(),
)
```

### 2. child 参数必须非空

在 `build()` 方法中使用 `child!`，表示 `child` 必须非空：

```dart
// 错误：child 为 null
_FactoryBind<UserController>(
  init: () => UserController(),
  // child: null, // 会导致运行时错误
)

// 正确：提供 child
_FactoryBind<UserController>(
  init: () => UserController(),
  child: MyWidget(),
)
```

### 3. init 和 create 的区别

- `init`：简单的创建函数，不需要 `BuildContext`
- `create`：接收 `BuildContext` 作为参数，可以访问上下文信息

```dart
// 使用 init
Bind.builder<UserController>(
  init: () => UserController(),
  child: MyWidget(),
)

// 使用 create
Bind.builder<UserController>(
  create: (context) => UserController(context),
  child: MyWidget(),
)
```

### 4. build() 方法只传递 create

`build()` 方法只传递 `create` 参数给 `Binder`，不传递 `init`。这是因为 `Binder` 优先使用 `create`，如果 `create` 为 `null`，才使用 `init`：

```dart
// _FactoryBind.build() 中
return Binder<T>(
  create: create, // 只传递 create
  // init 不传递，Binder 会从其他地方获取
  // ...
)
```

### 5. _copyWithChild() 的使用

`_copyWithChild()` 主要用于 `Binds` 中嵌套多个 `Bind` 实例。在普通使用中不需要直接调用：

```dart
// 在 Binds 中使用
Binds(
  binds: [
    Bind.put<UserController>(UserController()),
    Bind.put<CartController>(CartController()),
  ],
  child: MyWidget(),
)
// Binds 内部会调用 _copyWithChild() 方法
```

### 6. 静态方法返回的都是 _FactoryBind

所有 `Bind` 的静态方法都返回 `_FactoryBind` 实例，可以直接在 widget 树中使用：

```dart
// 所有这些都是 _FactoryBind 实例
Bind.put<UserController>(UserController())
Bind.lazyPut<HeavyController>(() => HeavyController())
Bind.create<LocalController>((context) => LocalController(context))
Bind.spawn<OrderController>(() => OrderController())
```

## 总结

`_FactoryBind` 是 `Bind` 抽象类的具体实现类，是 GetX 状态管理系统中依赖注入的核心实现。它通过实现 `build()` 方法创建 `Binder<T>` widget，将控制器注入到 widget 树中，并通过 `_copyWithChild()` 方法支持多个 `Bind` 实例的嵌套组合。

`_FactoryBind` 的主要优势在于：

1. **具体实现**：作为 `Bind` 的唯一具体实现，提供了完整的依赖注入功能
2. **Binder 创建**：通过 `build()` 方法创建 `Binder` widget，实现控制器的注入
3. **嵌套支持**：通过 `_copyWithChild()` 方法支持多个 `Bind` 实例的嵌套组合
4. **生命周期管理**：支持控制器的创建、订阅和销毁的完整生命周期管理

理解 `_FactoryBind` 的工作原理对于深入理解 GetX 的依赖注入系统非常重要。它是连接 `Bind` 抽象接口和 `Binder` 具体实现的重要桥梁，为 GetX 的状态管理提供了强大的支持。

## 参考资料

- [Bind 详解](lib/get_state_manager/src/simple/get_state.dart_bind.md)
- [Binder 和 BindElement 详解](lib/get_state_manager/src/simple/get_state.dart_binder.md)
- [Binds 详解](lib/get_state_manager/src/simple/get_state.dart_binds.md)
- [GetBuilder 详解](lib/get_state_manager/src/simple/get_state.dart_get-builder.md)
- [GetX 依赖注入文档](https://github.com/jonataslaw/getx/blob/master/README.md#dependency-injection)
