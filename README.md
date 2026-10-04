# SQL Data Warehouse Project

A hands-on SQL Server data warehouse project that integrates CRM and ERP
sales data using a **Bronze--Silver--Gold Medallion Architecture**. The
project demonstrates batch ingestion from CSV files, T-SQL
transformations, data quality validation, dimensional modeling, and
analytical querying.

**Author:** Yash Izate\
**Primary tools:** Microsoft SQL Server, T-SQL, SQL Server Management
Studio (SSMS), Git, GitHub

## Project Overview

The goal of this project is to build a SQL Server data warehouse that
turns raw source files into clean, integrated, business-ready data for
analysis.

The source data comes from two operational systems:

-   **CRM (Customer Relationship Management):** customer, product, and
    sales transaction information.
-   **ERP (Enterprise Resource Planning):** customer birthdate and
    location attributes, plus product category information.

The data is loaded into a Bronze layer, transformed and validated in a
Silver layer, and presented through Gold views designed for analytical
queries.

### Project objectives

-   Ingest six source CSV files into SQL Server.
-   Preserve raw source data in the Bronze layer.
-   Clean, standardize, and validate data in the Silver layer.
-   Integrate CRM and ERP attributes.
-   Create customer and product dimensions and a sales fact view in the
    Gold layer.
-   Run data quality checks and analytical SQL queries.
-   Document the architecture, data flow, and execution process.

## Objectives and Key Features

-   **Layered architecture:** Bronze, Silver, and Gold schemas.
-   **Stored-procedure ETL:** repeatable loading routines for Bronze and
    Silver.
-   **Data cleansing:** text trimming, standardization, duplicate
    handling, and date validation.
-   **Business-rule transformations:** product key derivation and
    sales/price correction logic.
-   **Data integration:** CRM customer and product records enriched with
    ERP attributes.
-   **Dimensional modeling:** Gold customer and product dimensions
    connected to a sales fact view.
-   **Quality checks:** SQL tests for invalid values, duplicates, and
    fact-to-dimension relationships.
-   **Analytics-ready outputs:** views that support sales, product,
    customer, and geographic analysis.

------------------------------------------------------------------------

## Architecture

The warehouse follows a Medallion Architecture, with each layer serving
a distinct purpose.

<img width="1086" height="559" alt="data_architecture" src="https://github.com/user-attachments/assets/bb50747f-9529-40f8-8f50-1c1498fff05e" />

 
### Architecture summary

  -----------------------------------------------------------------------
  Layer             Main object type  Purpose           Loading approach
  ----------------- ----------------- ----------------- -----------------
  Bronze            Tables            Preserve source   Full refresh
                                      data with minimal using truncate
                                      change            and insert

  Silver            Tables            Clean,            Full refresh
                                      standardize,      using truncate
                                      validate, and     and insert
                                      transform data    

  Gold              Views             Present           Views query the
                                      integrated,       Silver layer
                                      business-ready    
                                      analytical data   
  -----------------------------------------------------------------------

## Source Systems and Data Integration

The project uses six CSV files from CRM and ERP source systems.

  -------------------------------------------------------------------------------
  Source system     CSV file              Entity                Purpose
  ----------------- --------------------- --------------------- -----------------
  CRM               `cust_info.csv`       `crm_cust_info`       Customer
                                                                attributes

  CRM               `prd_info.csv`        `crm_prd_info`        Product
                                                                attributes and
                                                                product history

  CRM               `sales_details.csv`   `crm_sales_details`   Sales transaction
                                                                records

  ERP               `CUST_AZ12.csv`       `erp_cust_az12`       Customer
                                                                birthdate and
                                                                gender attributes

  ERP               `LOC_A101.csv`        `erp_loc_a101`        Customer location
                                                                and country

  ERP               `PX_CAT_G1V2.csv`     `erp_px_cat_g1v2`     Product category
                                                                information
  -------------------------------------------------------------------------------
<img width="759" height="370" alt="data_integration" src="https://github.com/user-attachments/assets/4515fded-dd26-4773-906b-5c41c95c6437" />


CRM supplies the primary customer, product, and sales records. ERP files
provide additional customer and product attributes. These sources are
cleaned in Silver and combined in the Gold views using business keys.

## Data Flow and Lineage

The data moves through the warehouse in a controlled sequence:

1.  CRM and ERP CSV files are loaded into Bronze tables.
2.  Silver stored-procedure transformations clean and standardize the
    raw data.
3.  Gold views combine the relevant Silver tables into customer,
    product, and sales analytical objects.
4.  Quality-check scripts validate selected data rules and
    relationships.
5.  Analytical queries use the Gold views.

<img width="874" height="531" alt="data_flow" src="https://github.com/user-attachments/assets/fa75cb50-09c1-4ebd-a1ac-978d01468ab7" />

## Medallion Architecture

### 1. Bronze Layer --- Raw Data

**Purpose:** retain a source-oriented copy of the data for traceability
and debugging.

Implementation: - Six Bronze tables correspond to the CRM and ERP CSV
files. - Data is loaded using SQL Server `BULK INSERT`. - The
`bronze.load_bronze` stored procedure orchestrates the file loads. - The
load strategy is a full refresh using `TRUNCATE` and `INSERT`. -
Business transformations are intentionally kept out of this layer.

### 2. Silver Layer --- Cleansed and Standardized Data

**Purpose:** make source data more consistent and reliable for
integration and analysis.

Implementation: - Six Silver tables mirror the source entities. - The
`silver.load_silver` stored procedure orchestrates the
transformations. - Text fields are trimmed and categorical values are
standardized. - Duplicate customer records are handled using a
row-numbering rule based on customer ID and creation date. - Product
category and product keys are derived from source product keys. -
Product validity end dates are calculated using `LEAD()`. - Sales date
fields are converted to date values, with invalid or placeholder values
handled as null. - Project-specific rules correct inconsistent sales and
price values. - ERP customer identifiers, gender, birthdates, and
country values are standardized.

### 3. Gold Layer --- Business-Ready Data

**Purpose:** provide analytical objects with integrated dimensions and
sales facts.

The Gold layer contains three views:

  -----------------------------------------------------------------------
  Gold object             Role                    Description
  ----------------------- ----------------------- -----------------------
  `gold.dim_customers`    Dimension               Customer details
                                                  enriched with ERP
                                                  birthdate, gender, and
                                                  country information
                                                  where available

  `gold.dim_products`     Dimension               Current product details
                                                  enriched with ERP
                                                  category attributes

  `gold.fact_sales`       Fact                    Sales transactions
                                                  linked to customer and
                                                  product dimension keys
  -----------------------------------------------------------------------

The Gold layer follows a **star-schema-style design**. The fact view
connects to the customer and product dimension views through generated
keys.

## Gold Data Model

<img width="1365" height="509" alt="data_model" src="https://github.com/user-attachments/assets/fa16b684-af78-4d58-814c-94ef6f2188cf" />

### `gold.dim_customers`

Combines CRM customer information with ERP customer and location
attributes. It includes customer identifiers, names, country, marital
status, gender, and birthdate.

### `gold.dim_products`

Combines CRM product attributes with ERP product category data. The view
filters to current product records according to the project's product
validity logic.

### `gold.fact_sales`

Exposes sales transaction attributes such as order number, product key,
customer key, order/shipping/due dates, sales amount, quantity, and
price.

**Implementation note:** Gold objects are views. The `customer_key` and
`product_key` surrogate keys are generated with `ROW_NUMBER()` at query
time; they are not persistent keys stored in dimension tables.

## ETL Workflow

<img width="1839" height="1635" alt="ETL" src="https://github.com/user-attachments/assets/27cf85a0-3fe9-4015-af6a-e83b84cf7356" />

### Execution sequence

1.  Create the database, schemas, and layer tables.
2.  Execute `bronze.load_bronze` to ingest all six CSV files.
3.  Validate Bronze table loads and row counts.
4.  Execute `silver.load_silver` to refresh and transform the Silver
    tables.
5.  Run Silver quality-check queries.
6.  Create or update the Gold views.
7.  Run Gold quality and relationship checks.
8.  Execute analytical queries against the Gold views.

### Transformation examples

-   `TRIM()` for removing unwanted leading and trailing spaces.
-   `CASE` expressions for standardizing categorical values.
-   `ROW_NUMBER()` for selecting a preferred customer record and
    generating Gold view keys.
-   `LEAD()` for deriving product validity end dates.
-   Date conversion logic for sales dates and customer birthdates.
-   Joins between CRM and ERP records using cleaned business keys.
-   Sales and price consistency rules based on quantity and sales
    amount.

## Data Quality and Validation

The project includes Silver and Gold SQL quality-check scripts.

### Silver checks

The checks cover: - Duplicate and null customer identifiers. - Unwanted
spaces in customer and product text fields. - Unexpected marital status,
gender, product line, country, and maintenance values. - Null or
negative product costs. - Invalid product date ranges. - Invalid sales
dates and date ordering. - Sales amount, quantity, and price
consistency. - Customer birthdates outside expected bounds.

### Gold checks

The checks cover: - Duplicate generated customer and product keys. -
Missing customer or product dimension matches from the sales fact view.

During development, the tested error-condition queries returned no rows.
This indicates that the specific conditions tested were not detected in
the dataset at that time. It is not a guarantee that all possible data
quality issues have been eliminated.

## Results

The following Silver row counts were recorded during development:

  Silver table                   Recorded rows
  ---------------------------- ---------------
  `silver.crm_cust_info`                18,484
  `silver.crm_prd_info`                    397
  `silver.crm_sales_details`            60,398
  `silver.erp_loc_a101`                 18,484
  `silver.erp_cust_az12`                18,483
  `silver.erp_px_cat_g1v2`                  37

These counts describe the dataset at the time of validation. They may
change if the source CSV files change or the loading logic is modified.

The Gold views returned data during validation, and the selected
dimension-key and fact-to-dimension quality checks returned no error
rows. For a final reconciliation, compare Silver sales row counts and
total sales against the corresponding Gold fact view values; do not
assume the totals match unless the actual values have been checked.

## Analytics Use Cases

The Gold views can be used for analytical questions such as:

-   How do sales and order volumes change month by month?
-   Which products generate the highest revenue?
-   Which products sell the most units?
-   Which countries contribute the most sales revenue?
-   How many distinct orders and customers are represented in the data?

These are supported analysis use cases, not claims about specific
business findings. Actual conclusions should be drawn from the query
results.

## Repository Structure

The following is a representative structure. Update it to match the
actual files in your repository.

``` text
sql-data-warehouse-project/
├── datasets/
│   ├── source_crm/
│   └── source_erp/
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
│   ├── silver/
│   └── gold/
├── tests/
│   ├── quality_checks_silver.sql
│   └── quality_checks_gold.sql
├── README.md
├── LICENSE
└── .gitignore
```

Only retain files and folders in this tree that actually exist in the
repository.

## Prerequisites

-   Microsoft SQL Server.
-   SQL Server Management Studio (SSMS).
-   Git, if cloning the repository.
-   Access to the six CRM and ERP CSV files.
-   Read access for the SQL Server service account to the source CSV
    file paths.

## How to Run

1.  Clone or download the repository.
2.  Place the source CSV files in the expected CRM and ERP directories.
3.  Open the SQL scripts in SSMS.
4.  Review the database, schema, and table creation scripts and execute
    them in dependency order.
5.  Update the file paths in the Bronze loading procedure to match your
    environment.
6.  Confirm that the SQL Server service account can access the CSV
    files.
7.  Execute `bronze.load_bronze`.
8.  Verify that the Bronze tables contain data.
9.  Execute `silver.load_silver`.
10. Run the Silver quality-check script and review any returned rows.
11. Create or update the Gold views.
12. Run the Gold quality-check script.
13. Run analytical queries against `gold.dim_customers`,
    `gold.dim_products`, and `gold.fact_sales`.

**Important:** review scripts before running them. `DROP` and `TRUNCATE`
statements can remove existing objects or data. The project uses full
refreshes, so running the load procedures replaces the corresponding
layer data rather than appending historical records.

## Design Decisions and Limitations

-   **Full refresh:** Bronze and Silver use full-refresh loading rather
    than incremental ingestion.
-   **No historical tracking:** the project is designed around the
    latest available dataset and does not implement historical change
    tracking.
-   **Gold views:** Gold dimensions and facts are views rather than
    physically materialized tables.
-   **Dynamic surrogate keys:** `ROW_NUMBER()` keys are calculated when
    the views are queried and may change if source data or ordering
    changes.
-   **Local file paths:** `BULK INSERT` paths must be adapted to the
    local SQL Server environment, and the SQL Server service account
    must have file access.
-   **Validation scope:** quality checks cover selected rules and should
    not be treated as exhaustive production-grade data observability.

## Future Improvements

Potential next steps include:

-   Persist surrogate keys in physical dimension tables.
-   Implement incremental loading where source data and requirements
    support it.
-   Add automated reconciliation tests for row counts and financial
    totals.
-   Expand data quality checks and centralize error reporting.
-   Add orchestration, logging, retry handling, and monitoring.
-   Create a Power BI report or dashboard on top of the Gold views.
-   Add a data catalog documenting column definitions, business rules,
    and source-to-target mappings.
-   Add deployment scripts and environment-specific configuration.

These are future opportunities, not features claimed as implemented.

## Attribution and Licensing

This project was developed as a learning and portfolio project inspired
by the SQL Data Warehouse Project by **Data With Baraa**. If you reuse
code or other project materials, retain applicable attribution,
copyright notices, and license terms.

The license for the project code does not automatically establish the
license for separately sourced datasets, images, or other third-party
assets. Verify their terms independently. If this repository includes an
MIT `LICENSE` file, that file defines the license applied to the
materials it covers.

## Author

**Yash Izate**

Interested in SQL Server, T-SQL, data engineering, ETL pipelines, data
quality, and dimensional modeling.

------------------------------------------------------------------------

*This README documents the implementation and validation details known
for this project. Adjust file paths, repository structure, and recorded
results if the local project differs from the details documented here.*
