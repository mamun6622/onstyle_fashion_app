# ON:STYLE - Modern Fashion & E-Commerce Application

**ON:STYLE** is a modern, responsive, full-featured fashion shopping mobile & web application built with **Flutter**, **Provider**, and **Supabase Database**.

---

## Key Features

- **Fashion Product Showcase & Catalog**: Browse fashion items by categories (*Tops*, *Dresses*, *Outerwear*, *Pants & Skirts*, *Shoes*, *Accessories*).
- **Search & Advanced Sorting**: Search items and sort by *Newest Arrival*, *Price: Low to High*, *Price: High to Low*, or *Highest Rated*.
- **Product Details & Customization**: Interactive size selection (S, M, L, XL), color swatches, rating breakdown, and stock status badges (*In Stock*, *Low Stock*, *Out of Stock*).
- **Cart & Order Calculator**: Dynamic cart badge, item quantity controls (+/-), and real-time subtotal, tax, and **Free Shipping Tracker** (unlocked over \$150).
- **Checkout & Payment Gateway**: Shipping form with required Phone Number and optional Email. Payment option selection (*Credit/Debit Card*, *Apple/Google Pay*, *Cash on Delivery*).
- **Live Order Tracking**: Track orders in real-time by entering a Phone Number or Email address with a status timeline (*Ordered* -> *Processing* -> *Shipped* -> *Delivered*).
- **Admin Control Panel**:
  - **Admin Authentication Protected**: Viewers have read-only access; Admin sign-in required to manage app inventory.
  - **Stock & Quantity Management**: Quick stock adjuster (`+` / `-`), stock summary statistics, and stock update logic upon customer checkout.
  - **Order Management System**: View all customer orders, filter by status, and update order status live (*Processing*, *Shipped*, *Delivered*, *Cancelled*).
- **Cross-Platform Responsive Design**: Optimized UI for Smartphones, Tablets, Foldables, Landscape orientation, and Desktop screens.

---

## Supabase Database Setup

Run the following SQL query in your **Supabase Console -> SQL Editor**:

```sql
-- 1. PRODUCTS TABLE
create table if not exists products (
  id text primary key,
  title text not null,
  description text not null,
  price double precision not null,
  original_price double precision,
  category text not null,
  image_url text not null,
  rating double precision default 4.5,
  sizes text[],
  colors text[],
  is_popular boolean default false,
  stock integer default 15,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. ORDERS TABLE
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

-- 3. ENABLE RLS PERMISSIONS
alter table products enable row level security;
alter table orders enable row level security;

create policy "Public products access" on products for all using (true);
create policy "Public orders access" on orders for all using (true);
```

---

## Getting Started

### Prerequisites
- Flutter SDK (v3.13.0 or higher)
- Dart SDK

### Installation & Run

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/onstyle_fashion_app.git

# 2. Navigate to directory
cd onstyle_fashion_app

# 3. Install dependencies
flutter pub get

# 4. Run application
flutter run
```

---

## Admin Credentials

- **Email**: `admin@fashion.com`
- **Password**: `admin123`
