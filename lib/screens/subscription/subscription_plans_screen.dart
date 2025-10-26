import 'package:flutter/material.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String price,
    required String duration,
    required List<String> features,
    required Color accentColor,
    bool isPopular = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: title == 'Free' 
              ? Colors.white 
              : title == 'Monthly Pro'
                  ? const Color(0xFF4B0082)
                  : const Color(0xFFFFD700), // Gold for yearly
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: duration,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Handle subscription
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: title == 'Free' 
                      ? Colors.white
                      : title == 'Monthly Pro'
                          ? const Color(0xFF4B0082)
                          : const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: title == 'Free' || title == 'Yearly Pro'
                      ? Colors.black // Black text for white and gold buttons
                      : Colors.white, // White text for purple button
                ),
                child: Text(
                  title == 'Free' ? 'Current Plan' : 'Subscribe',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
        elevation: 0,
        title: Text(
          'Subscription Plans',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Choose Your Plan',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the perfect plan for your needs',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            _buildPlanCard(
              context: context,
              title: 'Free',
              price: '₹0',
              duration: '/forever',
              accentColor: Colors.grey,
              features: [
                'Create up to 3 habits',
                'Basic habit tracking',
                'Daily reminders',
                'Progress statistics',
              ],
            ),
            _buildPlanCard(
              context: context,
              title: 'Monthly Pro',
              price: '₹99',
              duration: '/month',
              accentColor: theme.colorScheme.primary,
              isPopular: true,
              features: [
                'Unlimited habits',
                'Advanced analytics',
                'Priority support',
                'Custom habit icons',
                'Multiple reminders per habit',
                'Export data & insights',
              ],
            ),
            _buildPlanCard(
              context: context,
              title: 'Yearly Pro',
              price: '₹999',
              duration: '/year',
              accentColor: const Color(0xFFFFD700), // Gold color
              features: [
                'All Monthly Pro features',
                '2 months free',
                'Early access to new features',
                'Premium habit templates',
                'Advanced habit insights',
                'Personal habit coach AI',
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}