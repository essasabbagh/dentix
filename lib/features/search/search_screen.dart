import 'package:flutter/material.dart';

import 'package:template/components/form/debounced_search.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/utils/app_log.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).searchScreen),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: DebouncedSearch(
            onDebounceChange: (val) {
              AppLog.info('val: $val');
            },
            filterOnTap: () {
              //
            },
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with your dynamic item count
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.search_rounded),
            title: Text('Search Result $index'),
          );
        },
      ),
    );
  }
}
