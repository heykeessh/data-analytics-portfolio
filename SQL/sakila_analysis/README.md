# Sakila SQL Business Analysis

## Project Overview

This project evaluates transactional activity from the Sakila relational movie rental database, synthesizing transactional and catalog data sourced across core tables including rental, payment, inventory, customer, film, film_category, category, and store entities. The primary transactional activity spans May 2005 through August 2005, with a residual operational snapshot in February 2006, capturing 16,044 transactions and $67,406.56 in gross revenue across 599 unique customers. A notable data quality anomaly is the abrupt five-month gap between September 2005 and January 2006 where zero transactions were recorded, indicating either unrecorded off-season operations or a data ingestion failure. Additionally, 42 catalog titles record zero lifetime rentals, highlighting catalog inventory bloat and un-monetized stock.

The analysis demonstrates practical SQL skills used in data analytics, including:

- SELECT statements
- Filtering and sorting
- Aggregate functions
- GROUP BY and HAVING
- INNER and LEFT JOINs
- Subqueries
- Common Table Expressions (CTEs)
- Window functions
- CASE statements
- Date and time analysis

## Business Questions

1. Which films generate the most rental activity?
2. Which customers contribute the most revenue?
3. Which film categories have the highest rental demand?
4. Which stores generate the most rental revenue?
5. What are the monthly rental and revenue trends?
6. Which customers have the highest rental frequency?
7. Which films have low rental activity?

## Key Insights

**Insight 1:** **Summer Demand Surge Followed by Operational Drop-Off**

Rental volume and gross receipts experienced rapid growth from May 2005 ($4,823.44 across 1,156 rentals) to an aggressive peak in July ($28,368.91 across 6,709 rentals) and August ($24,070.14 across 5,686 rentals), before dropping to zero across autumn/winter until a nominal $514.18 (182 rentals) in February 2006. For the business, this reveals that 77.8% of historical revenue is concentrated within a two-month summer window, highlighting severe off-peak revenue vulnerability and unmanaged customer churn, alongside a probable transactional logging failure during the autumn blackout.

**Insight 2:** **Perfect Store Revenue Parity Mandates Network-Wide Strategy**

Store 2 generated $33,726.77 (50.03% share) and Store 1 generated $33,679.79 (49.97% share) across the $67,406.56 total revenue base, reflecting an almost identical commercial output. For executive leadership, this means physical store location, local market differences, and individual branch management are not the primary drivers of revenue variation. Growth initiatives should not focus on rehabilitating an underperforming unit, but rather on enterprise-wide programs such as cross-store loyalty perks, unified digital cataloging, and centralized replenishment.

**Insight 3:** **High-Velocity Genre Concentration vs. Low-Turnover Drag**

Rental demand is heavily anchored in Sports (1,179 rentals), Animation (1,166 rentals), and Action (1,112 rentals), led by top performers like Bucket Brotherhood (34 rentals) and Rocketeer Mother (33 rentals), while lagging titles like Hardly Robbers and Mixed Doors managed only 4 rentals each across the operational period. For the business, retail floor space and working capital are tied up in underperforming catalog inventory, while high-velocity genres risk stockouts during high-traffic periods, capping revenue potential.

## Strategic Recommendations

**Recommendation 1:** **Smooth Seasonal Volatility & Audit Ingestion**

Launch targeted pre-summer promotional campaigns and structured subscription passes starting in April to extend the customer lifecycle beyond the July–August peak. Concurrently, conduct an operational data audit to resolve transaction tracking gaps between September and January, ensuring continuous revenue visibility.

**Recommendation 2:** **Rebalance Inventory & Implement VIP Retention**

Reallocate capital from low-turnover titles (≤ 5 rentals) into high-demand categories (Sports, Animation, Action) to prevent stockouts and improve inventory turns. In parallel, roll out a dedicated VIP loyalty tier offering priority reservations and bundled discounts to top patrons (such as Karl Seal and Eleanor Hunt).

## Tools

- MySQL
- DataGrip
- GitHub

## Files

| File                           | Description                                                   |
| ------------------------------ | ------------------------------------------------------------- |
| `sakila-data.sql`              | Dataset source used for the analysis                          |
| `1_sql_foundations.sql`        | Select, limit, where, order by, distinct queries              |
| `2_data_retrieval_filtering.sql` | Select, aliases, computed columns, comparisons, in, between, null, text and date filtering queries |
| `3_aggregations_business_thinking.sql` | Aggregate functions, group by, having, case when queries |
| `4_joins.sql`                  | Inner, left, multi-table join, and joins with aggregation     |
| `business_questions.sql`       | Queries used to answer business questions                     | 
| `README.md`                    | Project overview, findings, and recommendations               |

## Database

Sakila Sample Database
