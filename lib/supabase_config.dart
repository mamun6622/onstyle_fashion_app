import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  /// Hardcoded Supabase Credentials
  static String supabaseUrl = 'https://scqrtdlixykoogyuoagj.supabase.co';
  static String supabaseAnonKey = 'sb_publishable_wk06smkCAM3_3-BCl8qEFw_NPJrHS8g';

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static Future<void> init() async {
    if (isConfigured && !_isInitialized) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
        _isInitialized = true;
      } catch (e) {
        // Fallback or already initialized handling
        _isInitialized = true;
      }
    }
  }

  /// SQL Script provided for user convenience to run in Supabase SQL Editor:
  static const String sqlSchemaScript = '''
-- 1. UPDATE PRODUCTS TABLE (Stock Column)
alter table if exists products 
  add column if not exists stock integer default 15;

-- 2. CREATE OR UPDATE ORDERS TABLE (Phone Number & Email for Tracking)
create table if not exists orders (
  id text primary key,
  item_count integer default 1,
  subtotal double precision not null,
  tax double precision not null,
  shipping double precision not null,
  total_amount double precision not null,
  shipping_address text not null,
  phone_number text not null default '',
  customer_email text default '',
  payment_method text not null,
  status text default 'Processing',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ADD MISSING COLUMNS IF ORDERS TABLE ALREADY EXISTS
alter table if exists orders
  add column if not exists phone_number text not null default '',
  add column if not exists customer_email text default '';

-- Enable RLS
alter table orders enable row level security;
drop policy if exists "Public orders access" on orders;
create policy "Public orders access" on orders for all using (true);
''';
}
