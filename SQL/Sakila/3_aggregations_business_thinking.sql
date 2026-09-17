# Module 3
-- Count the total number of customers in the database.
use sakila;
select count(*)
from customer;

-- Find the total, average, minimum, and maximum payment amount. Round to 2 decimals.
select
	round(sum(amount),2) as Total,
    round(avg(amount),2) as Average,
    round(min(amount),2) as Min,
    round(max(amount),2) as Max
from
	payment;
    
-- How many distinct ratings exist in the film table?
select
	count(distinct(rating))
from film;

select
	distinct(rating)
from film;

-- How many rentals have been returned vs not returned? Use COUNT(*) and COUNT(return_date).
select
	count(*) as all_rows,
	count(return_date) as returned,
    count(*)-count(return_date) as not_returned
from rental;

-- What is the average film length across the whole catalog, rounded to the nearest whole number?
select
	round(avg(length),0) as ave_length
from film;

-- Count the number of films for each rating.
select
	rating,
	count(*)
from film
group by rating;

-- Show the average rental rate for each rating, rounded to 2 decimals.
select
	rating,
    round(avg(rental_rate),2) as rental_rate
from film
group by rating;

-- Count the number of payments made each month (format payment_date as YYYY-MM).
select
	date_format(payment_date, '%Y-%m') as payment_month,
    count(*) as payment_count
from payment
group by date_format(payment_date, '%Y-%m')
order by payment_month;

-- For each rental_duration value, show the count of films and their average rental rate.
select
	count(*) as film_count,
    avg(rental_rate) as ave_rental_rate
from film
group by rental_duration
order by rental_duration;

SELECT
    rental_duration,
    COUNT(*) AS film_count,
    AVG(rental_rate) AS ave_rental_rate
FROM film
GROUP BY rental_duration
ORDER BY rental_duration;

-- Show total revenue per month, sorted from highest revenue to lowest.
select
	date_format(payment_date,'%Y-%m') as payment_month,
	sum(amount) as total_revenue
from payment
group by date_format(payment_date,'%Y-%m')
order by total_revenue desc;

-- For each rating, show the shortest and longest film length.
select
	rating,
	max(length) as longest_film_length,
    min(length) as shortest_film_length
from film
group by rating;

-- Show only the ratings that have more than 200 films.
select
	rating,
    count(*)
from film
group by rating
having count(*)>200;

-- Show rental_duration values where the average rental rate is above $2.95.
select
	rental_duration,
    round(avg(rental_rate),2) as avg_rental_rate
from film
group by rental_duration
having avg(rental_rate)>2.95;

-- Find months where total revenue exceeded $20,000. Show month and revenue.
select
	date_format(payment_date,'%Y-%m') as payment_month,
	sum(amount) as total_revenue
from payment
group by date_format(payment_date,'%Y-%m')
having sum(amount)>20000;

-- Among films longer than 100 minutes, show ratings that have more than 100 such films. Display rating, count, and average rate.
select
	rating,
    count(*) as film_count,
    round(avg(rental_rate),2) as avg_rate
from film
where length >100
group by rating
having count(*)>100;

-- Label each film as 'Cheap' (rate < $2) or 'Expensive' ($2+). Show title, rental_rate, and the label.
select
	title,
    rental_rate,
    case
		when rental_rate<2 then 'Cheap'
        when rental_rate>=2 then 'Expensive'
	end as label
from film;

-- Categorize films by length into Short/Medium/Long and count how many films fall in each category (one row, three columns).
# WRONG QUERY
select
	title,
    case
		when length < 60 then 'Short'
        when length < 120 then 'Medium'
        else 'Long'
    end as length,
    count(*) as film_count
from film;

# CORRECT QUERY
SELECT
    COUNT(CASE WHEN length < 60 THEN 1 END) AS short_films,
    COUNT(CASE WHEN length >= 60 AND length < 120 THEN 1 END) AS medium_films,
    COUNT(CASE WHEN length >= 120 THEN 1 END) AS long_films
FROM 
    film;
    
-- For each rating, count how many films are 'Long' (>120 min) vs 'Not Long'. Show rating and both counts.
select
	rating,
    count(case when length > 120 then 1 end) as 'Long',
    count(case when length <=120 then 1 end) as 'Not Long'
from film
group by rating;

-- Group films into price tiers (Budget/Standard/Premium) and show per tier: count, average length, and total replacement cost. Sort by tier.
select
	count(*) as film_count,
    round(avg(length),2) as avg_length,
    sum(replacement_cost) as tot_replacement_cost,
    case 
		when rental_rate <1 then 'budget'
        when rental_rate>=1 and rental_rate<1.5 then 'standard'
        else 'premium'
	end as price_tier
from film
group by price_tier
order by price_tier;

-- Build a monthly revenue report: for each month show payment count, total revenue, and average payment. Only include months with more than 100 payments. Sort by month.
select
	date_format(payment_date,'%Y-%m') as payment_month,
    sum(amount) as total_rev,
    round(avg(amount),2) as avg_amount,
    count(amount) as payment_count
from payment
group by date_format(payment_date,'%Y-%m')
having count(amount)>100
order by payment_month;

-- For each rating, show: total films, count of Short films (<60 min), count of Long films (>120 min), and average rental rate. Sort by total films descending.
select
	rating,
	count(*) as film_count,
    count(case when length < 60 then 1 end) as 'Short',
	count(case when length > 120 then 1 end) as 'Long',
    round(avg(rental_rate),2) as avg_rental
from film
group by rating
order by film_count desc;

-- Create a film catalog summary: group films by a length category (Short/Medium/Long), and for each show film count, average rate, min rate, max rate. Only keep categories with more than 100 films.
select
	case
		when length < 60 then 'Short'
        when length < 120 then 'Medium'
        else 'Long'
	end as length_category,
    count(*) as film_count,
	round(avg(rental_rate), 2) as avg_rental,
    min(rental_rate) as min_rate,
    max(rental_rate) as max_rate
from film
group by length_category
having count(*) >100;
    



