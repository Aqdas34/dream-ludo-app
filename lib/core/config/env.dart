// ───────────────────────────────────────────────────────────────
// env.dart  –  Environment configuration (dev / prod)
// Usage:  flutter run --dart-define=FLAVOR=dev
// ───────────────────────────────────────────────────────────────

enum Flavor { dev, prod }

class Env {
  Env._();

  static const String _flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static Flavor get flavor =>
      _flavor == 'prod' ? Flavor.prod : Flavor.dev;

  static bool get isDev => flavor == Flavor.dev;
  static bool get isProd => flavor == Flavor.prod;

  static String get baseUrl {
    switch (flavor) {
      case Flavor.prod:
        return 'https://slateblue-reindeer-226763.hostingersite.com/';
      case Flavor.dev:
        return 'http://192.168.211.79:3005/'; // local Node.js backend
    }
  }

  // WebSocket endpoint
  static String get wsUrl {
    switch (flavor) {
      case Flavor.prod:
        return 'wss://slateblue-reindeer-226763.hostingersite.com/ws';
      case Flavor.dev:
        return 'ws://192.168.211.79:3005'; // local Node.js backend
    }
  }

  static String get purchaseKey => '111111111111';
}
