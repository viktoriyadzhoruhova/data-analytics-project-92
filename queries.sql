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
    INITCAP(TRIM(TO_CHAR(s.sale_date, 'Day'))) as day_of_week,
    FLOOR(SUM(p.price * s.quantity)) as income
from sales s
inner join employees e on s.sales_person_id = e.employee_id
inner join products p on s.product_id = p.product_id
group by seller, day_of_week, EXTRACT(DOW from s.sale_date)
order by seller, EXTRACT(DOW from s.sale_date) asc;

-- Customers groups by age
select 
    case 
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+' 
    end as age_category,
    COUNT(*) as age_count
from customers
group by age_category
order by age_category;

-- Customers and income by months
select 
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    COUNT(DISTINCT s.customer_id) as total_customers,
    SUM(p.price * s.quantity) as income
from sales s
inner join products p on s.product_id = p.product_id
group by selling_month
order by selling_month;

-- Customers whose first purchase was for the promotion
with first_sale as (
    select 
        c.first_name || ' ' || c.last_name AS customer,
        s.sale_date,
        e.first_name || ' ' || e.last_name AS seller,
        ROW_NUMBER() OVER (partition by c.customer_id order by s.sale_date) as row_number
    from sales s
    inner join customers c on s.customer_id = c.customer_id
    inner join employees e on s.sales_person_id = e.employee_id
    inner join products p on s.product_id = p.product_id
    where p.price = 0
)
select customer, sale_date, seller
from first_sale
where row_number = 1
order by customer;
