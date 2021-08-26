import 'dart:async';

import 'package:scanner/models/picklist.dart';
import 'package:scanner/resources/picklist_line_db_provider.dart';
import 'package:sembast/sembast.dart';

class PicklistDbProvider {
  PicklistDbProvider(this.db) {
    var lineStore = intMapStoreFactory.store(PicklistLineDbProvider.name);
    lineStore.addOnChangesListener(db, (transaction, changes) async {
      for (var change in changes) {
        if (change.isUpdate) {
          final picklistId = change.newValue!['picklistId'] as int;
          final finder =
              Finder(filter: Filter.equals('picklistId', picklistId));
          final lines = await lineStore.find(transaction, finder: finder);
          if (lines
              .every((line) => line['pickAmount'] == line['pickedAmount'])) {
            await _store.record(picklistId).update(
              transaction,
              {
                'status': PicklistStatus.picked.name,
              },
            );
          }
        }
      }
    });
  }

  final _store = intMapStoreFactory.store('picklists');
  final Database db;

  Stream<List<Picklist>> getPicklistsStream(String? search) {
    var finder = Finder(
        filter: search == ''
            ? null
            : Filter.or([
                Filter.equals('uid', search),
                Filter.equals('debtor.name', search),
              ]));
    return _store.query(finder: finder).onSnapshots(db).transform(
        StreamTransformer.fromHandlers(handleData: (snapshotList, sink) {
      sink.add(
        snapshotList
            .map((snapshot) => Picklist.fromJson(snapshot.value))
            .toList(),
      );
    }));
  }

  Future<dynamic> savePicklists(List<Picklist> picklists) {
    return _store
        .records(picklists.map<int>((picklist) => picklist.id))
        .put(db, picklists.map((picklist) => picklist.toJson()).toList());
  }

  Future<int> count() {
    return _store.count(db);
  }

  Future<dynamic> clear() {
    return _store.drop(db);
  }
}