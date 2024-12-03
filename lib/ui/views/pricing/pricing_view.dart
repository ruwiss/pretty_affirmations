import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/services/revenue_cat_service.dart';
import 'package:pretty_affirmations/ui/views/pricing/pricing_viewmodel.dart';

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
                Padding(
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
                ),
                const SizedBox(height: 20),
                Container(
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
                ),
                const SizedBox(height: 20),
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
                              _buildPlanCard(
                                context,
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
                                onTap: () {},
                              ),
                              const Gap(16),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () async {
                    await RevenueCatService().restorePurchases();
                  },
                  icon: Icon(Icons.restore, color: context.colors.onSurface),
                  label: Text(
                    s.restorePurchases,
                    style: TextStyle(color: context.colors.onSurface),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    String? savings,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0XFFf9eaea) : Colors.grey.shade200,
          width: 2,
        ),
        color: isPopular ? const Color(0XFFf9eaea).withOpacity(0.2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPopular) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0XFFf9eaea),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            S.of(context).bestValue,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      if (savings != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          savings,
                          style: TextStyle(
                            color: Colors.pink.shade300,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
