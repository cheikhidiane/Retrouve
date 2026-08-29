import 'package:flutter/foundation.dart';

/// Global signal bumped by repositories whenever they mutate persisted
/// data (new item, new/confirmed match, new chat message, ...).
///
/// The app uses `StatefulShellRoute.indexedStack` for its bottom nav tabs,
/// which keeps every branch's page alive (like an `IndexedStack`). That
/// means switching tabs does NOT rerun `initState`/`build` on the page you
/// switch back to, so data loaded once can go stale until the app is
/// restarted. Pages that need to always reflect the latest data listen to
/// [version] and reload when it changes, instead of requiring the user to
/// leave and re-enter the app.
class DataRefreshBus {
  DataRefreshBus._();

  static final DataRefreshBus instance = DataRefreshBus._();

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  void bump() => version.value++;
}
