import 'package:flutter/material.dart';
import 'package:website_gallery/components/date_picker.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:website_gallery/components/rectangle_button.dart';
import 'package:website_gallery/components/time_picker.dart';

void main() {
  usePathUrlStrategy();

  runApp(const LucidWebsiteGalleryApp());
}

class LucidWebsiteGalleryApp extends StatelessWidget {
  const LucidWebsiteGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucid Gallery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: (RouteSettings settings) {
        print("Route name: '${settings.name}'");
        final demo = switch (settings.name) {
          "/components/date-picker" => DatePickerDemo(),
          "/components/time-picker" => TimePickerDemo(),
          "/components/rectangle-button" => RectangleButtonDemo(),
          "/" => _MissingDemoScreen(),
          "" => _MissingDemoScreen(),
          null => _MissingDemoScreen(),
          _ => _UnknownDemoScreen(settings.name!),
        };

        return MaterialPageRoute(builder: (_) => demo);
      },
      // routes: {
      //   "/": (_) => _MissingDemoScreen(),
      //   "/components/date-picker": (_) => DatePickerDemo(),
      // },
    );
  }
}

class _MissingDemoScreen extends StatelessWidget {
  const _MissingDemoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("The demo name missing. We don't know what to show here."),
      ),
    );
  }
}

class _UnknownDemoScreen extends StatelessWidget {
  const _UnknownDemoScreen(this.demoName);

  final String demoName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Unknown demo: $demoName"),
      ),
    );
  }
}
