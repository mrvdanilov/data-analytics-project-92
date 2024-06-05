--  1
/*
Используем агрегирующую функцию COUNT() для расчета
числа покупателей. Дополнительно прописал DISTINCT
на случай, если в справочнике будут дублирующие значения,
но результат для COUNT() и COUNT(DISTINCT) в данном случае
не отличается
*/

SELECT COUNT(DISTINCT customer_id) AS "customers_count"
FROM customers

--  2
/*
Джоиним два необходимых справочника employees и products по ключам
employee_id и product_id соответственно на "таблицу фактов" sales, после чего
создаем три поля: конкатинированное поле с именем и фамилией, число операций
и сумму выручки (округляем значения до целых через FLOOR()) как произведение
цены конкретного продукта на его количество. Группируем информацию по
продавцам через GROUP BY, отображаем по убыванию выручки.
*/

SELECT CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.*) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY seller
ORDER BY income DESC

-- 3
/*
Аналогично предыдущему запросу делаем джоины, но на этот раз делаем агрегацию
по средней выручке продавца. Пишем "условие" того, что средняя выручка
конкретного продавца меньше средней выручки по всем продавцам через подзапрос
в HAVING, так как "работаем" с агрегированной функцией AVG().
Округляем значения до целых через FLOOR().
*/

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
ORDER BY average_income ASC

--4
/*
Аналогично собираем таблицу из справочников и таблицы-факта, конвертируем дату в
имена дней недели, группируем по имени продавца и дню недели, сортируем
по тем же полям в прямом порядке.
UPD: сортировка была некорректна, т.к. приводила к сортировке
в алфавитном порядке. Изменено на to_char(s.sale_date, 'ID')
- конвертация даты в дни недели в ISO-формате.
*/

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
ORDER BY to_char(s.sale_date, 'ID'), seller

--5
/*
Через CASE прописываем условие для дифференциации покупателей по возрастным
группам (с учетом того, что BETWEEN включает в себя оба "края"),
считаем количество строк при группироке по возрастной
группе.
*/

SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category

--6
/*
Через джоины собираем таблицу из таблицы фактов и двух справочников,
а после SELECT'ом выбираем три поля: 1) дату в формате YYYY-MM,
2) число уникальных покупателей через COUNT(DISTINCT),
3) выручка как цена за единицу товара на количество проданных штук
с округлением до целых.
*/

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
ORDER BY selling_month ASC

--7
/*
Оконными функциями ищем "первые вхождения" промоционных товаров и соотв. дату.
Обертка в CTE для удобства написания запроса :)
*/

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
