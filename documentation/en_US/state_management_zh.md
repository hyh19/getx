- [状态管理](#状态管理)
  - [响应式状态管理器](#响应式状态管理器)
    - [优势](#优势)
    - [最大性能](#最大性能)
    - [声明响应式变量](#声明响应式变量)
        - [拥有响应式状态，很简单](#拥有响应式状态很简单)
    - [在视图中使用值](#在视图中使用值)
    - [重建条件](#重建条件)
    - [.obs 可以在哪里使用](#obs-可以在哪里使用)
    - [关于列表的说明](#关于列表的说明)
    - [为什么我必须使用 .value](#为什么我必须使用-value)
    - [Obx()](#obx)
    - [Workers](#workers)
  - [简单状态管理器](#简单状态管理器)
    - [优势](#优势-1)
    - [用法](#用法)
    - [它如何处理控制器](#它如何处理控制器)
    - [您不再需要 StatefulWidget](#您不再需要-statefulwidget)
    - [它为什么存在](#它为什么存在)
    - [其他使用方式](#其他使用方式)
    - [唯一 ID](#唯一-id)
  - [混合两种状态管理器](#混合两种状态管理器)
  - [StateMixin](#statemixin)
  - [GetBuilder vs GetX vs Obx vs MixinBuilder](#getbuilder-vs-getx-vs-obx-vs-mixinbuilder)

# 状态管理

GetX 不像其他状态管理器那样使用 Streams 或 ChangeNotifier。为什么？除了为 Android、iOS、Web、Windows、macOS 和 Linux 构建应用程序外，使用 GetX 您还可以使用与 Flutter/GetX 相同的语法构建服务器应用程序。为了提高响应时间并减少 RAM 消耗，我们创建了 GetValue 和 GetStream，它们是低延迟解决方案，以较低的操作成本提供大量性能。我们使用这个基础来构建所有资源，包括状态管理。

- _复杂性_：某些状态管理器很复杂，有很多样板代码。使用 GetX，您不必为每个事件定义一个类，代码非常简洁明了，您可以用更少的代码做更多的事情。许多人因为这个问题而放弃了 Flutter，现在他们终于有了一个极其简单的状态管理解决方案。
- _无需代码生成器_：您花费一半的开发时间编写应用程序逻辑。某些状态管理器依赖代码生成器来获得最小可读的代码。更改变量并必须运行 build_runner 可能会降低效率，通常在 flutter clean 之后的等待时间会很长，您将不得不喝很多咖啡。

使用 GetX，一切都是响应式的，不依赖代码生成器，从而提高您开发的各个方面的生产力。

- _它不依赖于 context_：您可能已经需要将视图的 context 发送到控制器，这使得视图与业务逻辑的耦合度很高。您可能不得不在没有 context 的地方使用依赖项，并且必须通过各种类和函数传递 context。这在 GetX 中不存在。您可以在控制器内部访问控制器，而无需任何 context。您不需要为任何东西通过参数发送 context。
- _细粒度控制_：大多数状态管理器都基于 ChangeNotifier。当调用 notifyListeners 时，ChangeNotifier 会通知所有依赖于它的 widget。如果您在一个屏幕上有 40 个 widget，它们都有您的 ChangeNotifier 类的变量，当您更新一个时，所有它们都会重建。

使用 GetX，即使是嵌套的 widget 也会被尊重。如果您有一个 Obx 监视您的 ListView，另一个监视 ListView 内的复选框，当更改 CheckBox 值时，只有它会更新，当更改 List 值时，只有 ListView 会更新。

- _它只在变量真正改变时才重建_：GetX 具有流控制，这意味着如果您显示一个带有 'Paola' 的 Text，如果您再次将可观察变量更改为 'Paola'，widget 将不会重建。这是因为 GetX 知道 'Paola' 已经显示在 Text 中，并且不会进行不必要的重建。

大多数（如果不是全部）当前的状态管理器会在屏幕上重建。

## 响应式状态管理器

响应式编程可能会让许多人望而却步，因为据说它很复杂。GetX 将响应式编程变得非常简单：

- 您不需要创建 StreamControllers。
- 您不需要为每个变量创建 StreamBuilder
- 您不需要为每个状态创建一个类。
- 您不需要为初始值创建一个 get。

使用 Get 进行响应式编程就像使用 setState 一样简单。

假设您有一个 name 变量，并且希望每次更改它时，所有使用它的 widget 都会自动更改。

这是您的 count 变量：

``` dart
var name = 'Jonatas Borges';
```

要使其可观察，您只需要在末尾添加 ".obs"：

``` dart
var name = 'Jonatas Borges'.obs;
```

就是这样。就是这么简单。

从现在开始，我们可能会将这种响应式-".obs"(可观察的)变量称为 _Rx_。

我们在底层做了什么？我们创建了一个 `String` 的 `Stream`，分配了初始值 `"Jonatas Borges"`，我们通知所有使用 `"Jonatas Borges"` 的 widget，它们现在"属于"这个变量，当 _Rx_ 值更改时，它们也必须更改。

这就是 **GetX 的魔力**，感谢 Dart 的能力。

但是，正如我们所知，`Widget` 只能在函数内部更改，因为静态类没有"自动更改"的能力。

您需要创建一个 `StreamBuilder`，订阅此变量以监听更改，如果要在同一作用域中更改多个变量，则需要创建嵌套 `StreamBuilder` 的"级联"，对吗？

不，您不需要 `StreamBuilder`，但您对静态类的看法是对的。

好吧，在视图中，当我们想要更改特定的 Widget 时，通常会有很多样板代码，这是 Flutter 的方式。
使用 **GetX**，您也可以忘记这些样板代码。

`StreamBuilder( … )` ？`initialValue: …` ？`builder: …` ？不，您只需要将此变量放在 `Obx()` Widget 中。

``` dart
Obx (() => Text (controller.name));
```

_您需要记住什么？_ 只有 `Obx(() =>`。

您只是通过箭头函数将该 Widget 传递给 `Obx()`（_Rx_ 的"观察者"）。

`Obx` 非常智能，只有在 `controller.name` 的值更改时才会更改。

如果 `name` 是 `"John"`，并且您将其更改为 `"John"`（`name.value = "John"`），因为它与之前的 `value` 相同，屏幕上不会发生任何变化，`Obx` 为了节省资源，将简单地忽略新值并且不重建 Widget。**这不是很棒吗？**

> 那么，如果我在 `Obx` 中有 5 个 _Rx_（可观察的）变量怎么办？

它只会在**任何**一个更改时更新。

> 如果我在一个类中有 30 个变量，当我更新一个时，它会更新该类中的**所有**变量吗？

不，只是使用该 _Rx_ 变量的**特定 Widget**。

因此，**GetX** 只在 _Rx_ 变量更改其值时更新屏幕。

```

final isOpen = false.obs;

// NOTHING will happen... same value.
void onButtonTap() => isOpen.value=false;
```

### 优势

**GetX()** 在您需要对正在更新的内容进行**细粒度**控制时很有帮助。

如果您不需要 `unique IDs`，因为执行操作时所有变量都会被修改，那么使用 `GetBuilder`，
因为它是一个简单状态更新器（按块，如 `setState()`），只用几行代码编写。
它被设计得很简单，以产生最小的 CPU 影响，只是为了完成单一目的（_State_ 重建）并花费最少的资源。

如果您需要一个**强大的**状态管理器，**GetX** 不会出错。

它不处理变量，而是处理__流__，其中的所有内容在底层都是 `Streams`。

您可以结合使用 _rxDart_，因为一切都是 `Streams`，
您可以监听每个"_Rx_ 变量"的 `event`，
因为其中的一切都是 `Streams`。

这实际上是一种 _BLoC_ 方法，比 _MobX_ 更容易，并且无需代码生成器或装饰器。
您只需使用 `.obs` 就可以将**任何东西**变成_"Observable"_。

### 最大性能

除了具有用于最小重建的智能算法外，**GetX** 使用比较器
来确保状态已更改。

如果您在应用程序中遇到任何错误，并发送重复的状态更改，
**GetX** 将确保它不会崩溃。

使用 **GetX**，状态只有在 `value` 更改时才会更改。
这是 **GetX** 和使用 _MobX 的 `computed`_ 之间的主要区别。
当连接两个__可观察对象__时，如果其中一个更改；该_可观察对象_的监听器也会更改。

使用 **GetX**，如果您连接两个变量，`GetX()`（类似于 `Observer()`）只会在它意味着状态真正更改时重建。

### 声明响应式变量

您有 3 种方法可以将变量转换为"可观察的"。

1 - 第一种是使用 **`Rx{Type}`**。

``` dart
// initial value is recommended, but not mandatory
final name = RxString('');
final isLogged = RxBool(false);
final count = RxInt(0);
final balance = RxDouble(0.0);
final items = RxList<String>([]);
final myMap = RxMap<String, int>({});
```

2 - 第二种是使用 **`Rx`** 并使用 Dart 的泛型，`Rx<Type>`

``` dart
final name = Rx<String>('');
final isLogged = Rx<Bool>(false);
final count = Rx<Int>(0);
final balance = Rx<Double>(0.0);
final number = Rx<Num>(0);
final items = Rx<List<String>>([]);
final myMap = Rx<Map<String, int>>({});

// Custom classes - it can be any class, literally
final user = Rx<User>();
```

3 - 第三种，更实用、更容易且首选的方法，只需将 **`.obs`** 作为 `value` 的属性添加：

``` dart
final name = ''.obs;
final isLogged = false.obs;
final count = 0.obs;
final balance = 0.0.obs;
final number = 0.obs;
final items = <String>[].obs;
final myMap = <String, int>{}.obs;

// Custom classes - it can be any class, literally
final user = User().obs;
```

##### 拥有响应式状态，很简单

正如我们所知，_Dart_ 现在正朝着_空安全_方向发展。
为了做好准备，从现在开始，您应该始终使用**初始值**启动您的 _Rx_ 变量。

> 使用 **GetX** 将变量转换为_可观察的_ + _初始值_是最简单、最实用的方法。

您只需在变量末尾添加一个 " `.obs` "，**就是这样**，您已经使其可观察，
其 `.value`，嗯，将是_初始值_）。

### 在视图中使用值

``` dart
// controller file
final count1 = 0.obs;
final count2 = 0.obs;
int get sum => count1.value + count2.value;
```

``` dart
// view file
GetX<Controller>(
  builder: (controller) {
    print("count 1 rebuild");
    return Text('${controller.count1.value}');
  },
),
GetX<Controller>(
  builder: (controller) {
    print("count 2 rebuild");
    return Text('${controller.count2.value}');
  },
),
GetX<Controller>(
  builder: (controller) {
    print("count 3 rebuild");
    return Text('${controller.sum}');
  },
),
```

如果我们递增 `count1.value++`，它将打印：

- `count 1 rebuild`

- `count 3 rebuild`

因为 `count1` 的值为 `1`，并且 `1 + 0 = 1`，更改了 `sum` getter 值。

如果我们更改 `count2.value++`，它将打印：

- `count 2 rebuild`

- `count 3 rebuild`

因为 `count2.value` 已更改，`sum` 的结果现在是 `2`。

- 注意：默认情况下，第一个事件将重建 widget，即使它是相同的 `value`。

这种行为的存在是由于布尔变量。

想象一下您这样做了：

``` dart
var isLogged = false.obs;
```

然后，您检查用户是否"已登录"以在 `ever` 中触发事件。

``` dart
@override
onInit() async {
  ever(isLogged, fireRoute);
  isLogged.value = await Preferences.hasToken();
}

fireRoute(logged) {
  if (logged) {
   Get.off(Home());
  } else {
   Get.off(Login());
  }
}
```

如果 `hasToken` 是 `false`，`isLogged` 不会有任何更改，因此 `ever()` 永远不会被调用。
为了避免这种行为，对_可观察对象_的第一次更改将始终触发事件，
即使它包含相同的 `.value`。

如果您愿意，可以使用以下方法删除此行为：
 `isLogged.firstRebuild = false;`

### 重建条件

此外，Get 提供了精细的状态控制。您可以根据某个条件来条件化事件（例如将对象添加到列表）。

``` dart
// First parameter: condition, must return true or false.
// Second parameter: the new value to apply if the condition is true.
list.addIf(item < limit, item);
```

无需装饰，无需代码生成器，无需复杂化 :smile:

您知道 Flutter 的计数器应用程序吗？您的 Controller 类可能如下所示：

``` dart
class CountController extends GetxController {
  final count = 0.obs;
}
```

使用简单的：

``` dart
controller.count.value++
```

您可以更新 UI 中的计数器变量，无论它存储在哪里。

### .obs 可以在哪里使用

您可以将任何东西转换为 obs。有两种方法：

- 您可以将类值转换为 obs

``` dart
class RxUser {
  final name = "Camila".obs;
  final age = 18.obs;
}
```

- 或者您可以将整个类转换为可观察的

``` dart
class User {
  User({String name, int age});
  var name;
  var age;
}

// when instantianting:
final user = User(name: "Camila", age: 18).obs;
```

### 关于列表的说明

列表是完全可观察的，其中的对象也是如此。这样，如果您向列表添加值，它将自动重建使用它的 widget。

您也不需要为列表使用 ".value"，令人惊叹的 dart api 允许我们删除它。
不幸的是，像 String 和 int 这样的原始类型无法扩展，这使得必须使用 .value，但如果您为这些使用 getter 和 setter，这不会有问题。

``` dart
// On the controller
final String title = 'User Info:'.obs
final list = List<User>().obs;

// on the view
Text(controller.title.value), // String need to have .value in front of it
ListView.builder (
  itemCount: controller.list.length // lists don't need it
)
```

当您使自己的类可观察时，更新它们的方式不同：

``` dart
// on the model file
// we are going to make the entire class observable instead of each attribute
class User() {
  User({this.name = '', this.age = 0});
  String name;
  int age;
}

// on the controller file
final user = User().obs;
// when you need to update the user variable:
user.update( (user) { // this parameter is the class itself that you want to update
user.name = 'Jonny';
user.age = 18;
});
// an alternative way of update the user variable:
user(User(name: 'João', age: 35));

// on view:
Obx(()=> Text("Name ${user.value.name}: Age: ${user.value.age}"))
// you can also access the model values without the .value:
user().name; // notice that is the user variable, not the class (variable has lowercase u)
```

如果您不想，您不必使用 sets。您可以使用 "assign" 和 "assignAll" api。
"assign" api 将清除您的列表，并添加您想要在那里开始的单个对象。
"assignAll" api 将清除现有列表并添加您注入其中的任何可迭代对象。

### 为什么我必须使用 .value

我们可以通过简单的装饰和代码生成器来消除对 `String` 和 `int` 使用 'value' 的义务，但此库的目的正是避免外部依赖。我们想提供一个随时可用的编程环境，涉及基本要素（路由、依赖项和状态的管理），以简单、轻量级和高性能的方式，无需外部包。

您可以在 pubspec 中添加 3 个字母（get）和一个冒号，然后开始编程。默认包含的所有解决方案，从路由管理到状态管理，都旨在提高易用性、生产力和性能。

这个库的总重量小于单个状态管理器的重量，即使它是一个完整的解决方案，这就是您必须理解的。

如果您对 `.value` 感到困扰，并且喜欢代码生成器，MobX 是一个很好的替代方案，您可以将其与 Get 结合使用。对于那些想在 pubspec 中添加单个依赖项并开始编程而不担心包的版本与另一个不兼容，或者状态更新的错误是来自状态管理器还是依赖项，或者仍然不想担心控制器的可用性，无论是字面上的"只是编程"，get 都是完美的。

如果您对 MobX 代码生成器没有问题，或者对 BLoC 样板没有问题，您可以简单地使用 Get 进行路由，并忘记它有状态管理器。Get SEM 和 RSM 是出于需要而诞生的，我的公司有一个超过 90 个控制器的项目，代码生成器在相当好的机器上执行 Flutter Clean 后完成其任务需要超过 30 分钟，如果您的项目有 5、10、15 个控制器，任何状态管理器都能很好地满足您的需求。如果您有一个非常大的项目，并且代码生成器对您来说是个问题，那么您已经获得了这个解决方案。

显然，如果有人想为项目做出贡献并创建代码生成器或类似的东西，我将在此 readme 中链接作为替代方案，我的需求不是所有开发人员的需求，但现在我说，已经有一些很好的解决方案可以做到这一点，比如 MobX。

### Obx()

在 Get 中使用 Bindings 进行类型标注是不必要的。您可以使用 Obx widget 而不是 GetX，它只接收创建 widget 的匿名函数。
显然，如果您不使用类型，您需要有一个控制器实例来使用变量，或使用 `Get.find<Controller>()` .value 或 Controller.to.value 来检索值。

### Workers

Workers 将帮助您，在事件发生时触发特定的回调。

``` dart
/// Called every time `count1` changes.
ever(count1, (_) => print("$_ has been changed"));

/// Called only first time the variable $_ is changed
once(count1, (_) => print("$_ was changed once"));

/// Anti DDos - Called every time the user stops typing for 1 second, for example.
debounce(count1, (_) => print("debouce$_"), time: Duration(seconds: 1));

/// Ignore all changes within 1 second.
interval(count1, (_) => print("interval $_"), time: Duration(seconds: 1));
```

所有 workers（除了 `debounce`）都有一个 `condition` 命名参数，它可以是 `bool` 或返回 `bool` 的回调。
此 `condition` 定义何时执行 `callback` 函数。

所有 workers 返回一个 `Worker` 实例，您可以使用它来取消（通过 `dispose()`）worker。

- **`ever`**

每次 _Rx_ 变量发出新值时都会调用。

- **`everAll`**

与 `ever` 非常相似，但它接受 _Rx_ 值的 `List`。每次其变量更改时都会调用。就是这样。

- **`once`**

'once' 只在变量第一次更改时调用。

- **`debounce`**

'debounce' 在搜索函数中非常有用，您只想在用户完成输入时调用 API。如果用户输入 "Jonny"，您将在 API 中进行 5 次搜索，按字母 J、o、n、n 和 y。使用 Get 不会发生这种情况，因为您将有一个 "debounce" Worker，它只会在输入结束时触发。

- **`interval`**

'interval' 与 debounce 不同。如果用户在 1 秒内对变量进行 1000 次更改，debounce 只会在规定的计时器（默认值为 800 毫秒）之后发送最后一个。Interval 相反，会在规定的时间内忽略所有用户操作。如果您在 1 分钟内发送事件，每秒 1000 次，debounce 只会在用户停止发送事件时发送最后一个。interval 将每秒传递事件，如果设置为 3 秒，它将在那一分钟内传递 20 个事件。建议避免滥用，在用户可以快速点击某些内容并获得某些优势的函数中（想象用户可以通过点击某些内容来赚取硬币，如果他在同一分钟内点击 300 次，他将有 300 个硬币，使用 interval，您可以设置 3 秒的时间范围，即使点击 300 次或一千次，他在 1 分钟内最多只能获得 20 个硬币，点击 300 次或 100 万次）。debounce 适用于反 DDoS，适用于搜索等函数，其中对 onChange 的每次更改都会导致对您的 api 的查询。Debounce 将等待用户停止输入名称，然后发出请求。如果在上文提到的硬币场景中使用它，用户只会赢得 1 个硬币，因为它只在用户"暂停"规定时间时执行。

- 注意：Workers 应该始终在启动 Controller 或 Class 时使用，因此它应该始终在 onInit（推荐）、Class 构造函数或 StatefulWidget 的 initState 中（在大多数情况下不推荐这种做法，但它不应该有任何副作用）。

## 简单状态管理器

Get 有一个极其轻量且简单的状态管理器，它不使用 ChangeNotifier，将满足需求，特别是对于 Flutter 新手，并且不会给大型应用程序带来问题。

GetBuilder 正是针对多重状态控制。想象一下，您向购物车添加了 30 个产品，您点击删除一个，同时列表更新，价格更新，购物车中的徽章更新为较小的数字。这种方法使 GetBuilder 非常出色，因为它将状态分组并一次性更改它们，而无需任何"计算逻辑"。GetBuilder 就是为这种情况而创建的，因为对于短暂的状态更改，您可以使用 setState，您不需要为此使用状态管理器。

这样，如果您想要一个单独的控制器，您可以为它分配 ID，或使用 GetX。这取决于您，记住您拥有的"单独"widget 越多，GetX 的性能就越突出，而当存在多重状态更改时，GetBuilder 的性能应该更优越。

### 优势

1. 只更新所需的 widget。

2. 不使用 changeNotifier，它是使用更少内存的状态管理器（接近 0mb）。

3. 忘记 StatefulWidget！使用 Get，您永远不需要它。使用其他状态管理器，您可能必须使用 StatefulWidget 来获取 Provider、BLoC、MobX Controller 等的实例。但是您是否曾经停下来思考过，您的 appBar、您的 scaffold 以及类中的大多数 widget 都是无状态的？那么，如果您只能保存有状态的 Widget 的状态，为什么要保存整个类的状态？Get 也解决了这个问题。创建一个 Stateless 类，使所有内容都是无状态的。如果您需要更新单个组件，请用 GetBuilder 包装它，其状态将得到维护。

4. 真正组织您的项目！控制器不能在您的 UI 中，将您的 TextEditController 或您使用的任何控制器放在您的 Controller 类中。

5. 您需要在 widget 渲染后立即触发事件来更新它吗？GetBuilder 具有 "initState" 属性，就像 StatefulWidget 一样，您可以直接从控制器调用事件，不再需要将事件放在 initState 中。

6. 您需要触发诸如关闭流、计时器等操作吗？GetBuilder 还具有 dispose 属性，您可以在该 widget 被销毁时立即调用事件。

7. 仅在必要时使用流。您可以在控制器内正常使用 StreamControllers，也可以正常使用 StreamBuilder，但请记住，流会合理消耗内存，响应式编程很漂亮，但您不应该滥用它。同时打开 30 个流可能比 changeNotifier 更糟糕（而 changeNotifier 非常糟糕）。

8. 更新 widget 而不为此花费 ram。Get 只存储 GetBuilder 创建者 ID，并在必要时更新该 GetBuilder。即使有数千个 GetBuilder，get ID 存储在内存中的内存消耗也非常低。当您创建新的 GetBuilder 时，您实际上是在共享具有创建者 ID 的 GetBuilder 的状态。不会为每个 GetBuilder 创建新状态，这为大型应用程序节省了大量 ram。基本上，您的应用程序将完全是无状态的，少数将有状态的 Widget（在 GetBuilder 内）将具有单一状态，因此更新一个将更新所有。状态只有一个。

9. Get 是全知的，在大多数情况下，它确切知道何时将控制器从内存中取出。您不必担心何时处理控制器，Get 知道执行此操作的最佳时间。

### 用法

``` dart
// Create controller class and extends GetxController
class Controller extends GetxController {
  int counter = 0;
  void increment() {
    counter++;
    update(); // use update() to update counter variable on UI when increment be called
  }
}
// On your Stateless/Stateful class, use GetBuilder to update Text when increment be called
GetBuilder<Controller>(
  init: Controller(), // INIT IT ONLY THE FIRST TIME
  builder: (_) => Text(
    '${_.counter}',
  ),
)
//Initialize your controller only the first time. The second time you are using ReBuilder for the same controller, do not use it again. Your controller will be automatically removed from memory as soon as the widget that marked it as 'init' is deployed. You don't have to worry about that, Get will do it automatically, just make sure you don't start the same controller twice.
```

**完成！**

- 您已经学会了如何使用 Get 管理状态。

- 注意：您可能想要更大的组织，而不使用 init 属性。为此，您可以创建一个类并扩展 Binding 类，并在其中提及将在该路由内创建的控制器。控制器不会在那个时候创建，相反，这只是一个声明，以便第一次使用 Controller 时，Get 知道在哪里查找。Get 将保持 lazyLoad，并将在不再需要时继续处理 Controllers。请参阅 pub.dev 示例以了解其工作原理。

如果您导航多个路由并需要先前使用的控制器中的数据，您只需要再次使用 GetBuilder（不使用 init）：

``` dart
class OtherClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GetBuilder<Controller>(
          builder: (s) => Text('${s.counter}'),
        ),
      ),
    );
  }

```

如果您需要在许多其他地方使用控制器，并且在 GetBuilder 之外，只需在控制器中创建一个 get 即可轻松获得它。（或使用 `Get.find<Controller>()`）

``` dart
class Controller extends GetxController {

  /// You do not need that. I recommend using it just for ease of syntax.
  /// with static method: Controller.to.increment();
  /// with no static method: Get.find<Controller>().increment();
  /// There is no difference in performance, nor any side effect of using either syntax. Only one does not need the type, and the other the IDE will autocomplete it.
  static Controller get to => Get.find(); // add this line

  int counter = 0;
  void increment() {
    counter++;
    update();
  }
}
```

然后您可以直接访问控制器，这样：

``` dart
FloatingActionButton(
  onPressed: () {
    Controller.to.increment(),
  } // This is incredibly simple!
  child: Text("${Controller.to.counter}"),
),
```

当您按下 FloatingActionButton 时，所有正在监听 'counter' 变量的 widget 都会自动更新。

### 它如何处理控制器

假设我们有这个：

 `Class a => Class B (has controller X) => Class C (has controller X)`

在类 A 中，控制器尚未在内存中，因为您还没有使用它（Get 是 lazyLoad）。在类 B 中，您使用了控制器，它进入了内存。在类 C 中，您使用了与类 B 中相同的控制器，Get 将与控制器 C 共享控制器 B 的状态，并且同一个控制器仍在内存中。如果您关闭屏幕 C 和屏幕 B，Get 将自动将控制器 X 从内存中取出并释放资源，因为类 A 不使用控制器。如果您再次导航到 B，控制器 X 将再次进入内存，如果不是去类 C，而是再次返回到类 A，Get 将以同样的方式将控制器从内存中取出。如果类 C 不使用控制器，并且您将类 B 从内存中取出，则没有类会使用控制器 X，同样它将被处理。唯一可能干扰 Get 的例外是，如果您意外地从路由中删除 B，并尝试在 C 中使用控制器。在这种情况下，B 中控制器的创建者 ID 被删除，Get 被编程为从内存中删除每个没有创建者 ID 的控制器。如果您打算这样做，请在类 B 的 GetBuilder 中添加 "autoRemove: false" 标志，并在类 C 的 GetBuilder 中使用 adoptID = true;。

### 您不再需要 StatefulWidget

使用 StatefulWidget 意味着不必要地存储整个屏幕的状态，甚至因为如果您需要最小程度地重建 widget，您会将其嵌入 Consumer/Observer/BlocProvider/GetBuilder/GetX/Obx 中，这将是另一个 StatefulWidget。
StatefulWidget 类比 StatelessWidget 大，这将分配更多 RAM，这对于一个或两个类可能不会有显著差异，但当您有 100 个类时，肯定会有所不同！
除非您需要使用 mixin，如 TickerProviderStateMixin，否则使用 Get 时完全不需要使用 StatefulWidget。

您可以直接从 GetBuilder 调用 StatefulWidget 的所有方法。
例如，如果您需要调用 initState() 或 dispose() 方法，可以直接调用它们；

``` dart
GetBuilder<Controller>(
  initState: (_) => Controller.to.fetchApi(),
  dispose: (_) => Controller.to.closeStreams(),
  builder: (s) => Text('${s.username}'),
),
```

比这更好的方法是直接从控制器使用 onInit() 和 onClose() 方法。

``` dart
@override
void onInit() {
  fetchApi();
  super.onInit();
}
```

- 注意：如果您想在第一次调用控制器时启动方法，您不需要为此使用构造函数，实际上，使用像 Get 这样面向性能的包，这接近于不良实践，因为它偏离了创建或分配控制器的逻辑（如果您创建此控制器的实例，构造函数将立即被调用，您将在使用之前填充控制器，您正在分配未使用的内存，这绝对会损害此库的原则）。onInit() 方法；和 onClose()；就是为此而创建的，它们将在创建 Controller 时或在第一次使用时被调用，这取决于您是否使用 Get.lazyPut。例如，如果您想调用 API 来填充数据，您可以忘记 initState/dispose 的旧方法，只需在 onInit 中开始调用 api，如果您需要执行任何命令（如关闭流），请使用 onClose()。

### 它为什么存在

此包的目的正是为您提供路由导航、依赖项和状态管理的完整解决方案，使用尽可能少的依赖项，具有高度解耦。Get 在其内部整合了所有高级和低级 Flutter API，以确保您以尽可能少的耦合工作。我们将所有内容集中在一个包中，以确保您的项目中没有任何类型的耦合。这样，您可以在视图中只放置 widget，让处理业务逻辑的团队成员自由工作，处理业务逻辑而不依赖于 View 的任何元素。这提供了一个更清洁的工作环境，这样您的部分团队只处理 widget，而不必担心向控制器发送数据，而您的部分团队只处理业务逻辑的广度，而不依赖于视图的任何元素。

所以简化一下：
您不需要在 initState 中调用方法并通过参数将它们发送到控制器，也不需要使用控制器构造函数，您有 onInit() 方法，它会在正确的时间被调用，以便您启动服务。
您不需要调用设备，您有 onClose() 方法，它将在控制器不再需要并将从内存中删除的确切时刻被调用。这样，将视图留给 widget，避免其中的任何业务逻辑。

不要在 GetxController 内调用 dispose 方法，它不会做任何事情，请记住控制器不是 Widget，您不应该"处理"它，它会被 Get 自动智能地从内存中删除。如果您在其上使用了任何流并想关闭它，只需将其插入 close 方法。示例：

``` dart
class Controller extends GetxController {
  StreamController<User> user = StreamController<User>();
  StreamController<String> name = StreamController<String>();

  /// close stream = onClose method, not dispose.
  @override
  void onClose() {
    user.close();
    name.close();
    super.onClose();
  }
}
```

控制器生命周期：

- onInit() 创建它的地方。
- onClose() 关闭它以准备删除方法的地方
- deleted：您无法访问此 API，因为它实际上是从内存中删除控制器。它实际上被删除，不留任何痕迹。

### 其他使用方式

您可以直接在 GetBuilder 值上使用 Controller 实例：

``` dart
GetBuilder<Controller>(
  init: Controller(),
  builder: (value) => Text(
    '${value.counter}', //here
  ),
),
```

您可能还需要在 GetBuilder 之外使用控制器实例，您可以使用这些方法来实现：

``` dart
class Controller extends GetxController {
  static Controller get to => Get.find();
[...]
}
// on you view:
GetBuilder<Controller>(  
  init: Controller(), // use it only first time on each controller
  builder: (_) => Text(
    '${Controller.to.counter}', //here
  )
),
```

或者

``` dart
class Controller extends GetxController {
 // static Controller get to => Get.find(); // with no static get
[...]
}
// on stateful/stateless class
GetBuilder<Controller>(  
  init: Controller(), // use it only first time on each controller
  builder: (_) => Text(
    '${Get.find<Controller>().counter}', //here
  ),
),
```

- 您可以使用"非规范"方法来实现这一点。如果您使用其他依赖管理器，如 get_it、modular 等，并且只想传递控制器实例，您可以这样做：

``` dart
Controller controller = Controller();
[...]
GetBuilder<Controller>(
  init: controller, //here
  builder: (_) => Text(
    '${controller.counter}', // here
  ),
),

```

### 唯一 ID

如果您想使用 GetBuilder 细化 widget 的更新控制，可以为它们分配唯一 ID：

``` dart
GetBuilder<Controller>(
  id: 'text'
  init: Controller(), // use it only first time on each controller
  builder: (_) => Text(
    '${Get.find<Controller>().counter}', //here
  ),
),
```

并以这种形式更新它：

``` dart
update(['text']);
```

您还可以为更新设置条件：

``` dart
update(['text'], counter < 10);
```

GetX 会自动执行此操作，并且只重建使用已更改的确切变量的 widget，如果您将变量更改为与之前相同的值，并且这不意味着状态更改，GetX 不会重建 widget 以节省内存和 CPU 周期（屏幕上显示 3，您再次将变量更改为 3。在大多数状态管理器中，这会导致新的重建，但使用 GetX，widget 只会在其状态实际更改时再次重建）。

## 混合两种状态管理器

有些人提出了功能请求，因为他们想只使用一种类型的响应式变量，以及其他机制，并且需要为此在 GetBuilder 中插入 Obx。考虑到这一点，创建了 MixinBuilder。它允许通过更改 ".obs" 变量进行响应式更改，以及通过 update() 进行机械更新。但是，在 4 个 widget 中，它是消耗最多资源的，因为除了具有订阅以从其子项接收更改事件外，它还订阅其控制器的 update 方法。

扩展 GetxController 很重要，因为它们有生命周期，并且可以在 onInit() 和 onClose() 方法中"启动"和"结束"事件。您可以使用任何类来实现这一点，但我强烈建议您使用 GetxController 类来放置变量，无论它们是否可观察。

## StateMixin

处理 `UI` 状态的另一种方法是使用 `StateMixin<T>`。
要实现它，使用 `with` 将 `StateMixin<T>` 添加到允许 T 模型的控制器。

``` dart
class Controller extends GetController with StateMixin<User>{}
```

`change()` 方法可以随时更改状态。
只需以这种方式传递数据和状态：

```dart
change(data, status: RxStatus.success());
```

RxStatus 允许这些状态：

``` dart
RxStatus.loading();
RxStatus.success();
RxStatus.empty();
RxStatus.error('message');
```

要在 UI 中表示它，请使用：

```dart
class OtherClass extends GetView<Controller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: controller.obx(
        (state)=>Text(state.name),
        
        // here you can put your custom loading indicator, but
        // by default would be Center(child:CircularProgressIndicator())
        onLoading: CustomLoadingIndicator(),
        onEmpty: Text('No data found'),

        // here also you can set your own error widget, but by
        // default will be an Center(child:Text(error))
        onError: (error)=>Text(error),
      ),
    );
}
```

## GetBuilder vs GetX vs Obx vs MixinBuilder

在我从事编程工作的十年中，我学到了一些宝贵的经验。

我第一次接触响应式编程时感觉"哇，这太不可思议了"，事实上响应式编程确实令人难以置信。
但是，它并不适合所有情况。通常您只需要同时更改 2 或 3 个 widget 的状态，或短暂的状态更改，在这种情况下，响应式编程并不坏，但它不合适。

响应式编程具有更高的 RAM 消耗，可以通过单独的工作流来补偿，这将确保只重建一个 widget 并在必要时重建，但创建一个包含 80 个对象的列表，每个对象都有多个流，这不是一个好主意。打开 dart inspect 并检查 StreamBuilder 消耗了多少，您就会明白我想告诉您的内容。

考虑到这一点，我创建了简单状态管理器。它很简单，这正是您应该要求的：以简单的方式和最经济的方式按块更新状态。

GetBuilder 在 RAM 方面非常经济，几乎没有比它更经济的方法（至少我无法想象，如果存在，请告诉我们）。

但是，GetBuilder 仍然是一个机械状态管理器，您需要调用 update()，就像您需要调用 Provider 的 notifyListeners() 一样。

还有其他情况，响应式编程确实很有趣，不使用它就像重新发明轮子。考虑到这一点，创建了 GetX 以提供状态管理器中最现代和先进的一切。它只更新必要的内容并在必要时更新，如果您有错误并同时发送 300 个状态更改，GetX 将过滤并仅在状态实际更改时更新屏幕。

GetX 仍然比任何其他响应式状态管理器更经济，但它比 GetBuilder 消耗更多 RAM。考虑到这一点并旨在最大化资源消耗，创建了 Obx。与 GetX 和 GetBuilder 不同，您无法在 Obx 内初始化控制器，它只是一个带有 StreamSubscription 的 Widget，用于从其子项接收更改事件，仅此而已。它比 GetX 更经济，但输给了 GetBuilder，这是可以预期的，因为它是响应式的，而 GetBuilder 具有最简化的方法，即存储 widget 的 hashcode 及其 StateSetter。使用 Obx，您不需要编写控制器类型，并且可以听到来自多个不同控制器的更改，但它需要在此之前初始化，要么使用本 readme 开头的示例方法，要么使用 Bindings 类。
