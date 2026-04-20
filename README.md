# 🏪 Superstore Sales Performance Analysis — SQL Project

![SQL](https://img.shields.io/badge/SQL-Microsoft%20SQL%20Server-blue?logo=microsoftsqlserver)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![Dataset](https://img.shields.io/badge/Records-896%20Stores-orange)
![Domain](https://img.shields.io/badge/Domain-Retail%20Analytics-purple)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Dataset Description](#dataset-description)
- [Tools & Environment](#tools--environment)
- [Project Structure](#project-structure)
- [Methodology](#methodology)
- [Key Findings](#key-findings)
- [Recommendations](#recommendations)
- [How to Run](#how-to-run)
- [Author](#author)

---

## 📌 Project Overview

This project is a full end-to-end SQL analysis of a retail superstore chain covering **896 store locations**. It demonstrates the complete data analytics workflow inside Microsoft SQL Server — from database creation and raw data ingestion, through data cleaning and validation, to exploratory analysis, advanced querying, and business intelligence reporting.

The goal is to understand **what separates high-performing stores from low-performing ones**, identify operational inefficiencies, and produce actionable recommendations for store management and regional operations teams.

---

## 📂 Dataset Description

| Column | Type | Description |
|---|---|---|
| `Store_ID` | INT | Unique identifier for each store |
| `Store_Area` | INT | Physical size of the store in square feet |
| `Items_Available` | INT | Number of unique product SKUs stocked |
| `Daily_Customer_Count` | INT | Average number of customers visiting per day |
| `Store_Sales` | INT | Total sales revenue generated |
| `Performance` | VARCHAR | Performance tier label: `High`, `Medium`, or `Low` |

**Dataset Summary:**

| Metric | Value |
|---|---|
| Total Stores | 896 |
| Total Revenue (all stores) | 53,121,940 |
| Average Store Sales | 59,354 |
| Minimum Store Sales | 14,920 |
| Maximum Store Sales | 116,320 |
| Missing Values Found | 1 (Store_Sales) — cleaned during data prep |

---

## 🛠️ Tools & Environment

- **Database:** Microsoft SQL Server
- **IDE:** SQL Server Management Studio (SSMS)
- **Language:** T-SQL (Transact-SQL)
- **Data Source:** CSV flat file imported via SSMS Import Wizard

---

## 📁 Project Structure

```
superstore-sql-analysis/
│
├── SQL_Project_Superstore_Sales_Analysis.sql   ← Main query file
├── Superstore_Sales_Performance_Analysis.csv   ← Raw dataset
└── README.md                                   ← This file
```

---

## 🔬 Methodology

The project is organised into **8 sections**, each building on the previous:

### 1. Database & Table Setup
Created the `SQL_project` database and defined the `superstore_sales` table with appropriate data types (`INT`, `VARCHAR`), column constraints (`NOT NULL`), and a `PRIMARY KEY` on `Store_ID`.

### 2. Data Ingestion
Loaded 896 rows from the CSV source using the SSMS Import Wizard and supplemented the setup with manual `INSERT` statements as demonstration. Both `LOAD DATA` (bulk) and row-by-row `INSERT` patterns are documented in the script.

### 3. Data Cleaning & Validation
- Checked for **duplicate Store IDs** — none found
- Checked for **NULL values** across all columns — 1 NULL found in `Store_Sales`, resolved
- Validated **performance labels** — confirmed only `High`, `Medium`, `Low` exist
- Detected **impossible values** (negatives, zeros) — none found
- **Standardised** the `Performance` column using `TRIM` + `UPPER` + `SUBSTRING` to enforce consistent capitalisation

> ⚠️ **Cross-platform note:** The `SUBSTRING` function in SQL Server requires 3 arguments — `SUBSTRING(string, start, length)` — unlike MySQL which accepts 2. `LEN()` was used as the length argument to capture the remainder of the string from a given position.

### 4. Exploratory Data Analysis (EDA)
- Global descriptive statistics (min, max, mean, standard deviation)
- Store count and percentage share by performance tier
- Average KPIs (sales, area, items, customers) broken down by tier
- Sales distribution across defined revenue buckets

### 5. Business Analysis
- **Sales per square foot** — revenue efficiency relative to store size
- **Sales per daily customer** — customer monetisation rate
- **Sales per available item** — product range utilisation
- Top 10 and Bottom 10 stores by total sales
- High performers with below-average area (efficient small stores)
- Low performers with above-average area (underutilised large stores)
- Sales behaviour segmented by customer traffic bands

### 6. Advanced SQL
- **Window Functions:** `RANK()`, `DENSE_RANK()`, `PERCENT_RANK()`, running totals with `SUM() OVER`, 3-period moving average with `AVG() OVER (ROWS BETWEEN ...)`, z-score calculation
- **CTEs:** Single-level and chained CTEs for tier comparison and store classification
- **Subqueries:** Cross-KPI filtering to identify stores outperforming global averages on all dimensions simultaneously

### 7. Views & Stored Procedures
- `vw_store_profile` — enriched per-store metrics view
- `vw_tier_summary` — aggregated performance tier summary view
- `sp_get_stores_by_tier` — parameterised procedure to retrieve stores by tier
- `sp_top_n_stores` — flexible top-N ranking procedure

### 8. Summary Report
A single `UNION ALL` query that generates a formatted metric sheet combining overall and tier-level statistics — suitable for stakeholder exports or screenshots.

---

## 📊 Key Findings

### Finding 1 — Performance Tier Distribution is Heavily Skewed

| Tier | Store Count | % of Total |
|---|---|---|
| High | 605 | 67.5% |
| Medium | 274 | 30.6% |
| Low | 17 | 1.9% |

The vast majority of stores (67.5%) are classified as High performers. Only 17 stores fall into the Low tier — a small but strategically critical group.

---

### Finding 2 — The Revenue Gap Between Tiers is Dramatic

| Performance Tier | Avg Store Sales | Avg Sales / Sqft |
|---|---|---|
| High | 68,519 | 46.94 |
| Medium | 41,469 | 29.39 |
| Low | 21,987 | 16.05 |

High-performing stores generate **3.1× more revenue** than Low-performing stores on average. Even on a per-square-foot basis, High stores produce nearly **3× the efficiency** of Low stores — meaning the gap is not simply a matter of store size.

---

### Finding 3 — Store Size, Stock, and Foot Traffic Are Weak Sales Predictors

| Variable | Correlation with Sales |
|---|---|
| Store Area | 0.097 |
| Items Available | 0.099 |
| Daily Customer Count | 0.008 |

All three variables show **near-zero correlation** with total sales revenue. This is the most important insight in the dataset: **bigger stores, more products, and higher foot traffic do not reliably drive higher sales.** Operational factors — management quality, staff effectiveness, product placement, local pricing — are the likely drivers of performance differences.

---

### Finding 4 — Low-Performing Stores Have the Highest Customer Traffic

| Tier | Avg Daily Customers |
|---|---|
| High | 794 |
| Medium | 760 |
| **Low** | **955** |

Counterintuitively, Low-performing stores attract **more daily customers** than both High and Medium stores. This is a significant red flag — these locations have the footfall but are failing to convert it into revenue. The problem is internal, not a market access issue.

---

### Finding 5 — The Real Problem is Conversion, Not Traffic

Because Low stores see ~955 customers/day but average only 21,987 in total sales, revenue per customer visit is very low. High stores convert fewer visitors into substantially more revenue per head. The bottleneck for Low stores is **basket size and conversion rate**, not store awareness or customer reach.

---

## ✅ Recommendations

### 1. Conduct Urgent Store Audits on the 17 Low-Performing Locations
These stores already have customers walking through the door — the challenge is internal. A structured audit covering staff-to-customer ratios, product availability, checkout experience, pricing competitiveness, and store layout is the logical next step.

### 2. Replicate the Practices of Small High-Performing Stores
Several High-tier stores operate below average square footage yet outperform larger stores on revenue per square foot. Their operational playbook — assortment selection, upsell techniques, staff deployment — should be documented and used as a training template for Medium-tier stores targeting promotion.

### 3. Launch a Conversion Improvement Programme for Low Stores
Since traffic is not the issue, the investment should focus on in-store conversion: basket-size promotions, loyalty incentives, staff sales training, and strategic product placement near high-traffic zones like entrances and checkouts.

### 4. Pause Physical Expansion Plans Until Operational Issues Are Resolved
The near-zero correlation between store area and sales means spending on bigger stores will not automatically improve revenue. Capital should be redirected toward operations, people, and technology rather than square footage.

### 5. Implement Quarterly Performance Tracking Using SQL Views
The `vw_store_profile` and `vw_tier_summary` views built in this project provide a ready-made reporting foundation. Running these quarterly will surface tier migration patterns — stores climbing from Medium to High (replicate their changes) or slipping from High to Medium (early intervention triggers).

---

## ▶️ How to Run

1. Open **SQL Server Management Studio (SSMS)**
2. Connect to your SQL Server instance
3. Open `SQL_Project_Superstore_Sales_Analysis.sql`
4. Run **Section 1** to create the database and table
5. Run **Section 2** — either use `LOAD DATA` (update the file path) or use the SSMS Import Wizard with the provided CSV
6. Run Sections 3–8 sequentially
7. Views and stored procedures are created automatically and available for reuse

> **Tested on:** Microsoft SQL Server 2019 | SSMS 19

---

## 👤 Author

**[Your Name]**  
Data Analyst | SQL · Python · Power BI

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/yourusername)

---

*This project was built as part of a data analytics portfolio to demonstrate end-to-end SQL proficiency: data ingestion, cleaning, EDA, business analysis, window functions, CTEs, subqueries, views, and stored procedures.*
