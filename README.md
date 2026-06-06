# 🛒 dbt E-Commerce Analytics Pipeline

A multi-layer dbt Core analytics pipeline modeling raw e-commerce data (customers and orders) into analytics-ready staging views and business mart tables — with schema tests, referential integrity checks, and customer segmentation.

---

## Pipeline Architecture

```
seeds/
├── customers.csv   ← raw customer data
└── orders.csv      ← raw order data
        │
        ▼
models/staging/     (materialized as views)
├── stg_customers   ← renamed + cleaned customers
└── stg_orders      ← renamed + cleaned orders
        │
        ▼
models/marts/       (materialized as tables)
├── dim_customers        ← customer dimension with order history
├── fct_orders           ← orders fact table with completion flag
└── fct_customer_orders  ← customer-level aggregation + segmentation
```

---

## Models

### Staging
| Model | Description |
|---|---|
| `stg_customers` | Renames and cleans raw customer fields |
| `stg_orders` | Renames and cleans raw order fields |

### Marts
| Model | Description |
|---|---|
| `dim_customers` | One row per customer with first/last order dates and order count |
| `fct_orders` | One row per order with completion status flag |
| `fct_customer_orders` | Customer-level aggregation: total orders, completion rate, return count, and segment (High Value / Returning / New / No Orders) |

---

## Data Tests (15 passing)

- `unique` and `not_null` on all primary keys
- `relationships` — orders.customer_id references customers.customer_id
- `accepted_values` — order status constrained to valid values
- `accepted_values` — customer_segment constrained to defined tiers

---

## Quick Start

```bash
# Install dependencies
pip install dbt-core dbt-duckdb

# Clone repo
git clone https://github.com/ShaharyarBusinessAnalyst/dbt-ecommerce-analytics
cd dbt-ecommerce-analytics

# Load seed data
dbt seed --profiles-dir .

# Run all models
dbt run --profiles-dir .

# Run all tests
dbt test --profiles-dir .

# Or run everything at once
dbt build --profiles-dir .
```

---

## Project Structure

```
dbt-ecommerce-analytics/
├── models/
│   ├── staging/
│   │   ├── stg_customers.sql
│   │   └── stg_orders.sql
│   ├── marts/
│   │   ├── dim_customers.sql
│   │   ├── fct_orders.sql
│   │   └── fct_customer_orders.sql
│   └── schema.yml          ← model descriptions + all tests
├── seeds/
│   ├── customers.csv
│   └── orders.csv
├── dbt_project.yml
├── profiles.yml            ← DuckDB local connection
└── README.md
```

---

## Tech Stack

- **dbt Core** — transformation framework
- **DuckDB** — local analytical database (no cloud account needed)
- **SQL** — Jinja-templated dbt models
