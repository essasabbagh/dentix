import 'pagination_status.dart';

/// Holds the current state of paginated data.
class PaginationState<T> {
  /// Creates a new [PaginationState] instance.
  const PaginationState({
    this.items = const [],
    this.status = PaginationStatus.initial,
    this.hasMoreData = true,
    this.currentPage = 1,
    this.errorMessage,
    this.e,
  });

  /// List of items currently loaded
  final List<T> items;

  /// Current status of the pagination
  final PaginationStatus status;

  /// Error message if status is error
  final String? errorMessage;

  /// Error object if status is error
  final Object? e;

  /// Whether more data can be loaded
  final bool hasMoreData;

  /// Current page number
  final int currentPage;

  /// Creates a copy of the current state with some fields replaced.
  PaginationState<T> copyWith({
    List<T>? items,
    PaginationStatus? status,
    bool? hasMoreData,
    int? currentPage,
    String? errorMessage,
    Object? e,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      e: e ?? this.e,
    );
  }
}
