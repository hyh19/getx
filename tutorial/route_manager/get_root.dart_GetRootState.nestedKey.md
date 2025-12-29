# GetRootState.nestedKey 方法解析

## 概述

`nestedKey` 是 `GetRootState` 类中的一个方法，用于管理嵌套路由的 `GetDelegate` 实例。该方法支持 GetX 框架的嵌套路由功能，允许在应用程序中创建多个独立的导航器（Navigator），每个导航器管理自己的路由栈。

## 方法签名

```dart 516:529:lib/get_navigation/src/root/get_root.dart
GetDelegate? nestedKey(String? key) {
  if (key == null) {
    return rootDelegate;
  }
  keys.putIfAbsent(
    key,
    () => GetDelegate(
      showHashOnUrl: true,
      //debugLabel: 'Getx nested key: ${key.toString()}',
      pages: RouteDecoder.fromRoute(key).currentChildren ?? [],
    ),
  );
  return keys[key];
}
```

## 参数说明

- **`key`** (`String?`): 可选的路由标识符。如果为 `null`，则返回根 `GetDelegate`；如果提供，则返回或创建对应路由的嵌套 `GetDelegate`。

## 返回值

- **`GetDelegate?`**: 返回对应的 `GetDelegate` 实例。当 `key` 为 `null` 时返回根 `GetDelegate`；当 `key` 不为 `null` 时返回对应的嵌套 `GetDelegate`。

## 工作原理

### 1. 空键处理

当 `key` 参数为 `null` 时，方法直接返回 `rootDelegate`，即应用程序的根导航器委托：

```dart
if (key == null) {
  return rootDelegate;
}
```

`rootDelegate` 是 `GetRootState` 类的一个 getter，定义如下：

```dart 502:504:lib/get_navigation/src/root/get_root.dart
GlobalKey<NavigatorState> get key => rootDelegate.navigatorKey;

GetDelegate get rootDelegate => config.routerDelegate as GetDelegate;
```

### 2. 嵌套键管理

当 `key` 不为 `null` 时，方法使用 `Map.putIfAbsent` 来确保每个路由键只创建一个 `GetDelegate` 实例：

```dart
keys.putIfAbsent(
  key,
  () => GetDelegate(
    showHashOnUrl: true,
    pages: RouteDecoder.fromRoute(key).currentChildren ?? [],
  ),
);
```

这里使用了延迟初始化模式：

- **`keys`**: 是一个 `Map<String, GetDelegate>` 类型的成员变量，用于缓存已创建的嵌套 `GetDelegate` 实例：

```dart 514:514:lib/get_navigation/src/root/get_root.dart
Map<String, GetDelegate> keys = {};
```

- **`putIfAbsent`**: 如果 `key` 已存在，直接返回对应的值；如果不存在，则调用提供的函数创建新值并存入 Map。

### 3. GetDelegate 创建参数

创建的嵌套 `GetDelegate` 使用了以下配置：

- **`showHashOnUrl: true`**: 在 Web 平台上，URL 中会显示哈希符号（#）。这确保了嵌套路由在浏览器中正确显示，并且不会干扰父路由。

- **`pages: RouteDecoder.fromRoute(key).currentChildren ?? []`**:
  - 使用 `RouteDecoder.fromRoute(key)` 解析路由字符串，获取路由解码器
  - 通过 `currentChildren` 获取当前路由的子路由页面列表
  - 如果 `currentChildren` 为 `null`，则使用空列表作为默认值

`RouteDecoder.fromRoute` 是一个工厂方法，它会：

1. 解析路由字符串为 `Uri` 对象
2. 创建 `PageSettings` 对象来存储路由参数
3. 调用根 `GetDelegate` 的 `matchRoute` 方法来匹配路由
4. 返回包含路由树分支和页面设置的 `RouteDecoder` 对象

```dart 14:25:lib/get_navigation/src/routes/parse_route.dart
factory RouteDecoder.fromRoute(String location) {
  var uri = Uri.parse(location);
  final args = PageSettings(uri);
  final decoder =
      (Get.rootController.rootDelegate).matchRoute(location, arguments: args);
  decoder.route = decoder.route?.copyWith(
    completer: null,
    arguments: args,
    parameters: args.params,
  );
  return decoder;
}
```

而 `currentChildren` 是一个 getter，返回当前路由的子页面列表：

```dart 42:42:lib/get_navigation/src/routes/parse_route.dart
List<GetPage>? get currentChildren => route?.children;
```

## 使用场景

### 1. GetRouterOutlet 中的使用

`nestedKey` 方法主要用于支持 `GetRouterOutlet` 组件，该组件用于在应用程序中创建嵌套的导航器。在 `GetRouterOutlet` 的构造函数中：

```dart 110:110:lib/get_navigation/src/routes/router_outlet.dart
navigatorKey: Get.nestedKey(anchorRoute)?.navigatorKey,
```

以及在 `builder` 构造函数中：

```dart 160:162:lib/get_navigation/src/routes/router_outlet.dart
delegate: routerDelegate ??
    (route != null
        ? Get.nestedKey(route)
```

这些使用场景展示了如何通过 `nestedKey` 获取嵌套路由对应的 `GetDelegate` 和其导航器键。

### 2. 扩展导航方法

`Get` 类的扩展方法也提供了 `nestedKey` 方法，它内部调用了 `GetRootState.nestedKey`：

```dart 1182:1184:lib/get_navigation/src/extension_navigation.dart
GetDelegate? nestedKey(String? key) {
  return rootController.nestedKey(key);
}
```

这使得开发者可以通过 `Get.nestedKey(key)` 来访问嵌套路由的 `GetDelegate`。

## 设计模式

### 1. 延迟初始化（Lazy Initialization）

方法使用了 `Map.putIfAbsent` 实现了延迟初始化模式。只有当首次请求某个路由键的 `GetDelegate` 时，才会创建对应的实例。这避免了不必要的对象创建，提高了性能。

### 2. 单例模式（Singleton Pattern）

对于每个路由键，方法确保只创建一个 `GetDelegate` 实例。后续对相同键的请求都会返回同一个实例，保证了嵌套导航器的一致性。

### 3. 缓存机制

`keys` Map 作为缓存存储已创建的 `GetDelegate` 实例，避免重复创建，提高了访问效率。

## 注意事项

1. **路由键的唯一性**: 每个路由键应该唯一，以便正确管理不同的嵌套导航器。

2. **子路由配置**: 创建嵌套 `GetDelegate` 时，它会使用 `RouteDecoder.fromRoute(key).currentChildren` 作为页面列表。因此，对应的路由必须在 `GetPage` 中正确配置 `children` 属性。

3. **Web 平台支持**: `showHashOnUrl: true` 确保了在 Web 平台上嵌套路由能够正确工作，URL 中会包含哈希符号。

4. **内存管理**: 虽然 `keys` Map 会缓存 `GetDelegate` 实例，但这些实例通常会在应用程序的整个生命周期中存在。如果需要清理，需要手动管理。

## 相关类型

- **`GetDelegate`**: Flutter 路由委托，继承自 `RouterDelegate<RouteDecoder>`，负责管理路由栈和导航状态。

- **`RouteDecoder`**: 路由解码器，包含路由树分支和页面设置信息。

- **`GetPage`**: GetX 框架中的页面定义，包含路由名称、页面构建函数、中间件等信息。

- **`GetRouterOutlet`**: 用于创建嵌套导航器的组件，支持独立的路由管理。

## 总结

`nestedKey` 方法是 GetX 框架实现嵌套路由的核心方法之一。它通过延迟初始化和缓存机制，高效地管理多个 `GetDelegate` 实例，为应用程序提供了灵活的嵌套导航能力。该方法主要用于支持 `GetRouterOutlet` 组件，使得开发者可以在应用程序中创建多个独立的导航栈，实现复杂的导航场景。
