# Retail Sales & Customer Insights

An end-to-end e-commerce analytics capstone covering **January 2024 through January 2026**. I used Python to clean seven retail datasets, build a 37,501-row order-line fact table, and create an interactive Streamlit dashboard for tracking merchandise revenue, customer behavior, and order operations.

**Tools** · Python, pandas, Streamlit, Altair, Matplotlib, Jupyter

![Monthly merchandise revenue in PHP from January 2024 to January 2026](charts/01_monthly.jpg)

## Executive summary

| Metric | Full reporting period |
| --- | ---: |
| Estimated merchandise revenue | ₱5,325,284.86 |
| Revenue-bearing orders | 11,643 |
| Average order value | ₱457.38 |
| Order cancellation rate | 8.2% |

- Estimated merchandise revenue was ₱5.33M across 11,643 revenue-bearing orders, with an average order value of ₱457.38.
- Revenue fell 1.7% from ₱2.59M in 2024 to ₱2.54M in 2025. April 2025 led all months at ₱236.3k.
- Toys led categories at ₱741.5k (13.9% of revenue), followed by Electronics at ₱721.9k. KidJoy Toys 607 led catalog products at ₱29.0k.
- Central Luzon led regions at ₱930.9k (17.5%). Olongapo led cities at ₱344.2k.
- Web led channels at ₱1.80M. Mobile App and Marketplace each generated about ₱1.75M–₱1.78M.
- Repeat orders generated ₱3.25M (61.0% of revenue) versus ₱2.06M from first observed orders. Unmatched customers accounted for the balance.
- Median order value was ₱379.51, below the ₱457.38 mean. The 90th percentile was ₱903.12.
- 1,235 of 15,000 orders were cancelled (8.2%). January 2025 had the highest order-month cancellation rate at 10.8%.
- Recommendation 1 — Test a second-purchase offer on a first-order cohort. Track 60-day repeat purchase and incremental merchandise revenue against a holdout group.
- Recommendation 2 — Reconcile missing checkout prices, discounts and unmatched IDs upstream. Audit the 1,701 sales lines valued at catalog prices and capture cancellation reasons by channel.

See [executive_summary.txt](executive_summary.txt) for the standalone summary.

## Interactive dashboard

Filter by **order month, product category, sales channel, and customer region**. Hover over any of the ten charts for exact values or select **Reset filters** to return to the full report.

| Dashboard tab | What you can explore |
| --- | --- |
| Sales Overview | Monthly revenue, channel performance, and the distribution of order values |
| Product Performance | Top 10 products by revenue and sales by category |
| Customer Geography | Revenue by region and the top 10 customer cities |
| Customer Mix | Revenue and order counts by customer type, plus distinct matched customers |
| Order Operations | Monthly cancellation rate and order volume by status |

## Dashboard screenshots

Each screenshot is **1920 × 1080** and shows one tab of the Streamlit dashboard.

### Sales Overview

![Sales Overview dashboard tab with the monthly revenue trend and channel comparison](screenshots/01_sales_overview.png)

| Tab | Full-size screenshot |
| --- | --- |
| Sales Overview | [Open screenshot](screenshots/01_sales_overview.png) |
| Product Performance | [Open screenshot](screenshots/02_product_performance.png) |
| Customer Geography | [Open screenshot](screenshots/03_customer_geography.png) |
| Customer Mix | [Open screenshot](screenshots/04_customer_mix.png) |
| Order Operations | [Open screenshot](screenshots/05_order_operations.png) |

## Data and methodology

1. **Clean and validate** the customer, product, order, order item, payment, shipment, and return datasets. Standardize category labels, parse dates and numeric fields, remove exact duplicates, and flag unmatched keys.
2. **Build the fact table** at one row per order item. Join order, product, and customer attributes and retain join flags for the data quality audit.
3. **Calculate merchandise revenue** for eligible lines from Completed and Shipped orders using quantity × unit price × (1 − order discount). Use catalog prices when purchase prices are unavailable and assume zero for missing or invalid discounts. The estimate excludes shipping fees and uses order-line values before any separately recorded refunds.
4. **Classify customer type** from order history. The first eligible order for a matched customer is New, and later eligible orders are Repeat. When a category filter is active, sales and average order value use matching line items, while cancellation metrics count orders containing those items.

### Metric definitions

| Metric | Calculation |
| --- | --- |
| Revenue-bearing orders | Distinct orders with at least one eligible line contributing to revenue |
| Average order value | Estimated merchandise revenue ÷ revenue-bearing orders |
| Cancellation rate | Cancelled orders ÷ all orders in the selected scope |

## Key takeaways

- **Customer retention.** Repeat orders contributed most of the estimated revenue. A second-purchase test would measure whether a retention offer increases repeat purchases.
- **Sales channel mix.** Web, Mobile App, and Marketplace each generated roughly ₱1.75M–₱1.80M. Web led by a narrow margin.
- **Order values.** The ₱379.51 median was below the ₱457.38 average. Use the median alongside the average when describing a typical order.

## Business insights

| Observation | Decision it can inform |
| --- | --- |
| Toys contributed 13.9% of merchandise revenue, with Electronics close behind. | Prioritize these categories when reviewing assortment and availability. |
| Central Luzon accounted for 17.5% of estimated revenue, and Olongapo led cities. | Use customer geography to select markets for targeted campaigns. |
| The cancellation rate reached 10.8% in January 2025 versus 8.2% overall. | Investigate cancellation reasons by channel and fulfillment stage. |

## Summary and conclusions

The store generated ₱5.33M in estimated merchandise revenue during the reporting period. Revenue declined slightly between the two complete years, with repeat orders contributing 61.0% of sales across the full period. Revenue measures merchandise sales using order-line prices and discounts, with catalog estimates for some missing purchase prices. These figures support sales and retention analysis. Profitability would require a separate review of costs, fees, and refunds.

## Recommendations

1. **Test a second-purchase offer.** Compare 60-day repeat purchase rates and incremental merchandise revenue against a holdout group.
2. **Improve checkout and order data.** Audit the 1,701 sales lines valued at catalog prices, reconcile missing prices and discounts, and record cancellation reasons by channel.

## Run locally on Windows

Use **Python 3.11 or newer**. Open Command Prompt in the project folder, then run:

```cmd
py -m venv .venv
.venv\Scripts\python.exe -m pip install -r requirements.txt
.venv\Scripts\python.exe -m streamlit run capstone_project.py
```

Open the local URL printed in Command Prompt, usually [http://localhost:8501](http://localhost:8501). The dashboard reads `sales_fact.csv`, `orders_clean.csv`, and `customers_clean.csv` from `data/cleaned_datasets/`. To reproduce the cleaning and JPG exports with the seven raw CSVs, open the notebook in Jupyter and run all cells.

## Project files

| File or folder | Purpose |
| --- | --- |
| [capstone_project.py](capstone_project.py) | Streamlit dashboard and filters |
| [retail_ecommerce_capstone.ipynb](retail_ecommerce_capstone.ipynb) | Data preparation, analysis, and chart exports |
| [analysis_pipeline.py](analysis_pipeline.py) | Shared cleaning, fact-table, and KPI logic |
| [data_quality_audit.csv](data_quality_audit.csv) | Data quality checks and flagged row counts |
| [charts/](charts/) | Ten exported JPG charts |
| `data/raw_datasets/` | Source CSVs for reproducing the analysis |
| `data/cleaned_datasets/` | Cleaned tables and the sales fact table |
| `.streamlit/config.toml` | Dashboard theme |

## Cleaned datasets

| File | Contents |
| --- | --- |
| `customers_clean.csv` | Customer attributes, location, and loyalty tier |
| `products_clean.csv` | Product catalog and standardized categories |
| `orders_clean.csv` | Order dates, channels, statuses, and discounts |
| `order_items_clean.csv` | Product lines, quantities, and analysis prices |
| `payments_clean.csv` | Payment methods, statuses, and amounts |
| `shipments_clean.csv` | Shipment dates, carriers, and statuses |
| `returns_clean.csv` | Return reasons and refunds |
| `sales_fact.csv` | Order-line dataset used in the dashboard |

All cleaned files belong in `data/cleaned_datasets/`. The [executed notebook](retail_ecommerce_capstone.ipynb) documents how they were built.

## Exported charts (JPG)

| Sales and product performance | Customers and operations |
| --- | --- |
| [Monthly merchandise revenue](charts/01_monthly.jpg) | [Revenue by customer region](charts/04_regions.jpg) |
| [Revenue by sales channel](charts/08_channels.jpg) | [Top 10 cities by revenue](charts/05_cities.jpg) |
| [Distribution of order values](charts/06_order_values.jpg) | [Revenue by customer type](charts/09_customer_types.jpg) |
| [Top 10 products by revenue](charts/02_products.jpg) | [Monthly cancellation rate](charts/07_cancellation_rate.jpg) |
| [Revenue by category](charts/03_categories.jpg) | [Orders by status](charts/10_statuses.jpg) |

## Before publishing the data

The source files contain customer names, emails, phone numbers, and shipment tracking numbers. For a public portfolio, use authorized, de-identified data. The dashboard only needs three CSVs, and it reads just `customer_id` and `region_name` from `customers_clean.csv`. Keep any de-identified join keys consistent across the files so the dashboard can still link records.
