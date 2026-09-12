use mavenmovies;
show tables;

-- QUESTION 1

select * from customer;
select * from rental;
select c.first_name, c.last_name, 
count(r.rental_id) as total_rentals
from customer c
join rental r
on c.customer_id = r.customer_id
group by c.customer_id, c.first_name, c.last_name
having count(r.rental_id)>(
select avg(rental_count)
from(
select count(rental_id) as rental_count
from rental
group by customer_id
) as avg_table
)
order by total_rentals desc;

-- QUESTION 2

select * from film;
select
    f.title,
    f.rental_rate,
    dense_rank() over (order by f.rental_rate desc) as rental_rate_rank
from film f
order by rental_rate_rank;

-- QUESTION 3

select * from customer;
create view customer_status as 
select first_name, last_name, email, active 
from  customer;
select * from customer_status;

-- QUESTION 4

select * from customer;
select * from payment;
select
    c.customer_id,
    c.first_name,
    c.last_name,
    sum(p.amount) as total_payment
from customer c
join payment p
    on c.customer_id = p.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_payment desc
limit 10;

-- QUESTION 5

select * from customer;
select * from payment;
with customer_spending as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        sum(p.amount) as total_spent
    from customer c
    join payment p
        on c.customer_id = p.customer_id
    group by c.customer_id, c.first_name, c.last_name
),
ranked_spending as (
    select
        cs.*,
        percent_rank() over (order by total_spent desc) as pct_rank
    from customer_spending cs
)
select
    customer_id,
    first_name,
    last_name,
    total_spent
from ranked_spending
where pct_rank <= 0.20
order by total_spent desc;

-- QUESTION 6

select * from actor;
select * from film_actor;
with actor_movie_counts as (
    select
        a.actor_id,
        a.first_name,
        a.last_name,
        count(fa.film_id) as movie_count
    from actor a
    join film_actor fa
        on a.actor_id = fa.actor_id
    group by a.actor_id, a.first_name, a.last_name
)
select
    actor_id,
    first_name,
    last_name,
    movie_count,
    dense_rank() over (order by movie_count desc) as movie_count_rank
from actor_movie_counts
order by movie_count_rank;

-- QUESTION 7

select * from film;
select * from film_category;
create view film_category_pricing as
select
    f.title,
    cat.name as category,
    f.rental_rate,
    f.replacement_cost
from film f
join film_category fc
    on f.film_id = fc.film_id
join category cat
    on fc.category_id = cat.category_id;
select * from film_category_pricing;

-- QUESTION 8

select * from film;
select * from inventory;
delimiter //
create procedure get_top_20_rented_movies()
begin
    select
        f.film_id,
        f.title,
        count(r.rental_id) as rental_count
    from film f
    join inventory i
        on f.film_id = i.film_id
    join rental r
        on i.inventory_id = r.inventory_id
    group by f.film_id, f.title
    order by rental_count desc
    limit 20;
end //

delimiter ;
call get_top_20_rented_movies();

-- QUESTION 9

select * from film;
delimiter //
create procedure get_movies_by_rating(in p_rating varchar(10))
begin
    select
        f.film_id,
        f.title,
        f.rating,
        f.rental_rate
    from film f
    where f.rating = p_rating
    order by f.title;
    end //

delimiter ;
    call get_movies_by_rating('PG');
    
-- QUESTION 10

select * from film;
select * from film_category;
select * from inventory;
select * from rental;
with film_rentals as (
    select
        cat.name as category,
        f.film_id,
        f.title,
        count(r.rental_id) as rental_count
    from film f
    join film_category fc
        on f.film_id = fc.film_id
    join category cat
        on fc.category_id = cat.category_id
    join inventory i
        on f.film_id = i.film_id
    join rental r
        on i.inventory_id = r.inventory_id
    group by cat.name, f.film_id, f.title
),
ranked_films as (
    select
        category,
        title,
        rental_count,
        rank() over (partition by category order by rental_count desc) as category_rank
    from film_rentals
)
select
    category,
    title,
    rental_count,
    category_rank
from ranked_films
where category_rank <= 3
order by category, category_rank;