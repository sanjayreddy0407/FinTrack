import 'package:collection/collection.dart';
import 'package:fintrack/core/presentation/widgets/fintrackk_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/app/accounts/account_form.dart';
import 'package:fintrack/app/accounts/details/account_details.dart';
import 'package:fintrack/core/database/services/account/account_service.dart';
import 'package:fintrack/core/presentation/app_colors.dart';
// ignore: unused_import
import 'package:fintrack/core/presentation/widgets/fintrack_reorderable_list.dart';
import 'package:fintrack/core/presentation/widgets/tappable.dart';
import 'package:fintrack/core/routes/route_utils.dart';
import 'package:fintrack/i18n/translations.g.dart';

import '../../core/presentation/widgets/no_results.dart';

class AllAccountsPage extends StatelessWidget {
  const AllAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.home.my_accounts)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: UniqueKey(),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.account.form.create),
        onPressed: () => RouteUtils.pushRoute(context, const AccountFormPage()),
      ),
      body: StreamBuilder(
        stream: AccountService.instance.getAccounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }

          final accounts = snapshot.data!;

          if (accounts.isEmpty) {
            return Column(
              children: [
                Expanded(
                    child: NoResults(
                        title: t.general.empty_warn,
                        description: t.account.no_accounts)),
              ],
            );
          }

          return fintrackReorderableList(
            totalItemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts.elementAt(index);

              return Tappable(
                onTap: () => RouteUtils.pushRoute(
                  context,
                  AccountDetailsPage(
                      account: account,
                      accountIconHeroTag:
                          'all-accounts-page__account-icon-${account.id}'),
                ),
                bgColor: AppColors.of(context).light,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                borderRadius: 12,
                child: ListTile(
                  trailing: accounts.length > 1
                      ? ReorderableDragIcon(index: index)
                      : null,
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.name,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (account.isClosed)
                        const Icon(Icons.archive_outlined,
                            color: Colors.amber, size: 16)
                    ],
                  ),
                  leading: Hero(
                    tag: 'all-accounts-page__account-icon-${account.id}',
                    child: account.displayIcon(context),
                  ),
                  subtitle: Text(
                    account.type.title(context),
                  ),
                ),
              );
            },
            onReorder: (from, to) async {
              if (to > from) to--;

              final item = accounts.removeAt(from);
              accounts.insert(to, item);

              await Future.wait(
                accounts.mapIndexed(
                  (index, element) => AccountService.instance.updateAccount(
                    element.copyWith(displayOrder: index),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ReorderableDragIcon extends StatelessWidget {
  const ReorderableDragIcon({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: Container(
          padding: const EdgeInsets.fromLTRB(14, 4, 2, 4),
          // Padding to increase the dragabble area
          //color: Colors.red,
          child: const Icon(Icons.drag_handle_rounded)),
    );
  }
}
