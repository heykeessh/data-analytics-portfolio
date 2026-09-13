**Olist Brazilian E-Commerce Business Performance & Growth Analysis**

*Executive Deliverable \| Dataset Period: Sep 2016 -- Sep 2018*

**1. Data Overview**

This dataset comprises customer transactions, order items, and product
catalog records from a Brazilian e-commerce platform spanning 24
recorded months from September 2016 through September 2018 across
relational database tables. A comprehensive data quality assessment
reveals key structural anomalies: November 2016 is entirely absent,
while September 2016 (R\$ 136.23), December 2016 (R\$ 19.62), and
September 2018 (R\$ 166.46) represent truncated pilot and wind-down
phases rather than full operating months. Consequently, business
evaluation must benchmark against the 20 continuous peak operational
months between January 2017 and August 2018, during which monthly
platform revenues scaled robustly to well over R\$ 1,000,000.
Additionally, customer spend values are heavily right-skewed, requiring
careful segmentation between routine purchasers and ultra-high-value
outliers.

**2. Business Insights**

**Customer Retention Bottleneck Threatens Long-Term Growth (Query 7):**
Analysis of customer purchase frequency shows that 96.96% of the
customer base (92,102 customers) are one-time buyers, while repeat
buyers represent a mere 3.04% (2,888 customers). For the business, this
indicates severe churn and an unsustainable reliance on continuous,
high-cost customer acquisition. Without dedicated post-purchase
engagement or loyalty mechanics, the platform is functioning merely as a
transactional checkout point rather than building durable customer
lifetime value, leaving future top-line growth vulnerable to rising
digital advertising costs.

**Top Categories Anchor Core Platform Volume (Query 4 & Query 8):**
Evaluating gross merchandise value across 74 product categories
indicates that revenue is heavily anchored in leading lifestyle
segments, led by Health & Beauty (beleza_saude) generating R\$
1,255,695.13 (9.31% of platform total), followed by Watches & Gifts (R\$
1.19M), Bed & Bath (R\$ 1.04M), and Sports & Leisure (R\$ 0.98M)---with
the top 5 categories driving nearly 40% of total catalog sales. For the
business, this proves that consumer demand is concentrated in recurring
personal care, home lifestyle, and gifting goods. Marketing
expenditures, inventory logistics, and merchant partnership terms should
prioritize these anchor verticals while rationalizing underperforming
niche categories.

**Extreme Long-Tail Spending Profile with Untapped Mid-Tier (Query 6):**
Customer spending tier segmentation reveals that 99.77% of clients
(95,870 individuals) fall into the 'Low' spend tier (under R\$ 2,000,
averaging R\$ 160.49), contributing R\$ 15.39M in aggregate sales,
whereas 'Medium' (204 customers) and 'High' (21 customers) represent
less than 0.25% of buyers combined. For the business, this demonstrates
an overwhelming dependence on entry-level, single-item basket sizes. The
business currently misses a vital monetization bridge between
entry-level shoppers and premium buyers, signaling an urgent need for
upselling, bundling, and minimum basket thresholds to lift average order
value.

**3. Recommendations**

**1. Deploy Automated Post-Purchase Lifecycle Campaigns to Combat 97%
One-Time Churn:** Implement triggered email/SMS re-engagement sequences
offering personalized, time-bound discounts on complementary catalog
items within 30 to 60 days of an initial order. Focusing this retention
campaign on high-velocity repeat categories like Health & Beauty will
systematically convert first-time buyers into loyal repeat purchasers
and lower blended acquisition costs.

**2. Implement Cross-Category Bundling and Tiered Free-Shipping
Thresholds to Lift Basket Size:** Introduce algorithmic cross-selling
prompts at checkout paired with a free shipping minimum threshold set
above the current R\$ 160 average basket size (e.g., free shipping at
R\$ 250+). This will encourage low-tier customers to add secondary items
to their carts, effectively migrating thousands of mass-market buyers
into higher spending tiers and driving higher platform margins.
