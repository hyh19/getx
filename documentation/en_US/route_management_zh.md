- [路由管理](#路由管理)
  - [如何使用](#如何使用)
  - [不使用命名路由的导航](#不使用命名路由的导航)
  - [使用命名路由的导航](#使用命名路由的导航)
    - [向命名路由发送数据](#向命名路由发送数据)
    - [动态 URL 链接](#动态-url-链接)
    - [中间件](#中间件)
  - [无 context 的导航](#无-context-的导航)
    - [SnackBars](#snackbars)
    - [Dialogs](#dialogs)
    - [BottomSheets](#bottomsheets)
  - [嵌套导航](#嵌套导航)

# 路由管理

这是关于 Getx 路由管理的完整说明。

## 如何使用

将此添加到您的 pubspec.yaml 文件中：

```yaml
dependencies:
  get:
```

如果您要使用无 context 的路由/snackbars/dialogs/bottomsheets，或使用高级 Get API，您只需要在 MaterialApp 前添加 "Get"，将其转换为 GetMaterialApp 即可！

```dart
GetMaterialApp( // Before: MaterialApp(
  home: MyHome(),
)
```

## 不使用命名路由的导航

导航到新屏幕：

```dart
Get.to(NextScreen());
```

关闭 snackbars、dialogs、bottomsheets 或您通常使用 Navigator.pop(context) 关闭的任何内容：

```dart
Get.back();
```

转到下一个屏幕且无法返回上一个屏幕（用于启动屏幕、登录屏幕等）

```dart
Get.off(NextScreen());
```

转到下一个屏幕并取消所有 previous 路由（在购物车、投票和测试中很有用）

```dart
Get.offAll(NextScreen());
```

导航到下一个路由，并在从它返回时立即接收或更新数据：

```dart
var data = await Get.to(Payment());
```

在另一个屏幕上，为上一个路由发送数据：

```dart
Get.back(result: 'success');
```

并使用它：

例如：

```dart
if(data == 'success') madeAnything();
```

您不想学习我们的语法吗？
只需将 Navigator（大写）更改为 navigator（小写），您将拥有标准导航的所有功能，而无需使用 context
示例：

```dart

// Default Flutter navigator
Navigator.of(context).push(
  context,
  MaterialPageRoute(
    builder: (BuildContext context) {
      return HomePage();
    },
  ),
);

// Get using Flutter syntax without needing context
navigator.push(
  MaterialPageRoute(
    builder: (_) {
      return HomePage();
    },
  ),
);

// Get syntax (It is much better, but you have the right to disagree)
Get.to(HomePage());


```

## 使用命名路由的导航

- 如果您更喜欢通过 namedRoutes 导航，Get 也支持此功能。

导航到 nextScreen

```dart
Get.toNamed("/NextScreen");
```

导航并从树中删除上一个屏幕。

```dart
Get.offNamed("/NextScreen");
```

导航并从树中删除所有 previous 屏幕。

```dart
Get.offAllNamed("/NextScreen");
```

要定义路由，请使用 GetMaterialApp：

```dart
void main() {
  runApp(
    GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MyHomePage()),
        GetPage(name: '/second', page: () => Second()),
        GetPage(
          name: '/third',
          page: () => Third(),
          transition: Transition.zoom  
        ),
      ],
    )
  );
}
```

要处理导航到未定义的路由（404 错误），您可以在 GetMaterialApp 中定义一个 unknownRoute 页面。

```dart
void main() {
  runApp(
    GetMaterialApp(
      unknownRoute: GetPage(name: '/notfound', page: () => UnknownRoutePage()),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MyHomePage()),
        GetPage(name: '/second', page: () => Second()),
      ],
    )
  );
}
```

### 向命名路由发送数据

只需发送您想要的参数。Get 在这里接受任何内容，无论是 String、Map、List，甚至是类实例。

```dart
Get.toNamed("/NextScreen", arguments: 'Get is the best');
```

在您的类或控制器上：

```dart
print(Get.arguments);
//print out: Get is the best
```

### 动态 URL 链接

Get 提供高级动态 URL，就像在 Web 上一样。Web 开发人员可能已经在 Flutter 上想要此功能，并且很可能已经看到包承诺此功能并提供与 Web 上 URL 完全不同的语法，但 Get 也解决了这个问题。

```dart
Get.offAllNamed("/NextScreen?device=phone&id=354&name=Enzo");
```

在您的控制器/bloc/stateful/stateless 类上：

```dart
print(Get.parameters['id']);
// out: 354
print(Get.parameters['name']);
// out: Enzo
```

您也可以轻松地使用 Get 接收命名参数：

```dart
void main() {
  runApp(
    GetMaterialApp(
      initialRoute: '/',
      getPages: [
      GetPage(
        name: '/',
        page: () => MyHomePage(),
      ),
      GetPage(
        name: '/profile/',
        page: () => MyProfile(),
      ),
       //You can define a different page for routes with arguments, and another without arguments, but for that you must use the slash '/' on the route that will not receive arguments as above.
       GetPage(
        name: '/profile/:user',
        page: () => UserProfile(),
      ),
      GetPage(
        name: '/third',
        page: () => Third(),
        transition: Transition.cupertino  
      ),
     ],
    )
  );
}
```

在路由名称上发送数据

```dart
Get.toNamed("/profile/34954");
```

在第二个屏幕上通过参数获取数据

```dart
print(Get.parameters['user']);
// out: 34954
```

或像这样发送多个参数

```dart
Get.toNamed("/profile/34954?flag=true&country=italy");
```

或

```dart
var parameters = <String, String>{"flag": "true","country": "italy",};
Get.toNamed("/profile/34954", parameters: parameters);
```

在第二个屏幕上像往常一样通过参数获取数据

```dart
print(Get.parameters['user']);
print(Get.parameters['flag']);
print(Get.parameters['country']);
// out: 34954 true italy
```

现在，您只需要使用 Get.toNamed() 导航您的命名路由，无需任何 context（您可以直接从 BLoC 或 Controller 类调用路由），当您的应用编译到 Web 时，您的路由将出现在 url 中 <3

### 中间件

如果您想监听 Get 事件以触发操作，可以使用 routingCallback

```dart
GetMaterialApp(
  routingCallback: (routing) {
    if(routing.current == '/second'){
      openAds();
    }
  }
)
```

如果您不使用 GetMaterialApp，可以使用手动 API 附加中间件观察者。

```dart
void main() {
  runApp(
    MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: "/",
      navigatorKey: Get.key,
      navigatorObservers: [
        GetObserver(MiddleWare.observer), // HERE !!!
      ],
    ),
  );
}
```

创建 MiddleWare 类

```dart
class MiddleWare {
  static observer(Routing routing) {
    /// You can listen in addition to the routes, the snackbars, dialogs and bottomsheets on each screen.
    ///If you need to enter any of these 3 events directly here,
    ///you must specify that the event is != Than you are trying to do.
    if (routing.current == '/second' && !routing.isSnackbar) {
      Get.snackbar("Hi", "You are on second route");
    } else if (routing.current =='/third'){
      print('last route called');
    }
  }
}
```

现在，在您的代码中使用 Get：

```dart
class First extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Get.snackbar("hi", "i am a modern snackbar");
          },
        ),
        title: Text('First Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Open route'),
          onPressed: () {
            Get.toNamed("/second");
          },
        ),
      ),
    );
  }
}

class Second extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Get.snackbar("hi", "i am a modern snackbar");
          },
        ),
        title: Text('second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Open route'),
          onPressed: () {
            Get.toNamed("/third");
          },
        ),
      ),
    );
  }
}

class Third extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Third Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
```

## 无 context 的导航

### SnackBars

要在 Flutter 中使用简单的 SnackBar，您必须获取 Scaffold 的 context，或者必须使用附加到 Scaffold 的 GlobalKey

```dart
final snackBar = SnackBar(
  content: Text('Hi!'),
  action: SnackBarAction(
    label: 'I am a old and ugly snackbar :(',
    onPressed: (){}
  ),
);
// Find the Scaffold in the widget tree and use
// it to show a SnackBar.
Scaffold.of(context).showSnackBar(snackBar);
```

使用 Get：

```dart
Get.snackbar('Hi', 'i am a modern snackbar');
```

使用 Get，您只需要从代码中的任何地方调用 Get.snackbar，或者按照您想要的任何方式自定义它！

```dart
Get.snackbar(
  "Hey i'm a Get SnackBar!", // title
  "It's unbelievable! I'm using SnackBar without context, without boilerplate, without Scaffold, it is something truly amazing!", // message
  icon: Icon(Icons.alarm),
  shouldIconPulse: true,
  onTap:(){},
  barBlur: 20,
  isDismissible: true,
  duration: Duration(seconds: 3),
);


  ////////// ALL FEATURES //////////
  //     Color colorText,
  //     Duration duration,
  //     SnackPosition snackPosition,
  //     Widget titleText,
  //     Widget messageText,
  //     bool instantInit,
  //     Widget icon,
  //     bool shouldIconPulse,
  //     double maxWidth,
  //     EdgeInsets margin,
  //     EdgeInsets padding,
  //     double borderRadius,
  //     Color borderColor,
  //     double borderWidth,
  //     Color backgroundColor,
  //     Color leftBarIndicatorColor,
  //     List<BoxShadow> boxShadows,
  //     Gradient backgroundGradient,
  //     TextButton mainButton,
  //     OnTap onTap,
  //     bool isDismissible,
  //     bool showProgressIndicator,
  //     AnimationController progressIndicatorController,
  //     Color progressIndicatorBackgroundColor,
  //     Animation<Color> progressIndicatorValueColor,
  //     SnackStyle snackStyle,
  //     Curve forwardAnimationCurve,
  //     Curve reverseAnimationCurve,
  //     Duration animationDuration,
  //     double barBlur,
  //     double overlayBlur,
  //     Color overlayColor,
  //     Form userInputForm
  ///////////////////////////////////
```

如果您更喜欢传统的 snackbar，或者想从头开始自定义它，包括只添加一行（Get.snackbar 使用强制标题和消息），您可以使用
`Get.rawSnackbar();`，它提供了构建 Get.snackbar 的 RAW API。

### Dialogs

打开对话框：

```dart
Get.dialog(YourDialogWidget());
```

打开默认对话框：

```dart
Get.defaultDialog(
  onConfirm: () => print("Ok"),
  middleText: "Dialog made in 3 lines of code"
);
```

要关闭对话框并返回结果，请使用 `Get.closeDialog`，提供 `result` 以返回到等待的 `Get.dialog` 调用。

```dart
Widget buttonWithResult({
  required final String text,
  required final bool result,
}) => TextButton(
          onPressed: () {
            Get.closeDialog(result: result);
          },
          child: Text(text),
        );

bool? delete = await Get.dialog(
    AlertDialog(
      content: const Text('Are you sure you would like to delete?'),
      actions: [
        buttonWithResult(text: 'No', result: false),
        buttonWithResult(text: 'Yes', result: true),
      ],
    ),
  );

if (delete != null && delete) {
  // Perform the deletion
}
```

您也可以使用 Get.generalDialog 代替 showGeneralDialog。

对于所有其他 Flutter 对话框 widget，包括 cupertinos，您可以使用 Get.overlayContext 代替 context，并在代码中的任何地方打开它。
对于不使用 Overlay 的 widget，您可以使用 Get.context。
这两个 context 在 99% 的情况下都可以替换 UI 的 context，除了在没有导航 context 的情况下使用 inheritedWidget 的情况。

### BottomSheets

Get.bottomSheet 类似于 showModalBottomSheet，但不需要 context。

```dart
Get.bottomSheet(
  Container(
    child: Wrap(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.music_note),
          title: Text('Music'),
          onTap: () {}
        ),
        ListTile(
          leading: Icon(Icons.videocam),
          title: Text('Video'),
          onTap: () {},
        ),
      ],
    ),
  )
);
```

## 嵌套导航

Get 使 Flutter 的嵌套导航变得更加容易。
您不需要 context，您将通过 Id 找到导航堆栈。

- 注意：创建并行导航堆栈可能很危险。理想情况是不使用 NestedNavigators，或者谨慎使用。如果您的项目需要它，请继续，但请记住，在内存中保留多个导航堆栈可能对 RAM 消耗不是一个好主意。

看看它有多简单：

```dart
Navigator(
  key: Get.nestedKey(1), // create a key by index
  initialRoute: '/',
  onGenerateRoute: (settings) {
    if (settings.name == '/') {
      return GetPageRoute(
        page: () => Scaffold(
          appBar: AppBar(
            title: Text("Main"),
          ),
          body: Center(
            child: TextButton(
              color: Colors.blue,
              onPressed: () {
                Get.toNamed('/second', id:1); // navigate by your nested route by index
              },
              child: Text("Go to second"),
            ),
          ),
        ),
      );
    } else if (settings.name == '/second') {
      return GetPageRoute(
        page: () => Center(
          child: Scaffold(
            appBar: AppBar(
              title: Text("Main"),
            ),
            body: Center(
              child:  Text("second")
            ),
          ),
        ),
      );
    }
  }
),
```
