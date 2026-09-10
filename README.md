# Medallion-Flow — ERP & CRM Data Warehouse

> **End-to-end data engineering project** that consolidates ERP and CRM source data into a structured, analytics-ready data warehouse using the **Medallion Architecture** on Microsoft SQL Server.

---

## Data Architecture

![Alt text](docs\Data_Architecture.png)

The pipeline follows a **Bronze → Silver → Gold** layered approach, progressively refining raw data into business-ready analytical models.

---

## Project Structure

```
erp-crm-medallion-warehouse/
│
├── datasets/
│   ├── source_crm/           # Raw CRM source files (CSV)
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/           # Raw ERP source files (CSV)
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── scripts/
│   ├── init_database.sql     # Database & schema initialisation
│   ├── bronze/
│   │   ├── ddl_bronze.sql           # Bronze table definitions
│   │   └── proc_load_bronze.sql     # Stored procedure: raw ingestion
│   ├── silver/
│   │   ├── ddl_silver.sql           # Silver table definitions
│   │   ├── proc_load_silver.sql     # Stored procedure: cleansing & enrichment
│   │   └── explore_bronze.sql       # EDA queries on bronze layer
│   └── gold/
│       └── ddl_gold.sql             # Gold views (Star Schema)
│
├── docs/
│   └── Data Architecture.png
│
└── tests/
```

---

## Pipeline Overview

### Bronze: Raw Ingestion
- **Object Type:** Tables
- **Load Strategy:** Full Load (Truncate & Insert) via Stored Procedure
- **Transformation:** None — data is loaded *as-is* from CSV files
- **Sources:** `crm_cust_info`, `crm_prd_info`, `crm_sales_details`, `erp_cust_az12`, `erp_loc_a101`, `erp_px_cat_g1v2`

### Silver: Cleansing & Standardisation
- **Object Type:** Tables
- **Load Strategy:** Full Load (Truncate & Insert) via Stored Procedure
- **Transformations applied:**
  - Data Cleansing (nulls, duplicates, invalid records)
  - Data Standardisation (date types, gender codes, country names)
  - Data Normalisation (product key derivation, category ID parsing)
  - Derived Columns (`dwh_create_date` audit stamp on all tables)
  - Data Enrichment (cross-source alignment)

### Gold: Business-Ready Analytics
- **Object Type:** SQL Views (no physical load)
- **Model:** Star Schema
- **Transformations applied:**
  - Data Integrations (CRM ⨝ ERP joins)
  - Surrogate Key generation (`ROW_NUMBER()`)
  - Business Logics (latest product filter, gender fallback logic)

| View | Type | Description |
|---|---|---|
| `gold.dim_customers` | Dimension | Customer profile enriched with birthdate, gender & country |
| `gold.dim_products` | Dimension | Active product catalogue with category & cost metadata |
| `gold.fact_sales` | Fact | Order-level sales transactions joined to dims |

---

## Getting Started

### Prerequisites
- Microsoft SQL Server 2019+
- SQL Server Management Studio (SSMS) or Azure Data Studio

### Setup

**1. Initialise the database and schemas**
```sql
-- Run: scripts/init_database.sql
CREATE DATABASE DataWarehouse;
-- Creates schemas: bronze, silver, gold
```

**2. Create Bronze tables**
```sql
-- Run: scripts/bronze/ddl_bronze.sql
```

**3. Load Bronze (raw ingestion)**
```sql
-- Run: scripts/bronze/proc_load_bronze.sql
-- Then execute:
EXEC bronze.load_bronze;
```

**4. Create Silver tables**
```sql
-- Run: scripts/silver/ddl_silver.sql
```

**5. Load Silver (cleansed & enriched)**
```sql
-- Run: scripts/silver/proc_load_silver.sql
-- Then execute:
EXEC silver.load_silver;
```

**6. Build Gold views**
```sql
-- Run: scripts/gold/ddl_gold.sql
-- Views are query-ready immediately
```

---

## Data Sources

| System | File | Records (approx.) | Description |
|---|---|---|---|
| CRM | `cust_info.csv` | ~29 K | Customer demographics & profile |
| CRM | `prd_info.csv` | ~500 | Product catalogue |
| CRM | `sales_details.csv` | ~60 K | Order transaction history |
| ERP | `CUST_AZ12.csv` | ~19 K | Customer birthdate & gender (ERP) |
| ERP | `LOC_A101.csv` | ~14 K | Customer country/location |
| ERP | `PX_CAT_G1V2.csv` | ~37 | Product category & subcategory |

---

## Analytical Use Cases

After the Gold layer is built, the Star Schema enables:

- **Sales Performance** — Revenue, quantity, and pricing trends over time
- **Customer Segmentation** — Demographics by gender, marital status, and geography
- **Product Analytics** — Category-level revenue contribution and product line analysis
- **Regional Analysis** — Country-level sales distribution
- **Machine Learning** — Clean, flat feature tables ready for model training

---

## Tech Stack

| Tool | Role |
|---|---|
| **Microsoft SQL Server** | Data Warehouse engine |
| **T-SQL Stored Procedures** | ETL automation (Bronze & Silver loads) |
| **SQL Views** | Gold layer semantic layer |
| **CSV Files** | Source system exports (CRM & ERP) |
| **SSMS / Azure Data Studio** | Development & query interface |

---

## Key Design Decisions

- **Full Load strategy** chosen for Bronze and Silver to ensure idempotency and simplify error recovery.
- **Stored Procedures** encapsulate transformation logic, making the pipeline rerunnable with a single `EXEC` call.
- **Gold as Views** avoids data duplication — the layer is always derived on-the-fly from Silver, ensuring consistency.
- **Surrogate keys** are generated in Gold via `ROW_NUMBER()` to decouple the warehouse model from source system IDs.
- **Gender fallback logic** — CRM gender value takes precedence; ERP gender is used only when CRM value is `'Unknown'`.

---
