# Iterable Extensions 代码讲解

## 概述

`iterable_extensions.dart` 文件为 Dart 的 `Iterable<T>` 类型提供了实用的扩展方法，主要用于集合的扁平化操作。这个扩展让开发者能够更方便地处理嵌套集合，将嵌套的集合结构扁平化为单一集合。

### 主要功能

1. **集合扁平化**：提供 `mapMany` 方法用于将嵌套集合扁平化为单一集合

## 文件结构

该文件包含一个扩展：

- `IterableExtensions` - 为 `Iterable<T>` 类型提供扩展方法

## IterableExtensions 扩展详解

### 集合扁平化方法

#### mapMany

将嵌套集合扁平化为单一集合。

```dart 1:9:lib/get_utils/src/extensions/iterable_extensions.dart
extension IterableExtensions<T> on Iterable<T> {
  Iterable<TRes> mapMany<TRes>(
      Iterable<TRes>? Function(T item) selector) sync* {
    for (var item in this) {
      final res = selector(item);
      if (res != null) yield* res;
    }
  }
}
```

**参数说明**：

- `selector`：选择器函数，接收一个元素并返回一个可选的 `Iterable<TRes>`。如果返回 `null`，则跳过该元素

**返回值**：返回一个 `Iterable<TRes>`，包含所有扁平化后的元素

**实现原理**：

1. 遍历当前集合的每个元素
2. 对每个元素调用 `selector` 函数
3. 如果 `selector` 返回非空集合，使用 `yield*` 将集合中的所有元素添加到结果中
4. 如果 `selector` 返回 `null`，则跳过该元素

**使用示例**：

```dart
// 基本用法：扁平化嵌套列表
final nested = [
  [1, 2, 3],
  [4, 5],
  [6, 7, 8, 9],
];

final flattened = nested.mapMany((list) => list);
print(flattened.toList()); // 输出: [1, 2, 3, 4, 5, 6, 7, 8, 9]

// 处理对象集合
class Person {
  final String name;
  final List<String> hobbies;
  
  Person(this.name, this.hobbies);
}

final people = [
  Person('Alice', ['reading', 'swimming']),
  Person('Bob', ['gaming']),
  Person('Charlie', ['cooking', 'traveling', 'photography']),
];

// 获取所有人的爱好
final allHobbies = people.mapMany((person) => person.hobbies);
print(allHobbies.toList());
// 输出: [reading, swimming, gaming, cooking, traveling, photography]

// 过滤空集合
final mixed = [
  [1, 2],
  null,
  [3, 4],
  [],
  [5],
];

final result = mixed.mapMany((list) => list);
print(result.toList()); // 输出: [1, 2, 3, 4, 5]
```

**与 `map` 和 `expand` 的区别**：

- `map`：将每个元素转换为另一个元素，返回 `Iterable<TRes>`
- `expand`：将每个元素展开为多个元素，返回 `Iterable<TRes>`
- `mapMany`：结合了 `map` 和 `expand` 的功能，同时支持转换和扁平化，并且可以处理 `null` 值

## 完整使用示例

### 示例 1：扁平化嵌套列表

```dart
class ListFlattener {
  // 扁平化整数列表
  List<int> flattenIntLists(List<List<int>> nested) {
    return nested.mapMany((list) => list).toList();
  }
  
  // 扁平化字符串列表
  List<String> flattenStringLists(List<List<String>> nested) {
    return nested.mapMany((list) => list).toList();
  }
  
  // 扁平化混合类型列表
  List<T> flattenLists<T>(List<List<T>> nested) {
    return nested.mapMany((list) => list).toList();
  }
}

void main() {
  final flattener = ListFlattener();
  
  // 扁平化整数列表
  final intLists = [
    [1, 2, 3],
    [4, 5],
    [6, 7, 8],
  ];
  final flattenedInts = flattener.flattenIntLists(intLists);
  print('扁平化整数: $flattenedInts');
  // 输出: 扁平化整数: [1, 2, 3, 4, 5, 6, 7, 8]
  
  // 扁平化字符串列表
  final stringLists = [
    ['apple', 'banana'],
    ['cherry'],
    ['date', 'elderberry'],
  ];
  final flattenedStrings = flattener.flattenStringLists(stringLists);
  print('扁平化字符串: $flattenedStrings');
  // 输出: 扁平化字符串: [apple, banana, cherry, date, elderberry]
}
```

### 示例 2：处理对象集合

```dart
class Student {
  final String name;
  final List<String> courses;
  
  Student(this.name, this.courses);
}

class CourseManager {
  // 获取所有学生的所有课程
  List<String> getAllCourses(List<Student> students) {
    return students.mapMany((student) => student.courses).toList();
  }
  
  // 获取去重后的课程列表
  List<String> getUniqueCourses(List<Student> students) {
    return students
        .mapMany((student) => student.courses)
        .toSet()
        .toList();
  }
  
  // 获取特定学生的课程
  List<String> getStudentCourses(
    List<Student> students,
    String studentName,
  ) {
    return students
        .where((s) => s.name == studentName)
        .mapMany((student) => student.courses)
        .toList();
  }
}

void main() {
  final manager = CourseManager();
  
  final students = [
    Student('Alice', ['Math', 'Physics', 'Chemistry']),
    Student('Bob', ['Math', 'Biology']),
    Student('Charlie', ['Physics', 'Chemistry', 'History']),
  ];
  
  // 获取所有课程
  final allCourses = manager.getAllCourses(students);
  print('所有课程: $allCourses');
  // 输出: 所有课程: [Math, Physics, Chemistry, Math, Biology, Physics, Chemistry, History]
  
  // 获取去重后的课程
  final uniqueCourses = manager.getUniqueCourses(students);
  print('去重课程: $uniqueCourses');
  // 输出: 去重课程: [Math, Physics, Chemistry, Biology, History]
  
  // 获取特定学生的课程
  final aliceCourses = manager.getStudentCourses(students, 'Alice');
  print('Alice 的课程: $aliceCourses');
  // 输出: Alice 的课程: [Math, Physics, Chemistry]
}
```

### 示例 3：处理可选集合

```dart
class DataProcessor {
  // 处理可能为空的集合
  List<String> processOptionalLists(
    List<List<String>?> optionalLists,
  ) {
    return optionalLists.mapMany((list) => list).toList();
  }
  
  // 处理混合类型的集合
  List<int> processMixedData(List<dynamic> mixed) {
    return mixed
        .mapMany((item) {
          if (item is List<int>) {
            return item;
          } else if (item is int) {
            return [item];
          }
          return null;
        })
        .toList();
  }
}

void main() {
  final processor = DataProcessor();
  
  // 处理可选列表
  final optionalLists = [
    ['a', 'b'],
    null,
    ['c', 'd'],
    [],
    ['e'],
  ];
  final processed = processor.processOptionalLists(optionalLists);
  print('处理后的数据: $processed');
  // 输出: 处理后的数据: [a, b, c, d, e]
  
  // 处理混合数据
  final mixed = [
    [1, 2, 3],
    4,
    [5, 6],
    7,
    null,
  ];
  final processedMixed = processor.processMixedData(mixed);
  print('处理后的混合数据: $processedMixed');
  // 输出: 处理后的混合数据: [1, 2, 3, 4, 5, 6, 7]
}
```

### 示例 4：数据转换和扁平化

```dart
class Order {
  final String id;
  final List<OrderItem> items;
  
  Order(this.id, this.items);
}

class OrderItem {
  final String productName;
  final int quantity;
  
  OrderItem(this.productName, this.quantity);
}

class OrderProcessor {
  // 获取所有订单的所有商品名称
  List<String> getAllProductNames(List<Order> orders) {
    return orders
        .mapMany((order) => order.items.map((item) => item.productName))
        .toList();
  }
  
  // 获取所有商品及其数量
  List<OrderItem> getAllOrderItems(List<Order> orders) {
    return orders.mapMany((order) => order.items).toList();
  }
  
  // 获取特定商品的总数量
  int getTotalQuantity(List<Order> orders, String productName) {
    return orders
        .mapMany((order) => order.items)
        .where((item) => item.productName == productName)
        .fold(0, (sum, item) => sum + item.quantity);
  }
}

void main() {
  final processor = OrderProcessor();
  
  final orders = [
    Order('order1', [
      OrderItem('Apple', 5),
      OrderItem('Banana', 3),
    ]),
    Order('order2', [
      OrderItem('Apple', 2),
      OrderItem('Cherry', 10),
    ]),
    Order('order3', [
      OrderItem('Banana', 7),
    ]),
  ];
  
  // 获取所有商品名称
  final allProducts = processor.getAllProductNames(orders);
  print('所有商品: $allProducts');
  // 输出: 所有商品: [Apple, Banana, Apple, Cherry, Banana]
  
  // 获取所有订单项
  final allItems = processor.getAllOrderItems(orders);
  print('所有订单项数量: ${allItems.length}');
  // 输出: 所有订单项数量: 5
  
  // 获取特定商品的总数量
  final appleTotal = processor.getTotalQuantity(orders, 'Apple');
  print('Apple 总数量: $appleTotal');
  // 输出: Apple 总数量: 7
}
```

### 示例 5：与过滤器结合使用

```dart
class FilteredFlattener {
  // 扁平化并过滤
  List<T> flattenAndFilter<T>(
    List<List<T>> nested,
    bool Function(T) test,
  ) {
    return nested
        .mapMany((list) => list)
        .where(test)
        .toList();
  }
  
  // 扁平化并转换
  List<TRes> flattenAndMap<T, TRes>(
    List<List<T>> nested,
    TRes Function(T) transform,
  ) {
    return nested
        .mapMany((list) => list)
        .map(transform)
        .toList();
  }
  
  // 扁平化、过滤和转换
  List<TRes> flattenFilterAndMap<T, TRes>(
    List<List<T>> nested,
    bool Function(T) test,
    TRes Function(T) transform,
  ) {
    return nested
        .mapMany((list) => list)
        .where(test)
        .map(transform)
        .toList();
  }
}

void main() {
  final flattener = FilteredFlattener();
  
  final numbers = [
    [1, 2, 3, 4, 5],
    [6, 7, 8],
    [9, 10, 11, 12],
  ];
  
  // 扁平化并过滤偶数
  final evens = flattener.flattenAndFilter(numbers, (n) => n % 2 == 0);
  print('偶数: $evens');
  // 输出: 偶数: [2, 4, 6, 8, 10, 12]
  
  // 扁平化并转换为字符串
  final strings = flattener.flattenAndMap(numbers, (n) => 'Number $n');
  print('字符串: $strings');
  // 输出: 字符串: [Number 1, Number 2, ..., Number 12]
  
  // 扁平化、过滤大于 5 的数并转换为字符串
  final filtered = flattener.flattenFilterAndMap(
    numbers,
    (n) => n > 5,
    (n) => 'Big $n',
  );
  print('过滤后: $filtered');
  // 输出: 过滤后: [Big 6, Big 7, Big 8, Big 9, Big 10, Big 11, Big 12]
}
```

## 最佳实践

### 何时使用这些扩展

1. **嵌套集合扁平化**：当需要将嵌套集合扁平化为单一集合时
2. **对象属性提取**：当需要从对象集合中提取嵌套集合属性时
3. **数据转换**：当需要同时进行数据转换和扁平化时

### 性能注意事项

1. **延迟计算**：`mapMany` 返回的是延迟计算的 `Iterable`，只有在需要时才计算
2. **内存使用**：对于大型集合，考虑使用流式处理而不是一次性转换为列表
3. **空值处理**：`mapMany` 会自动跳过 `null` 值，无需额外处理

### 常见使用场景

1. **数据扁平化**：将嵌套的数据结构扁平化
2. **属性提取**：从对象集合中提取嵌套集合属性
3. **数据聚合**：聚合多个集合的数据
4. **数据转换**：在扁平化的同时进行数据转换

### 注意事项

1. **空值处理**：`selector` 返回 `null` 时，该元素会被跳过
2. **类型安全**：使用泛型确保类型安全
3. **性能考虑**：对于大型集合，考虑使用流式处理
4. **与 expand 的区别**：`mapMany` 可以处理 `null` 值，而 `expand` 不能

## 与其他方法的对比

### 与 expand 对比

```dart
// 使用 expand
final result1 = nested.expand((list) => list).toList();

// 使用 mapMany（可以处理 null）
final result2 = nested.mapMany((list) => list).toList();
```

### 与 flatMap 对比

```dart
// mapMany 类似于其他语言中的 flatMap
// 但可以处理 null 值
final result = items.mapMany((item) => item.getChildren());
```

## 总结

`iterable_extensions.dart` 提供了实用的 `Iterable` 类型扩展方法：

- **集合扁平化**：`mapMany` 方法可以将嵌套集合扁平化为单一集合
- **空值处理**：自动跳过 `null` 值，无需额外处理
- **类型安全**：使用泛型确保类型安全
- **延迟计算**：返回延迟计算的 `Iterable`，提高性能

这个扩展方法遵循 Dart 的最佳实践，在保持代码简洁的同时，提供了强大的集合操作能力。通过使用这个扩展，开发者可以更方便地处理嵌套集合，将复杂的嵌套结构扁平化为单一集合。
