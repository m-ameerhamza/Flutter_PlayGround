import 'package:flutter/material.dart';
import 'models.dart';
import '../data/mock_data.dart';

class WalletProvider extends ChangeNotifier {
  int _currentCardIndex = 0;
  bool _showExpenses = true;
  int _selectedNavIndex = 0;
  String _transactionFilter = 'all'; // all, income, expense
  bool _isLoading = false;

  //  Getters 
  List<BankCard> get cards => MockData.cards;
  List<Transaction> get allTransactions => MockData.transactions;
  List<Budget> get budgets => MockData.budgets;
  List<Contact> get contacts => MockData.contacts;
  int get currentCardIndex => _currentCardIndex;
  bool get showExpenses => _showExpenses;
  int get selectedNavIndex => _selectedNavIndex;
  String get transactionFilter => _transactionFilter;
  bool get isLoading => _isLoading;

  BankCard get currentCard => cards[_currentCardIndex];

  double get totalBalance =>
      cards.fold(0, (sum, card) => sum + card.balance);

  double get totalIncome =>
      allTransactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses =>
      allTransactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

  double get totalSavings => totalIncome - totalExpenses;

  List<Transaction> get filteredTransactions {
    switch (_transactionFilter) {
      case 'income':
        return allTransactions.where((t) => t.isIncome).toList();
      case 'expense':
        return allTransactions.where((t) => !t.isIncome).toList();
      default:
        return allTransactions;
    }
  }

  //  Actions 
  void setCurrentCard(int index) {
    _currentCardIndex = index;
    notifyListeners();
  }

  void toggleShowExpenses() {
    _showExpenses = !_showExpenses;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setTransactionFilter(String filter) {
    _transactionFilter = filter;
    notifyListeners();
  }

  Future<void> simulateTransfer({
    required Contact contact,
    required double amount,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners();
  }

  // Chart: percentage breakdown by category
  Map<TransactionCategory, double> get categoryBreakdown {
    final expenses = allTransactions.where((t) => !t.isIncome).toList();
    final total = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final Map<TransactionCategory, double> result = {};
    for (final t in expenses) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result.map((k, v) => MapEntry(k, v / total));
  }
}