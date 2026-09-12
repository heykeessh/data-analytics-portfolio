# Olist SQL Analysis

## Overview

### E-Commerce Business Performance & Growth Analysis

**Executive Deliverable | Data Analytics Portfolio Project**
**Dataset Period: September 2016 – September 2018**

This project analyzes the business performance and growth patterns of a Brazilian e-commerce platform using relational transaction, customer, order-item, and product catalog data. The analysis covers 24 recorded months from September 2016 through September 2018 and evaluates customer retention, product-category performance, revenue concentration, and customer spending behavior.

Data quality assessment identified several structural anomalies in the dataset, including a missing November 2016 and truncated activity in September 2016, December 2016, and September 2018. Therefore, the analysis benchmarks core business performance primarily against the 20 continuous operational months from January 2017 through August 2018.

The analysis focuses on translating SQL-based findings into actionable business recommendations related to **customer retention, revenue growth, category prioritization, and average order value (AOV)**.

---

## Business Questions

This analysis addresses the following key business questions:

1. Who are the top 10 customers by total amount spent?
2. What is the monthly revenue trend across the dataset?
3. What is the month-over-month change in revenue?
4. Which product categories generate the most revenue?
5. Rank the top 3 products within each category by revenue.
6. Segment customers into spend tiers (Low / Medium / High).
7. How many customers are repeat buyers vs one-time buyers?
8. What percent of total revenue comes from the top category?

---

## Key Findings

### 1. Customer Retention Bottleneck Threatens Long-Term Growth

Customer purchase-frequency analysis shows that **96.96% of customers (92,102)** are one-time buyers, while only **3.04% (2,888)** are repeat customers.

This represents a significant customer-retention challenge. The platform currently relies heavily on continuously acquiring new customers rather than generating recurring purchases from its existing customer base.

**Business Impact:**
Low repeat-purchase activity limits customer lifetime value and increases dependence on ongoing customer acquisition. Improving post-purchase engagement and customer retention represents a major opportunity for sustainable revenue growth.

---

### 2. Top Product Categories Anchor Core Platform Revenue

Analysis across **74 product categories** shows that revenue is concentrated among several major lifestyle categories.

The leading category, **Health & Beauty (`beleza_saude`)**, generated approximately **R$1.26 million**, representing **9.31% of total platform sales**. Watches & Gifts, Bed & Bath, and Sports & Leisure were also among the strongest-performing categories.

The **top five categories collectively account for nearly 40% of catalog sales**, demonstrating significant revenue concentration among a relatively small group of product verticals.

**Business Impact:**
High-performing categories represent the platform's strongest demand centers and should receive greater attention in inventory availability, marketing investment, merchant acquisition, and promotional planning.

---

### 3. Extreme Long-Tail Spending Profile Reveals an Untapped Mid-Tier

Customer spending segmentation reveals that **99.77% of customers (95,870)** fall into the Low spending tier, defined as spending below R$2,000. These customers generated approximately **R$15.39 million** in aggregate sales while averaging only **R$160.49** in spending.

In comparison, only **204 customers** fall into the Medium tier and **21 customers** into the High tier.

**Business Impact:**
The extremely concentrated low-spend customer base indicates an opportunity to increase customer value through cross-selling, product bundling, personalized recommendations, and incentives designed to encourage larger baskets and additional purchases.

---

## Recommendations

### 1. Deploy Automated Post-Purchase Lifecycle Campaigns

With approximately **97% of customers purchasing only once**, the platform should implement automated post-purchase engagement campaigns designed to encourage a second purchase.

Potential initiatives include:

* Personalized email and SMS campaigns
* 30–60 day re-engagement campaigns
* Recommendations for complementary products
* Personalized discounts based on previous purchases
* Category-specific promotions
* Loyalty and repeat-purchase incentives

Health & Beauty and other high-velocity categories could serve as priority segments for initial retention campaigns.

**Expected Business Outcome:**
Increase repeat-purchase rate, improve customer lifetime value, and reduce dependence on continuous customer acquisition.

---

### 2. Implement Cross-Category Bundling and Tiered Free-Shipping Thresholds

The predominance of low-spending customers creates an opportunity to increase average basket size.

The platform could introduce:

* Product bundles
* Frequently-bought-together recommendations
* Cross-category promotions
* Checkout upselling
* Tiered free-shipping thresholds

For example, a free-shipping threshold of approximately **R$250+**, compared with the current low-spend average of approximately R$160, could encourage customers to add complementary products to their basket.

**Expected Business Outcome:**
Increase average order value, encourage cross-category purchases, and gradually migrate customers from low-value to higher-value spending tiers.

---

## Tools & Skills

### Tools

* **DataGrip**
* **MySQL**
* **SQL**
* **GitHub**

### SQL Skills Demonstrated

* Data exploration and profiling
* Data quality assessment
* Relational database analysis
* `SELECT` statements and filtering with `WHERE`
* `GROUP BY` and aggregate functions
* `JOIN` operations across multiple tables
* Subqueries
* Common Table Expressions (`CTEs`)
* Window functions
* Conditional logic using `CASE`
* Date and time analysis
* Customer segmentation
* Revenue and sales analysis
* Product and category performance analysis
* Business KPI analysis
* Data-driven business insights


### Data Analytics Skills

* Exploratory Data Analysis
* Customer behavior analysis
* Revenue analysis
* Customer segmentation
* Trend analysis
* Business insight generation
* Data-driven recommendations
* Translating SQL results into business actions

---

## Files

| File                           | Description                                                   |
| ------------------------------ | ------------------------------------------------------------- |
| `olist_analysis.sql`           | SQL queries used for the analysis          |
| `README.md`                    | Project overview, findings, and recommendations               |

---

## Project Objective

The objective of this project is to demonstrate how **SQL and data analytics can be used to transform raw e-commerce transaction data into actionable business insights**.

Rather than focusing solely on technical SQL execution, the analysis follows a business-oriented approach:

**Raw Data → SQL Analysis → Business Finding → Business Impact → Recommendation**

This framework demonstrates the ability to connect technical data analysis with practical business decision-making.

