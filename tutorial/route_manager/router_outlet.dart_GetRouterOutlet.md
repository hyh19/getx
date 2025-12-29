# GetRouterOutlet 类详解

## 概述

`GetRouterOutlet` 是 GetX 导航系统中的一个重要组件，用于创建嵌套的路由上下文。它继承自泛型类 `RouterOutlet<GetDelegate, RouteDecoder>`，专门为 GetX 的路由系统进行了定制。通过 `GetRouterOutlet`，开发者可以在应用中创建独立的路由分支，实现复杂的嵌套导航场景，如底部导航栏、侧边栏导航、Tab 页面等。

## 类定义

```dart 80:80:lib/get_navigation/src/routes/router_outlet.dart
class GetRouterOutlet extends RouterOutlet<GetDelegate, RouteDecoder> {
```

### 继承关系

`GetRouterOutlet` 继承自 `RouterOutlet<GetDelegate, RouteDecoder>`，其中：

- **`GetDelegate`**：GetX 的路由委托类型，实现了 `RouterDelegate<RouteDecoder>` 接口
- **`RouteDecoder`**：路由配置类型，包含当前路由树分支（`currentTreeBranch`）和页面设置信息

### 设计目的

`GetRouterOutlet` 提供了三种不同的构造函数，分别适用于不同的使用场景：

1. **默认构造函数**：适用于基于路由锚点（`anchorRoute`）的嵌套导航
2. **`pickPages` 构造函数**：适用于需要通过自定义逻辑选择页面的场景
3. **`builder` 构造函数**：适用于需要完全自定义 UI 构建的场景

## 构造函数详解

### 1. 默认构造函数（GetRouterOutlet）

```dart 81:112:lib/get_navigation/src/routes/router_outlet.dart
GetRouterOutlet({
  Key? key,
  String? anchorRoute,
  required String initialRoute,
  Iterable<GetPage> Function(Iterable<GetPage> afterAnchor)? filterPages,
  GetDelegate? delegate,
  String? restorationScopeId,
}) : this.pickPages(
        restorationScopeId: restorationScopeId,
        pickPages: (config) {
          Iterable<GetPage<dynamic>> ret;
          if (anchorRoute == null) {
            // jump the ancestor path
            final length = Uri.parse(initialRoute).pathSegments.length;

            return config.currentTreeBranch
                .skip(length)
                .take(length)
                .toList();
          }
          ret = config.currentTreeBranch.pickAfterRoute(anchorRoute);
          if (filterPages != null) {
            ret = filterPages(ret);
          }
          return ret;
        },
        key: key,
        emptyPage: (delegate) =>
            delegate.matchRoute(initialRoute).route ?? delegate.notFoundRoute,
        navigatorKey: Get.nestedKey(anchorRoute)?.navigatorKey,
        delegate: delegate,
      );
```

#### 参数说明

- **`key`**：可选，Widget 的键，用于在 widget 树中识别该 widget
- **`anchorRoute`**：可选，锚点路由名称。如果提供，将从该路由之后开始选择页面；如果为 `null`，则基于 `initialRoute` 的路径深度来选择页面
- **`initialRoute`**：必需，初始路由名称。当没有匹配到页面时，会尝试匹配此路由作为默认页面
- **`filterPages`**：可选，页面过滤器函数。接收从锚点路由之后的所有页面，返回过滤后的页面集合
- **`delegate`**：可选，路由委托实例。如果未提供，将使用根路由委托
- **`restorationScopeId`**：可选，用于状态恢复的作用域 ID

#### 实现逻辑

该构造函数通过重定向到 `pickPages` 构造函数来实现功能。核心逻辑在 `pickPages` 回调函数中：

1. **处理 `anchorRoute` 为 `null` 的情况**：
   - 解析 `initialRoute` 的路径段长度
   - 从当前路由树分支中跳过祖先路径（使用 `skip(length)`）
   - 然后取相同长度的页面（使用 `take(length)`）
   - 这样做的目的是"跳过祖先路径"，只显示与 `initialRoute` 同级或后续的路由

2. **处理 `anchorRoute` 不为 `null` 的情况**：
   - 使用 `pickAfterRoute(anchorRoute)` 方法从当前路由树分支中选择锚点路由之后的所有页面
   - 如果提供了 `filterPages` 函数，则对选中的页面进行进一步过滤

3. **空页面处理**：
   - 当没有匹配到页面时，会调用 `emptyPage` 回调
   - 尝试匹配 `initialRoute`，如果匹配失败则使用 `notFoundRoute`

4. **导航键设置**：
   - 如果提供了 `anchorRoute`，会尝试获取对应的嵌套导航键
   - 这允许在嵌套导航中独立管理返回按钮行为

#### 使用场景

适用于需要在特定路由下创建嵌套导航的场景，例如：

- 在底部导航栏的某个 Tab 下创建独立的导航栈
- 在侧边栏的某个菜单项下创建子路由
- 在特定页面下创建嵌套的页面流

### 2. pickPages 构造函数

```dart 113:151:lib/get_navigation/src/routes/router_outlet.dart
GetRouterOutlet.pickPages({
  super.key,
  Widget Function(GetDelegate delegate)? emptyWidget,
  GetPage Function(GetDelegate delegate)? emptyPage,
  required super.pickPages,
  bool Function(Route<dynamic>, dynamic)? onPopPage,
  String? restorationScopeId,
  GlobalKey<NavigatorState>? navigatorKey,
  GetDelegate? delegate,
}) : super(
        pageBuilder: (context, rDelegate, pages) {
          final pageRes = <GetPage?>[
            ...?pages,
            if (pages == null || pages.isEmpty) emptyPage?.call(rDelegate),
          ].whereType<GetPage>();

          if (pageRes.isNotEmpty) {
            return InheritedNavigator(
              navigatorKey: navigatorKey ??
                  Get.rootController.rootDelegate.navigatorKey,
              child: GetNavigator(
                restorationScopeId: restorationScopeId,
                onPopPage: onPopPage ??
                    (route, result) {
                      final didPop = route.didPop(result);
                      if (!didPop) {
                        return false;
                      }
                      return true;
                    },
                pages: pageRes.toList(),
                key: navigatorKey,
              ),
            );
          }
          return (emptyWidget?.call(rDelegate) ?? const SizedBox.shrink());
        },
        delegate: delegate ?? Get.rootController.rootDelegate,
      );
```

#### 参数说明

- **`key`**：可选，Widget 的键
- **`emptyWidget`**：可选，当没有页面需要显示时返回的 Widget 构建函数
- **`emptyPage`**：可选，当没有页面需要显示时返回的 `GetPage` 构建函数
- **`pickPages`**：必需，页面选择函数。接收当前的 `RouteDecoder` 配置，返回需要显示的页面集合
- **`onPopPage`**：可选，页面弹出时的回调函数。如果未提供，使用默认处理逻辑
- **`restorationScopeId`**：可选，状态恢复作用域 ID
- **`navigatorKey`**：可选，导航器的全局键。如果未提供，使用根导航器的键
- **`delegate`**：可选，路由委托实例。如果未提供，使用根路由委托

#### 实现逻辑

该构造函数是 `GetRouterOutlet` 的核心实现，它调用父类 `RouterOutlet` 的构造函数，并提供 `pageBuilder` 函数：

1. **页面集合构建**：
   - 如果 `pickPages` 返回了页面，将它们加入 `pageRes` 列表
   - 如果没有页面且提供了 `emptyPage` 回调，则调用它获取默认页面
   - 使用 `whereType<GetPage>()` 过滤掉 `null` 值

2. **有页面时的处理**：
   - 创建一个 `InheritedNavigator` widget，用于在 widget 树中向下传递导航器键
   - 内部使用 `GetNavigator` 来实际管理页面栈
   - 设置 `restorationScopeId` 用于状态恢复
   - 提供 `onPopPage` 回调处理页面弹出逻辑（默认实现是简单的 `didPop` 调用）

3. **无页面时的处理**：
   - 如果提供了 `emptyWidget` 回调，调用它返回自定义 Widget
   - 否则返回 `SizedBox.shrink()`（一个空的、不占空间的 Widget）

#### 使用场景

适用于需要完全自定义页面选择逻辑的场景，例如：

- 根据复杂的业务逻辑选择要显示的页面
- 实现动态的路由过滤和转换
- 创建自定义的嵌套导航策略

### 3. builder 构造函数

```dart 153:164:lib/get_navigation/src/routes/router_outlet.dart
GetRouterOutlet.builder({
  super.key,
  required super.builder,
  String? route,
  GetDelegate? routerDelegate,
}) : super.builder(
        delegate: routerDelegate ??
            (route != null
                ? Get.nestedKey(route)
                : Get.rootController.rootDelegate),
      );
```

#### 参数说明

- **`key`**：可选，Widget 的键
- **`builder`**：必需，Widget 构建函数。接收 `BuildContext` 并返回要显示的 Widget
- **`route`**：可选，路由名称。如果提供，将使用该路由对应的嵌套导航键来获取委托
- **`routerDelegate`**：可选，路由委托实例。如果提供，直接使用它；否则根据 `route` 参数或使用根委托

#### 实现逻辑

该构造函数是最灵活的构造函数，直接将构建逻辑委托给父类的 `builder` 构造函数：

1. **委托选择逻辑**：
   - 如果提供了 `routerDelegate`，直接使用它
   - 否则，如果提供了 `route`，使用 `Get.nestedKey(route)` 获取对应的委托
   - 如果都未提供，使用根路由委托 `Get.rootController.rootDelegate`

2. **构建逻辑**：
   - 完全由调用者通过 `builder` 参数控制
   - 父类的 `builder` 构造函数会在路由状态变化时调用 `builder` 函数重建 UI

#### 使用场景

适用于需要完全自定义 UI 构建逻辑的场景，例如：

- 需要在嵌套导航中添加额外的 Widget（如 AppBar、BottomBar 等）
- 需要实现复杂的自定义导航 UI
- 需要与其他状态管理方案集成

## 核心概念理解

### 路由树分支（currentTreeBranch）

`RouteDecoder` 的 `currentTreeBranch` 属性是一个 `List<GetPage>`，表示从根路由到当前路由的完整路径。例如，如果当前路由是 `/home/products/detail`，那么 `currentTreeBranch` 可能包含：

```dart
[
  GetPage(name: '/'),
  GetPage(name: '/home'),
  GetPage(name: '/home/products'),
  GetPage(name: '/home/products/detail'),
]
```

`GetRouterOutlet` 的作用就是从这棵树分支中选择一部分页面来显示，实现嵌套导航。

### 嵌套导航键（nestedKey）

`Get.nestedKey(route)` 用于获取特定路由的嵌套导航键。每个嵌套导航上下文都可以有自己独立的导航器键，这样可以在嵌套导航中独立处理返回按钮等行为。

### 页面选择逻辑（pickPages）

`pickPages` 函数接收当前的 `RouteDecoder` 配置（包含 `currentTreeBranch`），返回需要在该 outlet 中显示的页面集合。这个函数是 `GetRouterOutlet` 的核心，决定了哪些页面会被显示在嵌套导航中。

## 使用示例

### 示例 1：基于锚点路由的嵌套导航

```dart
GetRouterOutlet(
  anchorRoute: '/home',
  initialRoute: '/home/dashboard',
  delegate: Get.nestedKey('/home')?.delegate,
)
```

这个例子会显示 `/home` 路由之后的所有页面，适用于在 `/home` 路由下创建独立的导航栈。

### 示例 2：使用自定义页面过滤

```dart
GetRouterOutlet(
  anchorRoute: '/products',
  initialRoute: '/products/list',
  filterPages: (pages) {
    // 只显示产品相关的页面，过滤掉其他页面
    return pages.where((page) => page.name?.startsWith('/products') ?? false);
  },
)
```

这个例子在 `/products` 路由下创建嵌套导航，并过滤出产品相关的页面。

### 示例 3：使用 builder 构造函数

```dart
GetRouterOutlet.builder(
  route: '/settings',
  builder: (context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: GetRouterOutlet.pickPages(
        pickPages: (config) {
          return config.currentTreeBranch
              .pickAfterRoute('/settings');
        },
      ),
    );
  },
)
```

这个例子使用 `builder` 构造函数添加了 AppBar，并在 body 中使用 `pickPages` 构造函数选择页面。

## 总结

`GetRouterOutlet` 是 GetX 导航系统中实现嵌套导航的关键组件。通过三个不同的构造函数，它提供了从简单到复杂的各种使用场景支持：

- **默认构造函数**：适用于基于锚点路由的常见嵌套导航场景
- **`pickPages` 构造函数**：提供灵活的页面选择逻辑
- **`builder` 构造函数**：提供完全的 UI 构建控制

理解 `GetRouterOutlet` 的工作原理，有助于开发者更好地利用 GetX 的导航系统实现复杂的应用导航结构。
