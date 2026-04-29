import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final TransactionCategory category;
  final String? avatarUrl;

  const Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.category,
    this.avatarUrl,
  });
}

enum TransactionCategory {
  food,
  bills,
  entertainment,
  shopping,
  health,
  transfer,
  savings,
}

extension TransactionCategoryExt on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Food & Drink';
      case TransactionCategory.bills:
        return 'Bills';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.health:
        return 'Health';
      case TransactionCategory.transfer:
        return 'Transfer';
      case TransactionCategory.savings:
        return 'Savings';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant_rounded;
      case TransactionCategory.bills:
        return Icons.receipt_long_rounded;
      case TransactionCategory.entertainment:
        return Icons.tv_rounded;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TransactionCategory.health:
        return Icons.favorite_rounded;
      case TransactionCategory.transfer:
        return Icons.swap_horiz_rounded;
      case TransactionCategory.savings:
        return Icons.savings_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return AppTheme.yellow;
      case TransactionCategory.bills:
        return AppTheme.accent;
      case TransactionCategory.entertainment:
        return AppTheme.blue;
      case TransactionCategory.shopping:
        return AppTheme.purple;
      case TransactionCategory.health:
        return AppTheme.green;
      case TransactionCategory.transfer:
        return AppTheme.primary;
      case TransactionCategory.savings:
        return const Color(0xFF06D6A0);
    }
  }

  Color get bgColor {
    return color.withOpacity(0.12);
  }
}

// Card Models
class BankCard {
  final String id;
  final String cardHolder;
  final String cardNumber;
  final String expiry;
  final double balance;
  final CardType type;
  final List<Color> gradientColors;

  const BankCard({
    required this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiry,
    required this.balance,
    required this.type,
    required this.gradientColors,
  });
}

enum CardType { visa, mastercard, paypal }

// Budget Models
class Budget {
  final String id;
  final String title;
  final double amount;
  final double spent;
  final int items;
  final IconData icon;
  final Color color;

  const Budget({
    required this.id,
    required this.title,
    required this.amount,
    required this.spent,
    required this.items,
    required this.icon,
    required this.color,
  });

  double get percentage => (spent / amount).clamp(0.0, 1.0);
  double get remaining => amount - spent;
}

// Contact Model 
class Contact {
  final String id;
  final String name;
  final String initials;
  final Color color;
  final String? accountNumber;

  const Contact({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
    this.accountNumber,
  });
}
