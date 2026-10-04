# SQL Data Warehouse & Analytics Project

**Author:** Yash Izate  
**Status:** In development  
**Primary technology:** Microsoft SQL Server and T-SQL

## Overview

This project focuses on designing and implementing a SQL Server data warehouse that consolidates sales-related data from ERP and CRM source systems. The goal is to turn raw CSV data into a consistent, documented analytical model that can support business reporting and data analysis.

The project follows a layered data architecture and covers data ingestion, transformation, data quality, dimensional modeling, and SQL-based analytics. The implementation will be developed and validated step by step, with design decisions and lessons documented along the way.

## Project Goals

- Build a SQL Server data warehouse using a Bronze, Silver, and Gold architecture.
- Ingest source data supplied as ERP and CRM CSV files.
- Identify and address data quality issues before analytical use.
- Integrate related source data into a consistent model.
- Design fact and dimension tables for analytical queries.
- Analyze customer behavior, product performance, and sales trends.
- Document the data model, transformations, and project decisions.

## Data Architecture

The warehouse is organized into three logical layers.
<img width="874" height="531" alt="image" src="https://github.com/user-attachments/assets/ac1a4fc8-d55a-488f-96e9-20549ecc4671" />

<img width="1057" height="767" alt="image" src="https://github.com/user-attachments/assets/3dbd803e-d589-45b4-873c-98ed24747cf2" />

### Bronze — Raw Data

The Bronze layer stores data ingested from the source CSV files with minimal transformation. Keeping the raw data available makes it easier to inspect source values and investigate issues found in later stages.

### Silver — Cleaned and Integrated Data

The Silver layer prepares data for analysis. This stage is intended to address issues such as inconsistent formats, unsuitable data types, duplicate records, and other data quality problems identified during source inspection. Related ERP and CRM data is integrated where appropriate.

### Gold — Analytical Data Model

The Gold layer contains business-ready data organized for reporting and analytics. The planned model uses fact and dimension tables arranged as a star schema, supporting queries about sales, customers, and products.

> Architecture diagrams and implementation details will be added as the project develops.

## Project Requirements

### Data Engineering: Building the Warehouse

**Objective:** Develop a SQL Server data warehouse that consolidates sales data for analytical reporting and informed decision-making.

**Requirements:**

- **Source data:** Import ERP and CRM data supplied as CSV files.
- **Data quality:** Identify, cleanse, and resolve relevant data quality issues before analysis.
- **Integration:** Combine relevant source data into a unified, user-friendly analytical model.
- **Scope:** Focus on the latest available dataset. Historical tracking of changes is not part of the initial scope.
- **Documentation:** Document the data model so that its structure and meaning can be understood by both business stakeholders and analytics users.

### Analytics and Reporting

SQL-based analysis will focus on:

- **Customer behavior**
- **Product performance**
- **Sales trends**

The specific metrics and questions will depend on the fields available in the source datasets. Analytical outputs will be developed after the underlying data has been inspected, cleaned, and modeled.

## Technology and Tools

| Tool or technology | Intended use |
|---|---|
| Microsoft SQL Server | Database and data warehouse platform |
| SQL Server Management Studio (SSMS) | Database development and administration |
| T-SQL | Data loading, transformations, validation, and analytics |
| Git and GitHub | Version control and project history |
| Draw.io | Architecture, data flow, and data model diagrams |

## Repository Structure

The repository is expected to follow this structure as implementation progresses:

```text
sql-data-warehouse-project/
│
├── datasets/                       # Source CSV files (ERP and CRM)
│
├── docs/                           # Project documentation and diagrams
│   ├── data_catalog.md             # Dataset and column descriptions
│   ├── data_architecture.drawio    # Warehouse architecture
│   ├── data_flow.drawio            # Data movement between stages
│   ├── data_models.drawio          # Analytical data model / star schema
│   ├── etl.drawio                  # ETL process overview
│   └── naming-conventions.md       # Naming standards
│
├── scripts/
│   ├── bronze/                     # Raw data ingestion
│   ├── silver/                     # Cleaning and transformation
│   └── gold/                       # Analytical tables and model
│
├── tests/                          # Data quality and validation scripts
│
├── README.md
├── .gitignore
└── LICENSE                         # Add after selecting the project license
```

This is a planned structure. Files and folders will be added when they are needed; the tree should be updated to reflect the actual repository rather than imply that unfinished components already exist.

## Development Plan

The project will be built in stages:

- [ ] **1. Repository and source analysis** — set up the project, inspect the CSV files, and document their structures.
- [ ] **2. Database setup** — create the database and schemas for the warehouse layers.
- [ ] **3. Bronze layer** — load the raw ERP and CRM data into SQL Server.
- [ ] **4. Silver layer** — clean, standardize, validate, and integrate the source data.
- [ ] **5. Gold layer** — design and build fact and dimension tables.
- [ ] **6. Analytics** — develop SQL queries for customer behavior, product performance, and sales trends.
- [ ] **7. Validation and documentation** — verify results, document assumptions, and update diagrams and data definitions.

Checklist items will be marked complete only after the relevant implementation has been tested.

## Engineering Approach

The project emphasizes understanding and validating each stage rather than only producing a final set of tables.

- **Traceability:** Understand the source and transformation path of the data.
- **Data quality:** Validate assumptions and investigate unexpected values.
- **Clear modeling:** Define the purpose and relationships of fact and dimension tables.
- **Reproducibility:** Keep scripts organized and document the execution sequence.
- **Incremental development:** Build, test, and review one layer at a time.
- **Documentation:** Record important assumptions, rules, and design decisions.

## Current Status

The repository is being set up. The source datasets, warehouse scripts, diagrams, and analytical queries will be added and documented as each stage is implemented.

## Learning Reference and Attribution

This project is informed by publicly available data warehousing learning resources, including the [SQL Data Warehouse Project by Data With Baraa](https://github.com/DataWithBaraa/sql-data-warehouse-project).

The project will be implemented and documented independently. Any code, datasets, diagrams, or other materials reused or adapted will be handled according to their applicable license terms and attribution requirements.

## About Me

I'm Yash Izate, and this repository is part of my practical work in SQL Server, data engineering, and analytics. My aim is to strengthen my understanding of data warehousing by building a working project, validating its results, and documenting the reasoning behind the implementation.
