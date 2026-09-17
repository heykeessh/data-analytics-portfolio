# Module 2 - Data Retrieval & Filtering
	
-- List all films with title aliased as 'Movie Title' and rental_rate aliased as 'Daily Rate'. Limit to 20 rows.
use sakila;

select 
	title as 'Movie Title',
    rental_rate as 'Daily Rate'
from film
limit 20;

-- Compute the total rental value per film: rental_rate * rental_duration. Alias as total_value. Sort by total_value descending. Show top 10.
select
	title,
    rental_rate * rental_duration as total_value
from film
order by total_value desc
limit 10;

-- Show all unique rating and rental_duration combinations. How many combinations exist?
select 
	distinct rating,
    rental_duration
from film
order by rating;

-- Display each film's title, replacement_cost, and a column called 'markup' which is replacement_cost minus (rental_rate * 10). Show top 15 by markup descending.
select
	title,
    replacement_cost,
    replacement_cost - (rental_rate * 10) as 'Markup'
from film
order by Markup desc
limit 15;

-- Find all films with a replacement_cost greater than $20. Show title and replacement_cost.
select
	title,
    replacement_cost
from film
where replacement_cost > 20;

-- List all films rated G, PG, or PG-13 using the IN operator.
select
	title,
    rating
from film
where rating in ('G', 'PG', 'PG-13');

-- Find all films with a rental duration between 3 and 5 days (inclusive).
select
	title,
    rental_duration
from film
where 
	rental_duration between 3 and 5;
    
-- Find all films that do NOT have a rental rate of $0.99 or $2.99. Use NOT IN.
select	
	title,
    rental_rate
from	
	film
where
	rental_rate not in (0.99, 2.99);
    
-- List all customers who are NOT active (active = 0). Show full name and email.
select
	concat_ws(' ',c.first_name,c.last_name) as full_name,
    email
from customer c
where active =0;

-- Find all payments where the amount is between $7.00 and $11.99. How many are there?
select
	customer_id,
    amount
from payment
where amount between 7 and 11.99;

-- Find all films whose title starts with 'IRON'.
select	
	title 
from
	film
where title like 'Iron%';

-- Find all films whose title ends with 'STORY'.
select
	title
from film
where title like '%Story';

-- List all customers whose first name is exactly 4 characters long.
select
	first_name
from customer
where first_name like '____';
    
-- Find all films whose title contains the word 'MOVIE'. Show title and rating.
select
	title,
    rating
from film
where title like '%Movie%';

-- Find all customers whose email domain is 'sakilacustomer.org'. Show full name and email.
select
	concat_ws(' ', customer.first_name, customer.last_name) as full_name,
    email
from customer
where
	email like '%@sakilacustomer.org';

-- Find all films whose title starts with a vowel (A, E, I, O, or U). Show title. Hint: use multiple LIKE conditions.
select	
	title
from film
where
	title like 'A%' or
	title like 'E%' or
    title like 'I%' or
    title like 'O%' or
    title like 'U%'
;

-- List all rentals from June 2005 (Year 2005, Month 6). Show rental_id and rental_date.
select
	rental_id,
    rental_date
from rental
where 
	year(rental_date) = 2005 and
    month(rental_date) = 6;
    
-- Find all payments made on or after September 1, 2005.
select
	payment_id,
	payment_date
from
	payment
where
	payment_date >= '2005-09-01';

-- Show all rentals with their formatted rental_date as 'YYYY-MM' (e.g., '2005-07'). Alias as rental_month. Limit to 20.
select
	rental_id,
    date_format(rental_date, '%Y-%m') as rental_month
from rental
limit 20;

-- Find all rentals where the item was kept for exactly 3 days.
select
	rental_id,
	datediff(return_date,rental_date) as days_rented
from
	rental
where
	datediff(return_date,rental_date)=3;
    
-- List all Monday rentals (DAYOFWEEK = 2). Show rental_id, rental_date, and day_of_week.
select
	rental_id,
    rental_date,
    dayofweek(rental_date) as day_of_week
from
	rental
where 
	dayofweek(rental_date)=2;
    
-- Find all payments between July 1 and July 31, 2005. Use the safer >= / < pattern (not BETWEEN).
select
	payment_id,
    payment_date
from payment
where 
	payment_date>= '2005-07-01' and
    payment_date<= '2005-07-31';
    
-- Find all films that are rated 'PG' or 'PG-13', have a rental_rate above $2.99, and whose title contains the word 'THE'. Show title, rating, and rental_rate.
select
	title,
	rating,
	rental_rate
from film
where 
    (rating = 'PG' or rating = 'PG-13') 
    and rental_rate >=2.99 
    and title like '%The%';

-- Find the top 5 rentals with the longest rental period (most days between rental_date and return_date). Show rental_id, days_rented, and the rental_date formatted as 'Month YYYY'. Only include rentals that were returned. 
SELECT
    rental_id,
    DATEDIFF(return_date, rental_date) AS days_rented,
    DATE_FORMAT(rental_date, '%M %Y') AS rental_date
FROM rental
WHERE return_date IS NOT NULL
ORDER BY days_rented DESC
LIMIT 5;

-- List all films whose title starts with 'A' and are either rated 'G' with length < 80 minutes, or rated 'PG-13' with rental_rate = $2.99. Show title, rating, length, and rental_rate.
select 
	title,
    rating,
    length,
    rental_rate
from film
where title like 'A%' 
    and (
	(rating ='G' and length <80)
    or (rating ='PG-13' and rental_rate=2.99)
    );

    
    






