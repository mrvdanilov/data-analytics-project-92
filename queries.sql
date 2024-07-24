SELECT COUNT(DISTINCT customer_id) AS "customers_count"
FROM customers;

WITH sellers AS (
    SELECT
        e.employee_id AS seller_id,
        (e.first_name || ' ' || e.last_name) AS seller
    FROM employees AS e
)
SELECT
    sellers.seller,
    COUNT(*) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sellers
INNER JOIN sales AS s ON sellers.seller_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY 1 ORDER BY 3 DESC
LIMIT 10;

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY seller
HAVING
    FLOOR(AVG(p.price * s.quantity)) < (
        SELECT FLOOR(AVG(p.price * s.quantity))
        FROM sales AS s
        LEFT JOIN products AS p
            ON s.product_id = p.product_id
    )
ORDER BY average_income ASC;

SELECT
	CONCAT(e.first_name,' ', e.last_name) AS seller,
	to_char(s.sale_date, 'day') AS day_of_week,
	FLOOR(sum(p.price * s.quantity)) AS income
FROM sales s
	LEFT JOIN employees e
ON e.employee_id = s.sales_person_id 
	LEFT JOIN products p
ON s.product_id = p.product_id
GROUP BY seller, day_of_week, to_char(s.sale_date, 'ID')
ORDER BY to_char(s.sale_date, 'ID'), seller;

SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
LEFT JOIN customers AS c
    ON s.customer_id = c.customer_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;

WITH initial_table AS (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        FIRST_VALUE(s.sale_date)
            OVER (PARTITION BY c.customer_id ORDER BY s.sale_date)
        AS sale_date,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        FIRST_VALUE(p.price)
            OVER (
                PARTITION BY c.customer_id ORDER BY s.sale_date, c.customer_id
            )
        AS first_val_disc
    FROM customers AS c
    LEFT JOIN sales AS s
        ON c.customer_id = s.customer_id
    LEFT JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
),
first_val_disc_table AS (
    SELECT DISTINCT ON (customer)
        customer,
        sale_date,
        seller
    FROM initial_table
    WHERE first_val_disc = 0
)
SELECT * FROM first_val_disc_table
;
