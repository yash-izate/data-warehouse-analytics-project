```markdown
# SQL Server Data Warehouse Project

This project implements a **SQL Server data warehouse** for CRM and ERP sales data, using the **Medallion Architecture** (Bronze → Silver → Gold). It demonstrates the full extract-transform-load (ETL) pipeline from raw CSV source files into a queryable analytical star schema. The data warehouse is built in SQL Server (T-SQL) and managed with SSMS. 

**Author:** Yash Izate  
**Database:** `DataWarehouse`  
**Schemas:** `bronze`, `silver`, `gold`  
**Stored Procedures:** `bronze.load_bronze`, `silver.load_silver`  
**Views:** `gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`  

## Table of Contents

- [Project Overview](#project-overview)  
- [Business Objectives](#business-objectives)  
- [Source Data Files](#source-data-files)  
- [Data Architecture](#data-architecture)  
- [Data Flow and Lineage](#data-flow-and-lineage)  
- [Source System Integration](#source-system-integration)  
- [Bronze Layer](#bronze-layer)  
- [Silver Layer](#silver-layer)  
- [Gold Layer](#gold-layer)  
- [ETL Workflow](#etl-workflow)  
- [Data Quality and Validation](#data-quality-and-validation)  
- [Analytics Use Cases](#analytics-use-cases)  
- [Repository Structure](#repository-structure)  
- [Setup and Execution](#setup-and-execution)  
- [Design Decisions and Limitations](#design-decisions-and-limitations)  
- [Future Improvements](#future-improvements)  
- [Documentation and Attribution](#documentation-and-attribution)  
- [License](#license)  
- [Author](#author)  

## Project Overview

This data warehouse project ingests transactional and master data from separate CRM and ERP systems, cleans and standardizes it, and creates a star-schema that supports business reporting. The **Bronze** layer stores raw CSV data in SQL tables. The **Silver** layer performs transformations and data-quality cleansing. The **Gold** layer presents the data as analytical views: two dimension tables (`dim_customers`, `dim_products`) and one fact table (`fact_sales`).  

The warehouse enables queries such as monthly sales trends, top products by revenue, and geographic sales analysis. All ETL logic is implemented in T-SQL within stored procedures and views.

## Business Objectives

- Integrate customer, product, and sales data from two source systems (CRM and ERP).  
- Create a consolidated, clean dataset for analytics (e.g., sales trends, product performance).  
- Ensure data quality through validations (e.g., no duplicate keys, valid dates, consistent categories).  
- Support efficient reporting and analysis by business users.  

## Source Data Files

The project ingests **six CSV files** from CRM and ERP. Each file represents an entity or lookup table:

| Source System | CSV File            | Description             |
| ------------- | ------------------- | ----------------------- |
| **CRM**       | `cust_info.csv`     | Customer personal details (ID, name, address, marital status, etc.) |
| **CRM**       | `prd_info.csv`      | Product catalog (product key, name, cost, line, start date, etc.) |
| **CRM**       | `sales_details.csv` | Sales transactions (order number, customer ID, product key, dates, quantity, sales, etc.) |
| **ERP**       | `CUST_AZ12.csv`     | Customer demographics (customer ID, birthdate, gender) |
| **ERP**       | `LOC_A101.csv`      | Customer address lookup (location ID, country, state, etc.) |
| **ERP**       | `PX_CAT_G1V2.csv`   | Product category lookup (category codes, maintenance status) |

Each CSV is loaded into a corresponding table in the **Bronze** schema (one table per file) using `BULK INSERT`. No transformations are applied in Bronze.

## Data Architecture

The warehouse follows a classic three-layer medallion architecture:

- **Bronze** (raw): Holds raw data as loaded from source files.  
- **Silver** (cleaned): Stores standardized and deduplicated data with business transformations.  
- **Gold** (curated): Contains analytical views in a star schema (fact and dimensions).  

This separation helps in isolating raw ingestion logic from business rules and reporting logic. 

<!-- INSERT ORIGINAL HIGH-LEVEL ARCHITECTURE DIAGRAM HERE -->
<!-- ![High-Level Architecture](docs/diagrams/data_architecture.png) -->

### Components

- **Database:** `DataWarehouse`  
- **Schemas:** `bronze`, `silver`, `gold`  
- **ETL Procedures:** 
  - `bronze.load_bronze` (loads CSVs to Bronze tables)  
  - `silver.load_silver` (transforms data into Silver tables)  
- **Views:** 
  - `gold.dim_customers`, `gold.dim_products`, `gold.fact_sales` (create the star schema for analytics)  

## Data Flow and Lineage

All six source files flow into Bronze and then through Silver to Gold. The lineage is as follows:
- CRM and ERP CSVs → Bronze tables → Silver tables (cleaned) → Gold views.

The key transformations include trimming spaces, standardizing codes, deduplicating customers, deriving product validity dates (`LEAD()` function), and reconciling sales values. 

<!-- INSERT ORIGINAL DATA FLOW DIAGRAM HERE -->
<!-- ![Data Flow and Lineage](docs/diagrams/data_flow.png) -->

## Source System Integration

CRM and ERP data are joined by shared keys (e.g., customer ID, product key). For example, ERP address information is joined to CRM customer records using a location ID. ERP product categories are linked to CRM products via category codes. 

The **Silver Layer** harmonizes these integrations before exposing them in Gold. This ensures that the analytical model can drill across CRM/ERP sources seamlessly.

<!-- INSERT ORIGINAL DATA INTEGRATION DIAGRAM HERE -->
<!-- ![Data Integration](docs/diagrams/data_integration.png) -->

## Bronze Layer

The Bronze schema contains the raw tables loaded directly from CSV files:

- `bronze.crm_cust_info`  ← `cust_info.csv`  
- `bronze.crm_prd_info`   ← `prd_info.csv`  
- `bronze.crm_sales_details` ← `sales_details.csv`  
- `bronze.erp_cust_az12`  ← `CUST_AZ12.csv`  
- `bronze.erp_loc_a101`   ← `LOC_A101.csv`  
- `bronze.erp_px_cat_g1v2` ← `PX_CAT_G1V2.csv`  

The `bronze.load_bronze` stored procedure performs a full refresh load: it uses `TRUNCATE TABLE` followed by `BULK INSERT` for each file. This retains the exact source data for auditing and replay if needed, without any filtering or mapping.

### Bronze Highlights

- Maintains a 1:1 mapping with source data.  
- Used for auditing and reloading in case of source updates.  
- No duplicate or formatting changes are made in Bronze.

## Silver Layer

The Silver schema contains transformed data ready for business use. Key operations in `silver.load_silver` include:

- **Deduplication:** Remove duplicate customer records, keeping the latest.  
- **Standardization:** Trim extra spaces, uppercase codes, and unify text fields (e.g., marital status, gender).  
- **Date handling:** Convert dates to `DATE` types; mark invalid dates (out of range) as `NULL`.  
- **Sales logic:** Ensure `sales_amount` equals `quantity * price`. Adjust if discrepancies are found.  
- **Product validity:** Use T-SQL `LEAD()` to calculate `prd_end_dt` (end date) for each product version, with current products having `NULL` end dates.  
- **Key fields:** Generate surrogate keys (`cst_key`, `prd_key`) as needed for future integration.  

The Silver tables are:

- `silver.crm_cust_info` (cleaned customer info)  
- `silver.crm_prd_info` (cleaned product info with derived dates)  
- `silver.crm_sales_details` (cleaned sales transactions)  
- `silver.erp_cust_az12` (standardized ERP customer demographics)  
- `silver.erp_loc_a101` (standardized ERP location data)  
- `silver.erp_px_cat_g1v2` (standardized ERP product categories)  

### Silver Quality Checks

Quality checks were run after loading Silver. No duplicate IDs or NULL primary keys were found. Sample data validations included:

- **Customer table**: All `cst_id` values are unique; no leading/trailing spaces in names.  
- **Product table**: All `prd_id` values are unique; `prd_cost` is non-negative; `prd_end_dt ≥ prd_start_dt`.  
- **Sales table**: No orders with order date after shipping or due dates. All sales amounts match `quantity * price`.  
- **Cross-checks**: Every sales record has matching customer and product keys.  

The following Silver table row counts were observed during development (source data as of the project date):

| Silver Table             | Row Count |
|--------------------------|----------:|
| `silver.crm_cust_info`   |    18,484 |
| `silver.crm_prd_info`    |       397 |
| `silver.crm_sales_details` |  60,398 |
| `silver.erp_loc_a101`    |    18,484 |
| `silver.erp_cust_az12`   |    18,483 |
| `silver.erp_px_cat_g1v2` |       37 |

*Note: These counts reflect the provided source files. If the source data changes, re-run the ETL procedures to refresh the counts.*

## Gold Layer

The Gold layer presents the final star-schema views for analytics:

- **Customer Dimension:** `gold.dim_customers`  
- **Product Dimension:** `gold.dim_products`  
- **Sales Fact:** `gold.fact_sales`  

Each dimension contains a generated surrogate key and relevant attributes from CRM and ERP. The fact table references these keys and contains sales measures.

### Gold Data Model

The star schema links fact to dimensions:

<!-- INSERT ORIGINAL SALES DATA MART / STAR SCHEMA DIAGRAM HERE -->
<!-- ![Sales Data Mart (Star Schema)](docs/diagrams/data_model.png) -->

- `fact_sales` has foreign keys `customer_key` and `product_key`.  
- `dim_customers` contains unique customer demographics (from `crm_cust_info`, `erp_cust_az12`, `erp_loc_a101`).  
- `dim_products` contains unique product info (from `crm_prd_info`, `erp_px_cat_g1v2`).  

Surrogate keys (`customer_key`, `product_key`) are generated using `ROW_NUMBER()`. Since the Gold views are virtual (not persisted tables), these keys are recalculated on each query. This is acceptable for reporting queries but should be documented as a design consideration (persistent keys are a possible improvement).

## ETL Workflow

The data loading and transformation flow is orchestrated by the following sequence:

1. **Initial Setup:** Create the `DataWarehouse` database and `bronze`, `silver`, `gold` schemas.  
2. **Bronze Load:** Run `bronze.load_bronze` to load raw CSV files into Bronze tables.  
3. **Silver Load:** Run `silver.load_silver` to transform Bronze into Silver tables.  
4. **Quality Checks:** Execute custom SQL scripts to validate Silver data (unique keys, valid dates, matching sales logic, etc.).  
5. **Gold Views:** Create or update the `gold.dim_*` and `gold.fact_sales` views.  
6. **Final Validation:** Compare row counts and totals between Silver and Gold; run referential integrity checks.  

After initial setup, these procedures can be re-run whenever source CSVs are updated.

<!-- INSERT ORIGINAL ETL METHODS DIAGRAM HERE -->
<!-- ![ETL Workflow](docs/diagrams/ETL.png) -->

## Data Quality and Validation

Robust data quality checks are integral to the ETL process. Examples of checks performed:

- **Unique Keys:** No duplicate `cst_id` in customers, no duplicate `prd_id` in products.  
- **Referential Integrity:** Every sale record matches a customer and a product in Silver.  
- **Null/Missing Values:** Key fields (IDs, dates, amounts) are not unexpectedly NULL.  
- **Date Validity:** Birthdates are realistic; order/shipment dates are in logical order.  
- **Data Consistency:** Sales amount equals `quantity * price`; product start dates precede end dates.  
- **Text Standardization:** Categorical fields (gender, marital status, country) use consistent codes.  

When issues are detected, data transformations are adjusted (for example, converting impossible dates to `NULL`, or correcting sales figures). In our case, the automated checks returned **no critical errors** on the sample data, indicating the pipeline logic is sound for the given sources.

## Analytics Use Cases

The Gold schema supports a variety of business reports. Example queries include:

- **Monthly Sales Trend:** Total revenue and number of orders by month (to analyze seasonality).  
- **Top Products:** Products ranked by total revenue or units sold.  
- **Sales by Country:** Revenue and order counts aggregated by customer country.  
- **Customer Analysis:** Distribution of sales by customer attributes (e.g., country, gender).  
- **Average Order Value:** Insights on typical sales size per order or customer.  

These analytics help stakeholders understand performance, demand, and customer behavior. *Actual business insights (numeric results) should be derived by running these queries in SSMS on the warehouse.*

## Repository Structure

An example of the project repository layout is shown below. Adjust the structure to match actual file names/locations in this repo:

```text
sql-data-warehouse-project/
├── datasets/
│   ├── source_crm/            # CSV files from CRM
│   └── source_erp/            # CSV files from ERP
├── docs/
│   ├── diagrams/
│   │   ├── data_architecture.png
│   │   ├── data_flow.png
│   │   ├── data_integration.png
│   │   ├── data_model.png
│   │   └── ETL.png
│   ├── data_catalog.md
│   └── naming_conventions.md
├── scripts/
│   ├── bronze/
│   │   └── bronze_load.sql    # CREATE TABLE + load_bronze proc
│   ├── silver/
│   │   ├── silver_load.sql    # CREATE TABLE + load_silver proc
│   │   └── quality_checks_silver.sql
│   └── gold/
│       ├── gold_views.sql     # CREATE OR ALTER VIEW statements
│       └── quality_checks_gold.sql
├── tests/
│   ├── quality_checks_silver.sql
│   └── quality_checks_gold.sql
├── README.md                  # (this file)
├── LICENSE
└── .gitignore
```

## Setup and Execution

To set up and run the project:

1. **Install SQL Server:** Ensure a local or server instance of SQL Server is running (2016+).  
2. **Get the code:** Clone this repository.  
3. **Prepare data files:** Place the six source CSV files into the `datasets/source_crm/` and `datasets/source_erp/` folders as above.  
4. **Database creation:** In SSMS, create the `DataWarehouse` database and `bronze`, `silver`, `gold` schemas (or run provided SQL scripts).  
5. **Configure file paths:** In `scripts/bronze/bronze_load.sql`, update any file path or permissions as needed so SQL Server can access the CSV files.  
6. **Load Bronze:** Execute the `bronze.load_bronze` procedure (or run `bronze_load.sql`). This will truncate and load all Bronze tables.  
7. **Load Silver:** Execute the `silver.load_silver` procedure (or run `silver_load.sql`). This performs all cleaning/transformation steps into the Silver tables.  
8. **Validate Silver:** Run the quality-check queries in `quality_checks_silver.sql` to confirm the data is clean.  
9. **Create Gold Views:** Run the SQL in `gold/gold_views.sql` to create or replace the `dim_customers`, `dim_products`, and `fact_sales` views in the `gold` schema.  
10. **Validate Gold:** Run the `quality_checks_gold.sql` script to ensure referential integrity (no missing keys) in the Gold model.  
11. **Run Analytics Queries:** Use SSMS to query the Gold views and build reports (e.g. monthly sales, top products, country revenue).

**Warning:** Some scripts use `DROP TABLE`, `TRUNCATE`, or `DROP VIEW`. Ensure you have backups of any existing data if running on a production database. The procedures as written will overwrite data in the warehouse schemas.

## Design Decisions and Limitations

- **Full Refresh (not incremental):** The `bronze.load_bronze` and `silver.load_silver` procedures use full-refresh loads (`TRUNCATE` + `INSERT`). This simplifies development but is not optimized for very large or frequently-changing datasets.  
- **No History Tracking:** This warehouse captures only the current snapshot of data. Past versions (other than product version dates) are not stored. A slowly-changing-dimension strategy could be added in the future.  
- **Views with Dynamic Keys:** The Gold layer uses views and generates surrogate keys at query time using `ROW_NUMBER()`. This means the keys are not stable between loads, and the schema is not deployable as a standalone database without the source data. In production, you might use persisted dimension tables with fixed keys.  
- **Source Dependency:** The entire pipeline relies on the source CSV formats remaining consistent. Changes in field names or file layouts will require updates to the load procedures.  
- **Simplified Sales Rules:** The correction logic for sales and price assumes `sales = quantity * price`. This may not hold if there are discounts or returns.  
- **Data Quality Assumptions:** Checks assume dates outside reasonable ranges are errors. Business rules (e.g., valid birthdate range) are hard-coded and may need adjustment for real customers.  

These decisions were made for simplicity in a learning project. Production systems would include incremental loads, monitoring, error handling, and more robust data modeling.

## Future Improvements

Potential enhancements include:

- Implement **incremental loading** (load only new/changed records) for performance.  
- Persist dimension and fact tables (not just views) with **stable surrogate keys**.  
- Automate the ETL workflow with a scheduler or orchestration tool (SQL Agent, Airflow, etc.).  
- Expand data quality tests (e.g., null rate thresholds, anomaly detection).  
- Add more **analytic dimensions** (e.g., time dimension for date-based reporting).  
- Integrate additional data sources or a BI/reporting layer (Power BI, Tableau).  

## Documentation and Attribution

This README is based on an educational data warehouse project structure and inspired by existing examples (e.g., *DataWithBaraa/sql-data-warehouse-project* on GitHub). The repository includes additional documentation:

- `docs/data_catalog.md`: describes each data field and its source.  
- `docs/naming_conventions.md`: outlines database naming standards used.  

## License

This project’s code and documentation are released under the **MIT License**. See [LICENSE](LICENSE) for details.

## Author

**Yash Izate** – Data Engineer  
- GitHub: [github.com/YashIzate](https://github.com/YashIzate)  
- Email: yash.izate@example.com  

