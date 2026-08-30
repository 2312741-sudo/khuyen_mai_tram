import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

final customerServiceProvider = Provider<CustomerService>((ref) => CustomerService());

// Search state
class CustomerSearchState {
  final List<Customer> results;
  final bool isLoading;
  final String? error;
  final String query;
  final bool hasSearched;

  const CustomerSearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.hasSearched = false,
  });
}

class CustomerSearchNotifier extends StateNotifier<CustomerSearchState> {
  final CustomerService _service;

  CustomerSearchNotifier(this._service) : super(const CustomerSearchState());

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      state = const CustomerSearchState();
      return;
    }
    state = CustomerSearchState(query: keyword, isLoading: true, hasSearched: true);
    try {
      final results = await _service.searchByKeyword(keyword);
      state = CustomerSearchState(results: results, query: keyword, hasSearched: true);
    } catch (e) {
      state = CustomerSearchState(query: keyword, error: 'Lỗi tìm kiếm: $e', hasSearched: true);
    }
  }

  void clear() {
    state = const CustomerSearchState();
  }
}

final customerSearchProvider = StateNotifierProvider<CustomerSearchNotifier, CustomerSearchState>((ref) {
  return CustomerSearchNotifier(ref.read(customerServiceProvider));
});

// Single customer detail
final customerDetailProvider = FutureProvider.family<Customer?, String>((ref, maKhachHang) async {
  return ref.read(customerServiceProvider).getCustomer(maKhachHang);
});

// All customers list
class CustomerListState {
  final List<Customer> customers;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const CustomerListState({
    this.customers = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });
}

class CustomerListNotifier extends StateNotifier<CustomerListState> {
  final CustomerService _service;

  CustomerListNotifier(this._service) : super(const CustomerListState());

  Future<void> loadCustomers({bool refresh = false}) async {
    if (state.isLoading) return;
    state = CustomerListState(
      customers: refresh ? [] : state.customers,
      isLoading: true,
    );
    try {
      final customers = await _service.getAllCustomers(limit: 20);
      state = CustomerListState(
        customers: customers,
        hasMore: customers.length >= 20,
      );
    } catch (e) {
      state = CustomerListState(error: 'Lỗi tải danh sách: $e');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.customers.isEmpty) return;
    state = CustomerListState(
      customers: state.customers,
      isLoading: true,
      hasMore: state.hasMore,
    );
    try {
      // Note: For proper pagination, you'd pass the last DocumentSnapshot
      // This is simplified - in production, store lastDoc reference
      final more = await _service.getAllCustomers(limit: 20);
      state = CustomerListState(
        customers: [...state.customers, ...more],
        hasMore: more.length >= 20,
      );
    } catch (e) {
      state = CustomerListState(
        customers: state.customers,
        error: 'Lỗi tải thêm: $e',
      );
    }
  }
}

final customerListProvider = StateNotifierProvider<CustomerListNotifier, CustomerListState>((ref) {
  return CustomerListNotifier(ref.read(customerServiceProvider));
});

// Customer count
final customerCountProvider = FutureProvider<int>((ref) async {
  return ref.read(customerServiceProvider).getCustomerCount();
});
