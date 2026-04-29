import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/wallet_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../data/mock_data.dart';
import 'transactions_screen.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _cardController = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Consumer<WalletProvider>(
            builder: (ctx, provider, _) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(provider)),
                SliverToBoxAdapter(child: _buildCardCarousel(provider)),
                SliverToBoxAdapter(child: _buildStatRow(provider)),
                SliverToBoxAdapter(child: _buildQuickActions(context)),
                SliverToBoxAdapter(child: _buildWeeklyChart(provider)),
                SliverToBoxAdapter(child: _buildRecentTransactions(context, provider)),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Header 
  Widget _buildHeader(WalletProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Good Morning!',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(provider.currentCard.cardHolder,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          Row(
            children: [
              _iconBtn(Icons.search_rounded, () {}),
              const SizedBox(width: 10),
              _iconBtn(Icons.notifications_outlined, () {}, badge: true),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                // ignore: deprecated_member_use
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: const Text('MH',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppTheme.shadow, blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 20),
          ),
          if (badge)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppTheme.accent),
              ),
            ),
        ],
      ),
    );
  }

  //  Card Carousel 
  Widget _buildCardCarousel(WalletProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 22),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _cardController,
            itemCount: provider.cards.length,
            onPageChanged: provider.setCurrentCard,
            itemBuilder: (ctx, i) => Padding(
              padding: EdgeInsets.only(
                right: 12,
                left: i == 0 ? 22 : 0,
              ),
              child: BankCardWidget(card: provider.cards[i]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SmoothPageIndicator(
          controller: _cardController,
          count: provider.cards.length,
          effect: const WormEffect(
            dotColor: AppTheme.border,
            activeDotColor: AppTheme.primary,
            dotWidth: 8,
            dotHeight: 8,
            spacing: 6,
          ),
        ),
      ],
    );
  }

  //  Stat Row ─────────────────────────────────────────────────────────────────
  Widget _buildStatRow(WalletProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Row(
        children: [
          StatCard(
            label: 'Total Income',
            amount: provider.totalIncome,
            isPositive: true,
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(width: 14),
          StatCard(
            label: 'Total Expenses',
            amount: provider.totalExpenses,
            isPositive: false,
            icon: Icons.arrow_upward_rounded,
          ),
        ],
      ),
    );
  }

  //  Quick Actions 
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: GlassCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            QuickActionButton(
              icon: Icons.send_rounded,
              label: 'Send',
              color: AppTheme.primary,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const TransferScreen())),
            ),
            QuickActionButton(
              icon: Icons.add_rounded,
              label: 'Top Up',
              color: AppTheme.green,
              onTap: () {},
            ),
            QuickActionButton(
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              color: AppTheme.yellow,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const TransferScreen())),
            ),
            QuickActionButton(
              icon: Icons.more_horiz_rounded,
              label: 'More',
              color: AppTheme.textSecondary,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  //  Weekly Chart 
  Widget _buildWeeklyChart(WalletProvider provider) {
    final expenses = MockData.weeklyExpenses;
    final maxVal = expenses.reduce((a, b) => a > b ? a : b);
    final highlightIndex = 4; // Friday

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Expenses',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(formatCurrency(provider.totalExpenses),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Text('Weekly', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(MockData.weekDays.length, (i) {
                  final ratio = expenses[i] / maxVal;
                  final isHighlight = i == highlightIndex;
                  return _buildBar(
                    label: MockData.weekDays[i],
                    ratio: ratio,
                    isHighlight: isHighlight,
                    value: expenses[i],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required double ratio,
    required bool isHighlight,
    required double value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isHighlight)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('\$${(value / 1000).toStringAsFixed(1)}k',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          )
        else
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.border),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 30,
          height: 60 * ratio,
          decoration: BoxDecoration(
            color: isHighlight ? AppTheme.dark : AppTheme.surfaceVariant,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: isHighlight
                // ignore: deprecated_member_use
                ? [BoxShadow(color: AppTheme.dark.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  //  Recent Transactions 
  Widget _buildRecentTransactions(BuildContext context, WalletProvider provider) {
    final recent = provider.allTransactions.take(5).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(
        children: [
          SectionHeader(
            title: 'Recent Transactions',
            actionLabel: 'See All',
            onAction: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: recent
                  .map((t) => TransactionTile(transaction: t))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}