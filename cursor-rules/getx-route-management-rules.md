---
description: Use when working with GetX navigation, routes, Get.to/Get.toNamed, route middleware, context-free dialogs/snackbars, or route transitions
alwaysApply: false
---

# GetX Route Management Rules

## Overview

GetX provides powerful route management that works without context, making navigation simple and clean. This rule file guides proper usage patterns based on the official source code and documentation.

**Key Principles:**

- Navigation works without context - call from anywhere (controllers, services, etc.)
- Supports both named routes and direct navigation
- Automatic memory management - routes clean up when removed
- Dynamic URLs with parameters (web-like routing)
- Middleware support for route protection and customization
- Context-free dialogs, snackbars, and bottom sheets

## GetMaterialApp Setup

Replace `MaterialApp` with `GetMaterialApp` to enable GetX navigation:

```dart
GetMaterialApp(
  initialRoute: '/',
  getPages: [
    GetPage(name: '/', page: () => HomePage()),
    GetPage(name: '/details', page: () => DetailsPage()),
  ],
)
```

**Reference:** `lib/get_navigation/src/root/get_material_app.dart`

## Navigation Without Named Routes

### Basic Navigation

Navigate to a new screen:

```dart
Get.to(() => NextScreen());
```

Go back (closes snackbars, dialogs, bottom sheets):

```dart
Get.back();
```

Navigate and remove previous screen (no back button):

```dart
Get.off(() => NextScreen()); // Useful for login/splash screens
```

Navigate and remove all previous screens:

```dart
Get.offAll(() => HomeScreen()); // Useful for shopping carts, polls
```

**Reference:** `lib/get_navigation/src/extension_navigation.dart`

### Navigation with Return Values

Navigate and receive data when returning:

```dart
var data = await Get.to(() => PaymentPage());
if (data == 'success') {
  // Handle success
}
```

On the destination screen, send data back:

```dart
Get.back(result: 'success');
```

### Navigator Extension

GetX provides a `navigator` extension that replaces `Navigator.of(context)`:

```dart
navigator.push(MaterialPageRoute(builder: (_) => HomePage()));
```

**Reference:** `lib/get_navigation/src/extension_navigation.dart:13`

## Navigation With Named Routes

### Basic Named Navigation

Navigate to a named route:

```dart
Get.toNamed('/details');
```

Navigate and remove previous screen:

```dart
Get.offNamed('/details');
```

Navigate and remove all previous screens:

```dart
Get.offAllNamed('/home');
```

**Reference:** `lib/get_navigation/src/extension_navigation.dart:589`

### Configuring Named Routes

Define routes in `GetMaterialApp`:

```dart
GetMaterialApp(
  initialRoute: '/',
  getPages: [
    GetPage(name: '/', page: () => MyHomePage()),
    GetPage(name: '/second', page: () => Second()),
    GetPage(
      name: '/third',
      page: () => Third(),
      transition: Transition.zoom,
    ),
  ],
)
```

**Reference:** `lib/get_navigation/src/routes/get_route.dart`

### Unknown Route (404 Handling)

Handle navigation to undefined routes:

```dart
GetMaterialApp(
  unknownRoute: GetPage(name: '/notfound', page: () => UnknownRoutePage()),
  initialRoute: '/',
  getPages: [
    GetPage(name: '/', page: () => MyHomePage()),
  ],
)
```

### Sending Data to Named Routes

Send any type of data as arguments:

```dart
Get.toNamed('/details', arguments: 'Get is the best');
// Or with objects
Get.toNamed('/details', arguments: {'id': 123, 'name': 'John'});
```

Receive arguments on the destination:

```dart
print(Get.arguments); // 'Get is the best'
// Or
final data = Get.arguments as Map<String, dynamic>;
```

**Reference:** `lib/get_navigation/src/extension_navigation.dart:589`

### Dynamic URLs and Parameters

GetX supports web-like dynamic URLs with query parameters:

```dart
Get.offAllNamed("/NextScreen?device=phone&id=354&name=Enzo");
```

Access parameters:

```dart
print(Get.parameters['id']); // '354'
print(Get.parameters['name']); // 'Enzo'
```

**Reference:** `lib/get_navigation/src/routes/parse_route.dart`

### Named Parameters in Routes

Define routes with path parameters:

```dart
GetPage(
  name: '/profile/:user',
  page: () => UserProfile(),
),
```

Navigate with parameter:

```dart
Get.toNamed("/profile/34954");
```

Access path parameter:

```dart
print(Get.parameters['user']); // '34954'
```

Combine path and query parameters:

```dart
Get.toNamed("/profile/34954?flag=true&country=italy");
// Or programmatically
var parameters = <String, String>{
  "flag": "true",
  "country": "italy",
};
Get.toNamed("/profile/34954", parameters: parameters);
```

## Route Middleware

Middleware allows you to intercept and modify navigation behavior. Middleware functions run in this order:

1. `redirect` - Redirect to another route
2. `onPageCalled` - Modify page before creation
3. `onBindingsStart` - Modify bindings before initialization
4. `onPageBuildStart` - Called after bindings are initialized
5. `onPageBuilt` - Modify widget after creation
6. `onPageDispose` - Called when page is disposed

### Creating Middleware

```dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    return auth.isAuthenticated ? null : RouteSettings(name: '/login');
  }
  @override
  GetPage? onPageCalled(GetPage? page) {
    return page?.copyWith(title: 'Welcome ${Get.find<AuthService>().userName}');
  }
  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    if (Get.find<AuthService>().isAdmin) bindings?.add(AdminBinding());
    return bindings;
  }
}

// Usage
GetPage(name: '/admin', page: () => AdminPage(), middlewares: [AuthMiddleware()]);

// Priority (lower numbers run first): -8 => 2 => 4 => 5
final middlewares = [GetMiddleware(priority: 2), GetMiddleware(priority: 5), ...];
```

**Reference:** `lib/get_navigation/src/routes/route_middleware.dart`

## Context-Free Navigation

### SnackBars

```dart
Get.snackbar('Title', 'Message');
Get.snackbar("Title", "Message", icon: Icon(Icons.alarm), shouldIconPulse: true,
  onTap: (snack) => print('Tapped'), barBlur: 20, isDismissible: true,
  duration: Duration(seconds: 3), snackPosition: SnackPosition.BOTTOM);
Get.rawSnackbar(message: 'Custom', backgroundColor: Colors.blue);
```

**Reference:** `lib/get_navigation/src/snackbar/snackbar.dart`

### Dialogs

```dart
Get.dialog(YourDialogWidget());
Get.defaultDialog(onConfirm: () => print("Ok"), middleText: "Dialog in 3 lines");

// With result
bool? delete = await Get.dialog(AlertDialog(
  content: Text('Are you sure?'),
  actions: [
    TextButton(onPressed: () => Get.closeDialog(result: false), child: Text('No')),
    TextButton(onPressed: () => Get.closeDialog(result: true), child: Text('Yes')),
  ],
));

Get.generalDialog(pageBuilder: (c, a, s) => YourWidget());
```

**Reference:** `lib/get_navigation/src/dialog/dialog_route.dart`

### Bottom Sheets

```dart
Get.bottomSheet(Container(
  child: Wrap(children: [
    ListTile(leading: Icon(Icons.music_note), title: Text('Music'), onTap: () {}),
    ListTile(leading: Icon(Icons.videocam), title: Text('Video'), onTap: () {}),
  ]),
));
```

**Reference:** `lib/get_navigation/src/extension_navigation.dart:16`

### Context Helpers

```dart
Get.context; // For most cases
Get.contextOverlay; // For snackbar/dialog/bottomsheet
```

## Route Transitions

```dart
Get.to(() => NextScreen(), transition: Transition.fade,
  duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
```

Available: `fade`, `rightToLeft`, `leftToRight`, `upToDown`, `downToUp`, `zoom`, `cupertino`, `size`, `circularReveal`

**Reference:** `lib/get_navigation/src/routes/transitions_type.dart`

## Nested Navigation

Create parallel navigation stacks (use sparingly):

```dart
Navigator(
  key: Get.nestedKey(1), // Create a key by index
  initialRoute: '/',
  onGenerateRoute: (settings) {
    if (settings.name == '/') {
      return GetPageRoute(
        page: () => Scaffold(
          appBar: AppBar(title: Text("Main")),
          body: Center(
            child: TextButton(
              onPressed: () {
                Get.toNamed('/second', id: 1); // Navigate by nested route
              },
              child: Text("Go to second"),
            ),
          ),
        ),
      );
    }
  },
),
```

**Note:** Creating parallel navigation stacks can be dangerous for RAM consumption. Use sparingly.

## Route Observers

Listen to route changes:

```dart
GetMaterialApp(
  routingCallback: (routing) {
    if (routing.current == '/second') openAds();
  },
)
// Manual: MaterialApp(navigatorKey: Get.key, navigatorObservers: [GetObserver(...)])
```

## Best Practices

### Route Naming

- Always start route names with `/` (e.g., `/home`, not `home`)
- Use descriptive, consistent naming
- Group related routes with prefixes (e.g., `/auth/login`, `/auth/register`)

### Navigation Patterns

- Use `Get.to()` for simple navigation
- Use `Get.toNamed()` for better organization and web compatibility
- Use `Get.off()` for login/splash screens
- Use `Get.offAll()` when clearing navigation stack

### Memory Management

- GetX automatically disposes routes when removed
- Controllers bound to routes are automatically cleaned up
- Use `permanent: true` only when necessary

### Common Mistakes

**❌ DON'T:** Use context for navigation → **✅ DO:** Use `Get.to()` or `Get.toNamed()`

**❌ DON'T:** Forget leading slash in route names → **✅ DO:** Always use `/route`

**❌ DON'T:** Mix context-based and GetX navigation → **✅ DO:** Use GetX consistently

**❌ DON'T:** Create too many nested navigators → **✅ DO:** Use sparingly, consider alternatives

## Advanced Features

### Route Utilities

```dart
Get.arguments; // Current route arguments
Get.previousRoute; // Previous route name
Get.rawRoute.isFirst(); // Raw route access
Get.routing.current; // Current route
Get.removeRoute('/route'); // Remove one route
Get.until((route) => route.name == '/home'); // Back until condition
Get.offUntil(() => HomePage(), (route) => route.name == '/home');
Get.offNamedUntil('/home', (route) => route.name == '/login');
Get.isSnackbarOpen; // Check if snackbar is open
Get.isDialogOpen; // Check if dialog is open
Get.isBottomSheetOpen; // Check if bottomsheet is open
```

**Reference:** `lib/get_navigation/src/extension_navigation.dart`
