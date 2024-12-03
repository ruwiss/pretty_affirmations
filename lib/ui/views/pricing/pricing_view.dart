import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:intl/intl.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/services/revenue_cat_service.dart';
import 'package:pretty_affirmations/ui/views/pricing/pricing_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/pricing/widgets/plan_card.dart';

class PricingView extends StatelessWidget {
  const PricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PricingViewModel>(
        builder: (context, viewModel, child) {
          return viewModel.isBusy
              ? const Center(child: CircularProgressIndicator.adaptive())
              : _buildBody(context, viewModel);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PricingViewModel viewModel) {
    final s = S.of(context);
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.tertiary,
                const Color(0XFFf9eaea).withOpacity(0.8),
              ],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTitleBar(context, s),
                const Gap(20),
                _buildIconView(),
                const Gap(20),
                if (viewModel.hasError) ...[
                  Text(
                    viewModel.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const Gap(20),
                ],
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: viewModel.activePackages
                        .map(
                          (package) => Column(
                            children: [
                              PricingPlanCard(
                                title: switch (package.packageType.name) {
                                  'monthly' => s.monthlyPremium,
                                  'annual' => s.yearlyPremium,
                                  'twoMonth' => s.twoMonthPremium,
                                  _ => package.packageType.name,
                                },
                                price: viewModel.getFormattedPrice(package),
                                description: switch (package.packageType.name) {
                                  'monthly' => s.monthlyDescription,
                                  'annual' => s.annualDescription,
                                  'twoMonth' => s.twoMonthDescription,
                                  _ => package.packageType.name,
                                },
                                isPopular:
                                    package.packageType.name == 'twoMonth',
                                savings: switch (package.packageType.name) {
                                  'annual' => "28% ${s.savings}",
                                  'twoMonth' => "24% ${s.savings}",
                                  _ => null,
                                },
                                isPurchased: viewModel.isPurchased(package),
                                customerInfo: viewModel.customerInfo,
                                onTap:   () {
                                  viewModel.onPlanSelected(context, package);
                                },
                              ),
                              const Gap(16),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Gap(24),
                if (viewModel.customerInfo == null) ...[
                  _buildRestoreSubscription(viewModel, context, s),
                  const Gap(32),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextButton _buildRestoreSubscription(
      PricingViewModel viewModel, BuildContext context, S s) {
    return TextButton.icon(
      onPressed: () => viewModel.restorePurchases(context),
      icon: Icon(Icons.restore, color: context.colors.onSurface),
      label: Text(
        s.restorePurchases,
        style: TextStyle(color: context.colors.onSurface),
      ),
    );
  }

  Container _buildIconView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        size: 60,
        color: Colors.amber,
      ),
    );
  }

  Padding _buildTitleBar(BuildContext context, S s) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          Text(
            s.removeAds,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
