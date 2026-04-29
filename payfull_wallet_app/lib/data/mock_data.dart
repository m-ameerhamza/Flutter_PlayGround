import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class MockData {
  // ─── Cards ──────────────────────────────────────────────────────────────────
  static final List<BankCard> cards = [
    BankCard(
      id: '1',
      cardHolder: 'Ameer Hamza',
      cardNumber: '0000 0000 1111 1111',
      expiry: '09/27',
      balance: 8182.80,
      type: CardType.visa,
      gradientColors: const [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
    ),
    BankCard(
      id: '2',
      cardHolder: 'Ameer Hamza',
      cardNumber: '0000 0000 1111 1111',
      expiry: '03/26',
      balance: 3540.00,
      type: CardType.mastercard,
      gradientColors: const [Color(0xFF6C63FF), Color(0xFF4834D4), Color(0xFF2B1FA8)],
    ),
    BankCard(
      id: '3',
      cardHolder: 'Ameer Hamza',
      cardNumber: '0000 0000 1111 1111',
      expiry: '12/28',
      balance: 1520.00,
      type: CardType.paypal,
      gradientColors: const [Color(0xFF009FFF), Color(0xFF006FD6), Color(0xFF003087)],
    ),
  ];

  // ─── Transactions ────────────────────────────────────────────────────────────
  static final List<Transaction> transactions = [
    Transaction(
      id: 't1',
      title: 'Netflix Subscription',
      subtitle: 'Entertainment',
      amount: 15.99,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      category: TransactionCategory.entertainment,
    ),
    Transaction(
      id: 't2',
      title: 'Freelance Payment',
      subtitle: 'From Upwork',
      amount: 1200.00,
      isIncome: true,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      category: TransactionCategory.transfer,
    ),
    Transaction(
      id: 't3',
      title: 'Starbucks Coffee',
      subtitle: 'Food & Beverages',
      amount: 6.50,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: TransactionCategory.food,
    ),
    Transaction(
      id: 't4',
      title: 'Electricity Bill',
      subtitle: 'KESC Monthly',
      amount: 87.20,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: TransactionCategory.bills,
    ),
    Transaction(
      id: 't5',
      title: 'Salary Deposit',
      subtitle: 'Monthly Salary',
      amount: 5000.00,
      isIncome: true,
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: TransactionCategory.transfer,
    ),
    Transaction(
      id: 't6',
      title: 'Amazon Shopping',
      subtitle: '3 items ordered',
      amount: 142.30,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: TransactionCategory.shopping,
    ),
    Transaction(
      id: 't7',
      title: 'Doctor Visit',
      subtitle: 'City Hospital',
      amount: 55.00,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: TransactionCategory.health,
    ),
    Transaction(
      id: 't8',
      title: 'Transfer Received',
      subtitle: 'From Amilina Josef',
      amount: 300.00,
      isIncome: true,
      date: DateTime.now().subtract(const Duration(days: 4)),
      category: TransactionCategory.transfer,
    ),
    Transaction(
      id: 't9',
      title: 'Spotify Premium',
      subtitle: 'Music Streaming',
      amount: 9.99,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: TransactionCategory.entertainment,
    ),
    Transaction(
      id: 't10',
      title: 'Grocery Store',
      subtitle: 'Metro Supermarket',
      amount: 74.80,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 6)),
      category: TransactionCategory.food,
    ),
  ];

  // ─── Budgets ─────────────────────────────────────────────────────────────────
  static final List<Budget> budgets = [
    Budget(
      id: 'b1',
      title: 'Bills',
      amount: 800.00,
      spent: 620.00,
      items: 12,
      icon: Icons.receipt_long_rounded,
      color: AppTheme.accent,
    ),
    Budget(
      id: 'b2',
      title: 'Food',
      amount: 500.00,
      spent: 320.00,
      items: 15,
      icon: Icons.restaurant_rounded,
      color: AppTheme.yellow,
    ),
    Budget(
      id: 'b3',
      title: 'Entertainment',
      amount: 300.00,
      spent: 210.00,
      items: 20,
      icon: Icons.tv_rounded,
      color: AppTheme.blue,
    ),
    Budget(
      id: 'b4',
      title: 'Health',
      amount: 400.00,
      spent: 130.00,
      items: 9,
      icon: Icons.favorite_rounded,
      color: AppTheme.green,
    ),
    Budget(
      id: 'b5',
      title: 'Shopping',
      amount: 600.00,
      spent: 420.00,
      items: 18,
      icon: Icons.shopping_bag_rounded,
      color: AppTheme.purple,
    ),
  ];

  // Contacts 
  static final List<Contact> contacts = [
    const Contact(id: 'c1', name: 'Hamza', initials: 'AJ', color: Color(0xFF6C63FF), accountNumber: '4562 4568 2391 7780'),
    const Contact(id: 'c2', name: 'Haroon', initials: 'JL', color: Color(0xFF4CAF87), accountNumber: '5234 8821 4411 0022'),
    const Contact(id: 'c3', name: 'Ayesha', initials: 'SK', color: Color(0xFFFF6B6B), accountNumber: '4111 2233 4455 6677'),
    const Contact(id: 'c4', name: 'Sara', initials: 'DP', color: Color(0xFFFFC107), accountNumber: '5432 1109 8877 6655'),
    const Contact(id: 'c5', name: 'Ali', initials: 'ML', color: Color(0xFF48CAE4), accountNumber: '4000 1234 5678 9010'),
  ];

  // Weekly Chart Data
  static final List<double> weeklyExpenses = [1200, 900, 1500, 800, 2135, 600, 700];
  static final List<double> weeklyIncome = [2000, 1800, 2200, 1500, 2800, 1200, 900];
  static final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
