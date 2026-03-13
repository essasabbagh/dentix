import 'dart:async';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/extensions/context_ext.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/themes/app_gradients.dart';

class DebouncedSearch extends ConsumerStatefulWidget {
  const DebouncedSearch({
    super.key,
    required this.onDebounceChange,
    required this.filterOnTap,
  });

  final void Function(String) onDebounceChange;
  final VoidCallback filterOnTap;

  @override
  ConsumerState<DebouncedSearch> createState() => _DebouncedSearchState();
}

class _DebouncedSearchState extends ConsumerState<DebouncedSearch> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(
        milliseconds: 500,
      ), // replace with Durations.long1 if defined
      () => widget.onDebounceChange(query),
    );
  }

  void _clearSearch() {
    _controller.clear();
    widget.onDebounceChange('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildSuffixIcons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, _) {
            if (value.text.isEmpty) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            );
          },
        ),
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            gradient: AppGradient.linearGradient,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(context.isRtl ? 12.0 : 0),
              right: Radius.circular(context.isRtl ? 0 : 12.0),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_open_rounded, color: Colors.white),
            onPressed: widget.filterOnTap,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: S.of(context).search,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _buildSuffixIcons(context),
          border: const OutlineInputBorder(),
        ),
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        onChanged: _onSearchChanged,
        onSubmitted: widget.onDebounceChange,
      ),
    );
  }
}
