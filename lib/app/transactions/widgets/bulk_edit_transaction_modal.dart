import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:fintrack/app/categories/categories_list.dart';
import 'package:fintrack/core/database/services/transaction/transaction_service.dart';
import 'package:fintrack/core/models/transaction/transaction.dart';
import 'package:fintrack/core/presentation/widgets/dates/outlinedButtonStacked.dart';
import 'package:fintrack/core/presentation/widgets/modal_container.dart';
import 'package:fintrack/core/utils/date_time_picker.dart';
import 'package:fintrack/i18n/translations.g.dart';

class BulkEditTransactionModal extends StatelessWidget {
  const BulkEditTransactionModal({
    super.key,
    required this.transactionsToEdit,
    required this.onSuccess,
  });

  final List<MoneyTransaction> transactionsToEdit;

  final void Function() onSuccess;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return ModalContainer(
      title: t.transaction.edit_multiple,
      subtitle: t.transaction.list.selected_long(n: transactionsToEdit.length),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            OutlinedButtonStacked(
              text: t.transaction.list.bulk_edit.dates,
              onTap: () {
                openDateTimePicker(context, showTimePickerAfterDate: true).then(
                  (date) {
                    if (date == null) {
                      return;
                    }

                    performUpdates(
                      context,
                      futures: transactionsToEdit.map(
                        (e) => TransactionService.instance
                            .insertOrUpdateTransaction(e.copyWith(date: date)),
                      ),
                    );
                  },
                );
              },
              alignLeft: true,
              alignBeside: true,
              fontSize: 18,
              padding: const EdgeInsets.all(16),
              iconData: Icons.calendar_month,
            ),
            const SizedBox(height: 8),
            OutlinedButtonStacked(
              text: t.transaction.list.bulk_edit.categories,
              onTap: () {
                showCategoryListModal(
                  context,
                  const CategoriesList(
                    mode: CategoriesListMode.modalSelectSubcategory,
                  ),
                ).then(
                  (modalRes) {
                    if (modalRes != null && modalRes.isNotEmpty) {
                      performUpdates(
                        context,
                        futures: transactionsToEdit.map(
                          (e) => TransactionService.instance
                              .insertOrUpdateTransaction(e.copyWith(
                                  categoryID: Value(modalRes.first.id))),
                        ),
                      );
                    }
                  },
                );
              },
              alignLeft: true,
              alignBeside: true,
              fontSize: 18,
              padding: const EdgeInsets.all(16),
              iconData: Icons.category_rounded,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void performUpdates(
    BuildContext context, {
    required Iterable<Future<int>> futures,
  }) {
    Navigator.pop(context);

    Future.wait(futures).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(transactionsToEdit.length <= 1
            ? t.transaction.edit_success
            : t.transaction
                .edit_multiple_success(x: transactionsToEdit.length)),
      ));

      onSuccess();
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
    });
  }
}
