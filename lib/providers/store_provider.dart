import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store.dart';
import '../services/store_service.dart';

final storeServiceProvider = Provider<StoreService>((ref) => StoreService());

final storeListProvider = FutureProvider<List<KmtStore>>((ref) async {
  return ref.read(storeServiceProvider).getAllStores();
});
