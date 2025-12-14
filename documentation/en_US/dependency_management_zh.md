# 依赖管理

- [依赖管理](#依赖管理)
  - [实例化方法](#实例化方法)
    - [Get.put()](#getput)
    - [Get.lazyPut](#getlazyput)
    - [Get.putAsync](#getputasync)
    - [Get.create](#getcreate)
  - [使用实例化方法/类](#使用实例化方法类)
  - [指定替代实例](#指定替代实例)
  - [方法之间的差异](#方法之间的差异)
  - [Bindings](#bindings)
    - [Bindings 类](#bindings-类)
    - [BindingsBuilder](#bindingsbuilder)
    - [SmartManagement](#smartmanagement)
      - [如何更改](#如何更改)
      - [SmartManagement.full](#smartmanagementfull)
      - [SmartManagement.onlyBuilder](#smartmanagementonlybuilder)
      - [SmartManagement.keepFactory](#smartmanagementkeepfactory)
    - [Bindings 的工作原理](#bindings-的工作原理)
  - [注意事项](#注意事项)

Get 有一个简单而强大的依赖管理器，它允许您只用 1 行代码就能检索到与您的 Bloc 或 Controller 相同的类，无需 Provider context，无需 inheritedWidget：

```dart
Controller controller = Get.put(Controller()); // 而不是 Controller controller = Controller();
```

您不是在使用的类中实例化类，而是在 Get 实例中实例化它，这将使它在整个 App 中可用。
因此您可以正常使用控制器（或 Bloc 类）

- 注意：如果您使用的是 Get 的状态管理器，请多关注 [Bindings](#bindings) api，这将使您的视图更容易连接到控制器。
- 注意²：Get 的依赖管理与包中的其他部分是解耦的，因此如果您的应用已经使用了状态管理器（任何一个，都没关系），您不需要更改它，您可以毫无问题地使用此依赖注入管理器

## 实例化方法

这些方法及其可配置参数是：

### Get.put()

最常见的插入依赖的方式。例如，对于视图的控制器来说很好。

```dart
Get.put<SomeClass>(SomeClass());
Get.put<LoginController>(LoginController(), permanent: true);
Get.put<ListItemController>(ListItemController, tag: "some unique string");
```

这是使用 put 时可以设置的所有选项：

```dart
Get.put<S>(
  // mandatory: the class that you want to get to save, like a controller or anything
  // note: "S" means that it can be a class of any type
  S dependency

  // optional: this is for when you want multiple classess that are of the same type
  // since you normally get a class by using Get.find<Controller>(),
  // you need to use tag to tell which instance you need
  // must be unique string
  String tag,

  // optional: by default, get will dispose instances after they are not used anymore (example,
  // the controller of a view that is closed), but you might need that the instance
  // to be kept there throughout the entire app, like an instance of sharedPreferences or something
  // so you use this
  // defaults to false
  bool permanent = false,

  // optional: allows you after using an abstract class in a test, replace it with another one and follow the test.
  // defaults to false
  bool overrideAbstract = false,

  // optional: allows you to create the dependency using function instead of the dependency itself.
  // this one is not commonly used
  InstanceBuilderCallback<S> builder,
)
```

### Get.lazyPut

可以懒加载依赖，这样它只有在使用时才会被实例化。对于计算成本高的类非常有用，或者如果您想在一个地方实例化多个类（例如在 Bindings 类中），并且您知道您不会在那个时候使用该类。

```dart
/// ApiMock will only be called when someone uses Get.find<ApiMock> for the first time
Get.lazyPut<ApiMock>(() => ApiMock());

Get.lazyPut<FirebaseAuth>(
  () {
    // ... some logic if needed
    return FirebaseAuth();
  },
  tag: Math.random().toString(),
  fenix: true
)

Get.lazyPut<Controller>( () => Controller() )
```

这是使用 lazyPut 时可以设置的所有选项：

```dart
Get.lazyPut<S>(
  // mandatory: a method that will be executed when your class is called for the first time
  InstanceBuilderCallback builder,
  
  // optional: same as Get.put(), it is used for when you want multiple different instance of a same class
  // must be unique
  String tag,

  // optional: It is similar to "permanent", the difference is that the instance is discarded when
  // is not being used, but when it's use is needed again, Get will recreate the instance
  // just the same as "SmartManagement.keepFactory" in the bindings api
  // defaults to false
  bool fenix = false
  
)
```

### Get.putAsync

如果您想注册异步实例，可以使用 `Get.putAsync`：

```dart
Get.putAsync<SharedPreferences>(() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('counter', 12345);
  return prefs;
});

Get.putAsync<YourAsyncClass>( () async => await YourAsyncClass() )
```

这是使用 putAsync 时可以设置的所有选项：

```dart
Get.putAsync<S>(

  // mandatory: an async method that will be executed to instantiate your class
  AsyncInstanceBuilderCallback<S> builder,

  // optional: same as Get.put(), it is used for when you want multiple different instance of a same class
  // must be unique
  String tag,

  // optional: same as in Get.put(), used when you need to maintain that instance alive in the entire app
  // defaults to false
  bool permanent = false
)
```

### Get.create

这个比较棘手。关于这是什么以及与其他方法的差异的详细说明可以在 [方法之间的差异：](#方法之间的差异) 部分找到

```dart
Get.Create<SomeClass>(() => SomeClass());
Get.Create<LoginController>(() => LoginController());
```

这是使用 create 时可以设置的所有选项：

```dart
Get.create<S>(
  // required: a function that returns a class that will be "fabricated" every
  // time `Get.find()` is called
  // Example: Get.create<YourClass>(() => YourClass())
  FcBuilderFunc<S> builder,

  // optional: just like Get.put(), but it is used when you need multiple instances
  // of a of a same class
  // Useful in case you have a list that each item need it's own controller
  // needs to be a unique string. Just change from tag to name
  String name,

  // optional: just like int`Get.put()`, it is for when you need to keep the
  // instance alive thoughout the entire app. The difference is in Get.create
  // permanent is true by default
  bool permanent = true
```

## 使用实例化方法/类

想象一下，您已经浏览了无数条路由，现在您需要获取一个被遗留在控制器中的数据，那么您会需要一个状态管理器与 Provider 或 Get_it 相结合，对吗？使用 Get 则不然。您只需要让 Get 为您的控制器"查找"，您不需要任何额外的依赖：

```dart
final controller = Get.find<Controller>();
// OR
Controller controller = Get.find();

// Yes, it looks like Magic, Get will find your controller, and will deliver it to you.
// You can have 1 million controllers instantiated, Get will always give you the right controller.
```

然后您就可以恢复您之前获得的控制器数据：

```dart
Text(controller.textFromApi);
```

由于返回的值是一个正常的类，您可以做任何您想做的事情：

```dart
int count = Get.find<SharedPreferences>().getInt('counter');
print(count); // out: 12345
```

要删除 Get 的实例：

```dart
Get.delete<Controller>(); //usually you don't need to do this because GetX already delete unused controllers
```

## 指定替代实例

当前插入的实例可以通过使用 `replace` 或 `lazyReplace` 方法替换为相似或扩展的类实例。然后可以使用原始类检索它。

```dart
abstract class BaseClass {}
class ParentClass extends BaseClass {}

class ChildClass extends ParentClass {
  bool isChild = true;
}


Get.put<BaseClass>(ParentClass());

Get.replace<BaseClass>(ChildClass());

final instance = Get.find<BaseClass>();
print(instance is ChildClass); //true


class OtherClass extends BaseClass {}
Get.lazyReplace<BaseClass>(() => OtherClass());

final instance = Get.find<BaseClass>();
print(instance is ChildClass); // false
print(instance is OtherClass); //true
```

## 方法之间的差异

首先，让我们看看 Get.lazyPut 的 `fenix` 和其他方法的 `permanent`。

`permanent` 和 `fenix` 之间的根本区别在于您想要如何存储实例。

强化：默认情况下，GetX 会在不使用实例时删除它们。
这意味着：如果屏幕 1 有控制器 1，屏幕 2 有控制器 2，并且您从堆栈中删除第一个路由（例如，如果您使用 `Get.off()` 或 `Get.offNamed()`），控制器 1 失去了它的使用，所以它将被删除。

但是，如果您想选择使用 `permanent:true`，那么控制器不会在此转换中丢失——这对于您想在整个应用程序中保持活动的服务非常有用。

另一方面，`fenix` 适用于那些您不担心在屏幕更改之间丢失的服务，但当您需要该服务时，您希望它还活着。所以基本上，它会处理未使用的控制器/服务/类，但当您需要它时，它会"从灰烬中重新创建"一个新实例。

继续说明方法之间的差异：

- Get.put 和 Get.putAsync 遵循相同的创建顺序，区别在于第二个使用异步方法：这两种方法创建并初始化实例。它直接插入内存，使用内部方法 `insert`，参数为 `permanent: false` 和 `isSingleton: true`（此 isSingleton 参数的唯一目的是告诉它是使用 `dependency` 上的依赖，还是使用 `FcBuilderFunc` 上的依赖）。之后，调用 `Get.find()`，立即初始化内存中的实例。

- Get.create：顾名思义，它将"创建"您的依赖！类似于 `Get.put()`，它也调用内部方法 `insert` 来实例化。但是 `permanent` 变为 true，`isSingleton` 变为 false（因为我们正在"创建"依赖，它不可能成为单例实例，这就是为什么是 false）。因为它有 `permanent: true`，我们默认的好处是不会在屏幕之间丢失它！另外，`Get.find()` 不会立即调用，它等待在屏幕中使用时被调用。这样创建是为了利用 `permanent` 参数，因为值得注意，`Get.create()` 的目标是创建不共享的实例，但不会被处理，例如 listView 中的一个按钮，您想为该列表创建一个唯一实例——因此，Get.create 必须与 GetWidget 一起使用。

- Get.lazyPut：顾名思义，这是一个懒加载过程。实例已创建，但不会立即调用使用，它保持等待被调用。与其他方法相反，这里不调用 `insert`。相反，实例被插入到内存的另一个部分，一个负责告诉实例是否可以重新创建的部分，我们称之为"工厂"。如果我们想创建一些以后使用的东西，它不会与现在正在使用的东西混合。这就是 `fenix` 的魔力所在：如果您选择保留 `fenix: false`，并且您的 `smartManagement` 不是 `keepFactory`，那么当使用 `Get.find` 时，实例将把内存中的位置从"工厂"更改为公共实例内存区域。紧接着，默认情况下，它从"工厂"中移除。现在，如果您选择 `fenix: true`，实例将继续存在于这个专用部分，甚至进入公共区域，以便将来再次调用。

## Bindings

这个包最大的区别之一，也许就是可以将路由、状态管理器和依赖管理器完全集成的可能性。
当从堆栈中移除路由时，所有与它相关的控制器、变量和对象实例都会从内存中移除。如果您使用的是流或计时器，它们会自动关闭，您不必担心这些。
在 2.10 版本中，Get 完全实现了 Bindings API。
现在您不再需要使用 init 方法。如果您不想，您甚至不需要键入控制器。您可以在适当的地方启动控制器和服务。
Binding 类是一个将解耦依赖注入的类，同时将路由"绑定"到状态管理器和依赖管理器。
这使得 Get 可以知道当使用特定控制器时正在显示哪个屏幕，并知道在哪里以及如何处理它。
此外，Binding 类将允许您拥有 SmartManager 配置控制。您可以配置依赖项，以便在从堆栈中删除路由时，或在使用它的 widget 被布局时，或者两者都不进行安排。您将有智能依赖管理为您工作，但即使如此，您也可以按照您的意愿进行配置。

### Bindings 类

- 创建一个类并实现 Binding

```dart
class HomeBinding implements Bindings {}
```

您的 IDE 会自动要求您重写 "dependencies" 方法，您只需要点击灯泡，重写方法，并插入您将在该路由上使用的所有类：

```dart
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.put<Service>(()=> Api());
  }
}

class DetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailsController>(() => DetailsController());
  }
}
```

现在您只需要通知路由，您将使用该 binding 来建立路由管理器、依赖项和状态之间的连接。

- 使用命名路由：

```dart
getPages: [
  GetPage(
    name: '/',
    page: () => HomeView(),
    binding: HomeBinding(),
  ),
  GetPage(
    name: '/details',
    page: () => DetailsView(),
    binding: DetailsBinding(),
  ),
];
```

- 使用普通路由：

```dart
Get.to(Home(), binding: HomeBinding());
Get.to(DetailsView(), binding: DetailsBinding())
```

这样，您就不必再担心应用程序的内存管理了，Get 会为您处理。

Binding 类在调用路由时被调用，您可以在 GetMaterialApp 中创建一个 "initialBinding" 来插入所有将要创建的依赖项。

```dart
GetMaterialApp(
  initialBinding: SampleBind(),
  home: Home(),
);
```

### BindingsBuilder

创建 binding 的默认方法是创建一个实现 Bindings 的类。
但或者，您可以使用 `BindingsBuilder` 回调，这样您就可以简单地使用函数来实例化任何您想要的东西。

示例：

```dart
getPages: [
  GetPage(
    name: '/',
    page: () => HomeView(),
    binding: BindingsBuilder(() {
      Get.lazyPut<ControllerX>(() => ControllerX());
      Get.put<Service>(()=> Api());
    }),
  ),
  GetPage(
    name: '/details',
    page: () => DetailsView(),
    binding: BindingsBuilder(() {
      Get.lazyPut<DetailsController>(() => DetailsController());
    }),
  ),
];
```

这样您就可以避免为每条路由创建一个 Binding 类，使这变得更加简单。

两种方式都可以完美地工作，我们希望您使用最适合您的方式。

### SmartManagement

GetX 默认情况下会从内存中处理未使用的控制器，即使发生故障并且使用它的 widget 没有正确处理。
这就是所谓的依赖管理的 `full` 模式。
但是，如果您想更改 GetX 控制类处理的方式，您可以使用 `SmartManagement` 类来设置不同的行为。

#### 如何更改

如果您想更改此配置（通常不需要），这是方法：

```dart
void main () {
  runApp(
    GetMaterialApp(
      smartManagement: SmartManagement.onlyBuilder //here
      home: Home(),
    )
  )
}
```

#### SmartManagement.full

这是默认的。处理未使用且未设置为永久的类。在大多数情况下，您会希望保持此配置不变。如果您是 GetX 新手，请不要更改此配置。

#### SmartManagement.onlyBuilder

使用此选项，只有在 `init:` 中启动的控制器或使用 `Get.lazyPut()` 加载到 Binding 中的控制器才会被处理。

如果您使用 `Get.put()` 或 `Get.putAsync()` 或任何其他方法，SmartManagement 将没有权限排除此依赖项。

使用默认行为，即使使用 "Get.put" 实例化的 widget 也会被移除，这与 SmartManagement.onlyBuilder 不同。

#### SmartManagement.keepFactory

就像 SmartManagement.full 一样，当它不再被使用时，它将删除其依赖项。但是，它将保留它们的工厂，这意味着如果您再次需要该实例，它将重新创建依赖项。

### Bindings 的工作原理

Bindings 创建临时工厂，这些工厂在您点击转到另一个屏幕的那一刻创建，并在屏幕更改动画发生时立即销毁。
这发生得如此之快，以至于分析器甚至无法注册它。
当您再次导航到此屏幕时，将调用新的临时工厂，因此这比使用 SmartManagement.keepFactory 更可取，但如果您不想创建 Bindings，或者想将所有依赖项保留在同一 Binding 上，它肯定会帮助您。
工厂占用很少的内存，它们不持有实例，而是具有您想要的类的"形状"的函数。
这在内存中的成本非常低，但由于此库的目的是使用最少的资源获得最大的性能，Get 默认情况下甚至会删除工厂。
使用对您来说最方便的方式。

## 注意事项

- 如果您使用多个 Bindings，请勿使用 SmartManagement.keepFactory。它被设计为在没有 Bindings 的情况下使用，或者在 GetMaterialApp 的 initialBinding 中链接单个 Binding。

- 使用 Bindings 是完全可选的，如果您愿意，您可以在使用给定控制器的类上使用 `Get.put()` 和 `Get.find()`，没有任何问题。
但是，如果您使用 Services 或任何其他抽象，我建议使用 Bindings 以获得更好的组织。
