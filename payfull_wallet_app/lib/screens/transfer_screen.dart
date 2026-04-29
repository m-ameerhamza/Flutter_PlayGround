import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  Contact? _selectedContact;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transfer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        centerTitle: true,
      ),
      body: Consumer<WalletProvider>(
        builder: (ctx, provider, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Recipient',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.contacts.length,
                  itemBuilder: (ctx, i) {
                    final contact = provider.contacts[i];
                    final isSelected = _selectedContact?.id == contact.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedContact = contact),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: AppTheme.primary, width: 2) : null,
                                boxShadow: [BoxShadow(color: AppTheme.shadow, blurRadius: 10)],
                              ),
                              child: Center(
                                child: Text(contact.initials,
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? AppTheme.primary : AppTheme.textPrimary)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(contact.name.split(' ').first,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              const Text('Amount',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              GlassCard(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    hintText: '0.00',
                    hintStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.border),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Note (Optional)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              GlassCard(
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: TextStyle(color: AppTheme.border),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedContact != null && _amountController.text.isNotEmpty ? _handleTransfer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Send Money',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTransfer() async {
    if (_selectedContact == null || _amountController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);
    await context.read<WalletProvider>().simulateTransfer(
          contact: _selectedContact!,
          amount: amount,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
        );
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully sent \$${amount.toStringAsFixed(2)} to ${_selectedContact!.name}'),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }
}