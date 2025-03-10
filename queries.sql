-- Counts the number of customers in the table 'customers'
select 
	COUNT(customer_id) as customers_count
from customers

-- TOP 10 sellers by total income
select 
	e.first_name || ' ' || e.last_name as seller,
	COUNT(s.sales_id) as operations,
	FLOOR(SUM(s.quantity * p.price)) as income
from sales s
inner join employees e on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id
group by e.employee_id
order by income desc
limit 10;

-- TOP sellers with lowest total income (lower than average)
with average_sales as (
    select 
        s.sales_person_id,
        FLOOR(AVG(p.price * s.quantity)) as average_income
    from sales s
    inner join products p on p.product_id = s.product_id
    group by s.sales_person_id
)
select 
    e.first_name || ' ' || e.last_name as seller,
    a.average_income
from average_sales a
inner join employees e on e.employee_id = a.sales_person_id
where a.average_income < (select FLOOR(AVG(average_income)) from average_sales)
order by a.average_income;

-- Sales by each seller and day of week
select
    e.first_name || ' ' || e.last_name as seller,
    TRIM(TO_CHAR(s.sale_date, 'Day')) as day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income
from sales s
inner join employees e on s.sales_person_id = e.employee_id
inner join products p on s.product_id = p.product_id
group by seller, day_of_week
order by seller asc;
	
