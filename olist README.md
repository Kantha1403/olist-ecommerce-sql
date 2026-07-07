# Olist E-Commerce SQL Analysis

## Project Overview
End-to-end SQL analysis of the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — a real, anonymized dataset of ~100,000 orders placed on Brazil's largest e-commerce marketplace between 2016 and 2018.

The project covers database design, data import and cleaning, and business-driven SQL analysis across 9 queries, with results visualized in Power BI.

---

## Tools Used
- **MySQL 8.0** — database setup, data import, and all SQL analysis
- **MySQL Workbench** — query execution and result validation
- **Power BI** — dashboard and visualization (in progress)
- **Python (Pandas)** — pre-import data cleaning (fixing date formats in orders CSV)

---

## Dataset
- **Source:** [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Size:** 9 tables, ~100,000 orders, 112,650 order items, 99,441 customers, 3,095 sellers
- **Period:** September 2016 – August 2018

### Tables
| Table | Rows | Description |
|---|---|---|
| customers | 99,441 | Customer IDs and locations |
| sellers | 3,095 | Seller IDs and locations |
| products | 32,951 | Product details and categories |
| orders | 99,441 | Order status and timestamps |
| order_items | 112,650 | Line items with price and freight |
| order_payments | 103,886 | Payment types and values |
| order_reviews | 99,223 | Customer review scores and comments |
| geolocation | 1,000,163 | Zip code lat/long reference |
| product_category_name_translation | 71 | Portuguese to English category mapping |

---

## Data Cleaning Notes
- **Orders CSV:** original file had dates in `DD-MM-YYYY` format (Excel auto-formatting artifact) and 2 trailing empty columns. Fixed using a Python script before import — see `setup/olist_orders_dataset_fixed.csv`.
- **Zero-dates:** blank delivery dates imported as `0000-00-00 00:00:00` (MySQL strict mode behavior). Converted to proper `NULL` via UPDATE statements post-import.
- **Referential integrity:** 1,604 `order_items` rows reference product IDs missing from the `products` table — a known data quality issue in the original Olist dataset, documented and excluded from analysis.

---

## Business Questions & Key Findings

### Query 1: Monthly Revenue, Orders, and Average Order Value
**Question:** How is the business performing month over month?

**Finding:** Orders grew steadily from 3 in September 2016 to a peak of 7,544 in November 2017, with total revenue tracking proportionally. Average order value remained stable in the R$150–180 range throughout, suggesting growth was driven by volume, not price increases.

---

### Query 2: Top 10 Product Categories by Revenue
**Question:** Which product categories drive the most revenue?

**Finding:** `health_beauty` leads at R$1.26M, followed by `watches_gifts` (R$1.21M) and `bed_bath_table` (R$1.04M). These three categories alone account for a significant share of total platform revenue and represent the highest-priority areas for seller recruitment and inventory focus.

---

### Query 3: Delivery Performance — On Time vs Late vs Not Delivered
**Question:** What percentage of orders are delivered on time?

**Finding:** 90.4% of orders delivered on time, 6.6% late, and 3.0% never delivered. While the on-time rate looks healthy, the 6,535 late orders represent thousands of customers with a poor delivery experience — warranting deeper investigation into which sellers or regions are driving the delays.

---

### Query 4: Top 3 Sellers by Revenue per State
**Question:** Who are the top-performing sellers in each Brazilian state?

**Finding:** São Paulo (SP) dominates with top sellers generating R$229K, R$200K, and R$194K respectively — far ahead of smaller states like Amazonas (AM) where the #1 seller generated just R$1,177. This regional concentration suggests significant opportunity for seller expansion outside SP.

---

### Query 5: Customer Order History
**Question:** When did each customer place their first and most recent order, and how many orders have they placed?

**Finding:** The majority of customers placed only one order, indicating low repeat purchase rates — a significant retention opportunity for the business.

---

### Query 6: Month-over-Month Revenue Change
**Question:** How does this month's revenue compare to last month's?

**Finding:** Revenue grew consistently through 2017, with the largest single-month jump in November 2017 (+R$316K vs October), likely driven by Black Friday. Growth slowed in early 2018, stabilizing around R$1M–1.2M per month.

---

### Query 7: Average Review Score by Product Category
**Question:** Which product categories have the highest and lowest customer satisfaction?

**Finding:** Categories with the lowest review scores tend to be those with longer delivery times or heavier items (higher freight costs), suggesting delivery experience — not just product quality — drives review outcomes.

---

### Query 8: Delivery Delay Impact on Review Scores
**Question:** Do late deliveries actually result in lower review scores?

**Finding:** On-time orders average a significantly higher review score than late orders, confirming that delivery performance is a key driver of customer satisfaction. This supports prioritizing logistics improvements as a retention strategy.

---

### Query 9: Top 10 Sellers by Revenue with Average Review Score
**Question:** Among the highest-revenue sellers, who also maintains strong customer satisfaction?

**Finding:** Not all high-revenue sellers have strong review scores — some top earners score below average, flagging a potential quality risk. A combined revenue + satisfaction view gives a more complete picture of seller health than revenue alone.

---

## How to Run
1. Clone this repository
2. Run `setup/setup_olist_database.sql` in MySQL Workbench (adjust file paths to your local Olist CSV folder)
3. Run `queries/analysis_queries.sql` to reproduce all 9 analysis queries
4. Screenshot results are in `results/`

> **Note:** You will need to download the Olist dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) separately, as the raw CSVs are not included in this repository due to file size.

---

## Author
**Kantha Lakshminarasimhan**  
MSc Data Science — Dr. DY Patil College (2026)  
[LinkedIn](https://linkedin.com/in/kantha-lakshminarasimhan-355b18258) | [GitHub](https://github.com/Kantha1403) | kantha030114@gmail.com
