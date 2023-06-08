import 'package:flutter/material.dart';
import 'package:mba_project/src/sample_feature/sample_item.dart';
import 'package:realm/realm.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  final app = App(AppConfiguration('mba-app-sekez'));
  final user = app.currentUser ?? await app.logIn(Credentials.anonymous());
  final realm = Realm(Configuration.flexibleSync(user, [SampleItem.schema]));
  final allItems = realm.all<SampleItem>();
  realm.subscriptions.update((mutableSubscriptions) {
    mutableSubscriptions.add(realm.all<SampleItem>());
  });
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(
    settingsController: settingsController,
    items: allItems,
  ));
}
