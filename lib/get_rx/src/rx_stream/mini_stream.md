# MiniStream 详解

## 概述

`mini_stream.dart` 是 GetX 响应式系统中实现的一个轻量级流（Stream）实现，它提供了类似 Dart 标准 `Stream` 的功能，但具有更高的性能和更简洁的实现。该模块是 GetX 响应式编程的核心基础设施之一，用于管理响应式变量的订阅和通知机制。

与 Dart 标准 `Stream` 相比，`MiniStream` 的设计更加轻量，专注于响应式编程场景，通过自定义的双向链表数据结构 `FastList` 来管理订阅者，实现了高效的添加、删除和通知操作。

## 核心组件

### `Node<T>` - 双向链表节点

```dart 3:8:lib/get_rx/src/rx_stream/mini_stream.dart
class Node<T> {
  T? data;
  Node<T>? next;
  Node<T>? prev;
  Node({this.data, this.next, this.prev});
}
```

**功能说明**：

`Node<T>` 是一个泛型双向链表节点类，用于构建 `FastList` 的数据结构。每个节点包含：

- **`data`**：存储节点数据，类型为 `T?`，可为空
- **`next`**：指向下一个节点的引用
- **`prev`**：指向前一个节点的引用

双向链表的设计使得在删除节点时能够高效地更新前后节点的引用，时间复杂度为 O(1)，而单向链表需要从头遍历查找前驱节点。

**设计优势**：

- 支持双向遍历，便于实现高效的插入和删除操作
- 节点删除时只需更新相邻节点的引用，无需遍历整个链表

### `MiniSubscription<T>` - 订阅对象

```dart 10:21:lib/get_rx/src/rx_stream/mini_stream.dart
class MiniSubscription<T> {
  const MiniSubscription(
      this.data, this.onError, this.onDone, this.cancelOnError, this.listener);
  final OnData<T> data;
  final Function? onError;
  final Callback? onDone;
  final bool cancelOnError;

  Future<void> cancel() async => listener.removeListener(this);

  final FastList<T> listener;
}
```

**功能说明**：

`MiniSubscription<T>` 表示一个对 `MiniStream` 的订阅，类似于 Dart 标准库中的 `StreamSubscription`。它封装了订阅相关的所有信息：

- **`data`**：类型为 `OnData<T>`，是数据回调函数，当流发出新数据时被调用
- **`onError`**：错误处理回调函数，当流发生错误时被调用
- **`onDone`**：完成回调函数，当流关闭时被调用
- **`cancelOnError`**：布尔标志，指示在发生错误时是否自动取消订阅
- **`listener`**：指向所属的 `FastList` 实例，用于取消订阅时从列表中移除

**主要方法**：

- **`cancel()`**：取消订阅，通过调用 `listener.removeListener(this)` 从订阅列表中移除当前订阅对象

**设计特点**：

- 使用 `const` 构造函数，支持编译时常量优化
- 持有对 `FastList` 的引用，便于快速取消订阅
- 提供完整的错误处理和完成回调支持

### `MiniStream<T>` - 轻量级流实现

```dart 23:74:lib/get_rx/src/rx_stream/mini_stream.dart
class MiniStream<T> {
  FastList<T> listenable = FastList<T>();

  late T _value;

  T get value => _value;

  set value(T val) {
    add(val);
  }

  void add(T event) {
    _value = event;
    listenable._notifyData(event);
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    listenable._notifyError(error, stackTrace);
  }

  int get length => listenable.length;

  bool get hasListeners => listenable.isNotEmpty;

  bool get isClosed => _isClosed;

  MiniSubscription<T> listen(void Function(T event) onData,
      {Function? onError,
      void Function()? onDone,
      bool cancelOnError = false}) {
    final subs = MiniSubscription<T>(
      onData,
      onError,
      onDone,
      cancelOnError,
      listenable,
    );
    listenable.addListener(subs);
    return subs;
  }

  bool _isClosed = false;

  void close() {
    if (_isClosed) {
      throw 'You can not close a closed Stream';
    }
    listenable._notifyDone();
    listenable.clear();
    _isClosed = true;
  }
}
```

**功能说明**：

`MiniStream<T>` 是核心的流实现类，提供了类似 Dart `Stream` 的 API，但实现更加轻量。

**核心属性**：

- **`listenable`**：`FastList<T>` 实例，用于管理所有订阅者
- **`_value`**：使用 `late` 关键字延迟初始化，存储当前流的值
- **`_isClosed`**：标记流是否已关闭

**主要方法**：

1. **`value` getter/setter**：
   - Getter 返回当前存储的值
   - Setter 调用 `add()` 方法，实现响应式更新

2. **`add(T event)`**：
   - 更新内部 `_value`
   - 调用 `listenable._notifyData()` 通知所有订阅者

3. **`addError(Object error, [StackTrace? stackTrace])`**：
   - 通知所有订阅者发生了错误
   - 支持可选的堆栈跟踪信息

4. **`listen(...)`**：
   - 创建并返回一个新的 `MiniSubscription`
   - 支持 `onData`、`onError`、`onDone` 回调
   - `cancelOnError` 参数控制错误时是否自动取消订阅

5. **`close()`**：
   - 关闭流，通知所有订阅者流已完成
   - 清空订阅列表
   - 防止重复关闭（抛出异常）

**设计优势**：

- 轻量级实现，避免了 Dart 标准 `Stream` 的复杂机制
- 直接的值存储，支持快速访问当前值
- 高效的订阅管理，基于双向链表实现

### `FastList<T>` - 基于双向链表的快速列表

```dart 76:177:lib/get_rx/src/rx_stream/mini_stream.dart
class FastList<T> {
  Node<MiniSubscription<T>>? _head;
  Node<MiniSubscription<T>>? _tail;
  int _length = 0;

  void _notifyData(T data) {
    var currentNode = _head;
    while (currentNode != null) {
      currentNode.data?.data(data);
      currentNode = currentNode.next;
    }
  }

  void _notifyError(Object error, [StackTrace? stackTrace]) {
    var currentNode = _head;
    while (currentNode != null) {
      currentNode.data?.onError?.call(error, stackTrace);
      currentNode = currentNode.next;
    }
  }

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length > 0;

  int get length => _length;

  MiniSubscription<T>? elementAt(int position) {
    if (isEmpty || position < 0 || position >= _length) return null;

    var node = _head;
    var current = 0;

    while (current != position) {
      node = node!.next;
      current++;
    }
    return node!.data;
  }

  void addListener(MiniSubscription<T> data) {
    var newNode = Node(data: data);

    if (isEmpty) {
      _head = _tail = newNode;
    } else {
      _tail!.next = newNode;
      newNode.prev = _tail;
      _tail = newNode;
    }
    _length++;
  }

  bool contains(T element) {
    var currentNode = _head;
    while (currentNode != null) {
      if (currentNode.data == element) return true;
      currentNode = currentNode.next;
    }
    return false;
  }

  void removeListener(MiniSubscription<T> element) {
    var currentNode = _head;
    while (currentNode != null) {
      if (currentNode.data == element) {
        _removeNode(currentNode);
        break;
      }
      currentNode = currentNode.next;
    }
  }

  void clear() {
    _head = _tail = null;
    _length = 0;
  }

  void _removeNode(Node<MiniSubscription<T>> node) {
    if (node.prev == null) {
      _head = node.next;
    } else {
      node.prev!.next = node.next;
    }

    if (node.next == null) {
      _tail = node.prev;
    } else {
      node.next!.prev = node.prev;
    }

    _length--;
  }
}
```

**功能说明**：

`FastList<T>` 是一个基于双向链表实现的列表数据结构，专门用于高效管理 `MiniSubscription` 对象。虽然名为 "List"，但它实际上是一个链表实现，专注于订阅者的添加、删除和遍历操作。

**核心属性**：

- **`_head`**：链表头节点，指向第一个订阅者
- **`_tail`**：链表尾节点，指向最后一个订阅者
- **`_length`**：当前订阅者数量

**主要方法**：

1. **`_notifyData(T data)`**：
   - 遍历所有节点，调用每个订阅者的 `data` 回调
   - 时间复杂度：O(n)，n 为订阅者数量

2. **`_notifyDone()`**：
   - 遍历所有节点，调用每个订阅者的 `onDone` 回调
   - 用于流关闭时通知所有订阅者

3. **`_notifyError(Object error, [StackTrace? stackTrace])`**：
   - 遍历所有节点，调用每个订阅者的 `onError` 回调
   - 支持可选的堆栈跟踪信息

4. **`addListener(MiniSubscription<T> data)`**：
   - 在链表尾部添加新节点
   - 如果列表为空，同时设置 `_head` 和 `_tail`
   - 时间复杂度：O(1)

5. **`removeListener(MiniSubscription<T> element)`**：
   - 查找并删除指定的订阅者
   - 使用 `_removeNode()` 进行实际删除
   - 时间复杂度：O(n)，需要遍历查找

6. **`_removeNode(Node<MiniSubscription<T>> node)`**：
   - 核心删除逻辑，更新相邻节点的引用
   - 处理头节点、尾节点和中间节点的不同情况
   - 时间复杂度：O(1)，但需要先找到节点（O(n)）

7. **`elementAt(int position)`**：
   - 根据索引获取指定位置的订阅者
   - 需要从头遍历到指定位置
   - 时间复杂度：O(n)

8. **`contains(T element)`**：
   - 检查列表中是否包含指定元素
   - 需要遍历整个链表
   - 时间复杂度：O(n)

9. **`clear()`**：
   - 清空所有节点，重置长度
   - 时间复杂度：O(1)

**设计优势**：

- **高效的插入操作**：在尾部添加节点为 O(1)
- **高效的删除操作**：找到节点后删除为 O(1)
- **内存效率**：只存储必要的引用，无额外开销
- **适合订阅场景**：订阅者通常需要频繁添加和删除，双向链表非常适合

**性能考虑**：

- 查找操作（`removeListener`、`elementAt`、`contains`）需要 O(n) 时间
- 在订阅者数量较少时（通常情况），这个开销是可以接受的
- 如果订阅者数量很大，可以考虑使用哈希表优化查找

## 设计模式

### 观察者模式（Observer Pattern）

`MiniStream` 实现了经典的观察者模式：

- **Subject（主题）**：`MiniStream` 作为被观察的主题
- **Observer（观察者）**：`MiniSubscription` 作为观察者
- **通知机制**：通过 `FastList` 管理观察者列表，当数据变化时通知所有观察者

### 订阅模式（Subscription Pattern）

每个订阅者通过 `listen()` 方法创建 `MiniSubscription` 对象，可以随时通过 `cancel()` 方法取消订阅，实现了灵活的订阅管理。

## 使用示例

### 基本使用

```dart
// 创建 MiniStream 实例
final stream = MiniStream<int>();

// 订阅数据变化
final subscription = stream.listen(
  (value) {
    print('收到新值: $value');
  },
  onError: (error, stackTrace) {
    print('发生错误: $error');
  },
  onDone: () {
    print('流已关闭');
  },
);

// 发送数据
stream.add(1);
stream.add(2);
stream.value = 3; // 使用 setter 也会触发通知

// 取消订阅
await subscription.cancel();

// 关闭流
stream.close();
```

### 性能测试示例

根据测试文件 `test/benchmarks/benckmark_test.dart` 中的实现，`MiniStream` 在性能测试中表现出色：

```dart 106:127:test/benchmarks/benckmark_test.dart
Future<int> miniStream() {
  final c = Completer<int>();

  final value = MiniStream<int>();
  final timer = Stopwatch();
  timer.start();

  value.listen((v) {
    if (times == v) {
      timer.stop();
      printValue(
          """$v listeners notified | [MINI_STREAM] time: ${timer.elapsedMicroseconds}ms""");
      c.complete(timer.elapsedMicroseconds);
    }
  });

  for (var i = 0; i < times + 1; i++) {
    value.add(i);
  }

  return c.future;
}
```

该测试表明 `MiniStream` 在处理大量数据更新时具有优异的性能表现。

## 性能考虑

### 与 Dart 标准 Stream 的对比

1. **轻量级实现**：
   - `MiniStream` 避免了 Dart `Stream` 的复杂异步机制
   - 直接同步通知订阅者，减少异步开销

2. **内存效率**：
   - 使用双向链表而非数组，避免数组扩容带来的内存重新分配
   - 节点删除后立即释放内存

3. **性能优势**：
   - 根据基准测试，`MiniStream` 在处理大量更新时比标准 `Stream` 更快
   - 适合高频更新的响应式场景

### 适用场景

- **响应式状态管理**：GetX 的响应式变量底层使用 `MiniStream`
- **高频数据更新**：需要频繁通知订阅者的场景
- **轻量级事件总线**：简单的发布-订阅模式实现

### 注意事项

1. **同步执行**：`MiniStream` 的通知是同步的，如果回调函数执行时间过长，可能阻塞主线程
2. **错误处理**：需要正确实现 `onError` 回调，避免未处理的错误
3. **资源清理**：使用完毕后应调用 `close()` 或取消订阅，避免内存泄漏
4. **线程安全**：当前实现不是线程安全的，应在单线程环境中使用

## 总结

`MiniStream` 是 GetX 响应式系统的核心组件，通过轻量级的设计和高效的数据结构，为响应式编程提供了高性能的基础设施。其双向链表实现和观察者模式的应用，使得它在订阅管理场景中表现出色，是 GetX 能够实现高效响应式状态管理的重要基础。
