import 'package:flutter/material.dart';
import 'package:pretty_affirmations/generated/l10n.dart';

class PricingPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final String? savings;
  final bool isPopular;
  final VoidCallback onTap;

  const PricingPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    this.savings,
    required this.isPopular,
    required this.onTap,
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
                          savings!,
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
