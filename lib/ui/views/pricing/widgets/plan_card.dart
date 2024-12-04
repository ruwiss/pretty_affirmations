import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

class PricingPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final String? savings;
  final bool isPopular;
  final VoidCallback onTap;
  final bool isPurchased;
  final CustomerInfo? customerInfo;

  const PricingPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    this.savings,
    required this.isPopular,
    required this.onTap,
    this.isPurchased = false,
    this.customerInfo,
  });

  @override
  Widget build(BuildContext context) {
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
                      if (isPopular && !isPurchased) ...[
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
                        const Gap(8),
                      ],
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isPurchased
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(.5)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Gap(4),
                      if (!isPurchased)
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
                      if (customerInfo != null && isPurchased)
                        _buildCustomerInfo(context, S.of(context)),
                      if (savings != null && !isPurchased) ...[
                        const Gap(4),
                        Text(
                          savings!,
                          style: const TextStyle(
                            color: Colors.green,
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
                      color: isPurchased
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5)
                          : Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context, S s) {
    final activeEntitlements = customerInfo!.entitlements.active;
    late final String text;
    if (customerInfo!.entitlements.active.isNotEmpty) {
      final expiration = activeEntitlements.values.first.expirationDate!;
      final expirationDate = DateTime.parse(expiration).mmddyyyy;
      text = s.planIsActiveDescription(expirationDate);
    } else {
      text = s.planIsNotActiveDescription;
    }
    return Text(
      text,
      style: const TextStyle(color: Colors.blueGrey),
    );
  }
}
