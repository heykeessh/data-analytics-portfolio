# Module 4 - Joins
	
-- Join film and language. Show film title and language name.
use sakila;

select 
	f.title,
    l.name as language_name
from film f
join language l
	on f.language_id=l.language_id;
    
-- Join customer and address. Show each customer's full name and address line.
# Option 1:
select
	c.first_name,
    c.last_name,
    a.address
from customer c
join address a
	on c.address_id = a.address_id;

# Option 2:
select
	concat_ws(' ', c.first_name, c.last_name) as full_name,
    a.address
from customer c
join address a
	on c.address_id = a.address_id;
    
-- Join payment and customer. Show all payments above $8 with the customer's name.
select
	concat_ws(' ',c.first_name, c.last_name) as full_name,
    p.amount
from
	customer c
join payment p on
	c.customer_id = p.customer_id
where amount > 8;

-- Join city and country. List all cities with their country name, sorted by country.
select
	ci.city as City,
    co.country as Country
from city ci
join country co on
	ci.country_id = co.country_id
order by country;

-- Join film and film_category and category. Show film title and its category name.
select
	f.title as Film_Title,
    c.name as Category_Name
from film f
join film_category fc on
	f.film_id = fc.film_id
join category c on
	c.category_id = fc.category_id;
    
-- List all customers and their rental count, including customers with zero rentals.
select
	c.customer_id,
	concat_ws(' ', c.first_name, c.last_name) as full_name,
    count(r.rental_id) as rental_count
from customer c
left join rental r on
	c.customer_id = r.customer_id
group by 
	c.customer_id,
    c.first_name,
    c.last_name
order by rental_count;

-- Find all films that have never been placed in inventory.
select
	f.title
from film f
left join inventory i on
	f.film_id = i.film_id
where i.film_id is null;

-- List every actor and the number of films they appear in, including actors with zero films (if any).
select
	a.actor_id,
	concat_ws(' ', a.first_name, a.last_name) as actor_name,
    count(f.film_id) as film_count
from actor a
left join film_actor fa on fa.actor_id = a.actor_id
left join film f on f.film_id = fa.film_id
group by
	a.actor_id,
    a.first_name,
    a.last_name;

-- Show all addresses and the customer name living there, including addresses with no customer.
select
	concat_ws(' ', c.first_name, c.last_name) as customer_name,
    a.address
from address a
left join customer c 
	on c.address_id = a.address_id;

select
	concat_ws(' ', c.first_name, c.last_name) as customer_name,
    a.address
from address a
left join customer c 
	on c.address_id = a.address_id
where c.customer_id is null;

-- Find all categories that have no films assigned (if any). Use LEFT JOIN + IS NULL.
select
	c.category_id,
	c.name as category_name,
    f.title
from category c
left join film_category fc on c.category_id = fc.category_id
left join film f on fc.film_id = f.film_id
where fc.category_id is null;

-- Show which films customer 'MARY SMITH' rented. Join customer, rental, inventory, film.
select
	concat_ws(' ', c.first_name, c.last_name) as customer_name,
    f.title,
    r.rental_date
from
	customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where 
	c.first_name = 'Mary' and
    c.last_name = 'Smith';
    
-- List each customer's full name with their city and country. Join customer, address, city, country.
select
	concat_ws(' ', c.first_name, c.last_name) as customer_name,
    ct.city,
    cy.country
from customer c 
join address a on c.address_id = a.address_id
join city ct on a.city_id = ct.city_id
join country cy on ct.country_id = cy.country_id
order by customer_name;

-- Show total revenue per film category. Join payment, rental, inventory, film, film_category, category.
select
	c.name as category_name,
	sum(amount) as total_revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
group by c.name;

-- Find the top 5 most-rented films. Join rental, inventory, film and count rentals per film.
select
	f.film_id,
	f.title,
    count(rental_id) as rental_count
from rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
group by 
	f.film_id,
    f.title
order by rental_count desc
limit 5;

-- List each actor and the number of distinct films they appear in. Join actor, film_actor, film. Show top 10.
select
	f.film_id,
    concat_ws(' ', a.first_name, a.last_name) as actor_name,
    f.title
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join film f on fa.film_id = f.film_id
group by 
	f.film_id,
	a.first_name,
    a.last_name;
    
select
    a.actor_id,
    concat_ws(' ', a.first_name, a.last_name) as actor_name,
    count(distinct f.film_id) as film_count
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join film f on fa.film_id = f.film_id
group by 
    a.actor_id,
    a.first_name,
    a.last_name
order by 
    film_count desc
limit 10;

-- 	Top 10 customers by total amount spent. Show name, payment count, total spent.
select
	c.customer_id,
	concat_ws(' ', c.first_name, c.last_name) as customer_name,
    count(p.payment_id) as payment_count,
    sum(p.amount) as total_spent
from customer c
join payment p on c.customer_id = p.customer_id
group by 
	c.customer_id,
	c.first_name,
    c.last_name
order by total_spent desc
limit 10;

-- For each store, show the number of customers assigned to it. Join store and customer.
select
	s.store_id,
    count(customer_id) as customer_count
from store s
left join customer c on s.store_id = c.store_id
group by
	s.store_id;

-- Show the number of films per language, including languages with zero films.
select
	l.name as language_name,
    count(f.film_id) as film_count
from language l
left join film f on l.language_id = f.language_id
group by 
	l.language_id,
    l.name;
    
-- For each country, show the total number of customers. Join customer, address, city, country. Sort by customer count descending.
select
    cy.country,
    count(c.customer_id) as customer_count
from country cy
left join city ct on cy.country_id = ct.country_id
left join address a on ct.city_id = a.city_id
left join customer c on a.address_id = c.address_id
group by
    cy.country_id,
    cy.country
order by 
    customer_count desc;

-- Show monthly revenue: join payment to nothing extra, but display month and total revenue, only for months above $20,000.
select
	date_format(p.payment_date, '%Y-%m') as payment_month,
    sum(p.amount) as total_revenue
from payment p
group by 
	payment_month
having 
	total_revenue > 20000;
    
-- A query joining customer, rental, and payment shows each customer with thousands of rentals. Explain the fan-out and rewrite it so rental counts are correct.
SELECT *
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON c.customer_id = p.customer_id;

select
    c.customer_id,
    concat_ws(' ', c.first_name, c.last_name) as customer_name,
    count(distinct r.rental_id) as rental_count,
    sum(p.amount) as total_spent
from customer c
left join rental r on c.customer_id = r.customer_id
left join payment p on r.rental_id = p.rental_id
group by 
    c.customer_id,
    c.first_name,
    c.last_name;
    
with customer_rentals as (
    select 
        customer_id, 
        count(rental_id) as rental_count
    from rental
    group by customer_id
),
customer_payments as (
    select 
        customer_id, 
        sum(amount) as total_spent
    from payment
    group by customer_id
)
select 
    c.customer_id,
    concat_ws(' ', c.first_name, c.last_name) as customer_name,
    coalesce(cr.rental_count, 0) as rental_count,
    coalesce(cp.total_spent, 0.00) as total_spent
from customer c
left join customer_rentals cr on c.customer_id = cr.customer_id
left join customer_payments cp on c.customer_id = cp.customer_id;

-- A LEFT JOIN of film and inventory with WHERE i.store_id = 1 is dropping films with no inventory. Explain why and fix it using the ON clause.
use sakila;

select 
	distinct f.title as film_title
from film f
left join inventory i 
	on f.film_id = i.film_id
	and i.store_id = 1;
    
-- A query uses COUNT(*) after a LEFT JOIN and reports 1 for customers with no rentals instead of 0. Identify and fix the mistake.
select
	c.customer_id,
    concat_ws(' ', c.first_name, c.last_name) as customer_name,
    count(rental_id) as rental_count
from customer c
left join rental r on r.customer_id = c.customer_id
group by
	c.customer_id,
    c.first_name,
    c.last_name
order by rental_count desc;

-- A 3-table join is missing one customer who definitely exists. The joins are all INNER. Explain how an INNER JOIN could hide that customer and how a LEFT JOIN would reveal it.
select
	s.store_id as store_id,
	concat_ws(' ', c.first_name, c.last_name) as customer_name
from store s
left join customer c on s.store_id = c.store_id
group by
	s.store_id,
    c.first_name,
    c.last_name;
    
select
	s.store_id as store_id,
	concat_ws(' ', c.first_name, c.last_name) as customer_name
from store s
join customer c on s.store_id = c.store_id
group by
	s.store_id,
    c.first_name,
    c.last_name;

SELECT 
    c.customer_id,
    concat_ws(' ', c.first_name, c.last_name) as customer_name,
    a.address,
    ct.city
FROM customer c
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city ct ON a.city_id = ct.city_id;
    
    

	

