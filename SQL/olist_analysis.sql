-- ==========================================
-- OLIST E-COMMERCE ANALYSIS
-- ==========================================

-- Query 1. Who are the top 10 customers by total amount spent?

use olist;

select
    c.customer_unique_id,
    round(sum(op.payment_value),2) as total_amt_spent
from customers c
join orders o on o.customer_id = c.customer_id
join order_payments op on op.order_id = o.order_id
where o.order_status not in ('Canceled', 'Unavailable')
group by
    c.customer_unique_id
order by total_amt_spent desc
limit 10;


-- Query 2. What is the monthly revenue trend across the dataset?

use olist;

select
    date_format(o.order_purchase_timestamp, "%Y-%m") as purchase_month,
    round(sum(payment_value),2) as total_revenue
from orders o
join order_payments op on o.order_id = op.order_id
where o.order_status not in ('Canceled', 'Unavailable')
group by purchase_month
order by purchase_month;


-- Query 3. What is the month-over-month change in revenue?

use olist;

with monthly as (
                select date_format(o.order_purchase_timestamp, "%Y-%m") as month,
                        round(sum(payment_value), 2)                    as total_revenue
                from orders o
                join order_payments op on o.order_id = op.order_id
                where o.order_status not in ('canceled', 'unavailable')
                group by month
                order by month)
select
    month,
    total_revenue,
    lag(total_revenue) over (order by month) as prev_month,
    round(total_revenue - lag(total_revenue) over (order by month),2) as revenue_change
from monthly
order by month;


-- Query 4. Which product categories generate the most revenue?

use olist;

select
    coalesce(p.product_category_name, 'Unknown') AS product_category,
    round(sum(oi.price), 2) AS total_revenue
from order_items oi
join products p on oi.product_id = p.product_id
join orders o on oi.order_id = o.order_id
where o.order_status not in ('canceled', 'unavailable')
group by p.product_category_name
order by total_revenue desc;


-- Query 5. Rank the top 3 products within each category by revenue.

use olist;

with product_revenue as (
    select
        p.product_id,
        coalesce(p.product_category_name, 'Unknown') as product_category,
        round(sum(oi.price), 2) as total_revenue
    from order_items oi
    join products p on oi.product_id = p.product_id
    join orders o on oi.order_id = o.order_id
    where o.order_status not in ('canceled', 'unavailable')
    group by
        p.product_id,
        p.product_category_name
),
ranked_products AS (
    select
        product_id,
        product_category,
        total_revenue,
        dense_rank() over (
            partition by product_category
            order by total_revenue desc
        ) as rank_in_category
    from product_revenue
)
select
    product_category,
    rank_in_category,
    product_id,
    total_revenue
from ranked_products
where rank_in_category <= 3
order by product_category, rank_in_category;


-- Query 6. Segment customers into spend tiers (Low / Medium / High).

use olist;

with customer_spend as (
    select
        c.customer_unique_id as customer_unique_id,
        round(sum(op.payment_value), 2) as total_payments
    from customers c
    join orders o on c.customer_id = o.customer_id
    join order_payments op on o.order_id = op.order_id
    group by customer_unique_id
    )
select
    customer_unique_id,
    total_payments,
    case
        when total_payments <=2000 then 'Low'
        when total_payments <=4000 then 'Medium'
        else 'High'
    end as spend_tier
from customer_spend
order by total_payments desc;


-- Query 7. How many customers are repeat buyers vs one-time buyers?

use olist;

with customer_orders as (
    select
        c.customer_unique_id,
        count(distinct o.order_id) as order_count
    from customers c
    join orders o on c.customer_id = o.customer_id
    where o.order_status not in ('canceled', 'unavailable')
    group by c.customer_unique_id
),
buyer_segments as (
    select
        customer_unique_id,
        case
            when order_count = 1 then 'One-time buyer'
            else 'Repeat buyer'
        end as buyer_type
    from customer_orders
)
select
    buyer_type,
    count(customer_unique_id) as total_customers,
    round(count(customer_unique_id) * 100.0 / sum(count(customer_unique_id)) over (), 2) as pct_of_total
from buyer_segments
group by buyer_type;


-- Query 8. What percent of total revenue comes from the top category?

use olist;

with category_revenue as (select coalesce(p.product_category_name, 'Unknown') as product_category,
                                 round(sum(price), 2)                         as total_revenue
                          from order_items oi
                                   join products p on p.product_id = oi.product_id
                                   join orders o on oi.order_id = o.order_id
                          where o.order_status not in ('Canceled', 'Unavailable')
                          group by product_category)
select
    product_category,
    total_revenue,
    round(total_revenue * 100 / sum(total_revenue) over (), 2) as pct_total
from category_revenue
order by total_revenue desc
limit 1;
