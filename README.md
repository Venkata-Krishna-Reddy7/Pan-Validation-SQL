# 🔐 PAN Data Quality & Validation Pipeline

### PostgreSQL • SQL • PL/pgSQL • Data Quality • Data Validation

> A structured PostgreSQL data-quality pipeline designed to **clean, validate, categorize, and report PAN numbers** using SQL, regular expressions, and reusable PL/pgSQL functions.

---

## 📌 Project Overview

Data quality is critical when working with customer identifiers such as PAN numbers.

This project demonstrates how a raw PAN dataset can be processed through a structured validation pipeline to identify:

* Invalid PAN formats
* Missing and blank values
* Leading/trailing spaces
* Inconsistent letter casing
* Duplicate values
* Adjacent repeated characters
* Sequential characters
* Overall PAN validation status

The project is organized into independent SQL stages to simulate a **real-world data-quality workflow**.

---

## 🏗️ Data Validation Pipeline

```text
                    ┌─────────────────────┐
                    │     Raw PAN Data    │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Data Cleaning     │
                    │                     │
                    │ • TRIM              │
                    │ • UPPER             │
                    │ • NULL checks       │
                    │ • Duplicate checks  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Validation Functions│
                    │                     │
                    │ • Adjacent chars    │
                    │ • Sequential chars  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Validation Rules    │
                    │                     │
                    │ • PAN regex format  │
                    │ • Character rules   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Validation View     │
                    │                     │
                    │ Pan_Categorization  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Quality Reports   │
                    │                     │
                    │ • Valid records     │
                    │ • Invalid records   │
                    │ • Invalid reasons   │
                    └─────────────────────┘
```

---

## 🛠️ Technology Stack

| Technology             | Usage                          |
| ---------------------- | ------------------------------ |
| 🐘 PostgreSQL          | Database platform              |
| 🧮 SQL                 | Data processing and validation |
| ⚙️ PL/pgSQL            | Reusable validation functions  |
| 🔎 Regular Expressions | PAN format validation          |
| 📊 SQL Views           | Validation and reporting layer |
| 🧹 Data Quality        | Cleaning and validation rules  |

---

## 🔍 PAN Validation Logic

A PAN is expected to follow this structure:

```text
AAAAA9999A
```

Where:

```text
AAAAA → 5 uppercase letters
9999  → 4 digits
A     → 1 uppercase letter
```

The project validates this pattern using PostgreSQL regular expressions:

```sql
^[A-Z]{5}[0-9]{4}[A-Z]$
```

---

## 🧹 Data Cleaning

Before validation, the pipeline standardizes the incoming data.

### Cleaning operations

```text
Raw PAN
   │
   ├── Remove leading/trailing spaces
   │
   ├── Convert characters to uppercase
   │
   ├── Identify NULL values
   │
   ├── Identify blank values
   │
   └── Check duplicate PAN values
```

Example:

```text
Input:
  abcde1234f

After cleaning:
ABCDE1234F
```

---

## ⚙️ Custom PL/pgSQL Functions

The project contains reusable PostgreSQL functions for additional validation.

### 1. Adjacent Character Validation

```sql
Fn_Adjacent_Characters()
```

Identifies consecutive repeated characters.

Example:

```text
AABCD → TRUE
ABCDE → FALSE
```

---

### 2. Sequential Character Validation

```sql
Fn_Sequential_Characters()
```

Identifies alphabetical sequences.

Example:

```text
ABCDE → TRUE
ABCXE → FALSE
```

These functions make the validation logic reusable instead of repeating complex SQL expressions throughout the project.

---

## 📊 Validation Status

Each cleaned PAN is categorized into a final validation status.

### Valid

```text
VALID_PAN
```

### Invalid

```text
INVALID - Bad Format

INVALID - Adjacent Repeated Characters

INVALID - Sequential Letters In Prefix
```

This makes the validation output easier to consume for downstream reporting and data-quality processes.

---

## 📁 Project Structure

```text
Pan-Validation-SQL/
│
├── 📄 README.md
│
└── 📁 SQL/
    │
    ├── 01_create_tables.sql
    ├── 02_insert_sample_data.sql
    ├── 03_data_cleaning.sql
    ├── 04_validation_functions.sql
    ├── 05_validation_rules.sql
    ├── 06_validation_view.sql
    └── 07_validation_report.sql
```

### SQL Processing Flow

| File                          | Purpose                                      |
| ----------------------------- | -------------------------------------------- |
| `01_create_tables.sql`        | Creates the source PAN table                 |
| `02_insert_sample_data.sql`   | Loads raw PAN records                        |
| `03_data_cleaning.sql`        | Performs data-quality checks and cleaning    |
| `04_validation_functions.sql` | Creates reusable PL/pgSQL functions          |
| `05_validation_rules.sql`     | Applies PAN validation rules                 |
| `06_validation_view.sql`      | Creates the final validation view            |
| `07_validation_report.sql`    | Generates summary and invalid-reason reports |

---

## ▶️ How to Run

### Prerequisites

Install:

* PostgreSQL
* pgAdmin 4 or another PostgreSQL client

---

### Step 1 — Create the Table

Run:

```text
SQL/01_create_tables.sql
```

---

### Step 2 — Load Sample Data

Run:

```text
SQL/02_insert_sample_data.sql
```

---

### Step 3 — Perform Data Cleaning

Run:

```text
SQL/03_data_cleaning.sql
```

---

### Step 4 — Create Validation Functions

Run:

```text
SQL/04_validation_functions.sql
```

---

### Step 5 — Apply Validation Rules

Run:

```text
SQL/05_validation_rules.sql
```

---

### Step 6 — Create Validation View

Run:

```text
SQL/06_validation_view.sql
```

This creates:

```text
Pan_Categorization
```

---

### Step 7 — Generate Reports

Run:

```text
SQL/07_validation_report.sql
```

---

## 📈 Reporting

The final reporting layer provides:

### Overall Validation Summary

```text
Total PAN Numbers
        │
        ├── Valid PAN Numbers
        │
        ├── Invalid PAN Numbers
        │
        └── Missing PAN Numbers
```

### Invalid Reason Breakdown

The project also groups invalid records by validation reason.

Example:

```text
INVALID - Bad Format
INVALID - Adjacent Repeated Characters
INVALID - Sequential Letters In Prefix
```

---

## 💡 Data Engineering Concepts Demonstrated

This project demonstrates practical concepts used in Data Engineering and Data Quality workflows:

* Data ingestion
* Data cleaning
* Data standardization
* Data validation
* Business-rule implementation
* SQL transformations
* PostgreSQL
* PL/pgSQL
* Regular expressions
* Reusable database functions
* SQL Views
* Data-quality reporting
* Validation categorization

---

## 🚀 Future Enhancements

The current PostgreSQL pipeline can be extended into a larger end-to-end Data Engineering solution.

```text
CSV / API
   │
   ▼
Azure Data Factory
   │
   ▼
Azure Data Lake Storage
   │
   ▼
PostgreSQL
   │
   ▼
Data Quality Validation
   │
   ▼
Validated Data
   │
   ▼
Power BI
```

Potential enhancements:

* Automated CSV/API ingestion
* Incremental data loading
* Data-quality scorecards
* Error/rejection tables
* Audit logging
* Duplicate detection
* Automated scheduling
* Python orchestration
* Azure Data Factory integration
* Azure Data Lake Storage integration
* Power BI data-quality dashboard

---

## 🎯 Key Outcome

The project demonstrates how raw identifier data can be transformed into a **clean, validated, categorized, and reportable dataset** using PostgreSQL.

The modular SQL structure also makes each stage independently maintainable and easier to extend.

---

## 👨‍💻 Author

### K. Venkata Krishna Reddy

**Data Engineer**

`SQL` • `Python` • `PySpark` • `Azure` • `Data Engineering`

---

⭐ **If you found this project useful, feel free to explore the SQL implementation.**
