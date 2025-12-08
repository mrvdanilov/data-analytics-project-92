-- подсчет строк
SELECT COUNT(*) AS customers_count
FROM customers;

-- топ 10 продавцов
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.customer_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

-- продавцы с прибылью ниже среднего
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM sales AS s
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY seller
HAVING
    AVG(s.quantity * p.price)
    < (
        SELECT AVG(s1.quantity * p1.price)
        FROM sales AS s1
        INNER JOIN products AS p1 ON s.product_id = p.product_id
    )
ORDER BY average_income ASC

-- по дням недели
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    (CASE
        WHEN EXTRACT(
            DOW
            FROM s.sale_date
        ) = 1 THEN 'monday'
        WHEN EXTRACT(
            DOW
            FROM s.sale_date
        ) = 2 THEN 'tuesday'
        WHEN EXTRACT(
            DOW
            FROM s.sale_date
        ) = 3 THEN 'wednesday'
        WHEN EXTRACT(
            DOW
            FROM s.sale_date
        ) = 4 THEN 'thursday'
        WHEN EXTRACT(
            DOW
            FROM s.sale_date
        ) = 5 THEN 'friday'
        WHEN EXTRACT(
            DOW
            FROM s.sale_date
        ) = 6 THEN 'saturday'
        WHEN EXTRACT(
            DOW
            FROM s.sale_date
        ) = 0 THEN 'sunday'
    END) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN products AS p ON s1.product_id = p1.product_id
GROUP BY
    e.first_name,
    e.last_name,
    EXTRACT(
        DOW
        FROM s.sale_date
    )
ORDER BY MOD(EXTRACT(
    DOW
    FROM s.sale_date
)::int + 6, 7),
seller

-- группы возрастов
SELECT
    (CASE
        WHEN customers.age <= 25 THEN '16-25'
        WHEN customers.age <= 40 THEN '26-40'
        ELSE '40+'
    END) AS age_category,
    Count(*) AS age_count
FROM public.customers
GROUP BY age_category
ORDER BY age_category

-- покупатели по месяцам
SELECT
    to_char(s.sale_date, 'yyyy-mm') AS selling_month,
    count(DISTINCT s.customer_id) AS total_customers,
    floor(sum(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY to_char(s.sale_date, 'yyyy-mm')
ORDER BY to_char(s.sale_date, 'yyyy-mm') ASC

--первые покупки по акции
WITH first_purchases AS (
    SELECT
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        s.product_id,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.sale_date
        ) AS purchase_rank
    FROM sales AS s
)

SELECT
    fp.sale_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_purchases AS fp
INNER JOIN customers AS c ON fp.customer_id = c.customer_id
INNER JOIN employees AS e ON fp.sales_person_id = e.employee_id
INNER JOIN products AS p ON fp.product_id = p.product_id
WHERE
    fp.purchase_rank = 1
    AND p.price = 0
ORDER BY fp.customer_id;
