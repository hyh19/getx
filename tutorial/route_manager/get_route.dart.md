# GetPage 类详解

## 概述

`GetPage` 是 GetX 路由系统的核心类，它扩展了 Flutter 的 `Page<T>` 类，为 GetX 提供了强大的路由配置能力。作为 GetX 导航系统的基础，`GetPage` 不仅定义了路由的基本信息（如名称、页面构建器、参数等），还集成了中间件、绑定系统、过渡动画等高级功能。

### 与 Flutter Page 的关系

```dart 13:13:lib/get_navigation/src/routes/get_route.dart
class GetPage<T> extends Page<T> {
```

`GetPage` 继承自 Flutter 的 `Page<T>` 类，这意味着它可以无缝集成到 Flutter 的导航系统中。`Page` 类是 Flutter 声明式导航 API 的核心组件，`GetPage` 在此基础上添加了 GetX 特有的功能，如中间件、绑定、自定义过渡动画等。

### 在 GetX 路由系统中的地位

`GetPage` 在 GetX 路由系统中扮演着路由配置单元的角色。当你使用 `GetMaterialApp` 或 `GetRouterDelegate` 配置路由时，每个路由都是通过 `GetPage` 实例来定义的。`GetPage` 不仅存储了路由的配置信息，还负责在需要时创建实际的 `Route` 对象（通过 `createRoute` 方法）。

## GetPage 类详解

### 类定义和继承关系

```dart 13:14:lib/get_navigation/src/routes/get_route.dart
class GetPage<T> extends Page<T> {
  final GetPageBuilder page;
```

- **泛型参数 `T`**：表示该页面路由返回值的类型。例如，如果页面需要返回一个字符串结果，可以使用 `GetPage<String>`。

### 核心属性详解

#### 路由基本信息

##### `name`

```dart 43:44:lib/get_navigation/src/routes/get_route.dart
  @override
  final String name;
```

路由的唯一标识符，必须以 `/` 开头。这是路由匹配的基础，用于通过 `Get.toNamed('/route-name')` 等方式进行导航。

##### `arguments`

```dart 40:41:lib/get_navigation/src/routes/get_route.dart
  @override
  final Object? arguments;
```

传递给路由的任意类型参数。可以通过 `Get.arguments` 在目标页面中访问这些参数。

##### `title`

```dart 17:17:lib/get_navigation/src/routes/get_route.dart
  final String? title;
```

页面的标题，通常用于浏览器的标题栏或应用栏。

##### `path`

```dart 50:50:lib/get_navigation/src/routes/get_route.dart
  final PathDecoded path;
```

路由路径的解析结果，包含用于匹配 URL 的正则表达式和动态参数的键列表。这个属性在构造函数中通过 `_nameToRegex` 方法自动生成。

#### 页面构建

##### `page`

```dart 14:14:lib/get_navigation/src/routes/get_route.dart
  final GetPageBuilder page;
```

页面构建器函数，返回要显示的 Widget。`GetPageBuilder` 定义为 `typedef GetPageBuilder = Widget Function()`，是一个无参数的函数，返回一个 Widget。

##### `children`

```dart 48:48:lib/get_navigation/src/routes/get_route.dart
  final List<GetPage> children;
```

子路由列表，支持嵌套路由结构。子路由会自动继承父路由的路径前缀，这使得路由配置更加模块化和易于维护。

##### `inheritParentPath`

```dart 46:46:lib/get_navigation/src/routes/get_route.dart
  final bool inheritParentPath;
```

指示子路由是否继承父路由的路径。默认为 `true`，当设置为 `true` 时，子路由的完整路径将是父路径加上子路径。

#### 中间件和绑定

##### `middlewares`

```dart 49:49:lib/get_navigation/src/routes/get_route.dart
  final List<GetMiddleware> middlewares;
```

中间件列表，用于在路由导航的各个阶段执行自定义逻辑（如权限检查、日志记录、重定向等）。中间件按照优先级顺序执行。

##### `binding` 和 `bindings`

```dart 25:26:lib/get_navigation/src/routes/get_route.dart
  final BindingsInterface? binding;
  final List<BindingsInterface> bindings;
```

用于依赖注入的绑定对象。`binding` 是单个绑定，`bindings` 是绑定列表。如果同时提供了 `binding` 和 `bindings`，它们会被合并。绑定在页面构建前初始化，确保页面需要的依赖已经准备好。

##### `binds`

```dart 27:27:lib/get_navigation/src/routes/get_route.dart
  final List<Bind> binds;
```

`Bind` 对象的列表，用于在页面中直接绑定控制器。`Bind` 是一个特殊的 Widget，用于简化控制器的绑定过程。

#### 过渡动画

##### `transition`

```dart 18:18:lib/get_navigation/src/routes/get_route.dart
  final Transition? transition;
```

页面过渡动画的类型，支持多种预定义的动画效果，如淡入淡出、左右滑动、上下滑动、缩放等。如果不指定，将使用默认的过渡动画。

##### `customTransition`

```dart 28:28:lib/get_navigation/src/routes/get_route.dart
  final CustomTransition? customTransition;
```

自定义过渡动画对象，允许完全自定义页面切换动画。当提供了 `customTransition` 时，它会优先于 `transition` 使用。

##### `transitionDuration` 和 `reverseTransitionDuration`

```dart 29:30:lib/get_navigation/src/routes/get_route.dart
  final Duration? transitionDuration;
  final Duration? reverseTransitionDuration;
```

过渡动画的时长。`transitionDuration` 用于进入动画，`reverseTransitionDuration` 用于退出动画。如果不指定，将使用全局默认值。

##### `curve`

```dart 19:19:lib/get_navigation/src/routes/get_route.dart
  final Curve curve;
```

动画曲线，控制动画的速度变化。默认为 `Curves.linear`（线性动画）。

#### UI 配置

##### `opaque`

```dart 23:23:lib/get_navigation/src/routes/get_route.dart
  final bool opaque;
```

指示页面是否不透明。如果为 `true`，页面将完全覆盖下层内容；如果为 `false`，下层内容可能透过页面显示。默认为 `true`。

##### `maintainState`

```dart 22:22:lib/get_navigation/src/routes/get_route.dart
  final bool maintainState;
```

指示当页面不可见时是否保持其状态。如果为 `true`，页面的状态（包括 ScrollController 等）会被保留；如果为 `false`，页面每次都会重新构建。默认为 `true`。

##### `fullscreenDialog`

```dart 31:31:lib/get_navigation/src/routes/get_route.dart
  final bool fullscreenDialog;
```

指示页面是否以全屏对话框的形式显示。在 iOS 上，这会改变页面转场动画的样式。默认为 `false`。

##### `alignment`

```dart 21:21:lib/get_navigation/src/routes/get_route.dart
  final Alignment? alignment;
```

页面在屏幕上的对齐方式，用于控制过渡动画的起始位置。

##### `showCupertinoParallax`

```dart 52:52:lib/get_navigation/src/routes/get_route.dart
  final bool showCupertinoParallax;
```

是否在 iOS 上显示视差效果。这个效果会在页面切换时产生深度感。默认为 `true`。

#### 手势和导航

##### `popGesture`

```dart 15:15:lib/get_navigation/src/routes/get_route.dart
  final bool? popGesture;
```

是否启用返回手势（在 iOS 上为从左侧边缘滑动返回）。`null` 表示使用全局默认值。

##### `gestureWidth`

```dart 24:24:lib/get_navigation/src/routes/get_route.dart
  final double Function(BuildContext context)? gestureWidth;
```

返回手势的触发宽度函数。可以动态计算在不同设备上的手势触发区域。

##### `participatesInRootNavigator`

```dart 20:20:lib/get_navigation/src/routes/get_route.dart
  final bool? participatesInRootNavigator;
```

指示页面是否参与根导航器。这会影响对话框和 SnackBar 的显示位置。

##### `preventDuplicates`

```dart 32:32:lib/get_navigation/src/routes/get_route.dart
  final bool preventDuplicates;
```

是否防止重复路由。如果为 `true`，当尝试导航到已存在的路由时，系统会根据 `preventDuplicateHandlingMode` 采取相应的处理策略。默认为 `true`。

##### `preventDuplicateHandlingMode`

```dart 54:54:lib/get_navigation/src/routes/get_route.dart
  final PreventDuplicateHandlingMode preventDuplicateHandlingMode;
```

处理重复路由的策略模式，包括：

- `reorderRoutes`：将现有路由移到栈顶（推荐）
- `popUntilOriginalRoute`：弹出路由直到找到原始路由
- `doNothing`：不做任何操作
- `recreate`：重新创建路由

默认为 `reorderRoutes`。

##### `completer`

```dart 33:33:lib/get_navigation/src/routes/get_route.dart
  final Completer<T?>? completer;
```

用于异步等待页面返回结果的 `Completer` 对象。当页面被关闭时，可以通过 `Navigator.pop(context, result)` 返回结果。

#### 参数和未知路由

##### `parameters`

```dart 16:16:lib/get_navigation/src/routes/get_route.dart
  final Map<String, String>? parameters;
```

URL 参数的映射表。例如，对于路由 `/user/:id`，如果 URL 是 `/user/123`，则 `parameters` 可能包含 `{'id': '123'}`。

##### `unknownRoute`

```dart 51:51:lib/get_navigation/src/routes/get_route.dart
  final GetPage? unknownRoute;
```

当路由匹配失败时使用的备用路由。这通常用于实现 404 页面。

### 构造函数

```dart 58:100:lib/get_navigation/src/routes/get_route.dart
  GetPage({
    required this.name,
    required this.page,
    this.title,
    this.participatesInRootNavigator,
    this.gestureWidth,
    // RouteSettings settings,
    this.maintainState = true,
    this.curve = Curves.linear,
    this.alignment,
    this.parameters,
    this.opaque = true,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.popGesture,
    this.binding,
    this.bindings = const [],
    this.binds = const [],
    this.transition,
    this.customTransition,
    this.fullscreenDialog = false,
    this.children = const <GetPage>[],
    this.middlewares = const [],
    this.unknownRoute,
    this.arguments,
    this.showCupertinoParallax = true,
    this.preventDuplicates = true,
    this.preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
    this.completer,
    this.inheritParentPath = true,
    LocalKey? key,
    super.canPop,
    super.onPopInvoked = _defaultPopInvokedHandler,
    super.restorationId,
  })  : path = _nameToRegex(name),
        assert(name.startsWith('/'),
            'It is necessary to start route name [$name] with a slash: /$name'),
        super(
          key: key ?? ValueKey(name),
          name: name,
          // arguments: Get.arguments,
        );
```

构造函数的关键特性：

1. **必需参数**：
   - `name`：路由名称，必须以 `/` 开头
   - `page`：页面构建器函数

2. **初始化列表**：
   - `path = _nameToRegex(name)`：将路由名称转换为正则表达式，用于路径匹配
   - `assert(name.startsWith('/'), ...)`：断言路由名称必须以 `/` 开头

3. **父类初始化**：
   - `key`：如果没有提供 key，则使用 `ValueKey(name)`
   - `name`：传递给父类 `Page` 的 `name` 参数

4. **默认值**：
   - 大多数属性都有合理的默认值，使得简单场景下的使用更加便捷

### copyWith 方法

```dart 103:173:lib/get_navigation/src/routes/get_route.dart
  GetPage<T> copyWith({
    LocalKey? key,
    String? name,
    GetPageBuilder? page,
    bool? popGesture,
    Map<String, String>? parameters,
    String? title,
    Transition? transition,
    Curve? curve,
    Alignment? alignment,
    bool? maintainState,
    bool? opaque,
    List<BindingsInterface>? bindings,
    BindingsInterface? binding,
    List<Bind>? binds,
    CustomTransition? customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool? fullscreenDialog,
    RouteSettings? settings,
    List<GetPage<T>>? children,
    GetPage? unknownRoute,
    List<GetMiddleware>? middlewares,
    bool? preventDuplicates,
    final double Function(BuildContext context)? gestureWidth,
    bool? participatesInRootNavigator,
    Object? arguments,
    bool? showCupertinoParallax,
    Completer<T?>? completer,
    bool? inheritParentPath,
    bool? canPop,
    PopInvokedWithResultCallback<T>? onPopInvoked,
    String? restorationId,
  }) {
    return GetPage(
      key: key ?? this.key,
      participatesInRootNavigator:
          participatesInRootNavigator ?? this.participatesInRootNavigator,
      preventDuplicates: preventDuplicates ?? this.preventDuplicates,
      name: name ?? this.name,
      page: page ?? this.page,
      popGesture: popGesture ?? this.popGesture,
      parameters: parameters ?? this.parameters,
      title: title ?? this.title,
      transition: transition ?? this.transition,
      curve: curve ?? this.curve,
      alignment: alignment ?? this.alignment,
      maintainState: maintainState ?? this.maintainState,
      opaque: opaque ?? this.opaque,
      bindings: bindings ?? this.bindings,
      binds: binds ?? this.binds,
      binding: binding ?? this.binding,
      customTransition: customTransition ?? this.customTransition,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      reverseTransitionDuration:
          reverseTransitionDuration ?? this.reverseTransitionDuration,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      children: children ?? this.children,
      unknownRoute: unknownRoute ?? this.unknownRoute,
      middlewares: middlewares ?? this.middlewares,
      gestureWidth: gestureWidth ?? this.gestureWidth,
      arguments: arguments ?? this.arguments,
      showCupertinoParallax:
          showCupertinoParallax ?? this.showCupertinoParallax,
      completer: completer ?? this.completer,
      inheritParentPath: inheritParentPath ?? this.inheritParentPath,
      canPop: canPop ?? this.canPop,
      onPopInvoked: onPopInvoked ?? this.onPopInvoked,
      restorationId: restorationId ?? restorationId,
    );
  }
```

`copyWith` 方法实现了不可变对象的复制模式。它创建一个新的 `GetPage` 实例，其中指定的属性被新值替换，未指定的属性保持原值。这种模式使得在需要修改部分属性时，可以方便地创建新的实例，而不需要重新构建整个对象。

### createRoute 方法

```dart 175:185:lib/get_navigation/src/routes/get_route.dart
  @override
  Route<T> createRoute(BuildContext context) {
    // return GetPageRoute<T>(settings: this, page: page);
    final page = PageRedirect(
      route: this,
      settings: this,
      unknownRoute: unknownRoute,
    ).getPageToRoute<T>(this, unknownRoute, context);

    return page;
  }
```

`createRoute` 方法是 `Page` 类的抽象方法，用于将 `Page` 对象转换为实际的 `Route` 对象。在 GetX 的实现中：

1. 创建一个 `PageRedirect` 对象来处理重定向逻辑
2. 调用 `getPageToRoute` 方法将 `GetPage` 转换为 `GetPageRoute`
3. `PageRedirect` 会处理中间件的重定向逻辑，可能会多次循环直到没有重定向需要执行
4. 最终返回一个 `GetPageRoute<T>` 实例，这是实际的 `Route` 对象

### _nameToRegex 静态方法

```dart 187:206:lib/get_navigation/src/routes/get_route.dart
  static PathDecoded _nameToRegex(String path) {
    var keys = <String?>[];

    String recursiveReplace(Match pattern) {
      var buffer = StringBuffer('(?:');

      if (pattern[1] != null) buffer.write('.');
      buffer.write('([\\w%+-._~!\$&\'()*,;=:@]+))');
      if (pattern[3] != null) buffer.write('?');

      keys.add(pattern[2]);
      return "$buffer";
    }

    var stringPath = '$path/?'
        .replaceAllMapped(RegExp(r'(\.)?:(\w+)(\?)?'), recursiveReplace)
        .replaceAll('//', '/');

    return PathDecoded(RegExp('^$stringPath\$'), keys);
  }
```

这个静态方法将路由路径字符串转换为正则表达式，用于匹配 URL。它支持动态参数：

1. **动态参数语法**：
   - `:param`：必需的动态参数
   - `:param?`：可选的动态参数
   - `.param`：匹配任意字符的参数

2. **处理流程**：
   - 使用正则表达式 `(\.)?:(\w+)(\?)?` 匹配动态参数
   - 对于每个匹配的参数，提取参数名并添加到 `keys` 列表中
   - 将参数占位符替换为正则表达式模式
   - 处理可选参数（添加 `?` 后缀）
   - 清理路径中的双斜杠
   - 在路径前后添加 `^` 和 `$` 确保完全匹配

3. **示例**：
   - `/user/:id` → 正则表达式匹配 `/user/123`，参数 `id` = `"123"`
   - `/user/:id?` → 正则表达式匹配 `/user` 或 `/user/123`
   - `/user/:id/posts` → 正则表达式匹配 `/user/123/posts`

### 操作符重载

#### `==` 运算符

```dart 208:212:lib/get_navigation/src/routes/get_route.dart
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetPage<T> && other.key == key;
  }
```

两个 `GetPage` 实例相等当且仅当它们的 `key` 相等。这用于在路由栈中识别相同的路由。

#### `hashCode`

```dart 218:221:lib/get_navigation/src/routes/get_route.dart
  @override
  int get hashCode {
    return key.hashCode;
  }
```

哈希码基于 `key` 计算，与 `==` 运算符保持一致。

#### `toString`

```dart 214:216:lib/get_navigation/src/routes/get_route.dart
  @override
  String toString() =>
      '${objectRuntimeType(this, 'Page')}("$name", $key, $arguments)';
```

返回调试友好的字符串表示，包含类名、路由名称、key 和参数。

## PathDecoded 类详解

```dart 224:240:lib/get_navigation/src/routes/get_route.dart
@immutable
class PathDecoded {
  final RegExp regex;
  final List<String?> keys;
  const PathDecoded(this.regex, this.keys);

  @override
  int get hashCode => regex.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PathDecoded &&
        other.regex == regex; // && listEquals(other.keys, keys);
  }
}
```

`PathDecoded` 是一个不可变类，用于存储路由路径的解析结果：

- **`regex`**：用于匹配 URL 的正则表达式
- **`keys`**：动态参数的名称列表，顺序与正则表达式中的捕获组对应

该类实现了 `==` 运算符和 `hashCode`，使得相同的路径解析结果可以被识别为相等（基于正则表达式比较）。

## 使用示例

### 基本用法

```dart
GetPage(
  name: '/home',
  page: () => HomePage(),
)
```

### 带参数的路由

```dart
GetPage(
  name: '/user/:id',
  page: () => UserDetailPage(),
  binding: UserBinding(),
)
```

### 嵌套路由

```dart
GetPage(
  name: '/home',
  page: () => HomePage(),
  children: [
    GetPage(
      name: '/products',
      page: () => ProductsPage(),
      children: [
        GetPage(
          name: '/electronics',
          page: () => ElectronicsPage(),
        ),
      ],
    ),
  ],
)
```

当访问 `/home/products/electronics` 时，会直接导航到 `ElectronicsPage`，因为子路由自动继承了父路由的路径。

### 使用中间件

```dart
GetPage(
  name: '/profile',
  page: () => ProfilePage(),
  middlewares: [
    AuthMiddleware(), // 检查用户是否已登录
    LogMiddleware(),  // 记录访问日志
  ],
)
```

### 自定义过渡动画

```dart
GetPage(
  name: '/detail',
  page: () => DetailPage(),
  transition: Transition.zoom,
  transitionDuration: Duration(milliseconds: 400),
  curve: Curves.easeInOut,
)
```

## 设计模式和最佳实践

### 不可变对象模式

`GetPage` 的所有属性都是 `final` 的，这使得 `GetPage` 实例是不可变的。这种设计带来了以下好处：

1. **线程安全**：不可变对象天然线程安全
2. **可预测性**：对象状态不会在创建后改变
3. **易于缓存**：相同配置的路由可以安全地重用

当需要修改路由配置时，使用 `copyWith` 方法创建新实例。

### 建造者模式

`copyWith` 方法实现了类似建造者模式的模式，允许通过链式调用逐步构建对象：

```dart
final page = GetPage(
  name: '/home',
  page: () => HomePage(),
).copyWith(
  title: '首页',
  transition: Transition.fadeIn,
);
```

### 路由匹配机制

`GetPage` 使用正则表达式进行路由匹配，这提供了强大的灵活性：

1. **动态参数**：支持必需的 (`:param`) 和可选的 (`:param?`) 参数
2. **精确匹配**：使用 `^` 和 `$` 确保完全匹配，避免部分匹配
3. **参数提取**：通过捕获组提取参数值，并按照定义的顺序存储在 `keys` 列表中

### 与中间件的集成

`GetPage` 通过 `middlewares` 属性集成了中间件系统。中间件在路由创建和执行的不同阶段被调用，包括：

- 路由重定向检查
- 页面调用前的处理
- 绑定初始化
- 页面构建
- 页面销毁

这种设计使得路由系统具有高度的可扩展性。
