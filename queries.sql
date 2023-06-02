-- Посчитать количество покупателей

SELECT count(*) AS customers_count FROM customers;

-- Посчитать записи и подписать категории возврастов

SELECT age_category, COUNT(*)
FROM (
    SELECT
        CASE
            WHEN age <= 15 THEN '10-15'
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category,
        age
    FROM customers
) t
GROUP BY age_category
ORDER BY age_category

-- топ 10 продавцов по продажам

SELECT
   CONCAT(e.first_name, ' ', e.last_name) AS name,
   COUNT(*) as operations,
   SUM(p.price * s.quantity) AS income
FROM
   public.sales AS s
   JOIN
      public.products AS p
      on s.product_id = p.product_id
   JOIN
      public.employees AS e
      ON s.sales_person_id = e.employee_id
GROUP BY
   e.first_name,
   e.last_name
ORDER BY
   income DESC LIMIT 10;

-- Продавцы, чей средний доход за сделку меньше среднего дохода за сделку по всем продовцам

WITH avg_income_per_sale AS (
   SELECT ROUND(AVG(p.price * s.quantity)) AS average_income_per_sale
   FROM public.sales AS s
   JOIN public.products AS p
   ON s.product_id = p.product_id
)
SELECT
   CONCAT(e.first_name, ' ', e.last_name) AS name,
   ROUND(AVG(p.price * s.quantity)) AS average_income_per_sale
FROM
   public.sales AS s
   JOIN public.products AS p
   ON s.product_id = p.product_id
   JOIN public.employees AS e
   ON s.sales_person_id = e.employee_id
GROUP BY e.first_name, e.last_name
HAVING AVG(p.price * s.quantity) < (SELECT average_income_per_sale FROM avg_income_per_sale)
ORDER BY average_income_per_sale ASC;

-- Продажи отдельных продавцов по дням недели

SELECT
   CONCAT(e.first_name, ' ', e.last_name) AS name,
   to_char(s.sale_date, 'day') AS weekday,
   ROUND(SUM(s.quantity * p.price)) AS income
from public.sales AS s
join employees AS e ON s.sales_person_id = e.employee_id
JOIN products AS p ON s.product_id = p.product_id
GROUP BY CONCAT(e.first_name, ' ', e.last_name), weekday, to_char(s.sale_date, 'ID')
ORDER BY to_char(s.sale_date, 'ID'), CONCAT(e.first_name, ' ', e.last_name)

-- Количество покупателей по месяцам и принесенная выручка

SELECT
   to_char(s.sale_date, 'YYYY-MM') AS date,
   COUNT(DISTINCT s.customer_id) AS total_customers,
   SUM(s.quantity * p.price) AS income
FROM
   public.sales AS s
   JOIN
      public.products AS p
      ON s.product_id = p.product_id
GROUP BY
   date
ORDER BY
   date ASC;

-- Покупатели, первая покупка которых пришлась на акционный товар

SELECT DISTINCT
   ON(s.customer_id) CONCAT(c.first_name, ' ', c.last_name) AS customer,
   s.sale_date,
   CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM
   public.sales AS s
   JOIN
      public.customers AS c
      ON s.customer_id = c.customer_id
   JOIN
      public.products AS p
      ON s.product_id = p.product_id
   JOIN
      public.employees AS e
      ON s.sales_person_id = e.employee_id
WHERE
   p.price = 0
ORDER BY
   s.customer_id,
   sale_date
