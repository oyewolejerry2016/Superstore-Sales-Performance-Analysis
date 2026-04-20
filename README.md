# 🏪 Superstore Sales Performance Analysis — SQL Project

![SQL](https://img.shields.io/badge/SQL-Server-blue?logo=microsoftsqlserver)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![Dataset](https://img.shields.io/badge/Records-896_Stores-orange)

A full end-to-end SQL project covering database setup, data ingestion, cleaning, exploratory analysis, and business intelligence queries on a retail superstore dataset. Built as a portfolio project to demonstrate practical SQL skills across all difficulty levels.

---

## 📁 Project Structure

```
📦 SQL-Superstore-Analysis
 ┣ 📄 SQL_Project_Superstore_Sales_Analysis.sql   ← Main SQL script (all sections)
 ┣ 📄 Superstore_Sales_Performance_Analysis.csv   ← Source dataset
 ┗ 📄 README.md                                   ← You are here
```

---

## 🗃️ Dataset Overview

| Field | Description |
|---|---|
| `Store_ID` | Unique identifier for each store |
| `Store_Area` | Physical store size in square feet |
| `Items_Available` | Number of unique products stocked |
| `Daily_Customer_Count` | Average number of customers per day |
| `Store_Sales` | Total sales revenue |
| `Performance` | Tier label — `High`, `Medium`, or `Low` |

- **Total stores:** 896  
- **Sales range:** 14,920 – 116,320  
- **Average store sales:** 59,354  
- **Total revenue across all stores:** 53,121,940  

---

## 🔧 SQL Skills Demonstrated

| Area | Techniques Used |
|---|---|
| DDL | `CREATE DATABASE`, `CREATE TABLE`, `ALTER TABLE`, `PRIMARY KEY`, `NOT NULL` |
| DML | `INSERT`, `UPDATE`, `DELETE`, `LOAD DATA` |
| Data Cleaning | `TRIM`, `SUBSTRING`, `LOWER`, `UPPER`, `NULL` checks, duplicate detection |
| Aggregation | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `STDDEV`, `GROUP BY`, `HAVING` |
| Filtering | `WHERE`, `CASE WHEN`, `BETWEEN`, `IN`, `NULLIF` |
| Subqueries | Correlated and non-correlated subqueries for cross-KPI filtering |
| CTEs | Single and chained `WITH` expressions |
| Window Functions | `RANK()`, `DENSE_RANK()`, `PERCENT_RANK()`, `SUM() OVER`, `AVG() OVER`, `PARTITION BY` |
| Views | `CREATE VIEW` for reusable enriched profiles and tier summaries |
| Stored Procedures | Parameterised `CREATE PROCEDURE` for dynamic querying |

---

## 🧹 Data Cleaning Steps

Before any analysis was performed, the data went through the following validation and cleaning steps:

1. **Duplicate check** — confirmed all `Store_ID` values are unique via `GROUP BY ... HAVING COUNT(*) > 1`
2. **NULL check** — verified zero NULL values across all six columns
3. **Performance label validation** — confirmed only `High`, `Medium`, `Low` values exist
4. **Outlier/impossible value detection** — flagged rows with zero or negative numeric values
5. **Suspicious low-traffic stores** — identified stores with fewer than 50 daily customers for review
6. **Label standardisation** — applied `TRIM` + `UPPER/LOWER + SUBSTRING` to normalise casing and remove whitespace

> **Note:** SQL Server requires `SUBSTRING(string, start, length)` with all 3 arguments. MySQL allows omitting the length. This cross-platform difference was encountered and resolved during the project.

---

## 📊 Key Findings

### 1. Performance Tier Distribution

| Tier | Stores | % of Total | Avg Sales | Total Sales |
|---|---|---|---|---|
| High | 605 | 67.5% | 68,519 | 41,385,710 |
| Medium | 274 | 30.6% | 41,469 | 11,362,450 |
| Low | 17 | 1.9% | 21,987 | 373,780 |

The vast majority of stores (67.5%) fall in the **High** performance tier, with only 17 stores classified as **Low** — suggesting the low-performing group is a small but meaningful outlier worth investigating.

---

### 2. Sales Efficiency (Revenue per Square Foot)

| Tier | Avg Sales per Sq Ft |
|---|---|
| High | **46.94** |
| Medium | 29.39 |
| Low | 16.05 |

High-tier stores generate nearly **3× more revenue per square foot** than Low-tier stores, making store size utilisation one of the strongest indicators of performance.

---

### 3. The Customer Count Paradox

A counterintuitive finding emerged from the data:

| Tier | Avg Daily Customers |
|---|---|
| High | 794 |
| **Low** | **955** |
| Medium | 760 |

**Low-performing stores actually attract more daily customers on average than High-performing stores.** This strongly suggests that **foot traffic alone does not drive sales** — conversion quality, product range, and store layout are likely more important factors.

Additionally, **294 out of 605 High-performing stores** have below-average daily customer counts, yet still achieve top-tier sales. This reinforces that customer value per visit matters more than raw volume.

---

### 4. Top vs Bottom Stores

- The **top store** (Store 650) recorded sales of **116,320** with 1,989 sq ft and 860 daily customers
- The **bottom store** recorded sales of just **14,920**
- That is a **7.8× gap** between the best and worst performers

---

### 5. Small But Mighty (Under-Resourced High Performers)

A significant subset of High-tier stores operate **below average store area** yet still reach the top performance tier. These stores show that:
- Efficient stock selection (`items_available`) can compensate for limited floor space
- Strong sales-per-sqft ratios are achievable without large footprints

---

### 6. Turnaround Targets (Large Low Performers)

Low-tier stores with **above-average store area** represent the biggest opportunity for improvement. These locations have the physical capacity but are not converting it into sales — likely due to poor customer experience, product mix, or staffing.

---

## 💡 Recommendations

### 🔴 For Low-Performing Stores
- **Audit product mix** — these stores have the space and customers; the issue is likely what they sell and how it's arranged
- **Investigate conversion rates** — high foot traffic with low sales points to in-store experience problems (layout, pricing, staff)
- **Set targeted KPIs** — use `sales_per_customer` as the primary turnaround metric, not total headcount

### 🟡 For Medium-Performing Stores
- **Benchmark against efficient High-tier stores of similar size** — identify which operational practices can be replicated
- **Focus on `sales_per_sqft`** — Medium stores average 29.39 vs 46.94 for High stores; this gap is closeable

### 🟢 For High-Performing Stores
- **Document what works** — particularly the 294 stores achieving High performance with below-average customer counts
- **Use as training benchmarks** — their `sales_per_item` and `sales_per_customer` ratios should be the organisational standard

### 📌 General
- **Do not use daily customer count as a success metric** in isolation — the data shows it is weakly correlated with tier
- **Collect additional data** — region, store age, staff count, and promotional activity would significantly improve predictive power
- **Automate the tier classification** using the stored procedure `sp_get_stores_by_tier` for regular operational reporting

---

## ▶️ How to Run

1. Open **Microsoft SQL Server Management Studio (SSMS)**
2. Connect to your SQL Server instance
3. Open `SQL_Project_Superstore_Sales_Analysis.sql`
4. Run **Section 1** to create the database and table
5. Use **Section 2** to load data (via `LOAD DATA` or manual inserts)
6. Run remaining sections in order, or execute individual queries as needed

> The script is written for **Microsoft SQL Server**. Minor syntax adjustments (e.g., `SUBSTRING` argument handling) may be needed for MySQL or PostgreSQL.

---

## 👤 Author

**[Your Name]**  
Aspiring Data Analyst | SQL · Excel · Python  
📧 your.email@example.com  
🔗 [LinkedIn](https://linkedin.com/in/yourprofile) | [GitHub](https://github.com/yourusername)

---

## 📄 License

This project is open for portfolio and educational use.  
Dataset used for learning purposes only.
