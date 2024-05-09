select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from public.sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by 1
order by income desc
limit 10;

with a as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        avg(s.quantity * p.price) as income
    from public.sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    group by 1
),

b as (select avg(income) as avg_total from a
),

c as (
    select
        seller,
        avg(income) as avg_sale
    from a group by 1
)

select
    seller,
    floor(avg_sale) as average_income
from c
cross join b
where avg_sale < avg_total
order by average_income asc;

select
    concat(e.first_name, ' ', e.last_name) as seller,
    to_char(sale_date, 'day') as day_of_week,
    floor(sum(s.quantity * p.price)) as income
from public.sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by 1, 2
order by extract(isodow from max(s.sale_date)), 1;

with a as (
    select
        case
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            else '40+'
        end as age_category
    from customers
)

select
    age_category,
    count(*) as age_count
from a
group by 1
order by 1;

select
    to_char(sale_date, 'YYYY-MM') as selling_month,
    count(distinct customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from public.sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by 1
order by 1;

select distinct on (c.customer_id)
    s.sale_date,
    concat(c.first_name, ' ', c.last_name) as customer,
    concat(e.first_name, ' ', e.last_name) as seller
from
    sales as s
inner join
    customers as c
    on s.customer_id = c.customer_id
inner join
    employees as e
    on s.sales_person_id = e.employee_id
inner join
    products as p
    on s.product_id = p.product_id
where p.price = 0
order by c.customer_id, s.sale_date;
