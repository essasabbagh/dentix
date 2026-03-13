import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../errors/app_error_widget.dart';
import '../errors/empty_state_widgets.dart';
import '../locale/generated/l10n.dart';

import 'models/pagination_state.dart';
import 'models/pagination_status.dart';
import 'notifiers/paginated_list_notifier.dart';

class PaginatedGridWidget<T> extends ConsumerStatefulWidget {
  const PaginatedGridWidget({
    super.key,
    required this.itemBuilder,
    required this.provider,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.bottomLoadingWidget,
    this.bottomErrorWidget,
    this.noMoreDataWidget,
    this.loadTriggerThreshold = 0.8,
    this.enablePullToRefresh = true,
    this.scrollController,
    this.padding = const EdgeInsets.all(8.0),
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 1.0,
  });

  final Widget Function(BuildContext context, T item) itemBuilder;

  final AutoDisposeStateNotifierProvider<
    PaginatedListNotifier<T>,
    PaginationState<T>
  >
  provider;

  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget? bottomLoadingWidget;
  final Widget? bottomErrorWidget;
  final Widget? noMoreDataWidget;

  final double loadTriggerThreshold;
  final bool enablePullToRefresh;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  @override
  ConsumerState<PaginatedGridWidget<T>> createState() =>
      _PaginatedGridWidgetState<T>();
}

class _PaginatedGridWidgetState<T>
    extends ConsumerState<PaginatedGridWidget<T>> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(widget.provider.notifier).loadNextPage();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold =
        _scrollController.position.maxScrollExtent *
        widget.loadTriggerThreshold;

    if (_scrollController.position.pixels >= threshold) {
      ref.read(widget.provider.notifier).loadNextPage();
    }
  }

  Widget _buildLoadingWidget() {
    return widget.loadingWidget ??
        const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(Object? error) {
    return widget.errorWidget ??
        AppErrorWidget.fromError(
          error!,
          null,
          onRetry: ref.read(widget.provider.notifier).refresh,
        );
  }

  Widget _buildEmptyWidget() {
    return widget.emptyWidget ?? EmptyStateWidgets.noData();
  }

  Widget _buildBottomLoadingWidget() {
    return widget.bottomLoadingWidget ??
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
  }

  Widget _buildBottomErrorWidget() {
    return widget.bottomErrorWidget ??
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: ref.read(widget.provider.notifier).loadNextPage,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(S.current.loadMore),
            ),
          ),
        );
  }

  Widget _buildNoMoreDataWidget() {
    return widget.noMoreDataWidget ??
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              S.of(context).noMoreItems,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    if (state.status == PaginationStatus.initial ||
        (state.status == PaginationStatus.loading && state.items.isEmpty)) {
      return _buildLoadingWidget();
    }

    if (state.status == PaginationStatus.error && state.items.isEmpty) {
      return _buildErrorWidget(state.e);
    }

    if (state.items.isEmpty) {
      return _buildEmptyWidget();
    }

    Widget grid = CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return widget.itemBuilder(context, state.items[index]);
              },
              childCount: state.items.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              crossAxisSpacing: widget.crossAxisSpacing,
              mainAxisSpacing: widget.mainAxisSpacing,
              childAspectRatio: widget.childAspectRatio,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (state.status == PaginationStatus.loading)
                _buildBottomLoadingWidget(),
              if (state.status == PaginationStatus.error)
                _buildBottomErrorWidget(),
              if (!state.hasMoreData) _buildNoMoreDataWidget(),
            ],
          ),
        ),
      ],
    );

    if (widget.enablePullToRefresh) {
      grid = RefreshIndicator(
        onRefresh: ref.read(widget.provider.notifier).refresh,
        child: grid,
      );
    }

    return grid;
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _scrollController.dispose();
    super.dispose();
  }
}
