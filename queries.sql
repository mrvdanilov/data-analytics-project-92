-- Выбераем счет по полколонке ОК
--customer_id с указанием псевдонима колонки
--как customers_count из таблицы customers
SELECT COUNT(customer_id) AS customers_count
FROM customers;

-- 5 задание в проекте OK
--1.Подготовьте в файл top_10_total_income.csv 
--отчет с продавцами у которых наибольшая выручка
-- Выбираем поля
-- Выбираем first_name и lASt_name "склеевая" их с помощью
-- Создаем новую колонку сумарная выручка продавца за весь 
--период умножая количество продаж на сумму кругляя в меньшую сторону income
-- Левая таблица sales устанавливаем псевдоним s
-- Присоеденяем левым соединением таблицу employees устанавливаем псевдоним e
-- Соединяем две таблицы по столбцам s.sales_persON_id = e.employee_id
-- Присоеденяем левым соединением таблицу products устанавливаем псевдоним p
-- Соединяем две таблицы по столбцам s.product_id = p.product_id
-- Группируем итоговую выборку по столбцу seller
-- Упорядочиваем итоговую выборку по столбцу income в порядке убывания
-- Выводим первые 10 записей итоговой таблицы т.к. 
--по условию задачи нам нужны  топ 10 продавцов у которых наибольшая выручка
--функции cONcat и присваевая псевдоним seller
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

-- 2.Подготовьте в файл lowest_average_income.csv отчет с продавцами, OK
--чья выручка ниже средней выручки всех продавцов
-- Для решения задачи используем обобщённое табличное выражение, CTE.
-- Выбираем поля
-- Выбираем first_name и lASt_name "склеевая" их с помощью функции 
--cONcat и присваевая псевдоним seller
-- Считаем количество продаж каждого менеджера по колонке sales_id 
--присваевая псевдоним operations
-- Создаем новую колонку сумарная выручка продавца за весь период 
--умножая количество продаж на сумму округляя в меньшую сторону income
-- Расчитываем среднюю выручку по каждому продавцу с помощью деления 
--суммы его выручки на сумму количества его сделок
-- Рассчитываем сумму выручки всех продавцов путем сложения всех сумм 
--выручек всех продавцов
-- Рассчитываем сумму всех продаж всех продавцов
-- Рассчитываем сдеднее значение суммы продаж по всем продавцам с 
--помощью оконных функций путем деления общей суммы на общее количество продаж
-- Левая таблица sales устанавливаем псевдоним s
-- Присоеденяем левым соединением таблицу employees устанавливаем псевдоним e
-- Соединяем две таблицы по столбцам s.sales_persON_id = e.employee_id
-- Присоеденяем левым соединением таблицу products устанавливаем псевдоним p
-- Соединяем две таблицы по столбцам s.product_id = p.product_id
-- Группируем по продавцам
-- Основной запрос. Выбераем поля
-- Среднюю сумарная выручки продавца
-- Из CTE таблицы raschet
-- Задаем условие отбора, тех продавцов средняя общая выручка, 
--которых меньше общей средней выручки
-- Упорядочиваем выборку по средней выручке продавца по убывания
WITH raschet AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        COUNT(s.sales_id) AS operations,
        FLOOR(SUM(s.quantity * p.price)) AS income,
        FLOOR(AVG(s.quantity * p.price)) AS average_income,
        SUM(SUM(s.quantity * p.price)) OVER () AS all_income,
        SUM(COUNT(s.sales_id)) OVER () AS all_operation,
        FLOOR(SUM(SUM(s.quantity * p.price))
            OVER ()
        / SUM(COUNT(s.sales_id)) OVER ()) AS avg_all
    FROM sales AS s
    LEFT JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY seller
)

SELECT
    seller,
    average_income
FROM raschet
WHERE average_income < avg_all
ORDER BY average_income DESC;

--3. Подготовьте в файл day_of_the_week_income.csv отчет с данными OK
--по выручке по каждому продавцу и дню недели
-- Для решения задачи используем обобщённое табличное выражение, CTE.
-- Выбираем first_name и lASt_name "склеевая" их с помощью 
--функции cONcat и присваевая псевдоним seller
-- Выбераем день из даты с помощью Day, приобразуем в текст, 
--удаляем лишние пробелы, присваиваем псевдоним
-- Выбираем поля
-- Извлекаем порядковый день недели
-- Создаем новую колонку сумарная выручка продавца за весь период 
--умножая количество продаж на сумму кругляя в меньшую сторону income
-- Левая таблица sales устанавливаем псевдоним s
-- Присоеденяем левым соединением таблицу employees 
--устанавливаем псевдоним e
-- Соединяем две таблицы по столбцам s.sales_persON_id = e.employee_id
-- Присоеденяем левым соединением таблицу products 
--устанавливаем псевдоним p
-- Соединяем две таблицы по столбцам s.product_id = p.product_id
-- Группируем
-- Основной запрос. Выбераем поля
-- Из CTE таблицы sales_by_day
-- Упорядочиваем итоговую таблицу
WITH sales_by_day AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        TRIM(TO_CHAR(s.sale_date, 'Day')) AS day_of_week,
        EXTRACT(ISODOW FROM s.sale_date) AS day_number,
        FLOOR(SUM(s.quantity * p.price)) AS income
    FROM sales AS s
    LEFT JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY seller, day_of_week, day_number
)

SELECT
    seller,
    day_of_week,
    income
FROM sales_by_day
ORDER BY day_number, seller;

-- 6 Задание проекта OK
-- 1. Подготовьте в файл age_groups.csv с возрастными группами покупателей
-- Выбираем поля
-- Используя условный оператор cASe задаем условия 
--для формирования возрастных групп
-- Задаем псевдоним после разделения на группы
-- Считаем количество человек в возрвстных группах и задаем псевдоним
-- Наименование ьаблицы из которой осуществляется выборка
-- Групперуем по возрвстным категориям
-- Сортируем по возрастным категориям в порядке возрастания
SELECT
    CASE
        WHEN age >= 16 AND age <= 25 THEN '16-25'
        WHEN age >= 26 AND age <= 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(customer_id) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

-- 2. Подготовьте в файл customers_by_month.csv с количеством OK
--покупателей и выручкой по месяцам
-- Для решения задачи используем обобщённое табличное выражение, CTE.
-- Для решения задачи используем обобщённое табличное выражение, CTE.
-- Выбираем поля
-- Извлекаем и склеиваем гол и месяц
--Считаем количество клиентов
-- Считаем суммы потраченных клиентами средств
-- Соединяем таблицы по услокиям
-- Группируем тпо месяцу продажи
-- Основной запрос. Выбераем поля
-- Из CTE таблицы sales_by_month
-- Группируем данные 
WITH sales_by_month AS (
    SELECT
        EXTRACT(YEAR FROM s.sale_date)
        ::TEXT || '-' || LPAD(EXTRACT(MONTH FROM s.sale_date)::TEXT, 2, '0')
            AS selling_month,
        COUNT(c.customer_id) AS total_customers,
        FLOOR(SUM(s.quantity * p.price)) AS income
    FROM sales AS s
    LEFT JOIN customers AS c
        ON s.customer_id = c.customer_id
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY selling_month
)

SELECT
    selling_month,
    total_customers,
    income
FROM sales_by_month
ORDER BY selling_month;
-- 3. Подготовьте в файл special_offer.csv с покупателями ОК
--первая покупка которых пришлась на время проведения специальных акций
-- Для решения задачи используем обобщённое 
--табличное выражение, CTE.
--Использовуем оконную функцию ROW_NUMBER(), 
--чтобы выбрать первый заказ каждого клиента
-- Соединяем таблицы по услокиям
-- Основной запрос
-- Выбераем поля
-- Из CTE таблицы discount
-- Условия первая покупка клиента по цене 0
-- Упоряддочиваем по customer_id
SELECT
    customer,
    sale_date,
    seller
FROM (
    SELECT DISTINCT ON (c.first_name, c.last_name)
        c.first_name,
        c.last_name,
        s.sale_date,
        e.first_name AS seller_first_name,
        e.last_name AS seller_last_name,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        CONCAT(e.first_name, ' ', e.last_name) AS seller
    FROM sales AS s
    INNER JOIN customers AS c ON s.customer_id = c.customer_id
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
    WHERE p.price = 0
    ORDER BY c.first_name, c.last_name, s.sale_date
) AS subquery
ORDER BY customer, sale_date;
