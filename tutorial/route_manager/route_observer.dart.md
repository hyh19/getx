# GetObserver 路由观察者详解

## 概述

`GetObserver` 是 GetX 路由系统的导航观察者，它继承自 Flutter 的 `NavigatorObserver`，用于监听和跟踪应用中的路由导航事件。通过 `GetObserver`，你可以获取当前路由信息、监听路由变化、记录导航日志，并在路由变化时执行自定义逻辑。

### 核心功能

`GetObserver` 提供了以下核心功能：

1. **路由事件监听**：监听路由的推送（push）、弹出（pop）、移除（remove）和替换（replace）事件
2. **路由状态跟踪**：维护当前路由、前一个路由、路由参数等状态信息
3. **日志记录**：自动记录路由导航的日志信息
4. **路由报告**：与 `RouterReportManager` 集成，用于依赖管理和内存管理
5. **路由信息回调**：通过 `routing` 回调函数，将路由变化通知给外部代码

### 在 GetX 中的使用

`GetObserver` 通常在 `GetMaterialApp` 或 `MaterialApp` 中作为 `navigatorObservers` 使用：

```dart
MaterialApp(
  navigatorKey: Get.key,
  navigatorObservers: [GetObserver()],
);
```

也可以传入自定义的回调函数：

```dart
GetObserver((routing) {
  print('Current route: ${routing?.current}');
  print('Previous route: ${routing?.previous}');
})
```

## _extractRouteName 函数

```dart 11:29:lib/get_navigation/src/routes/observers/route_observer.dart
String? _extractRouteName(Route? route) {
  if (route?.settings.name != null) {
    return route!.settings.name;
  }

  if (route is GetPageRoute) {
    return route.routeName;
  }

  if (route is GetDialogRoute) {
    return 'DIALOG ${route.hashCode}';
  }

  if (route is GetModalBottomSheetRoute) {
    return 'BOTTOMSHEET ${route.hashCode}';
  }

  return null;
}
```

这是一个私有辅助函数，用于从不同的路由类型中提取路由名称。提取策略按优先级顺序如下：

1. **RouteSettings.name**：如果路由的 `settings.name` 不为空，直接返回
2. **GetPageRoute**：如果是 `GetPageRoute` 类型，返回其 `routeName` 属性
3. **GetDialogRoute**：如果是对话框路由，返回格式化的字符串 `'DIALOG ${hashCode}'`
4. **GetModalBottomSheetRoute**：如果是底部表单路由，返回格式化的字符串 `'BOTTOMSHEET ${hashCode}'`
5. **其他情况**：返回 `null`

对于对话框和底部表单，由于它们可能没有明确的名称，因此使用哈希码来生成唯一标识符。

## GetObserver 类

### 类定义

```dart 31:36:lib/get_navigation/src/routes/observers/route_observer.dart
class GetObserver extends NavigatorObserver {
  final Function(Routing?)? routing;

  final Routing? _routeSend;

  GetObserver([this.routing, this._routeSend]);
```

`GetObserver` 继承自 Flutter 的 `NavigatorObserver`，这是 Flutter 导航系统提供的观察者基类。构造函数接受两个可选参数：

- **`routing`**：一个回调函数，当路由发生变化时会被调用，参数是 `Routing?` 类型的对象，包含当前路由的状态信息
- **`_routeSend`**：一个私有的 `Routing` 对象，用于存储和传递路由状态信息

### didPop 方法

```dart 38:74:lib/get_navigation/src/routes/observers/route_observer.dart
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final currentRoute = _RouteData.ofRoute(route);
    final newRoute = _RouteData.ofRoute(previousRoute);

    if (currentRoute.isBottomSheet || currentRoute.isDialog) {
      Get.log("CLOSE ${currentRoute.name}");
    } else if (currentRoute.isGetPageRoute) {
      Get.log("CLOSE TO ROUTE ${currentRoute.name}");
    }
    if (previousRoute != null) {
      RouterReportManager.instance.reportCurrentRoute(previousRoute);
    }

    // Here we use a 'inverse didPush set', meaning that we use
    // previous route instead of 'route' because this is
    // a 'inverse push'
    _routeSend?.update((value) {
      // Only PageRoute is allowed to change current value
      if (previousRoute is PageRoute) {
        value.current = _extractRouteName(previousRoute) ?? '';
        value.previous = newRoute.name ?? '';
      } else if (value.previous.isNotEmpty) {
        value.current = value.previous;
      }

      value.args = previousRoute?.settings.arguments;
      value.route = previousRoute;
      value.isBack = true;
      value.removed = '';
      value.isBottomSheet = newRoute.isBottomSheet;
      value.isDialog = newRoute.isDialog;
    });

    routing?.call(_routeSend);
  }
```

当路由被弹出（用户返回上一页）时，`didPop` 方法会被调用。

**处理逻辑**：

1. **日志记录**：根据路由类型记录相应的日志信息
   - 如果是底部表单或对话框，记录 "CLOSE" 日志
   - 如果是页面路由，记录 "CLOSE TO ROUTE" 日志

2. **路由报告**：如果存在前一个路由，通知 `RouterReportManager` 当前路由已变为前一个路由

3. **状态更新**：更新 `_routeSend` 对象的状态：
   - **`current`**：如果前一个路由是 `PageRoute`，则使用前一个路由的名称作为当前路由；否则，如果前一个路由名称不为空，使用前一个路由的名称
   - **`previous`**：设置为当前被弹出的路由名称
   - **`isBack`**：设置为 `true`，表示这是一个返回操作
   - **`removed`**：清空（因为这不是移除操作）
   - **`isBottomSheet` 和 `isDialog`**：根据前一个路由的类型更新

4. **回调通知**：调用 `routing` 回调函数，通知外部代码路由状态的变化

**注释说明**：代码中注释提到这是一个 "反向推送"（inverse push），意思是使用前一个路由而不是当前路由来更新状态，因为弹出操作实际上是从当前路由返回到前一个路由。

### didPush 方法

```dart 76:109:lib/get_navigation/src/routes/observers/route_observer.dart
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final newRoute = _RouteData.ofRoute(route);

    if (newRoute.isBottomSheet || newRoute.isDialog) {
      Get.log("OPEN ${newRoute.name}");
    } else if (newRoute.isGetPageRoute) {
      Get.log("GOING TO ROUTE ${newRoute.name}");
    }

    RouterReportManager.instance.reportCurrentRoute(route);
    _routeSend?.update((value) {
      if (route is PageRoute) {
        value.current = newRoute.name ?? '';
      }
      final previousRouteName = _extractRouteName(previousRoute);
      if (previousRouteName != null) {
        value.previous = previousRouteName;
      }

      value.args = route.settings.arguments;
      value.route = route;
      value.isBack = false;
      value.removed = '';
      value.isBottomSheet =
          newRoute.isBottomSheet ? true : value.isBottomSheet ?? false;
      value.isDialog = newRoute.isDialog ? true : value.isDialog ?? false;
    });

    if (routing != null) {
      routing!(_routeSend);
    }
  }
```

当新路由被推送（导航到新页面）时，`didPush` 方法会被调用。

**处理逻辑**：

1. **日志记录**：根据新路由的类型记录相应的日志
   - 如果是底部表单或对话框，记录 "OPEN" 日志
   - 如果是页面路由，记录 "GOING TO ROUTE" 日志

2. **路由报告**：通知 `RouterReportManager` 当前路由已变为新推送的路由

3. **状态更新**：更新 `_routeSend` 对象的状态：
   - **`current`**：如果新路由是 `PageRoute`，设置为新路由的名称
   - **`previous`**：如果前一个路由存在，设置为前一个路由的名称
   - **`args`**：设置为新路由的参数
   - **`route`**：设置为新路由对象
   - **`isBack`**：设置为 `false`，表示这不是返回操作
   - **`removed`**：清空
   - **`isBottomSheet` 和 `isDialog`**：根据新路由的类型更新，如果新路由是底部表单或对话框，设置为 `true`；否则保持原有值

4. **回调通知**：调用 `routing` 回调函数

### didRemove 方法

```dart 111:135:lib/get_navigation/src/routes/observers/route_observer.dart
  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = _extractRouteName(route);
    final currentRoute = _RouteData.ofRoute(route);
    final previousRouteName = _extractRouteName(previousRoute);

    Get.log("REMOVING ROUTE $routeName");
    Get.log("PREVIOUS ROUTE $previousRouteName");

    _routeSend?.update((value) {
      value.route = previousRoute;
      value.isBack = false;
      value.removed = routeName ?? '';
      value.previous = previousRouteName ?? '';
      value.isBottomSheet =
          currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });

    if (route is GetPageRoute) {
      RouterReportManager.instance.reportRouteWillDispose(route);
    }
    routing?.call(_routeSend);
  }
```

当路由从导航栈中被移除时（不是通过返回操作），`didRemove` 方法会被调用。这通常发生在使用 `Get.off()` 或 `Get.offAll()` 等方法时。

**处理逻辑**：

1. **日志记录**：记录被移除的路由名称和前一个路由名称

2. **状态更新**：
   - **`route`**：设置为前一个路由对象
   - **`isBack`**：设置为 `false`（移除操作不是返回操作）
   - **`removed`**：设置为被移除的路由名称
   - **`previous`**：设置为前一个路由的名称
   - **`isBottomSheet` 和 `isDialog`**：如果被移除的路由是底部表单或对话框，则设置为 `false`；否则保持原有值

3. **路由报告**：如果被移除的路由是 `GetPageRoute`，通知 `RouterReportManager` 该路由即将被销毁

4. **回调通知**：调用 `routing` 回调函数

### didReplace 方法

```dart 137:171:lib/get_navigation/src/routes/observers/route_observer.dart
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = _extractRouteName(newRoute);
    final oldName = _extractRouteName(oldRoute);
    final currentRoute = _RouteData.ofRoute(oldRoute);

    Get.log("REPLACE ROUTE $oldName");
    Get.log("NEW ROUTE $newName");

    if (newRoute != null) {
      RouterReportManager.instance.reportCurrentRoute(newRoute);
    }

    _routeSend?.update((value) {
      // Only PageRoute is allowed to change current value
      if (newRoute is PageRoute) {
        value.current = newName ?? '';
      }

      value.args = newRoute?.settings.arguments;
      value.route = newRoute;
      value.isBack = false;
      value.removed = '';
      value.previous = oldName ?? '';
      value.isBottomSheet =
          currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });
    if (oldRoute is GetPageRoute) {
      RouterReportManager.instance.reportRouteWillDispose(oldRoute);
    }

    routing?.call(_routeSend);
  }
```

当路由被替换时（用新路由替换旧路由），`didReplace` 方法会被调用。

**处理逻辑**：

1. **日志记录**：记录被替换的路由名称和新的路由名称

2. **路由报告**：如果新路由不为空，通知 `RouterReportManager` 当前路由已变为新路由

3. **状态更新**：
   - **`current`**：如果新路由是 `PageRoute`，设置为新路由的名称
   - **`args`**：设置为新路由的参数
   - **`route`**：设置为新路由对象
   - **`isBack`**：设置为 `false`
   - **`removed`**：清空（因为这不是移除操作）
   - **`previous`**：设置为旧路由的名称
   - **`isBottomSheet` 和 `isDialog`**：如果旧路由是底部表单或对话框，设置为 `false`；否则保持原有值

4. **路由报告**：如果旧路由是 `GetPageRoute`，通知 `RouterReportManager` 旧路由即将被销毁

5. **回调通知**：调用 `routing` 回调函数

## Routing 类

```dart 174:199:lib/get_navigation/src/routes/observers/route_observer.dart
//TODO: Use copyWith, and remove mutate variables
class Routing {
  String current;
  String previous;
  dynamic args;
  String removed;
  Route<dynamic>? route;
  bool? isBack;
  bool? isBottomSheet;
  bool? isDialog;

  Routing({
    this.current = '',
    this.previous = '',
    this.args,
    this.removed = '',
    this.route,
    this.isBack,
    this.isBottomSheet,
    this.isDialog,
  });

  void update(void Function(Routing value) fn) {
    fn(this);
  }
}
```

`Routing` 类用于存储和传递路由状态信息。代码中有一个 TODO 注释，建议使用 `copyWith` 方法并移除可变变量，以实现不可变对象模式。

### 属性说明

- **`current`**：当前路由的名称，默认为空字符串
- **`previous`**：前一个路由的名称，默认为空字符串
- **`args`**：路由的参数，可以是任意类型
- **`removed`**：被移除的路由名称，默认为空字符串
- **`route`**：当前的路由对象
- **`isBack`**：是否为返回操作（`true` 表示用户按返回键或调用 `Get.back()`）
- **`isBottomSheet`**：当前是否显示底部表单
- **`isDialog`**：当前是否显示对话框

### update 方法

`update` 方法接受一个函数，该函数接收 `Routing` 对象并可以修改其属性。这种模式允许在函数式编程风格中更新对象的状态。

**使用示例**：

```dart
routing.update((value) {
  value.current = '/home';
  value.previous = '/login';
  value.isBack = false;
});
```

## _RouteData 类

```dart 201:223:lib/get_navigation/src/routes/observers/route_observer.dart
/// This is basically a util for rules about 'what a route is'
class _RouteData {
  final bool isGetPageRoute;
  final bool isBottomSheet;
  final bool isDialog;
  final String? name;

  const _RouteData({
    required this.name,
    required this.isGetPageRoute,
    required this.isBottomSheet,
    required this.isDialog,
  });

  factory _RouteData.ofRoute(Route? route) {
    return _RouteData(
      name: _extractRouteName(route),
      isGetPageRoute: route is GetPageRoute,
      isDialog: route is GetDialogRoute,
      isBottomSheet: route is GetModalBottomSheetRoute,
    );
  }
}
```

`_RouteData` 是一个私有工具类，用于封装路由的类型信息。它提供了一种统一的方式来查询路由的类型，而不需要在代码中多次进行类型检查。

### 属性说明

- **`isGetPageRoute`**：是否为 `GetPageRoute` 类型
- **`isBottomSheet`**：是否为 `GetModalBottomSheetRoute` 类型（底部表单）
- **`isDialog`**：是否为 `GetDialogRoute` 类型（对话框）
- **`name`**：路由的名称

### ofRoute 工厂方法

`ofRoute` 是一个工厂方法，接受一个 `Route?` 对象，创建一个 `_RouteData` 实例。它通过类型检查来确定路由的类型，并通过 `_extractRouteName` 函数提取路由名称。

这种设计模式的优点：

1. **封装性**：将路由类型判断逻辑集中在一个地方
2. **可维护性**：如果需要添加新的路由类型判断，只需要修改这一个地方
3. **可读性**：代码中使用 `_RouteData.ofRoute(route)` 比多次类型检查更清晰

## 使用示例

### 基本使用

```dart
MaterialApp(
  navigatorKey: Get.key,
  navigatorObservers: [
    GetObserver(),
  ],
  // ... 其他配置
)
```

### 自定义路由回调

```dart
GetObserver((routing) {
  if (routing != null) {
    print('当前路由: ${routing.current}');
    print('前一个路由: ${routing.previous}');
    print('是否返回操作: ${routing.isBack}');
    print('是否显示对话框: ${routing.isDialog}');
    print('是否显示底部表单: ${routing.isBottomSheet}');
    
    // 根据路由变化执行自定义逻辑
    if (routing.current == '/home') {
      // 用户导航到首页
      analytics.track('navigate_to_home');
    }
  }
})
```

### 在 GetMaterialApp 中使用

当使用 `GetMaterialApp` 时，`GetObserver` 会自动配置。如果需要自定义，可以通过 `routingCallback` 参数传入回调函数：

```dart
GetMaterialApp(
  routingCallback: (routing) {
    // 处理路由变化
    print('路由变化: ${routing?.current}');
  },
  // ... 其他配置
)
```

### 结合 RouterReportManager

`GetObserver` 与 `RouterReportManager` 紧密集成，用于依赖管理和内存管理。当你使用 `GetMaterialApp` 时，这种集成是自动的，无需额外配置。

## 设计模式

### 观察者模式

`GetObserver` 实现了观察者模式，它观察 `Navigator` 的路由变化事件，并在事件发生时执行相应的逻辑。这是 Flutter 导航系统的标准设计模式。

### 状态管理模式

`Routing` 类作为一个状态对象，存储了路由导航的所有相关信息。通过 `update` 方法，可以以函数式的方式更新状态。

### 工厂模式

`_RouteData.ofRoute` 使用了工厂模式，根据输入的路由对象创建相应的 `_RouteData` 实例，隐藏了对象创建的复杂性。

## 注意事项

1. **性能考虑**：`GetObserver` 会在每次路由变化时执行，包括日志记录和回调调用。如果回调函数执行耗时操作，可能会影响导航性能。

2. **内存管理**：`GetObserver` 与 `RouterReportManager` 集成，用于自动管理依赖项的生命周期。在使用 `Get.create()` 创建实例时，这些实例会在路由销毁时自动清理。

3. **路由状态一致性**：`Routing` 对象的状态更新是同步的，在回调函数被调用时，状态已经更新完成。

4. **类型检查**：代码中多处使用了 `is` 操作符进行类型检查，这是 Dart 语言的标准做法，性能开销很小。

5. **TODO 注释**：`Routing` 类有一个 TODO 注释，建议使用不可变对象模式。在未来的版本中，这个类可能会重构为使用 `copyWith` 方法。
