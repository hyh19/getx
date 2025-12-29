# pickPagesForRootNavigator 字段详解

## 概述

`pickPagesForRootNavigator` 是 `GetDelegate` 类中的一个可选的可调用对象（函数类型字段），用于自定义选择哪些页面应该显示在根导航器中。这个字段允许开发者完全控制根导航器显示的页面列表，提供了比默认 `getVisualPages` 方法更灵活的页面选择机制。

## 字段定义

```dart 45:46:lib/get_navigation/src/routes/get_router_delegate.dart
final Iterable<GetPage> Function(RouteDecoder currentNavStack)?
    pickPagesForRootNavigator;
```

### 类型说明

- **类型**：`Iterable<GetPage> Function(RouteDecoder currentNavStack)?`
- **可空性**：可选字段（`?` 表示可以为 `null`）
- **参数类型**：`RouteDecoder currentNavStack` - 当前的路由导航栈
- **返回值类型**：`Iterable<GetPage>` - 应该显示在根导航器中的页面集合

### RouteDecoder 结构

`RouteDecoder` 包含了当前路由导航栈的信息：

```dart 6:12:lib/get_navigation/src/routes/parse_route.dart
@immutable
class RouteDecoder {
  const RouteDecoder(
    this.currentTreeBranch,
    this.pageSettings,
  );
  final List<GetPage> currentTreeBranch;
  final PageSettings? pageSettings;
```

- **`currentTreeBranch`**：`List<GetPage>` - 当前路由树分支，包含了从根路由到当前路由的所有页面
- **`pageSettings`**：`PageSettings?` - 页面设置信息，包含参数、查询参数等

## 在代码中的使用

### 构造函数初始化

`pickPagesForRootNavigator` 在构造函数中作为可选参数传入：

```dart 81:88:lib/get_navigation/src/routes/get_router_delegate.dart
GetDelegate({
  GetPage? notFoundRoute,
  this.navigatorObservers,
  this.transitionDelegate,
  this.backButtonPopMode = PopMode.history,
  this.preventDuplicateHandlingMode =
      PreventDuplicateHandlingMode.reorderRoutes,
  this.pickPagesForRootNavigator,
```

### build 方法中的调用

在 `build` 方法中，`pickPagesForRootNavigator` 被调用来决定哪些页面应该显示：

```dart 309:315:lib/get_navigation/src/routes/get_router_delegate.dart
@override
Widget build(BuildContext context) {
  final currentHistory = currentConfiguration;
  final pages = currentHistory == null
      ? <GetPage>[]
      : pickPagesForRootNavigator?.call(currentHistory).toList() ??
          getVisualPages(currentHistory).toList();
```

**调用逻辑**：

1. 如果 `currentHistory` 为 `null`，返回空列表
2. 如果 `pickPagesForRootNavigator` 不为 `null`，调用它并获取页面列表
3. 否则，使用默认的 `getVisualPages` 方法

### 与 getVisualPages 的关系

默认的 `getVisualPages` 方法根据 `participatesInRootNavigator` 属性来选择页面：

```dart 293:307:lib/get_navigation/src/routes/get_router_delegate.dart
/// gets the visual pages from the current _activePages entry
///
/// visual pages must have [GetPage.participatesInRootNavigator] set to true
Iterable<GetPage> getVisualPages(RouteDecoder? currentHistory) {
  final res = currentHistory!.currentTreeBranch
      .where((r) => r.participatesInRootNavigator != null);
  if (res.isEmpty) {
    //default behavior, all routes participate in root navigator
    return _activePages.map((e) => e.route!);
  } else {
    //user specified at least one participatesInRootNavigator
    return res
        .where((element) => element.participatesInRootNavigator == true);
  }
}
```

**默认行为**：

- 如果没有任何页面设置 `participatesInRootNavigator`，返回所有活跃路由
- 如果至少有一个页面设置了 `participatesInRootNavigator`，只返回 `participatesInRootNavigator == true` 的页面

**自定义 `pickPagesForRootNavigator` 的优势**：

- 可以完全自定义页面选择逻辑，不受 `participatesInRootNavigator` 限制
- 可以基于路由深度、页面名称、参数等进行复杂的选择
- 可以实现动态的页面选择策略

## 代码示例

### 示例 1：基础用法 - 只显示当前页面

这个示例展示了如何只显示路由树中的最后一个页面（当前页面），忽略所有中间页面：

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pages = [
      GetPage(name: '/', page: () => HomePage()),
      GetPage(name: '/profile', page: () => ProfilePage()),
      GetPage(name: '/settings', page: () => SettingsPage()),
    ];

    return GetMaterialApp.router(
      getPages: pages,
      routerDelegate: GetDelegate(
        pages: pages,
        // 只显示当前页面，忽略路由树中的其他页面
        pickPagesForRootNavigator: (RouteDecoder currentNavStack) {
          final currentTreeBranch = currentNavStack.currentTreeBranch;
          // 只返回路由树中的最后一个页面
          if (currentTreeBranch.isEmpty) {
            return [];
          }
          return [currentTreeBranch.last];
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/profile'),
          child: Text('跳转到个人资料'),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('个人资料')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/settings'),
          child: Text('跳转到设置'),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: Center(
        child: Text('设置页面'),
      ),
    );
  }
}
```

**说明**：

- 这个函数返回一个只包含当前页面的列表
- 无论路由树中有多少页面，只有最后一个页面会被显示
- 适用于需要简化导航栈显示的场景

### 示例 2：自定义过滤 - 根据 participatesInRootNavigator 过滤

这个示例展示了如何手动实现基于 `participatesInRootNavigator` 属性的过滤逻辑，同时添加额外的自定义条件：

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pages = [
      GetPage(
        name: '/',
        page: () => HomePage(),
        participatesInRootNavigator: true,
      ),
      GetPage(
        name: '/profile',
        page: () => ProfilePage(),
        participatesInRootNavigator: true,
      ),
      GetPage(
        name: '/settings',
        page: () => SettingsPage(),
        participatesInRootNavigator: false,
      ),
      GetPage(
        name: '/notifications',
        page: () => NotificationPage(),
        participatesInRootNavigator: true,
      ),
    ];

    return GetMaterialApp.router(
      getPages: pages,
      routerDelegate: GetDelegate(
        pages: pages,
        // 自定义过滤逻辑：只显示 participatesInRootNavigator == true 的页面
        pickPagesForRootNavigator: (RouteDecoder currentNavStack) {
          return currentNavStack.currentTreeBranch
              .where((page) => page.participatesInRootNavigator == true)
              .toList();
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed('/profile'),
              child: Text('跳转到个人资料'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed('/settings'),
              child: Text('跳转到设置'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed('/notifications'),
              child: Text('跳转到通知'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('个人资料')),
      body: Center(child: Text('个人资料页面')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: Center(
        child: Text('设置页面（不显示在根导航器中）'),
      ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('通知')),
      body: Center(child: Text('通知页面')),
    );
  }
}
```

**说明**：

- 手动实现了基于 `participatesInRootNavigator` 的过滤
- 可以在此基础上添加更多自定义逻辑
- 提供了比默认 `getVisualPages` 更精确的控制

### 示例 3：高级用法 - 基于路由深度和条件的复杂选择

这个示例展示了如何根据路由深度、页面名称等进行复杂的页面选择逻辑：

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pages = [
      GetPage(name: '/', page: () => HomePage()),
      GetPage(
        name: '/dashboard',
        page: () => DashboardPage(),
        children: [
          GetPage(name: '/overview', page: () => OverviewPage()),
          GetPage(name: '/analytics', page: () => AnalyticsPage()),
        ],
      ),
      GetPage(name: '/profile', page: () => ProfilePage()),
      GetPage(name: '/settings', page: () => SettingsPage()),
    ];

    return GetMaterialApp.router(
      getPages: pages,
      routerDelegate: GetDelegate(
        pages: pages,
        // 复杂的页面选择逻辑
        pickPagesForRootNavigator: (RouteDecoder currentNavStack) {
          final treeBranch = currentNavStack.currentTreeBranch;

          if (treeBranch.isEmpty) {
            return [];
          }

          // 策略 1：如果路由深度 <= 2，显示所有页面
          if (treeBranch.length <= 2) {
            return treeBranch;
          }

          // 策略 2：对于深度 > 2 的路由，只显示根页面和当前页面
          final result = <GetPage>[];

          // 始终包含根页面
          result.add(treeBranch.first);

          // 检查是否有特定的父页面需要保留
          for (int i = 1; i < treeBranch.length - 1; i++) {
            final page = treeBranch[i];
            // 如果页面名称包含 'dashboard'，保留它
            if (page.name.contains('dashboard')) {
              result.add(page);
            }
          }

          // 始终包含当前页面（最后一个）
          result.add(treeBranch.last);

          // 去重（如果根页面和当前页面相同）
          return result.toSet().toList();
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页')),
      body: ListView(
        children: [
          ListTile(
            title: Text('仪表盘'),
            subtitle: Text('深度 = 1'),
            onTap: () => Get.toNamed('/dashboard'),
          ),
          ListTile(
            title: Text('仪表盘概览'),
            subtitle: Text('深度 = 2，显示所有页面'),
            onTap: () => Get.toNamed('/dashboard/overview'),
          ),
          ListTile(
            title: Text('仪表盘分析'),
            subtitle: Text('深度 = 2，显示所有页面'),
            onTap: () => Get.toNamed('/dashboard/analytics'),
          ),
          ListTile(
            title: Text('个人资料'),
            subtitle: Text('深度 = 1'),
            onTap: () => Get.toNamed('/profile'),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('仪表盘')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('仪表盘主页'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed('/dashboard/overview'),
              child: Text('查看概览'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed('/dashboard/analytics'),
              child: Text('查看分析'),
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('概览')),
      body: Center(child: Text('概览页面')),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('分析')),
      body: Center(child: Text('分析页面')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('个人资料')),
      body: Center(child: Text('个人资料页面')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: Center(child: Text('设置页面')),
    );
  }
}
```

**说明**：

- **策略 1**：对于浅层路由（深度 <= 2），显示所有页面
- **策略 2**：对于深层路由，保留根页面、包含 'dashboard' 的页面和当前页面
- **去重处理**：确保返回的页面列表中没有重复项

这个示例展示了如何实现复杂的、多层次的页面选择逻辑，适用于大型应用的导航管理。

## 使用场景

### 何时需要使用 pickPagesForRootNavigator

1. **自定义导航栈显示**：当默认的 `getVisualPages` 方法无法满足需求时
2. **动态页面选择**：需要根据路由参数、页面状态等动态选择显示的页面
3. **复杂导航结构**：应用有复杂的嵌套路由结构，需要精确控制哪些页面显示在根导航器
4. **性能优化**：在导航栈很深时，只显示必要的页面以减少渲染负担
5. **特殊 UI 需求**：需要实现特殊的导航栈展示效果，如只显示当前页面

### 与默认 getVisualPages 的对比

| 特性 | `getVisualPages`（默认） | `pickPagesForRootNavigator`（自定义） |
| --- | --- | --- |
| **配置方式** | 通过 `participatesInRootNavigator` 属性 | 通过函数逻辑 |
| **灵活性** | 中等（只能基于布尔属性） | 高（可以基于任何条件） |
| **复杂度** | 简单 | 可以很复杂 |
| **性能** | 固定逻辑，性能稳定 | 取决于实现，可能有性能开销 |
| **适用场景** | 大多数标准场景 | 需要特殊控制的场景 |

### 最佳实践

1. **优先使用默认方法**：如果 `getVisualPages` 能满足需求，优先使用它
2. **保持函数简洁**：自定义函数应该保持逻辑清晰，避免过度复杂
3. **性能考虑**：对于大型导航栈，注意函数执行的性能影响
4. **测试覆盖**：自定义函数应该充分测试各种路由场景
5. **文档说明**：为自定义函数添加注释，说明选择逻辑

## 总结

`pickPagesForRootNavigator` 字段为 GetX 导航系统提供了强大的自定义能力，允许开发者完全控制根导航器显示的页面。虽然大多数场景下默认的 `getVisualPages` 方法已经足够，但在需要复杂导航逻辑时，这个字段提供了必要的灵活性。通过合理使用，可以实现精确的导航栈管理，提升用户体验和应用性能。
