import 'package:flutter/material.dart';
import 'package:fintrack/app/stats/widgets/balance_bar_chart.dart';
import 'package:fintrack/app/stats/widgets/finance_health_details.dart';
import 'package:fintrack/app/stats/widgets/fund_evolution_line_chart.dart';
import 'package:fintrack/app/stats/widgets/income_expense_comparason.dart';
import 'package:fintrack/app/stats/widgets/movements_distribution/chart_by_categories.dart';
import 'package:fintrack/app/stats/widgets/movements_distribution/tags_stats.dart';
import 'package:fintrack/core/database/services/account/account_service.dart';
import 'package:fintrack/core/models/date-utils/date_period_state.dart';
import 'package:fintrack/core/presentation/widgets/card_with_header.dart';
import 'package:fintrack/core/presentation/widgets/dates/segmented_calendar_button.dart';
import 'package:fintrack/core/presentation/widgets/filter_row_indicator.dart';
import 'package:fintrack/core/presentation/widgets/persistent_footer_button.dart';
import 'package:fintrack/core/presentation/widgets/transaction_filter/filter_sheet_modal.dart';
import 'package:fintrack/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:fintrack/i18n/translations.g.dart';

import '../../core/models/transaction/transaction_type.enum.dart';
import '../accounts/all_accounts_balance.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({
    super.key,
    this.initialIndex = 0,
    this.filters = const TransactionFilters(),
    this.dateRangeService = const DatePeriodState(),
  });

  final int initialIndex;

  final TransactionFilters filters;
  final DatePeriodState dateRangeService;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final accountService = AccountService.instance;

  late TransactionFilters filters;
  late DatePeriodState dateRangeService;

  @override
  void initState() {
    super.initState();

    filters = widget.filters;
    dateRangeService = widget.dateRangeService;
  }

  Widget buildContainerWithPadding(
    List<Widget> children, {
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  }) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.stats.title),
          actions: [
            IconButton(
                onPressed: () async {
                  final modalRes = await openFilterSheetModal(
                    context,
                    FilterSheetModal(
                      preselectedFilter: filters,
                      showDateFilter: false,
                    ),
                  );

                  if (modalRes != null) {
                    setState(() {
                      filters = modalRes;
                    });
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined)),
          ],
          bottom: TabBar(
              tabAlignment: TabAlignment.center,
              tabs: [
                Tab(text: t.financial_health.display),
                Tab(text: t.stats.distribution),
                Tab(text: t.stats.balance),
                Tab(text: t.stats.cash_flow),
              ],
              isScrollable: true),
        ),
        persistentFooterButtons: [
          PersistentFooterButton(
            child: SegmentedCalendarButton(
              initialDatePeriodService: dateRangeService,
              onChanged: (value) {
                setState(() {
                  dateRangeService = value;
                });
              },
            ),
          )
        ],
        body: Column(
          children: [
            if (filters.hasFilter) ...[
              FilterRowIndicator(
                filters: filters,
                onChange: (newFilters) {
                  setState(() {
                    filters = newFilters;
                  });
                },
              ),
              const Divider()
            ],
            Expanded(
              child: TabBarView(children: [
                buildContainerWithPadding(
                  [
                    FinanceHealthDetails(
                      filters: filters.copyWith(
                          minDate: dateRangeService.startDate,
                          maxDate: dateRangeService.endDate),
                    )
                  ],
                ),
                buildContainerWithPadding([
                  CardWithHeader(
                    title: t.stats.by_categories,
                    body: ChartByCategories(
                      datePeriodState: dateRangeService,
                      showList: true,
                      initialSelectedType: TransactionType.expense,
                      filters: filters,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardWithHeader(
                    title: t.stats.by_tags,
                    body: TagStats(
                      filters: filters.copyWith(
                        minDate: dateRangeService.startDate,
                        maxDate: dateRangeService.endDate,
                      ),
                    ),
                  ),
                ]),
                buildContainerWithPadding([
                  CardWithHeader(
                    title: t.stats.balance_evolution,
                    body: FundEvolutionLineChart(
                      showBalanceHeader: true,
                      dateRange: dateRangeService,
                      filters: filters,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AllAccountBalancePage(
                    date: dateRangeService.endDate ?? DateTime.now(),
                    filters: filters,
                  ),
                ]),
                buildContainerWithPadding([
                  CardWithHeader(
                    title: t.stats.cash_flow,
                    body: IncomeExpenseComparason(
                      startDate: dateRangeService.startDate,
                      endDate: dateRangeService.endDate,
                      filters: filters,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardWithHeader(
                    title: t.stats.by_periods,
                    bodyPadding: const EdgeInsets.only(bottom: 12, top: 16),
                    body: BalanceBarChart(
                      dateRange: dateRangeService,
                      filters: filters,
                    ),
                  )
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
