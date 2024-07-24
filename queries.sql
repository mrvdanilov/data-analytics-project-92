--top_10_total_income

SELECT
    --use CONCAT for connect first and last name
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
    COUNT(sales.sales_id) AS operations, --use COUNT for quantify operations
    --use SUM for find income and FLOOR for round up to integers
    FLOOR(SUM(sales.quantity * products.price)) AS income
FROM employees
INNER JOIN sales ON employees.employee_id = sales.sales_person_id
INNER JOIN products ON sales.product_id = products.product_id
GROUP BY CONCAT(employees.first_name, ' ', employees.last_name)
ORDER BY income DESC --filtrate income by descending
LIMIT 10; --use limit for find only 10 empolyeers

--lowest_average_income

SELECT
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
    FLOOR(AVG(sales.quantity * products.price)) AS avg_income
FROM sales
INNER JOIN employees
    ON sales.sales_person_id = employees.employee_id
INNER JOIN products
    ON sales.product_id = products.product_id
GROUP BY CONCAT(employees.first_name, ' ', employees.last_name)
HAVING
    FLOOR(AVG(sales.quantity * products.price)) < (
        SELECT FLOOR(AVG(sales.quantity * products.price)) AS avg_income
        FROM sales
        INNER JOIN products ON sales.product_id = products.product_id
    )
ORDER BY FLOOR(AVG(sales.quantity * products.price)) ASC;

--day_of_the_week_income

SELECT
    --find seller with CONCAT
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller,
    --use the LOWER to lowercase
    LOWER(TO_CHAR(sales.sale_date, 'Day')) AS day_of_week,
    --use FLOOR for round up to integers
    FLOOR(SUM(sales.quantity * products.price)) AS income,
    EXTRACT(ISODOW FROM sales.sale_date) AS sale_date1
FROM sales
INNER JOIN employees ON sales.sales_person_id = employees.employee_id
INNER JOIN products ON sales.product_id = products.product_id
GROUP BY seller, day_of_week, sale_date1
ORDER BY sale_date1, seller;

--age_groups

SELECT
    CASE --create categorys
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END
ORDER BY CASE
    WHEN age BETWEEN 16 AND 25 THEN '16-25'
    WHEN age BETWEEN 26 AND 40 THEN '26-40'
    ELSE '40+'
END;

--customers_by_month

SELECT
    --use TO_CHAR for extract year and month
    TO_CHAR(sales.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT sales.customer_id) AS total_customers, --count customers
    --use SUM for find income and TRUNC for round up to integers
    SUM(TRUNC(sales.quantity * products.price)) AS income
FROM sales
INNER JOIN products ON sales.product_id = products.product_id
GROUP BY TO_CHAR(sales.sale_date, 'YYYY-MM')
ORDER BY TO_CHAR(sales.sale_date, 'YYYY-MM') ASC; --prioritize

--special_offer

SELECT
    CONCAT(customers.first_name, ' ', customers.last_name) AS customer,
    MIN(sales.sale_date) AS sale_date, --use MIN for find first buy
    CONCAT(employees.first_name, ' ', employees.last_name) AS seller
FROM sales
INNER JOIN products ON sales.product_id = products.product_id
INNER JOIN customers ON sales.customer_id = customers.customer_id
INNER JOIN employees ON sales.sales_person_id = employees.employee_id
WHERE products.price = 0 --select promotional goods
GROUP BY customers.customer_id, customer, seller
ORDER BY customers.customer_id;
