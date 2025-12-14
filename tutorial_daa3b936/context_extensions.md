# Context Extensions 代码讲解

## 概述

`context_extensions.dart` 文件为 Flutter 的 `BuildContext` 提供了丰富的扩展方法，简化了媒体查询、主题访问、设备类型判断和响应式设计等常见操作。这些扩展方法让开发者能够更简洁、更直观地编写响应式 Flutter 应用。

### 主要功能

1. **媒体查询简化**：提供便捷的属性访问屏幕尺寸、内边距等信息
2. **尺寸转换工具**：支持灵活的屏幕尺寸计算和转换
3. **主题访问**：简化主题数据的访问和暗色模式检测
4. **设备类型判断**：快速判断设备类型（手机、平板、桌面等）
5. **响应式值选择**：根据屏幕尺寸自动选择合适的值

## 文件结构

该文件包含两个扩展：

- `ContextExt` - 为 `BuildContext` 提供扩展方法
- `IterableExt` - 为 `Iterable<T>` 提供扩展方法（辅助扩展）

## ContextExt 扩展详解

### 媒体查询基础属性

#### mediaQuerySize

获取屏幕尺寸信息。

```dart 4:5:lib/get_utils/src/extensions/context_extensions.dart
extension ContextExt on BuildContext {
  /// The same of [MediaQuery.sizeOf(context)]
  Size get mediaQuerySize => MediaQuery.sizeOf(this);
```

**说明**：等同于 `MediaQuery.sizeOf(context)`，返回屏幕的 `Size` 对象，包含 `width` 和 `height` 属性。

**使用示例**：

```dart
final size = context.mediaQuerySize;
print('屏幕宽度: ${size.width}, 屏幕高度: ${size.height}');
```

#### height

获取屏幕高度。

```dart 7:10:lib/get_utils/src/extensions/context_extensions.dart
  /// The same of [MediaQuery.of(context).size.height]
  /// Note: updates when you resize your screen (like on a browser or
  /// desktop window)
  double get height => mediaQuerySize.height;
```

**说明**：等同于 `MediaQuery.of(context).size.height`。注意：当屏幕尺寸改变时（如浏览器窗口或桌面窗口调整大小），该值会自动更新。

**使用示例**：

```dart
Container(
  height: context.height * 0.5, // 屏幕高度的 50%
  child: YourWidget(),
)
```

#### width

获取屏幕宽度。

```dart 12:15:lib/get_utils/src/extensions/context_extensions.dart
  /// The same of [MediaQuery.of(context).size.width]
  /// Note: updates when you resize your screen (like on a browser or
  /// desktop window)
  double get width => mediaQuerySize.width;
```

**说明**：等同于 `MediaQuery.of(context).size.width`。注意：当屏幕尺寸改变时，该值会自动更新。

**使用示例**：

```dart
Container(
  width: context.width * 0.8, // 屏幕宽度的 80%
  child: YourWidget(),
)
```

#### mediaQueryPadding

获取系统内边距（如状态栏、刘海屏等占用的空间）。

```dart 68:69:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.paddingOf(context)]
  EdgeInsets get mediaQueryPadding => MediaQuery.paddingOf(this);
```

**说明**：等同于 `MediaQuery.paddingOf(context)`，返回系统的内边距信息。

**使用示例**：

```dart
Padding(
  padding: context.mediaQueryPadding,
  child: YourWidget(),
)
```

#### mediaQueryViewPadding

获取视图内边距。

```dart 74:75:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.viewPaddingOf(context)]
  EdgeInsets get mediaQueryViewPadding => MediaQuery.viewPaddingOf(this);
```

**说明**：等同于 `MediaQuery.viewPaddingOf(context)`，返回视图的内边距信息。

#### mediaQueryViewInsets

获取视图插入（如键盘弹出时占用的空间）。

```dart 77:78:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.viewInsetsOf(context)]
  EdgeInsets get mediaQueryViewInsets => MediaQuery.viewInsetsOf(this);
```

**说明**：等同于 `MediaQuery.viewInsetsOf(context)`，常用于处理键盘弹出时的布局调整。

**使用示例**：

```dart
final viewInsets = context.mediaQueryViewInsets;
if (viewInsets.bottom > 0) {
  // 键盘已弹出
  return Padding(
    padding: EdgeInsets.only(bottom: viewInsets.bottom),
    child: YourWidget(),
  );
}
```

#### mediaQuery

获取完整的 `MediaQueryData` 对象。

```dart 71:72:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.of(context).padding]
  MediaQueryData get mediaQuery => MediaQuery.of(this);
```

**说明**：等同于 `MediaQuery.of(context)`，返回完整的媒体查询数据对象。

#### mediaQueryShortestSide

获取屏幕最短边长度。

```dart 95:96:lib/get_utils/src/extensions/context_extensions.dart
  /// get the shortestSide from screen
  double get mediaQueryShortestSide => mediaQuerySize.shortestSide;
```

**说明**：返回屏幕尺寸的 `shortestSide` 属性，常用于判断设备类型。

### 尺寸转换方法

#### heightTransformer

高度转换器，支持除法和百分比减少。

```dart 17:30:lib/get_utils/src/extensions/context_extensions.dart
  /// Gives you the power to get a portion of the height.
  /// Useful for responsive applications.
  ///
  /// [dividedBy] is for when you want to have a portion of the value you
  /// would get like for example: if you want a value that represents a third
  /// of the screen you can set it to 3, and you will get a third of the height
  ///
  /// [reducedBy] is a percentage value of how much of the height you want
  /// if you for example want 46% of the height, then you reduce it by 56%.
  double heightTransformer({double dividedBy = 1, double reducedBy = 0.0}) {
    return (mediaQuerySize.height -
            ((mediaQuerySize.height / 100) * reducedBy)) /
        dividedBy;
  }
```

**参数说明**：

- `dividedBy`：除数，默认为 1。例如设置为 3 时，返回高度的三分之一
- `reducedBy`：减少的百分比，默认为 0.0。例如想要 46% 的高度，可以设置 `reducedBy` 为 56%

**使用示例**：

```dart
// 获取屏幕高度的三分之一
final thirdHeight = context.heightTransformer(dividedBy: 3);

// 获取屏幕高度的 46%（减少 56%）
final partialHeight = context.heightTransformer(reducedBy: 56.0);

// 组合使用：获取减少 20% 后的高度的二分之一
final customHeight = context.heightTransformer(dividedBy: 2, reducedBy: 20.0);
```

#### widthTransformer

宽度转换器，支持除法和百分比减少。

```dart 32:44:lib/get_utils/src/extensions/context_extensions.dart
  /// Gives you the power to get a portion of the width.
  /// Useful for responsive applications.
  ///
  /// [dividedBy] is for when you want to have a portion of the value you
  /// would get like for example: if you want a value that represents a third
  /// of the screen you can set it to 3, and you will get a third of the width
  ///
  /// [reducedBy] is a percentage value of how much of the width you want
  /// if you for example want 46% of the width, then you reduce it by 56%.
  double widthTransformer({double dividedBy = 1, double reducedBy = 0.0}) {
    return (mediaQuerySize.width - ((mediaQuerySize.width / 100) * reducedBy)) /
        dividedBy;
  }
```

**参数说明**：与 `heightTransformer` 相同，但作用于宽度。

**使用示例**：

```dart
// 获取屏幕宽度的四分之一
final quarterWidth = context.widthTransformer(dividedBy: 4);

// 获取屏幕宽度的 80%（减少 20%）
final partialWidth = context.widthTransformer(reducedBy: 20.0);
```

#### ratio

计算宽高比。

```dart 46:54:lib/get_utils/src/extensions/context_extensions.dart
  /// Divide the height proportionally by the given value
  double ratio({
    double dividedBy = 1,
    double reducedByW = 0.0,
    double reducedByH = 0.0,
  }) {
    return heightTransformer(dividedBy: dividedBy, reducedBy: reducedByH) /
        widthTransformer(dividedBy: dividedBy, reducedBy: reducedByW);
  }
```

**参数说明**：

- `dividedBy`：同时应用于高度和宽度的除数
- `reducedByW`：宽度减少的百分比
- `reducedByH`：高度减少的百分比

**返回值**：处理后的高度与宽度的比值。

**使用示例**：

```dart
// 计算屏幕的宽高比
final aspectRatio = context.ratio();

// 计算减少内边距后的宽高比
final adjustedRatio = context.ratio(
  reducedByW: 10.0, // 宽度减少 10%
  reducedByH: 5.0,  // 高度减少 5%
);
```

### 主题相关属性

#### theme

获取主题数据。

```dart 56:57:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.of(context).padding]
  ThemeData get theme => Theme.of(this);
```

**说明**：等同于 `Theme.of(context)`，返回当前上下文中的 `ThemeData` 对象。

**使用示例**：

```dart
final primaryColor = context.theme.colorScheme.primary;
final textStyle = context.theme.textTheme.headlineLarge;
```

#### isDarkMode

检查是否启用暗色模式。

```dart 59:60:lib/get_utils/src/extensions/context_extensions.dart
  /// Check if dark mode theme is enable
  bool get isDarkMode => (theme.brightness == Brightness.dark);
```

**说明**：通过检查主题的 `brightness` 属性来判断是否为暗色模式。

**使用示例**：

```dart
if (context.isDarkMode) {
  // 暗色模式下的逻辑
  return DarkModeWidget();
} else {
  // 亮色模式下的逻辑
  return LightModeWidget();
}
```

#### iconColor

获取图标颜色。

```dart 62:63:lib/get_utils/src/extensions/context_extensions.dart
  /// give access to Theme.of(context).iconTheme.color
  Color? get iconColor => theme.iconTheme.color;
```

**说明**：等同于 `Theme.of(context).iconTheme.color`，返回主题中定义的图标颜色。

**使用示例**：

```dart
Icon(
  Icons.star,
  color: context.iconColor,
)
```

#### textTheme

获取文本主题。

```dart 65:66:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.of(context).padding]
  TextTheme get textTheme => Theme.of(this).textTheme;
```

**说明**：等同于 `Theme.of(context).textTheme`，返回主题中定义的文本样式集合。

**使用示例**：

```dart
Text(
  'Hello World',
  style: context.textTheme.headlineLarge,
)
```

### 设备方向与显示

#### orientation

获取屏幕方向。

```dart 80:81:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.orientationOf(context)]
  Orientation get orientation => MediaQuery.orientationOf(this);
```

**说明**：等同于 `MediaQuery.orientationOf(context)`，返回 `Orientation.landscape` 或 `Orientation.portrait`。

#### isLandscape

检查是否为横屏模式。

```dart 83:84:lib/get_utils/src/extensions/context_extensions.dart
  /// check if device is on landscape mode
  bool get isLandscape => orientation == Orientation.landscape;
```

**使用示例**：

```dart
if (context.isLandscape) {
  return LandscapeLayout();
} else {
  return PortraitLayout();
}
```

#### isPortrait

检查是否为竖屏模式。

```dart 86:87:lib/get_utils/src/extensions/context_extensions.dart
  /// check if device is on portrait mode
  bool get isPortrait => orientation == Orientation.portrait;
```

**使用示例**：

```dart
if (context.isPortrait) {
  return SingleColumnLayout();
} else {
  return TwoColumnLayout();
}
```

#### devicePixelRatio

获取设备像素比。

```dart 89:90:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.devicePixelRatioOf(context)]
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);
```

**说明**：等同于 `MediaQuery.devicePixelRatioOf(context)`，返回设备的像素比（如 2.0、3.0 等）。

#### textScaleFactor

获取文本缩放因子。

```dart 92:93:lib/get_utils/src/extensions/context_extensions.dart
  /// similar to [MediaQuery.textScaleFactorOf(context)]
  TextScaler get textScaleFactor => MediaQuery.textScalerOf(this);
```

**说明**：等同于 `MediaQuery.textScalerOf(context)`，返回文本缩放因子（注意：返回的是 `TextScaler` 对象，不是 `double`）。

#### showNavbar

判断是否显示导航栏（基于宽度 > 800）。

```dart 98:99:lib/get_utils/src/extensions/context_extensions.dart
  /// True if width be larger than 800
  bool get showNavbar => (width > 800);
```

**使用示例**：

```dart
if (context.showNavbar) {
  return Scaffold(
    body: Row(
      children: [
        NavigationRail(), // 侧边导航栏
        Expanded(child: MainContent()),
      ],
    ),
  );
} else {
  return Scaffold(
    body: MainContent(),
    bottomNavigationBar: BottomNavigationBar(), // 底部导航栏
  );
}
```

### 设备类型判断

#### 手机相关判断

##### isPhone

判断是否为手机（最短边 < 600）。

```dart 107:108:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the shortestSide is smaller than 600p
  bool get isPhone => (mediaQueryShortestSide < 600);
```

**说明**：基于屏幕最短边判断，如果最短边小于 600 像素，则认为是手机。

##### isPhoneOrLess

判断宽度是否小于等于 600。

```dart 101:102:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the width is smaller than 600p
  bool get isPhoneOrLess => width <= 600;
```

##### isPhoneOrWider

判断宽度是否大于等于 600。

```dart 104:105:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the width is higher than 600p
  bool get isPhoneOrWider => width >= 600;
```

#### 平板相关判断

##### isSmallTablet

判断是否为小平板（最短边 >= 600）。

```dart 116:117:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the shortestSide is largest than 600p
  bool get isSmallTablet => (mediaQueryShortestSide >= 600);
```

##### isLargeTablet

判断是否为大平板（最短边 >= 720）。

```dart 119:120:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the shortestSide is largest than 720p
  bool get isLargeTablet => (mediaQueryShortestSide >= 720);
```

##### isTablet

判断是否为平板（小平板或大平板）。

```dart 128:129:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the current device is Tablet
  bool get isTablet => isSmallTablet || isLargeTablet;
```

##### isSmallTabletOrLess

判断宽度是否小于等于 600。

```dart 110:111:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the width is smaller than 600p
  bool get isSmallTabletOrLess => width <= 600;
```

##### isSmallTabletOrWider

判断宽度是否大于等于 600。

```dart 113:114:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the width is higher than 600p
  bool get isSmallTabletOrWider => width >= 600;
```

##### isLargeTabletOrLess

判断宽度是否小于等于 720。

```dart 122:123:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the width is smaller than 720p
  bool get isLargeTabletOrLess => width <= 720;
```

##### isLargeTabletOrWider

判断宽度是否大于等于 720。

```dart 125:126:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the width is higher than 720p
  bool get isLargeTabletOrWider => width >= 720;
```

#### 桌面相关判断

##### isDesktop

判断是否为桌面设备（宽度 <= 1200）。

```dart 137:138:lib/get_utils/src/extensions/context_extensions.dart
  /// same as [isDesktopOrLess]
  bool get isDesktop => isDesktopOrLess;
```

**注意**：此属性与 `isDesktopOrLess` 相同，逻辑上可能有些反直觉。

##### isDesktopOrLess

判断宽度是否小于等于 1200。

```dart 131:132:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the width is smaller than 1200p
  bool get isDesktopOrLess => width <= 1200;
```

##### isDesktopOrWider

判断宽度是否大于等于 1200。

```dart 134:135:lib/get_utils/src/extensions/context_extensions.dart
  /// True if the width is higher than 1200p
  bool get isDesktopOrWider => width >= 1200;
```

**设备类型判断使用示例**：

```dart
Widget buildResponsiveLayout(BuildContext context) {
  if (context.isPhone) {
    return MobileLayout();
  } else if (context.isTablet) {
    return TabletLayout();
  } else if (context.isDesktopOrWider) {
    return DesktopLayout();
  } else {
    return DefaultLayout();
  }
}
```

### 响应式值选择

#### responsiveValue

根据屏幕宽度返回不同的值。

```dart 140:170:lib/get_utils/src/extensions/context_extensions.dart
  /// Returns a specific value according to the screen size
  /// if the device width is higher than or equal to 1200 return
  /// [desktop] value. if the device width is higher than  or equal to 600
  /// and less than 1200 return [tablet] value.
  /// if the device width is less than 300  return [watch] value.
  /// in other cases return [mobile] value.
  T responsiveValue<T>({
    T? watch,
    T? mobile,
    T? tablet,
    T? desktop,
  }) {
    assert(
        watch != null || mobile != null || tablet != null || desktop != null);

    var deviceWidth = mediaQuerySize.width;
    //big screen width can display smaller sizes
    final strictValues = [
      if (deviceWidth >= 1200) desktop, //desktop is allowed
      if (deviceWidth >= 600) tablet, //tablet is allowed
      if (deviceWidth >= 300) mobile, //mobile is allowed
      watch, //watch is allowed
    ].whereType<T>();
    final looseValues = [
      watch,
      mobile,
      tablet,
      desktop,
    ].whereType<T>();
    return strictValues.firstOrNull ?? looseValues.first;
  }
```

**参数说明**：

- `watch`：手表尺寸（宽度 < 300）的值
- `mobile`：手机尺寸（300 <= 宽度 < 600）的值
- `tablet`：平板尺寸（600 <= 宽度 < 1200）的值
- `desktop`：桌面尺寸（宽度 >= 1200）的值

**返回值逻辑**：

1. 首先根据屏幕宽度构建严格匹配的值列表（大屏幕可以显示小尺寸的内容）
2. 如果严格匹配列表为空，则从所有提供的值中选择第一个非空值
3. 使用 `firstOrNull` 安全获取第一个元素

**使用示例**：

```dart
// 根据屏幕尺寸返回不同的字体大小
final fontSize = context.responsiveValue<double>(
  watch: 12.0,
  mobile: 14.0,
  tablet: 16.0,
  desktop: 18.0,
);

// 根据屏幕尺寸返回不同的 Widget
final widget = context.responsiveValue<Widget>(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
);

// 根据屏幕尺寸返回不同的边距
final padding = context.responsiveValue<EdgeInsets>(
  mobile: EdgeInsets.all(16),
  tablet: EdgeInsets.all(24),
  desktop: EdgeInsets.all(32),
);
```

## IterableExt 扩展详解

### firstOrNull

安全获取第一个元素，如果集合为空则返回 `null`。

```dart 173:180:lib/get_utils/src/extensions/context_extensions.dart
extension IterableExt<T> on Iterable<T> {
  /// The first element, or `null` if the iterable is empty.
  T? get firstOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
```

**说明**：这是一个辅助扩展，用于安全地获取集合的第一个元素，避免在空集合上调用 `first` 时抛出异常。

**使用示例**：

```dart
final list = <int>[];
final first = list.firstOrNull; // 返回 null，而不是抛出异常

final numbers = [1, 2, 3];
final firstNumber = numbers.firstOrNull; // 返回 1
```

**在 responsiveValue 中的应用**：

```dart
return strictValues.firstOrNull ?? looseValues.first;
```

这里使用 `firstOrNull` 安全地获取第一个元素，如果 `strictValues` 为空，则使用 `looseValues.first`。

## 完整使用示例

### 示例 1：响应式布局

```dart
class ResponsivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('响应式页面'),
      ),
      body: context.responsiveValue<Widget>(
        mobile: MobileView(),
        tablet: TabletView(),
        desktop: DesktopView(),
      ),
      // 根据屏幕宽度决定显示底部导航栏还是侧边栏
      bottomNavigationBar: context.isPhone
          ? BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
              ],
            )
          : null,
    );
  }
}
```

### 示例 2：自适应容器尺寸

```dart
class AdaptiveContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.widthTransformer(dividedBy: 2, reducedBy: 10.0),
      height: context.heightTransformer(dividedBy: 3),
      padding: context.responsiveValue<EdgeInsets>(
        mobile: EdgeInsets.all(8),
        tablet: EdgeInsets.all(16),
        desktop: EdgeInsets.all(24),
      ),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(
          context.responsiveValue<double>(
            mobile: 8.0,
            tablet: 12.0,
            desktop: 16.0,
          ),
        ),
      ),
      child: Text(
        '自适应内容',
        style: context.textTheme.bodyLarge?.copyWith(
          color: context.iconColor,
        ),
      ),
    );
  }
}
```

### 示例 3：处理键盘弹出

```dart
class KeyboardAwareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewInsets = context.mediaQueryViewInsets;
    final hasKeyboard = viewInsets.bottom > 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: hasKeyboard ? viewInsets.bottom : 0,
      ),
      child: Column(
        children: [
          Expanded(
            child: YourContent(),
          ),
          if (hasKeyboard)
            Container(
              height: 50,
              child: KeyboardToolbar(),
            ),
        ],
      ),
    );
  }
}
```

### 示例 4：设备类型特定布局

```dart
class DeviceSpecificLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return SingleColumnLayout();
    } else if (context.isTablet) {
      return TwoColumnLayout();
    } else if (context.isDesktopOrWider) {
      return ThreeColumnLayout();
    } else {
      return DefaultLayout();
    }
  }
}
```

## 最佳实践

### 何时使用这些扩展

1. **响应式设计**：当需要根据屏幕尺寸调整布局时，使用 `responsiveValue` 或设备类型判断属性
2. **简化代码**：使用扩展属性替代冗长的 `MediaQuery.of(context)` 调用
3. **主题访问**：使用 `theme`、`isDarkMode` 等属性简化主题相关操作
4. **尺寸计算**：使用 `heightTransformer` 和 `widthTransformer` 进行灵活的尺寸计算

### 性能注意事项

1. **避免频繁调用**：这些扩展方法内部会调用 `MediaQuery.of(context)`，在 `build` 方法中频繁调用是安全的，因为 Flutter 会优化这些调用
2. **缓存值**：如果需要在多个地方使用相同的值，考虑将其存储在变量中
3. **响应式更新**：这些值会在屏幕尺寸改变时自动更新，无需手动监听

### 常见使用场景

1. **响应式布局切换**：根据屏幕尺寸显示不同的布局结构
2. **自适应字体大小**：根据设备类型设置不同的字体大小
3. **边距和间距调整**：根据屏幕尺寸调整内边距和外边距
4. **导航栏切换**：在手机和平板上使用底部导航栏，在桌面上使用侧边栏
5. **暗色模式适配**：根据 `isDarkMode` 显示不同的 UI 元素

### 注意事项

1. **isDesktop 的逻辑**：`isDesktop` 属性实际上等同于 `isDesktopOrLess`（宽度 <= 1200），这个命名可能有些反直觉，使用时需要注意
2. **设备类型判断的差异**：有些属性基于 `width`，有些基于 `shortestSide`，使用时需要理解其区别
3. **responsiveValue 的优先级**：大屏幕可以显示小尺寸的内容，这是设计上的考虑，符合响应式设计原则

## 总结

`context_extensions.dart` 提供了丰富的 `BuildContext` 扩展方法，大大简化了 Flutter 应用中的响应式设计和媒体查询操作。通过使用这些扩展，开发者可以：

- 更简洁地访问屏幕尺寸和媒体查询信息
- 更灵活地进行尺寸计算和转换
- 更方便地判断设备类型和屏幕方向
- 更优雅地实现响应式布局

这些扩展方法遵循 Flutter 的最佳实践，在保持代码简洁的同时，提供了强大的响应式设计能力。
