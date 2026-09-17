-- Which films generate the most rental activity?

use sakila;
select 
	f.title,
    count(f.film_id) as rental_count
from film f
join inventory i on i.film_id = f.film_id
join rental r on i.inventory_id = r.inventory_id
group by
	f.title,
	f.film_id
order by rental_count desc;
    
-- Which customers contribute the most revenue?

select
	c.customer_id,
	concat_ws(' ', c.first_name, c.last_name) as customer_name,
    sum(p.amount) as total_revenue
from customer c
join payment p on c.customer_id = p.customer_id
group by
	c.customer_id,
	c.first_name,
    c.last_name
order by total_revenue desc;

-- Which film categories have the highest rental demand?
select 
	c.name,
    count(r.rental_id) as rental_count
from category c
join film_category fc on c.category_id = fc.category_id
join film f on fc.film_id = f.film_id
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by 
	c.category_id,
    c.name
order by rental_count desc;	

-- Which stores generate the most rental revenue?

select
    i.store_id as store,
    sum(p.amount) as total_revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
group by i.store_id
order by total_revenue desc;

-- What are the monthly rental and revenue trends?
select 
    date_format(r.rental_date, '%Y-%m') as `year_month`,
    count(r.rental_id) as total_rentals,
    coalesce(sum(p.amount), 0) as total_revenue
from rental r
left join payment p on r.rental_id = p.rental_id
group by 
    date_format(r.rental_date, '%Y-%m')
order by 
    `year_month` asc;

-- Which customers have the highest rental frequency?
select
	c.customer_id,
	concat_ws(' ', c.first_name, c.last_name) as customer_name,
    count(r.rental_id) as rental_count
from customer c
join rental r on c.customer_id = r.customer_id
group by
	c.customer_id
order by rental_count desc;

-- Which films have low rental activity?
select 
	f.film_id,
    f.title,
    count(r.rental_id) as rental_count
from film f
left join inventory i on i.film_id = f.film_id
join rental r on i.inventory_id = r.inventory_id
group by
	f.film_id,
    f.title
order by rental_count asc;