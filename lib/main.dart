import 'package:flutter/material.dart';
import 'frontend/screens/loading_screen.dart';

void main() {
  runApp(const FraudDetectionApp());
}

class FraudDetectionApp extends StatelessWidget {
  const FraudDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fraud Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // Simulate loading process
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      amount: 250.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      merchant: 'Online Store',
      isFlagged: true,
    ),
    Transaction(
      id: '2',
      amount: 45.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      merchant: 'Coffee Shop',
      isFlagged: false,
    ),
    Transaction(
      id: '3',
      amount: 1250.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      merchant: 'Electronics Store',
      isFlagged: true,
    ),
    Transaction(
      id: '4',
      amount: 19.99,
      date: DateTime.now().subtract(const Duration(days: 3)),
      merchant: 'Subscription Service',
      isFlagged: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Fraud Detection',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          _showReportDialog();
        },
        child: const Icon(Icons.add_alert, color: Colors.white),
        tooltip: 'Report Suspicious Activity',
      ),
    );
  }

  Widget _buildSummaryCard() {
    final flaggedCount = _transactions.where((t) => t.isFlagged).length;
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            Icons.credit_card,
            '${_transactions.length}',
            'Total Transactions',
          ),
          _buildSummaryItem(
            Icons.warning_amber,
            '$flaggedCount',
            'Flagged Transactions',
            isAlert: true,
          ),
          _buildSummaryItem(
            Icons.security,
            'Medium',
            'Risk Level',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label, {bool isAlert = false}) {
    return Column(
      children: [
        Icon(
          icon,
          color: isAlert ? Colors.red : Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isAlert ? Colors.red : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.isFlagged ? Colors.red.shade100 : Colors.blue.shade100,
              child: Icon(
                transaction.isFlagged ? Icons.warning : Icons.check_circle,
                color: transaction.isFlagged ? Colors.red : Colors.blue,
              ),
            ),
            title: Text(transaction.merchant),
            subtitle: Text(
              '${_formatDate(transaction.date)} • \$${transaction.amount.toStringAsFixed(2)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Action for transaction details
              },
            ),
          ),
        );
      },
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Suspicious Activity'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Transaction ID',
                hintText: 'Enter transaction ID',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the suspicious activity',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle report submission
              Navigator.of(context).pop();
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String merchant;
  final bool isFlagged;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.merchant,
    required this.isFlagged,
  });
}
