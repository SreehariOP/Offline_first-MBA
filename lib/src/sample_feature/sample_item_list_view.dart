import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class ListBloc {
  final RealmResults<SampleItem> items;
  final Realm _realm;
  ListBloc(this.items) : _realm = items.realm;

  void addNewItem() {
    _realm.write(() =>
        _realm.add(SampleItem(ObjectId(), 1 + (items.lastOrNull?.no ?? 0))));
  }
}

class SampleItemListView extends StatelessWidget {
  const SampleItemListView({
    super.key,
    required this.bloc,
  });

  static const routeName = '/';

  final ListBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: bloc.addNewItem,
        // ignore: prefer_const_constructors
        child: Icon(Icons.add),
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: StreamBuilder(
          stream: bloc.items.changes,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'sampleItemListView',
              itemCount: bloc.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = bloc.items[index];

                return SampleItemTile(bloc: ItemBloc(item));
              },
            );
          }),
    );
  }
}

class ItemBloc {
  final SampleItem item;
  final Realm _realm;

  ItemBloc(this.item) : _realm = item.realm;
  void delete() {
    _realm.write(() => _realm.delete(item));
  }
}

class SampleItemTile extends StatelessWidget {
  const SampleItemTile({
    super.key,
    required this.bloc,
  });

  final ItemBloc bloc;

  @override
  Widget build(BuildContext context) {
    final item = bloc.item;
    return Dismissible(
      key: ValueKey(item.id),
      background: Container(color: Colors.red),
      onDismissed: (direction) => bloc.delete(),
      child: ListTile(
          title: Text('SampleItem ${item.id}'),
          leading: const CircleAvatar(
            // Display the Flutter Logo image asset.
            foregroundImage: AssetImage('assets/images/flutter_logo.png'),
          ),
          onTap: () {
            // Navigate to the details page. If the user leaves and returns to
            // the app after it has been killed while running in the
            // background, the navigation stack is restored.
            Navigator.restorablePushNamed(
              context,
              SampleItemDetailsView.routeName,
            );
          }),
    );
  }
}
