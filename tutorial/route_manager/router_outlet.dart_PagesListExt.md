# PagesListExt 扩展方法详解

## 概述

`PagesListExt` 是一个为 `List<GetPage>` 类型添加路由筛选功能的扩展方法。它提供了两个方法，用于从路由页面列表中提取特定路由及其后续路由，这在嵌套路由和路由树操作中非常有用。

## 扩展定义

```dart 190:205:lib/get_navigation/src/routes/router_outlet.dart
extension PagesListExt on List<GetPage> {
  /// Returns the route and all following routes after the given route.
  Iterable<GetPage> pickFromRoute(String route) {
    return skipWhile((value) => value.name != route);
  }

  /// Returns the routes after the given route.
  Iterable<GetPage> pickAfterRoute(String route) {
    // If the provided route is root, we take the first route after root.
    if (route == '/') {
      return pickFromRoute(route).skip(1).take(1);
    }
    // Otherwise, we skip the route and take all routes after it.
    return pickFromRoute(route).skip(1);
  }
}
```

## 方法详解

### pickFromRoute 方法

**功能**：返回从指定路由开始的所有路由（包括指定路由本身）。

**实现原理**：

- 使用 `skipWhile` 方法跳过所有不匹配指定路由名称的页面
- 一旦找到匹配的路由，就返回该路由及其之后的所有路由
- 如果列表中不存在指定路由，返回空的可迭代对象

**参数**：

- `route`：要查找的路由名称（字符串）

**返回值**：

- `Iterable<GetPage>`：从指定路由开始的所有页面（包括指定路由）

**示例**：

假设有一个路由列表：`['/home', '/profile', '/settings', '/about']`

```dart
final pages = [homePage, profilePage, settingsPage, aboutPage];
final result = pages.pickFromRoute('/profile');
// 返回：[profilePage, settingsPage, aboutPage]
```

### pickAfterRoute 方法

**功能**：返回指定路由之后的所有路由（不包括指定路由本身）。

**实现逻辑**：

1. **根路由特殊处理**：如果传入的路由是根路由 `'/'`，则只返回根路由之后的第一个路由
2. **普通路由处理**：对于其他路由，返回指定路由之后的所有路由

**参数**：

- `route`：要查找的路由名称（字符串）

**返回值**：

- `Iterable<GetPage>`：指定路由之后的所有页面（不包括指定路由）

**根路由的特殊行为**：

当 `route == '/'` 时，使用 `take(1)` 只取第一个后续路由。这是因为根路由通常作为整个应用的基础，其后的第一个路由通常代表主要的子路由。

**示例**：

```dart
// 示例 1：普通路由
final pages = [homePage, profilePage, settingsPage, aboutPage];
final result = pages.pickAfterRoute('/profile');
// 返回：[settingsPage, aboutPage]

// 示例 2：根路由
final pages = [rootPage, homePage, profilePage];
final result = pages.pickAfterRoute('/');
// 返回：[homePage]（只返回第一个）
```

## 使用场景

### 在 GetRouterOutlet 中的应用

这个扩展方法在 `GetRouterOutlet` 中被使用，用于从路由树中提取特定锚点路由之后的页面：

```dart 101:101:lib/get_navigation/src/routes/router_outlet.dart
ret = config.currentTreeBranch.pickAfterRoute(anchorRoute);
```

在这个场景中：

1. `config.currentTreeBranch` 包含了当前路由树分支的所有页面
2. `anchorRoute` 是锚点路由，用于确定从哪个路由开始提取后续页面
3. `pickAfterRoute` 方法提取锚点路由之后的所有页面，用于构建嵌套的路由出口

### 典型应用场景

1. **嵌套路由管理**：在嵌套路由结构中，需要从父路由中提取子路由页面
2. **路由树操作**：在路由树中查找特定分支并提取后续路由
3. **路由过滤**：根据锚点路由筛选出需要渲染的页面列表

## 方法对比

| 方法 | 是否包含指定路由 | 根路由特殊处理 | 返回内容 |
| --- | --- | --- | --- |
| `pickFromRoute` | ✅ 包含 | ❌ 无 | 从指定路由开始的所有路由 |
| `pickAfterRoute` | ❌ 不包含 | ✅ 有（只取第一个） | 指定路由之后的所有路由 |

## 注意事项

1. **路由不存在**：如果指定的路由在列表中不存在，两个方法都会返回空的可迭代对象
2. **路由名称匹配**：方法使用 `value.name != route` 进行精确匹配，确保路由名称完全一致
3. **性能考虑**：这些方法返回的是 `Iterable`，采用惰性求值，只有在实际使用时才会执行筛选操作
4. **根路由处理**：`pickAfterRoute` 对根路由有特殊处理，只返回第一个后续路由，这是为了适应常见的路由结构模式

## 实现细节

### skipWhile 的使用

`skipWhile` 是 Dart 中 `Iterable` 的一个方法，它会跳过满足条件的元素，直到遇到第一个不满足条件的元素，然后返回该元素及其之后的所有元素。

在这个扩展中：

```dart
skipWhile((value) => value.name != route)
```

这行代码会：

- 跳过所有 `name != route` 的页面
- 一旦找到 `name == route` 的页面，就停止跳过
- 返回该页面及其之后的所有页面

### 链式调用

`pickAfterRoute` 方法通过链式调用 `pickFromRoute` 来实现：

```dart
pickFromRoute(route).skip(1)
```

这种设计：

- 复用了 `pickFromRoute` 的逻辑
- 通过 `skip(1)` 跳过第一个元素（即指定路由本身）
- 对于根路由，额外使用 `take(1)` 限制只取一个元素
