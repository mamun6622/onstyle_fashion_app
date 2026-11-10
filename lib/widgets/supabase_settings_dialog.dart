import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../supabase_config.dart';
import '../providers/product_provider.dart';

class SupabaseSettingsDialog extends StatefulWidget {
  const SupabaseSettingsDialog({super.key});

  @override
  State<SupabaseSettingsDialog> createState() => _SupabaseSettingsDialogState();
}

class _SupabaseSettingsDialogState extends State<SupabaseSettingsDialog> {
  late TextEditingController _urlController;
  late TextEditingController _keyController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: SupabaseConfig.supabaseUrl);
    _keyController = TextEditingController(text: SupabaseConfig.supabaseAnonKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveAndConnect() async {
    setState(() => _isSaving = true);

    SupabaseConfig.supabaseUrl = _urlController.text.trim();
    SupabaseConfig.supabaseAnonKey = _keyController.text.trim();

    await SupabaseConfig.init();

    if (mounted) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.loadProducts();

      if (!mounted) return;

      setState(() => _isSaving = false);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            SupabaseConfig.isConfigured
                ? 'Supabase Configured & Connected Successfully!'
                : 'Running in Demo Mode with Sample Fashion Database',
          ),
          backgroundColor: SupabaseConfig.isConfigured ? Colors.green[700] : Colors.blueGrey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_sync, color: Colors.indigo, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Supabase Database',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SupabaseConfig.isConfigured
                    ? Colors.green.withOpacity(0.1)
                    : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: SupabaseConfig.isConfigured
                      ? Colors.green
                      : Colors.amber[800]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    SupabaseConfig.isConfigured
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: SupabaseConfig.isConfigured
                        ? Colors.green[800]
                        : Colors.amber[900],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      SupabaseConfig.isConfigured
                          ? 'Connected to Supabase Cloud Database'
                          : 'Currently using built-in Fashion Sample Data (Provide credentials below to sync with your database)',
                      style: TextStyle(
                        fontSize: 12,
                        color: SupabaseConfig.isConfigured
                            ? Colors.green[900]
                            : Colors.amber[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Supabase Project URL',
                hintText: 'https://xxxx.supabase.co',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: 'Supabase Anon Key',
                hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'SQL Table Schema Setup:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Run this SQL script in Supabase SQL Editor to create the products table:',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: SupabaseConfig.sqlSchemaScript),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SQL Script copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy SQL Schema'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAndConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save & Connect Supabase',
                        style: TextStyle(
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
}
