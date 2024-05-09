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

c as (select
    seller,
    avg(income) as avg_sale
from a group by 1)

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
    COUNT(*) as age_count
from a
group by 1
order by 1;

select
    TO_CHAR(sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from public.sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by 1
order by 1;

SELECT DISTINCT ON (c.customer_id)
    s.sale_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM
    sales AS s
INNER JOIN
    customers AS c
    ON s.customer_id = c.customer_id
INNER JOIN
    employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
WHERE p.price = 0
ORDER BY c.customer_id, s.sale_date;
