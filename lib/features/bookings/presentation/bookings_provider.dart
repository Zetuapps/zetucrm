import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bookings_repository.dart';
import '../data/models/booking_model.dart';
import '../../../core/auth/auth_provider.dart';

class BookingsState {
  final List<BookingModel> bookings;
  final Map<String, int> stats;
  final bool isLoading;
  final String? errorMessage;
  final String selectedStatusFilter; // all, upcoming, confirmed, completed, cancelled
  final String searchQuery;
  final int currentPage;
  final int totalCount;

  BookingsState({
    this.bookings = const [],
    this.stats = const {
      'total': 0,
      'upcoming': 0,
      'completed': 0,
      'cancelled': 0,
    },
    this.isLoading = false,
    this.errorMessage,
    this.selectedStatusFilter = 'all',
    this.searchQuery = '',
    this.currentPage = 1,
    this.totalCount = 0,
  });

  BookingsState copyWith({
    List<BookingModel>? bookings,
    Map<String, int>? stats,
    bool? isLoading,
    String? errorMessage,
    String? selectedStatusFilter,
    String? searchQuery,
    int? currentPage,
    int? totalCount,
  }) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class BookingsNotifier extends Notifier<BookingsState> {
  @override
  BookingsState build() {
    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated) {
      Future.microtask(() => loadBookings());
    }
    return BookingsState();
  }

  BookingsRepository get _repository => ref.read(bookingsRepositoryProvider);

  Future<void> loadBookings({bool refresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      String? backendFilter;
      if (state.selectedStatusFilter != 'all') {
        backendFilter = state.selectedStatusFilter;
      }

      final res = await _repository.getBookings(
        status: backendFilter,
        search: state.searchQuery,
        page: refresh ? 1 : state.currentPage,
      );

      state = state.copyWith(
        bookings: res.bookings,
        stats: res.stats,
        totalCount: res.total,
        currentPage: res.currentPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load bookings: $e',
      );
    }
  }

  void setStatusFilter(String filter) {
    if (state.selectedStatusFilter == filter) return;
    state = state.copyWith(selectedStatusFilter: filter);
    loadBookings(refresh: true);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadBookings(refresh: true);
  }

  Future<void> updateStatus(String bookingId, String newStatus, {String? reason}) async {
    try {
      final updated = await _repository.updateStatus(bookingId, newStatus, reason: reason);
      final updatedList = state.bookings.map((b) => b.id == bookingId ? updated : b).toList();
      state = state.copyWith(bookings: updatedList);
      loadBookings(); // refresh stats
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reschedule(String bookingId, DateTime newStartAt, {String? reason}) async {
    try {
      final updated = await _repository.reschedule(bookingId, newStartAt, reason: reason);
      final updatedList = state.bookings.map((b) => b.id == bookingId ? updated : b).toList();
      state = state.copyWith(bookings: updatedList);
      loadBookings();
    } catch (e) {
      rethrow;
    }
  }
}

final bookingsProvider = NotifierProvider<BookingsNotifier, BookingsState>(
  BookingsNotifier.new,
);
