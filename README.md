
# SQL Data Warehouse & Analytics Project

A SQL Server data warehouse project that integrates CRM and ERP data using a Bronze, Silver, and Gold architecture. The project transforms raw CSV files into clean, structured, and analytics-ready data for business analysis.

**Author:** Yash Izate  
**Technology:** Microsoft SQL Server, T-SQL, SSMS, Git, GitHub  
**Status:** Core implementation completed

---

## 1. Project Overview

This project focuses on building a data warehouse that consolidates sales-related data from CRM (Customer Relationship Management) and ERP (Enterprise Resource Planning) systems.

The warehouse follows the Medallion Architecture to organize data ingestion, transformation, integration, and analytical modeling.

### Objectives

- Build a structured SQL Server data warehouse.
- Ingest data from CRM and ERP CSV files.
- Clean and standardize data using T-SQL.
- Integrate customer, product, and sales information.
- Create an analytical data model for reporting and analysis.
- Perform data quality checks to validate the transformed data.

---

## 2. Data Architecture

The project uses three layers to process data from raw source files to business-ready analytical views.

<!-- Add the High-Level Architecture diagram here -->
<img width="1086" height="559" alt="data_architecture" src="https://github.com/user-attachments/assets/97ccfa59-dfcd-4373-9fe9-526299b0ffa7" />


| Layer | Description |
|---|---|
| **Bronze** | Stores raw data loaded from source CSV files. |
| **Silver** | Cleans, standardizes, and transforms the data. |
| **Gold** | Provides business-ready analytical views. |

---

## 3. Data Sources

The project integrates six CSV files from two source systems.

| Source System | Data |
|---|---|
| CRM | Customer information |
| CRM | Product information |
| CRM | Sales transactions |
| ERP | Customer birthdate and gender |
| ERP | Customer location and country |
| ERP | Product category information |

<!-- Add the Data Integration diagram here -->
<img width="759" height="370" alt="data_integration" src="https://github.com/user-attachments/assets/05ccafca-397a-4e38-b481-41afba5573b5" />


---

## 4. ETL Process

The data flows through the warehouse in the following sequence:

1. **Extract and Load:** Import CRM and ERP CSV files into Bronze tables.
2. **Transform:** Clean, standardize, validate, and integrate data in Silver tables.
3. **Model:** Create Gold views for customer, product, and sales analysis.
4. **Validate:** Run SQL quality checks to identify selected data issues and verify relationships.
5. **Analyze:** Query the Gold views to explore sales trends and product performance.

Bronze and Silver use a full-refresh loading strategy implemented through stored procedures.

<!-- Add the Data Flow and Lineage diagram here -->
<img width="1839" height="1635" alt="ETL" src="https://github.com/user-attachments/assets/d092f633-3472-464a-9726-9a49be13048c" />


---

## 5. Gold Data Model

The Gold layer contains three analytical views designed in a star-schema-style structure.

| View | Description |
|---|---|
| `gold.dim_customers` | Customer attributes enriched with available ERP information. |
| `gold.dim_products` | Product details combined with product category information. |
| `gold.fact_sales` | Sales transactions connected to customer and product dimensions. |

<!-- Add the Gold Star Schema / Sales Data Mart diagram here -->
<img width="874" height="531" alt="data_flow" src="https://github.com/user-attachments/assets/bfcda005-f7a6-4cde-94e4-42a643229af3" />

These views support analytical queries without requiring users to work directly with the underlying source tables.

---

## 6. Data Quality and Validation

Data quality checks were implemented to validate the transformed data and analytical model.

Key checks include:

- Duplicate and null identifiers.
- Unwanted spaces and inconsistent categorical values.
- Invalid dates and product validity ranges.
- Sales, quantity, and price consistency.
- Duplicate generated dimension keys.
- Missing customer or product matches in sales records.

The tested error-condition queries returned no rows during the reported validation runs.

---

## 7. Implementation Results

The following row counts were recorded in the Silver layer during development.

| Table | Rows |
|---|---:|
| `silver.crm_cust_info` | 18,484 |
| `silver.crm_prd_info` | 397 |
| `silver.crm_sales_details` | 60,398 |
| `silver.erp_loc_a101` | 18,484 |
| `silver.erp_cust_az12` | 18,483 |
| `silver.erp_px_cat_g1v2` | 37 |

The Gold views returned data and the selected dimension-key and fact-to-dimension validation checks returned no error rows.

---

## 8. Analytics Use Cases

The warehouse supports SQL-based analysis of:

- Monthly sales trends.
- Top-performing products by revenue.
- Product quantities sold.
- Sales revenue by country.
- Customer and order analysis.

---

## 9. Technology Stack

- **Database:** Microsoft SQL Server
- **Query Language:** T-SQL
- **Development Environment:** SQL Server Management Studio (SSMS)
- **Version Control:** Git and GitHub
- **Documentation and Diagrams:** Markdown and Draw.io

---

## 10. Repository Structure

```text
sql-data-warehouse-project/
├── datasets/
│   ├── source_crm/
│   └── source_erp/
├── docs/
│   ├── ETL.png
│   ├── data_architecture.png.png
│   ├── data_flow.png
│   ├── data_integration.png
│   ├── data_model.png
│   ├── data_catalog.md
│   └── naming_conventions.md
├── scripts/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── tests/
├── README.md
├── .gitignore
└── LICENSE
```

*Update this structure if the actual repository differs.*

---

## 11. How to Run

1. Install Microsoft SQL Server and SSMS.
2. Clone or download the repository.
3. Place the source CSV files in the appropriate directories.
4. Update file paths in the Bronze loading procedure.
5. Execute the database, schema, and table creation scripts.
6. Run `bronze.load_bronze`.
7. Run `silver.load_silver`.
8. Create or update the Gold views.
9. Execute the data quality checks and analytical queries.

**Note:** Bronze and Silver use full refreshes. Review scripts containing `DROP` or `TRUNCATE` before execution, as they can remove existing objects or data.

---

## 12. Design Considerations

- The project focuses on the latest available dataset rather than historical change tracking.
- Bronze and Silver use full-refresh loading instead of incremental processing.
- Gold dimensions and facts are implemented as views.
- Surrogate keys generated using `ROW_NUMBER()` are calculated dynamically and are not persistent identifiers.

---

## About Me

**Yash Izate**

I am an aspiring data engineer interested in SQL Server, data warehousing, ETL pipelines, data quality, and analytical data modeling.

This project helped me apply SQL concepts to a practical data engineering workflow, from raw data ingestion and transformation to dimensional modeling and analytics.
