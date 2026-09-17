# Section A — SELECT & LIMIT (Warm-Up)
-- Show all columns from the actor table. How many actors are there?
select count(*) as total_actors
from actor;

-- List the first 10 customers (customer_id, first_name, last_name only).
select customer_id, first_name, last_name
from customer
limit 10;

-- Show the title, description, and rental_rate of the first 20 films, sorted by title A-Z.
select title, description, rental_rate
from film
order by title;

-- Display the top 5 most expensive films to rent (rental_rate descending).
select title, rental_rate
from film
order by rental_rate desc
limit 5;

-- What are all the unique film ratings in the database? (G, PG, etc.)
select distinct rating
from film;

# Section B — WHERE Filtering
-- Find all films with a rental duration of exactly 7 days.
select *
from film
where rental_duration = 7;

-- List all films that cost $4.99 to rent.
select *
from film
where rental_rate = 4.99;

-- Find all films that are rated 'G' or 'PG'. Show title and rating.
select title, rating
from film
where rating in ('G', 'PG');

select title, rating
from film
where rating = 'G' or rating = 'PG';

-- List all films between 60 and 90 minutes long. Show title and length.
select title, length
from film
where length between 60 and 90;

-- Find all films whose title starts with the letter 'S'.
select *
from film
where title like 'S%';

-- Find all films with 'dragon' anywhere in the title (case-insensitive).
select *
from film
where title like '%dragon%';

-- List all active customers (active = 1). Show first_name, last_name, and email.
select first_name, last_name, email
from customer
where active = 1;

-- Find all films rated 'PG-13' with a rental rate greater than $3.00. Show title, rating, and rental_rate.
select title, rating, rental_rate
from film
where rating = 'PG-13' and rental_rate >3;

# Section C — ORDER BY & DISTINCT
-- List all unique rental rates charged for films.
select distinct rental_rate
from film;

-- Show the 10 longest films in the database (title and length).
select title, length
from film
order by length desc
limit 10;

-- List all films sorted by rental_rate descending, then by title ascending. Show title and rental_rate.
select title, rental_rate
from film
order by rental_rate desc, title asc;

-- Find all distinct ratings for films longer than 120 minutes.
select distinct rating
from film
where length > 120;

-- Find all films that are either rated 'G' AND shorter than 60 minutes, OR rated 'NC-17' AND longer than 150 minutes. Show title, rating, and length.
select title, rating, length
from film
where (rating = 'G' and length < 60) 
	or (rating = 'NC-17' and length > 150);
    
-- List all customers whose last name starts with 'S' and who are currently active. Show full name and email, sorted by last_name.
select last_name, first_name, email
from customer
where last_name like 'S%' and active = 1
order by last_name;

-- How many distinct replacement costs are there for films rated 'PG'? (Just list the values — counting comes in Module 3.)
select distinct replacement_cost
from film
where rating = 'PG'


