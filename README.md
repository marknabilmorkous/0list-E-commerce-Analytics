# Olist E-Commerce Analytics Dashboard

An end-to-end data analytics solution built using **SQL** and **Power BI** to analyze Olist's Brazilian e-commerce dataset containing **$13.6M+ in sales** and **99K+ orders**.

This project demonstrates a complete analytics pipeline: data cleaning and transformation using SQL Views, data modeling and custom calculations via DAX, and interactive dashboard design in Power BI to drive business insights across sales performance, logistics, customer satisfaction, and payment methods.

---

## 📋 Table of Contents
- [Project Architecture](#-project-architecture)
- [Tech Stack](#-tech-stack)
- [Dashboard Overview](#-dashboard-overview)
  - [1. Executive / Sales Overview](#1-executive--sales-overview)
  - [2. Delivery & Customer Satisfaction](#2-delivery--customer-satisfaction)
  - [3. Payments & Product Analysis](#3-payments--product-analysis)
- [Data Pipeline & SQL Transformations](#-data-pipeline--sql-transformations)
- [DAX Measures](#-dax-measures)
- [Key Insights & Findings](#-key-insights--findings)
- [How to Replicate](#-how-to-replicate)

---

## 🏗 Project Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌───────────────────┐     ┌────────────────────┐
│  Raw Olist CSVs │ ──> │  SQL Server /    │ ──> │ Power BI Desktop  │ ──> │  Interactive       │
│  (Kaggle Data)  │     │  SQL Views & ETL │     │  Data Model & DAX │     │  Dashboards        │
└─────────────────┘     └──────────────────┘     └───────────────────┘     └────────────────────┘
```

---

## 🛠 Tech Stack

* **SQL (SQL Server / PostgreSQL):** Data cleaning, filtering, handling nulls, structural transformations, and creating optimized `SQL Views`.
* **Power BI Desktop:** Data modeling, star schema design, interactive UI/UX layout, and custom visualizations.
* **DAX (Data Analysis Expressions):** Calculated columns, time intelligence, dynamic aggregation measures, and KPI metrics.

---

## 📊 Dashboard Overview
<img width="1422" height="810" alt="Dashboard 1" src="https://github.com/user-attachments/assets/f381adf7-1c2d-447a-990e-65e5c2562618" />
<img width="1265" height="806" alt="Dashboard 2 " src="https://github.com/user-attachments/assets/2c35184c-6bfc-45f6-80c7-c20b2f43a34b" />
<img width="1483" height="771" alt="Dashboard 3 " src="https://github.com/user-attachments/assets/e517d404-8db9-42ab-8384-73c0147c3ef3" />


The dashboard is structured into three dedicated interactive views designed for distinct business functions:

### 1. Executive / Sales Overview
Focuses on high-level performance metrics, regional sales distribution, and temporal trends.
* **Key KPIs:** Total Sales ($13.6M), Total Orders (99K), Total Customers (96K), Total Sellers (3,095), Total Products (33K).
* **Sales Over Time:** A monthly line chart tracking revenue growth from Sep 2016 through Sep 2018, peaking at **$1.01M** in late 2017.
* **Geographic Map:** Spatial visual rendering sales across Brazilian states (heavy concentration in São Paulo and Rio de Janeiro).
* **Top Categories & Sellers:** Bar charts highlighting top-performing categories (`health_beauty` at $1.26M, `watches_gifts` at $1.21M) and seller contribution.
* **Customer Efficiency:** Average Order Value ($136.7) and Average Orders per Customer (1.0).

### 2. Delivery & Customer Satisfaction
Monitors logistics reliability, delivery SLA compliance, and impact on customer reviews.
* **Key KPIs:** Average Delivery Days (12.5 days), On-Time Delivery Rate (**91.9%**), Late Delivery Rate (**8.1%** / 7,827 orders), Average Review Score (**4.09 / 5.0**).
* **Delivery Status Breakdown:** Donut chart visual showing 89.15% on-time vs 7.87% late deliveries.
* **Impact of Shipping on Ratings:** Review score comparison revealing on-time deliveries average **4.3 stars** versus **2.6 stars** for late deliveries.
* **Review Score Distribution:** Horizontal bar chart showing 5-star reviews dominate (57K), while 1-star reviews stand at 11K.
* **Monthly Delivery Trends:** Stacked area chart showing monthly volume of on-time vs. late shipments over time.

### 3. Payments & Product Analysis
Analyzes transaction methods, installment behaviors, and top revenue-generating items.
* **Key KPIs:** Total Payment Value ($16M), Average Payment Value ($154.10), Average Installment Count (2.85).
* **Payment Type Share:** Donut chart breakdown showing **Credit Card dominance (78.34%)**, followed by Boleto (17.92%), Voucher, and Debit Card.
* **Installment Breakdown:** Bar chart displaying revenue split by installment counts—1 installment leads ($5.9M), followed by 6+ installments ($4.9M).
* **Payment Value Trends:** Line graph illustrating total payment volume over the project timeline.
* **Top Products:** Revenue ranking by individual SKU identifiers (top product generating over $64K).

---

## 🧹 Data Pipeline & SQL Transformations

Raw data was imported into SQL where data hygiene and view layer logic were performed before ingestion into Power BI:

```sql
-- Sample View Creation: Delivery & Review Analytics
CREATE VIEW vw_delivery_performance AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days,
    CASE 
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On-Time'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'Pending/Undelivered'
    END AS delivery_status,
    r.review_score
FROM orders o
LEFT JOIN order_reviews r ON o.order_id = r.order_id;
```

---

## 🧮 DAX Measures

Key metrics calculated in Power BI using DAX:

```dax
// Total Sales Amount
Total Sales = SUM(order_items[price])

// On-Time Delivery Rate
On-Time Delivery Rate = 
DIVIDE(
    CALCULATE(COUNT(orders[order_id]), orders[delivery_status] = "On-Time"),
    COUNT(orders[order_id]),
    0
)

// Average Order Value (AOV)
Average Order Value = 
DIVIDE([Total Sales], DISTINCTCOUNT(orders[order_id]), 0)

// Average Review Score
Average Review Score = AVERAGE(order_reviews[review_score])
```

---

## 📌 Key Insights & Findings

1. **Logistics Drive Satisfaction:** Late deliveries severely damage customer sentiment, causing average ratings to drop from **4.3 to 2.6 stars**. Improving fulfillment in high-volume states (São Paulo, Rio) can directly boost ratings.
2. **Credit & Installments Dominate:** Over **78%** of purchases use credit cards, with a substantial portion opting for **6+ installments ($4.9M)**, indicating high customer reliance on financing options for larger purchases.
3. **Product Concentration:** `health_beauty`, `watches_gifts`, and `bed_bath_table` drive over $3.5M combined sales, representing core growth engines for the platform.

---

## 🚀 How to Replicate

1. **Database Setup:** Run SQL scripts in the `/SQL` directory to load raw tables and generate required `Views`.
2. **Power BI Data Import:** Connect Power BI Desktop to your SQL database and import the created SQL Views.
3. **Data Model & DAX:** Open `.pbix` file to explore relationships and measures.
