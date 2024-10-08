/* Query to determine the number of clients
* customer_count
*/
select count(customer_id) as customers_count
from customers;
/* Вычисление количества клиентов из таблицы "сustomers"*/



/* Request to find the top 10 sellers with the highest amounts sales
* top_10_total_income
* In the subquery "tab1" we join the tables according to their id references.
* Select the required columns, merge the columns "e.first_name"
* and "e.last_name" from "employees" table
*/
with tab1 as (
    select
        p.product_id,
        s.quantity,
        p.price,
        concat(e.first_name, ' ', e.last_name) as seller
    from sales as s
    left join employees as e
        on s.sales_person_id = e.employee_id
    left join products as p
        on s.product_id = p.product_id
)

select distinct
    seller, -- Сhoose only unique sellers
    count(*)
        over (partition by seller)
    as operations, -- Вычисление количества операций одного продавца
    floor(
        sum(quantity * price)
            over (partition by seller)
    ) as income -- Вычисление суммы продаж продавца и округление до целого
from tab1
order by income desc
limit 10;
/* В итоговом запросе мы получили таблицу с 10-ю продавцами
   с самыми большими суммами продаж. */


/* Запрос по поиску худших продавцов по средней сумме продаж
* lowest_average_income
*/
with tab1 as (
    select
        p.product_id,
        s.quantity,
        p.price,
        concat(e.first_name, ' ', e.last_name) as seller
    from sales as s
    left join employees as e
        on s.sales_person_id = e.employee_id
    left join products as p
        on s.product_id = p.product_id
),

/* В подзапросе "tab1" мы соединяем таблицы согласно референсам их id.
 * Выбираем необходимые столбцы, объеденяем столбцы "e.first_name" и "e.last_name" из
 * таблицы "employees"
 */
tab2 as (
    select distinct
        seller, -- оставляем только уникальные имена продавцов
        floor(
            avg(quantity * price)
                over (partition by seller)
        ) as average_income, -- Вычисляем среднюю сумму продажи по продавцу
        avg(quantity * price)
            over ()
        as avg_total -- Вычисляем среднюю сумму по всем продажам
    from tab1
)

/* Запрос по поиску продаж продавцов в разрезе дней недели.
 * day_of_week_income
 */
with tab1 as (
    select
        p.product_id,
        s.quantity,
        p.price,
        concat(e.first_name, ' ', e.last_name) as seller,
        -- приводим нумерацию к Mon = 0
        (extract(isodow from s.sale_date) - 1) as num_of_day,
        -- выделяем название дня недели
        to_char(s.sale_date, 'Day') as day_of_week
    from sales as s
    left join employees as e
        on s.sales_person_id = e.employee_id
    left join products as p
        on s.product_id = p.product_id
),

/* В подзапросе tab2 мы выводим уникальных продавцов и
 * считаем сумму продаж каждого продавца в партиции продавца и дня недели
 */
tab2 as (
    select distinct
        seller,
        day_of_week,
        num_of_day,
        sum(price * quantity)
            over (partition by seller, day_of_week)
        as income
    from tab1
    order by num_of_day, seller
)

select
    seller,
    day_of_week,
    floor(income) as income
from tab2;
/* Итоговая витрина продаж в разрезе продавцов и дней
*/



/* Запрос по вычислению количества покупателей в разрезе
 * возрастных групп.
 * age_groups
*/
with tab1 as (
    select
        *,
        case -- Присвоение категорий каждому диапазону возрастов
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            when age > 40 then '40+'
        end as age_category
    from customers
)

select distinct
    age_category,
    -- подсчёт количества покупателей в категории
    count(age) over (partition by age_category) as age_count
from tab1
order by age_category;
--------------------------------------------------------------
/* В этом подзапросе мы вычисляем количество уникальных покупателей
 * и выручки в разрезе каждого месяца.
 * customers_by_month
 */
with tab1 as ( -- В подзапросе tab1 происходит приведение данных
   select -- к необходимым типам.
      to_char(s.sale_date, 'YYYY-MM') as selling_month,
      concat(c.first_name, ' ', c.last_name) as customer_name
   from sales AS s
   left join customers AS c
   on s.customer_id = c.customer_id
),
tab2 as (     -- В подзапросе tab2 мы находим уникальных покупателей в каждом месяце.
   select
      distinct customer_name,
      selling_month
   from tab1
),
tab3 as (     -- В подзапросе tab3 мы находим количество уникальных покупателей
   select         -- в разрезе каждого месяца.
      distinct selling_month,
      count(customer_name)
         over (partition by selling_month)
   from tab2
),
tab4 as (     -- tab4 представляет собой CTE с данными для подсчета суммарной выручки
   select        -- в итоговом запросе.
      to_char(s.sale_date, 'YYYY-MM') as selling_month,
      p.product_id,
      s.quantity,
      p.price
   from sales AS s
   left join products AS p
   on s.product_id = p.product_id
)
select        
   distinct tab4.selling_month,
   tab3.count as total_customers,
   floor(sum(tab4.price * tab4.quantity) 
      over (partition by tab4.selling_month)) as income
from tab4
inner join tab3
on tab4.selling_month = tab3.selling_month;
/* В итоговом запросе мы соеденили CTE tab4 и tab3 по месяцам,
 * посчитали и округлили суммарную выручку по месяцам и указали количество уникальных клиентов
 * в каждом месяце
 */



/* В этом запросе мы будем искать даты первых акционных покупок
 * клиентами.
 * special_offer
*/

with tab1 as (
   select         
      s.customer_id,
      concat(c.first_name, ' ', c.last_name) as customer, - объеденяем имя и фамилию
      sale_date,
      concat(e.first_name, ' ', e.last_name) as seller,
      p.price,
      row_number () -- присваиваем номера в партиции клиент, продавец с сортировкой по дате ASC
         over (partition by concat(c.first_name, ' ', c.last_name),  
            concat(e.first_name, ' ', e.last_name) 
            order by sale_date) as flag_1,
      row_number () -- присваиваем номер каждой записи с клиентом для последующего отбора первого значения
         over (partition by concat(c.first_name, ' ', c.last_name)) as flag_2 
   from sales AS s
   left join customers AS c
   on s.customer_id = c.customer_id
   left join employees AS e
   on s.sales_person_id = e.employee_id
   left join products AS p
   on s.product_id = p.product_id
   where price = 0 - условие выбора записей соответствующее акции
)
select
   customer,
   sale_date,
   seller
from tab1 
where flag_1 = 1 and flag_2 = 1 -- выбор flag_1 = первая клиент-дата, flag_2 = одна запись - один клиент
order by customer_id; -- сортировка записей по id клиента
/* Итоговая таблица предоставляет даты первых покупок клиентами соответствующих условиям акции
 *




