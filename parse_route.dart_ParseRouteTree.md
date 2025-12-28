# ParseRouteTree 类详解

## 概述

`ParseRouteTree` 是 GetX 路由系统中的核心路由树管理类，负责维护路由树结构、匹配路由路径、解析路由参数，以及管理路由的添加和移除。它是路由系统的核心引擎，将扁平化的路由列表组织成树形结构，并支持嵌套路由和参数解析。

## 类定义

```dart 84:89:lib/get_navigation/src/routes/parse_route.dart
class ParseRouteTree {
  ParseRouteTree({
    required this.routes,
  });

  final List<GetPage> routes;
```

### 特性说明

- **`routes`**：存储所有注册的路由页面列表，这是路由树的基础数据源
- **构造函数**：接受必需的路由列表参数，初始化路由树

## 核心方法：路由匹配

### matchRoute 方法

```dart 91:151:lib/get_navigation/src/routes/parse_route.dart
RouteDecoder matchRoute(String name, {PageSettings? arguments}) {
  final uri = Uri.parse(name);
  final split = uri.path.split('/').where((element) => element.isNotEmpty);
  var curPath = '/';
  final cumulativePaths = <String>[
    '/',
  ];
  for (var item in split) {
    if (curPath.endsWith('/')) {
      curPath += item;
    } else {
      curPath += '/$item';
    }
    cumulativePaths.add(curPath);
  }

  final treeBranch = cumulativePaths
      .map((e) => MapEntry(e, _findRoute(e)))
      .where((element) => element.value != null)

      ///Prevent page be disposed
      .map((e) => MapEntry(e.key, e.value!.copyWith(key: ValueKey(e.key))))
      .toList();

  final params = Map<String, String>.from(uri.queryParameters);
  if (treeBranch.isNotEmpty) {
    //route is found, do further parsing to get nested query params
    final lastRoute = treeBranch.last;
    final parsedParams = _parseParams(name, lastRoute.value.path);
    if (parsedParams.isNotEmpty) {
      params.addAll(parsedParams);
    }
    //copy parameters to all pages.
    final mappedTreeBranch = treeBranch
        .map(
          (e) => e.value.copyWith(
            parameters: {
              if (e.value.parameters != null) ...e.value.parameters!,
              ...params,
            },
            name: e.key,
          ),
        )
        .toList();
    arguments?.params.clear();
    arguments?.params.addAll(params);
    return RouteDecoder(
      mappedTreeBranch,
      arguments,
    );
  }

  arguments?.params.clear();
  arguments?.params.addAll(params);

  //route not found
  return RouteDecoder(
    treeBranch.map((e) => e.value).toList(),
    arguments,
  );
}
```

这是路由匹配的核心方法，负责将路由字符串解析为路由树分支。

#### 执行流程详解

**第一步：路径分解和累积路径构建**

```dart 92:105:lib/get_navigation/src/routes/parse_route.dart
final uri = Uri.parse(name);
final split = uri.path.split('/').where((element) => element.isNotEmpty);
var curPath = '/';
final cumulativePaths = <String>[
  '/',
];
for (var item in split) {
  if (curPath.endsWith('/')) {
    curPath += item;
  } else {
    curPath += '/$item';
  }
  cumulativePaths.add(curPath);
}
```

- **解析 URI**：将路由字符串解析为 `Uri` 对象
- **路径分割**：按 `/` 分割路径，过滤掉空字符串
- **累积路径构建**：构建从根路径到完整路径的所有中间路径

**示例**：对于路径 `/user/profile/settings`，会生成：

- `/`
- `/user`
- `/user/profile`
- `/user/profile/settings`

**第二步：路由树分支匹配**

```dart 107:113:lib/get_navigation/src/routes/parse_route.dart
final treeBranch = cumulativePaths
    .map((e) => MapEntry(e, _findRoute(e)))
    .where((element) => element.value != null)

    ///Prevent page be disposed
    .map((e) => MapEntry(e.key, e.value!.copyWith(key: ValueKey(e.key))))
    .toList();
```

- **路由查找**：对每个累积路径调用 `_findRoute` 查找匹配的路由
- **过滤空值**：移除未找到匹配的路由
- **添加 ValueKey**：为每个路由页面添加 `ValueKey`，防止页面被意外销毁（Flutter 的 Widget 生命周期管理需要）

**第三步：参数解析和合并**

```dart 115:122:lib/get_navigation/src/routes/parse_route.dart
final params = Map<String, String>.from(uri.queryParameters);
if (treeBranch.isNotEmpty) {
  //route is found, do further parsing to get nested query params
  final lastRoute = treeBranch.last;
  final parsedParams = _parseParams(name, lastRoute.value.path);
  if (parsedParams.isNotEmpty) {
    params.addAll(parsedParams);
  }
```

- **查询参数提取**：从 URI 中提取查询参数（如 `?id=123&name=test`）
- **路径参数解析**：如果找到匹配的路由，进一步解析路径中的参数（如 `/user/:id` 中的 `:id`）
- **参数合并**：将查询参数和路径参数合并

**第四步：路由树分支映射和参数分发**

```dart 123:140:lib/get_navigation/src/routes/parse_route.dart
//copy parameters to all pages.
final mappedTreeBranch = treeBranch
    .map(
      (e) => e.value.copyWith(
        parameters: {
          if (e.value.parameters != null) ...e.value.parameters!,
          ...params,
        },
        name: e.key,
      ),
    )
    .toList();
arguments?.params.clear();
arguments?.params.addAll(params);
return RouteDecoder(
  mappedTreeBranch,
  arguments,
);
```

- **参数分发**：将解析出的参数复制到路由树分支中的所有页面
- **保留原有参数**：如果页面已有参数，先保留原有参数，再添加新参数
- **更新页面名称**：使用累积路径作为页面名称
- **返回 RouteDecoder**：创建并返回包含完整路由树分支的 `RouteDecoder` 对象

**第五步：路由未找到的处理**

```dart 142:150:lib/get_navigation/src/routes/parse_route.dart
arguments?.params.clear();
arguments?.params.addAll(params);

//route not found
return RouteDecoder(
  treeBranch.map((e) => e.value).toList(),
  arguments,
);
```

如果未找到完整匹配的路由，仍然返回已匹配的部分路由树分支，并包含解析出的参数。

## 路由管理方法

### 添加路由

#### addRoute 方法

```dart 172:179:lib/get_navigation/src/routes/parse_route.dart
void addRoute<T>(GetPage<T> route) {
  routes.add(route);

  // Add Page children.
  for (var page in _flattenPage(route)) {
    addRoute(page);
  }
}
```

**功能**：添加单个路由及其所有子路由到路由树中。

**执行逻辑**：

1. **添加主路由**：将路由添加到 `routes` 列表
2. **扁平化子路由**：调用 `_flattenPage` 获取所有嵌套子路由
3. **递归添加**：递归调用 `addRoute` 添加所有子路由

#### addRoutes 方法

```dart 153:157:lib/get_navigation/src/routes/parse_route.dart
void addRoutes<T>(List<GetPage<T>> getPages) {
  for (final route in getPages) {
    addRoute(route);
  }
}
```

**功能**：批量添加多个路由，内部循环调用 `addRoute`。

### 移除路由

#### removeRoute 方法

```dart 165:170:lib/get_navigation/src/routes/parse_route.dart
void removeRoute<T>(GetPage<T> route) {
  routes.remove(route);
  for (var page in _flattenPage(route)) {
    removeRoute(page);
  }
}
```

**功能**：移除单个路由及其所有子路由。

**执行逻辑**：

1. **移除主路由**：从 `routes` 列表中移除路由
2. **获取子路由**：调用 `_flattenPage` 获取所有嵌套子路由
3. **递归移除**：递归调用 `removeRoute` 移除所有子路由

#### removeRoutes 方法

```dart 159:163:lib/get_navigation/src/routes/parse_route.dart
void removeRoutes<T>(List<GetPage<T>> getPages) {
  for (final route in getPages) {
    removeRoute(route);
  }
}
```

**功能**：批量移除多个路由，内部循环调用 `removeRoute`。

## 路由树扁平化

### _flattenPage 方法

```dart 181:238:lib/get_navigation/src/routes/parse_route.dart
List<GetPage> _flattenPage(GetPage route) {
  final result = <GetPage>[];
  if (route.children.isEmpty) {
    return result;
  }

  final parentPath = route.name;
  for (var page in route.children) {
    // Add Parent middlewares to children
    final parentMiddlewares = [
      if (page.middlewares.isNotEmpty) ...page.middlewares,
      if (route.middlewares.isNotEmpty) ...route.middlewares
    ];

    final parentBindings = [
      if (page.binding != null) page.binding!,
      if (page.bindings.isNotEmpty) ...page.bindings,
      if (route.bindings.isNotEmpty) ...route.bindings
    ];

    final parentBinds = [
      if (page.binds.isNotEmpty) ...page.binds,
      if (route.binds.isNotEmpty) ...route.binds
    ];

    result.add(
      _addChild(
        page,
        parentPath,
        parentMiddlewares,
        parentBindings,
        parentBinds,
      ),
    );

    final children = _flattenPage(page);
    for (var child in children) {
      result.add(_addChild(
        child,
        parentPath,
        [
          ...parentMiddlewares,
          if (child.middlewares.isNotEmpty) ...child.middlewares,
        ],
        [
          ...parentBindings,
          if (child.binding != null) child.binding!,
          if (child.bindings.isNotEmpty) ...child.bindings,
        ],
        [
          ...parentBinds,
          if (child.binds.isNotEmpty) ...child.binds,
        ],
      ));
    }
  }
  return result;
}
```

**功能**：将嵌套的路由树结构扁平化为列表，同时继承父路由的中间件、绑定等配置。

#### 执行流程

**第一步：基础检查**

```dart 182:185:lib/get_navigation/src/routes/parse_route.dart
final result = <GetPage>[];
if (route.children.isEmpty) {
  return result;
}
```

如果路由没有子路由，直接返回空列表。

**第二步：处理直接子路由**

```dart 187:214:lib/get_navigation/src/routes/parse_route.dart
final parentPath = route.name;
for (var page in route.children) {
  // Add Parent middlewares to children
  final parentMiddlewares = [
    if (page.middlewares.isNotEmpty) ...page.middlewares,
    if (route.middlewares.isNotEmpty) ...route.middlewares
  ];

  final parentBindings = [
    if (page.binding != null) page.binding!,
    if (page.bindings.isNotEmpty) ...page.bindings,
    if (route.bindings.isNotEmpty) ...route.bindings
  ];

  final parentBinds = [
    if (page.binds.isNotEmpty) ...page.binds,
    if (route.binds.isNotEmpty) ...route.binds
  ];

  result.add(
    _addChild(
      page,
      parentPath,
      parentMiddlewares,
      parentBindings,
      parentBinds,
    ),
  );
```

对每个直接子路由：

- **合并中间件**：将子路由和父路由的中间件合并（子路由的中间件在前）
- **合并绑定**：将子路由和父路由的绑定合并
- **合并 Binds**：将子路由和父路由的 Binds 合并
- **创建子路由副本**：调用 `_addChild` 创建配置好的子路由副本

**第三步：递归处理嵌套子路由**

```dart 216:235:lib/get_navigation/src/routes/parse_route.dart
final children = _flattenPage(page);
for (var child in children) {
  result.add(_addChild(
    child,
    parentPath,
    [
      ...parentMiddlewares,
      if (child.middlewares.isNotEmpty) ...child.middlewares,
    ],
    [
      ...parentBindings,
      if (child.binding != null) child.binding!,
      if (child.bindings.isNotEmpty) ...child.bindings,
    ],
    [
      ...parentBinds,
      if (child.binds.isNotEmpty) ...child.binds,
    ],
  ));
}
```

递归处理更深层的嵌套子路由，将父路由的配置继续向下传递。

**设计要点**：

- **配置继承**：子路由自动继承父路由的中间件、绑定等配置
- **配置合并**：子路由的配置优先，父路由的配置作为补充
- **路径继承**：根据 `inheritParentPath` 决定是否继承父路径

## 子路由处理

### _addChild 方法

```dart 240:257:lib/get_navigation/src/routes/parse_route.dart
/// Change the Path for a [GetPage]
GetPage _addChild(
  GetPage origin,
  String parentPath,
  List<GetMiddleware> middlewares,
  List<BindingsInterface> bindings,
  List<Bind> binds,
) {
  return origin.copyWith(
    middlewares: middlewares,
    name: origin.inheritParentPath
        ? (parentPath + origin.name).replaceAll(r'//', '/')
        : origin.name,
    bindings: bindings,
    binds: binds,
    // key:
  );
}
```

**功能**：创建子路由的副本，应用父路径和配置。

**参数说明**：

- **`origin`**：原始子路由页面
- **`parentPath`**：父路由的路径
- **`middlewares`**：合并后的中间件列表
- **`bindings`**：合并后的绑定列表
- **`binds`**：合并后的 Binds 列表

**路径处理逻辑**：

```dart 250:252:lib/get_navigation/src/routes/parse_route.dart
name: origin.inheritParentPath
    ? (parentPath + origin.name).replaceAll(r'//', '/')
    : origin.name,
```

- 如果 `inheritParentPath` 为 `true`，将父路径和子路径拼接，并清理重复的 `/`
- 如果为 `false`，保持子路由的原始路径

**示例**：

- 父路径：`/user`
- 子路径：`/profile`
- 结果：`/user/profile`

## 路由查找

### _findRoute 方法

```dart 259:265:lib/get_navigation/src/routes/parse_route.dart
GetPage? _findRoute(String name) {
  final value = routes.firstWhereOrNull(
    (route) => route.path.regex.hasMatch(name),
  );

  return value;
}
```

**功能**：在路由列表中查找匹配指定路径的路由。

**匹配逻辑**：

- 使用 `firstWhereOrNull` 扩展方法查找第一个匹配的路由
- 通过 `route.path.regex.hasMatch(name)` 使用正则表达式匹配路径
- 如果找到匹配的路由，返回该路由；否则返回 `null`

**注意**：`firstWhereOrNull` 是文件末尾定义的扩展方法，用于在列表中查找第一个满足条件的元素。

## 参数解析

### _parseParams 方法

```dart 267:284:lib/get_navigation/src/routes/parse_route.dart
Map<String, String> _parseParams(String path, PathDecoded routePath) {
  final params = <String, String>{};
  var idx = path.indexOf('?');
  final uri = Uri.tryParse(path);
  if (uri == null) return params;
  if (idx > -1) {
    params.addAll(uri.queryParameters);
  }
  var paramsMatch = routePath.regex.firstMatch(uri.path);
  if (paramsMatch == null) {
    return params;
  }
  for (var i = 0; i < routePath.keys.length; i++) {
    var param = Uri.decodeQueryComponent(paramsMatch[i + 1]!);
    params[routePath.keys[i]!] = param;
  }
  return params;
}
```

**功能**：从路径字符串中解析出路径参数和查询参数。

#### 执行流程

**第一步：初始化并解析 URI**

```dart 268:271:lib/get_navigation/src/routes/parse_route.dart
final params = <String, String>{};
var idx = path.indexOf('?');
final uri = Uri.tryParse(path);
if (uri == null) return params;
```

- 初始化参数映射
- 查找查询字符串的位置（`?`）
- 尝试解析 URI，如果失败则返回空映射

**第二步：提取查询参数**

```dart 272:274:lib/get_navigation/src/routes/parse_route.dart
if (idx > -1) {
  params.addAll(uri.queryParameters);
}
```

如果路径包含查询字符串（`?`），提取所有查询参数（如 `?id=123&name=test`）。

**第三步：匹配路径参数**

```dart 275:278:lib/get_navigation/src/routes/parse_route.dart
var paramsMatch = routePath.regex.firstMatch(uri.path);
if (paramsMatch == null) {
  return params;
}
```

使用路由路径的正则表达式匹配 URI 路径，如果匹配失败则返回已提取的查询参数。

**第四步：提取路径参数**

```dart 279:282:lib/get_navigation/src/routes/parse_route.dart
for (var i = 0; i < routePath.keys.length; i++) {
  var param = Uri.decodeQueryComponent(paramsMatch[i + 1]!);
  params[routePath.keys[i]!] = param;
}
```

- 遍历路由路径中定义的参数键（如 `/user/:id` 中的 `id`）
- 从正则匹配结果中提取对应的参数值（`paramsMatch[i + 1]` 是因为第一个匹配组是整个路径）
- 使用 `Uri.decodeQueryComponent` 解码参数值（处理 URL 编码）
- 将参数键值对添加到参数映射中

**示例**：

- 路由路径：`/user/:id/profile/:tab`
- 实际路径：`/user/123/profile/settings`
- 解析结果：`{'id': '123', 'tab': 'settings'}`

## 设计模式与架构

### 树形结构管理

`ParseRouteTree` 使用树形结构管理路由，支持：

- **嵌套路由**：路由可以包含子路由，形成树形结构
- **路径继承**：子路由可以选择继承父路由的路径
- **配置继承**：子路由自动继承父路由的中间件、绑定等配置

### 扁平化处理

通过 `_flattenPage` 方法将树形结构扁平化，使得：

- **统一管理**：所有路由（包括嵌套路由）都在一个列表中管理
- **快速查找**：扁平化后可以快速查找和匹配路由
- **配置传播**：在扁平化过程中自动传播父路由的配置

### 参数解析策略

参数解析支持两种类型：

1. **查询参数**：通过 URI 的 `queryParameters` 提取（如 `?id=123`）
2. **路径参数**：通过正则表达式匹配提取（如 `/user/:id` 中的 `:id`）

两种参数会被合并到同一个参数映射中。

## 使用场景

`ParseRouteTree` 在 GetX 路由系统中主要用于：

1. **路由注册**：管理应用的所有路由页面
2. **路由匹配**：根据路径字符串匹配对应的路由页面
3. **参数提取**：从路径中提取参数并传递给页面
4. **嵌套路由支持**：支持多层次的嵌套路由结构
5. **配置管理**：管理路由的中间件、绑定等配置

## 注意事项

1. **路由树扁平化**：添加路由时会自动扁平化所有子路由，确保所有路由都在 `routes` 列表中
2. **配置继承顺序**：子路由的配置优先于父路由的配置
3. **路径拼接**：路径拼接时会自动清理重复的 `/`，避免路径错误
4. **参数解码**：路径参数会使用 `Uri.decodeQueryComponent` 进行解码，支持 URL 编码的参数
5. **ValueKey 设置**：匹配路由时会为每个页面设置 `ValueKey`，防止 Flutter 误销毁页面
