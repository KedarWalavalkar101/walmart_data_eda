create database if not exists walmart_sales_data;

CREATE TABLE IF NOT EXISTS walmart_sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);




-- Data wrangling and feature engineering

ALTER TABLE walmart_sales
CHANGE COLUMN tax_pct VAT FLOAT(6,4) NOT NULL;

select * from walmart_sales;

select time,
case when time between '00:00:00' and '12:00:00' then 'Morning'
	when time between '12:00:01' and '16:00:00' then 'Afternoon'
    when time between '16:00:01' and '24:00:00' then 'Evening' end as time_of_day
from walmart_sales;

alter table walmart_sales add column time_of_day varchar(20);

update walmart_sales set time_of_day = 
(
case when time between '00:00:00' and '12:00:00' then 'Morning'
	when time between '12:00:01' and '16:00:00' then 'Afternoon'
    when time between '16:00:01' and '24:00:00' then 'Evening' end 
);

select date,
dayname(date) as day 
from walmart_sales;

alter table walmart_sales add column day_name varchar(30);

update walmart_sales set day_name = 
(
dayname(date)
);

select date,
monthname(date)
from walmart_sales;

alter table walmart_sales add column month_name varchar(15);

update walmart_sales set month_name = 
(
monthname(date)
);




-- EDA 
-- 1. How many cities does the data cover?

select distinct city 
from walmart_sales;


-- 2. Which branch is assigned to each city?

select distinct city, branch
from walmart_sales;


-- 3. How many unique products does the data have?

select count(distinct product_line) as products
from walmart_sales;


-- 4. What is the most commonly used payment method?

select payment as most_common_pay_mtd
FROM walmart_sales
group by payment
order by count(*) desc
limit 1;


-- 5. What is the most selling product line(from highest to lowest)?

select product_line, count(*) as qty_sold
FROM walmart_sales
group by product_line
order by count(*) desc;


-- 6. What is the total revenue by month?

select month_name as month, round(sum(total),2) as revenue,mo
from walmart_sales
group by month_name
order by revenue desc;
 
 
-- 7. What month had the largest COGS?

select month_name
from walmart_sales
group by month_name
order by sum(cogs) desc
limit 1;


-- 8. What product line had the largest revenue?

select product_line, sum(total) as revenue
from walmart_sales
group by product_line
order by sum(total) desc
limit 1;


-- 9. What is the city with the largest revenue?

select city, round(sum(total),2) as revenue
from walmart_sales
group by city 
order by sum(total) desc
limit 1;


-- 10. What product line had the largest VAT?

select product_line, avg(VAT) as avg_tax
from walmart_sales
group by product_line
order by avg_tax desc;


-- 11. Fetch each product line and add a column to those product line showing "Good", "Bad". 
--       Good if its greater than average sales

select product_line,
case when sum(quantity)>avg(quantity) then 'Good'
	else 'Bad'
end as sales_remark
from walmart_sales
group by product_line;


-- 12. Which branch sold more products than average product sold?

select branch , round(sum(quantity))
from walmart_sales
group by branch
having round(sum(quantity)) > (select round(avg(quantity)) from walmart_sales);


-- 13. What is the most common product line by gender?

with a as (
select gender ,product_line ,sum(quantity),
rank() over(partition by gender order by sum(quantity) desc) as rnk
from walmart_sales
group by gender, product_line
order by sum(quantity) desc
)
select gender, product_line
from a where a.rnk = 1;


-- 14. Number of sales made in each time of the day per weekday.

select time_of_day, sum(quantity)
from walmart_sales
where day_name in ('Saturday','Sunday')
group by time_of_day;


-- 15. What is the distribution of total revenue across different types of customers?

select customer_type, round(sum(total)) as total_revenue
from walmart_sales
group by customer_type;


-- 16. How many unique customer types does the data have?

select count(distinct customer_type) as unique_cust_types from walmart_sales;


-- 17. How many unique payment methods does the data have?

select count(distinct payment) as unique_cust_types from walmart_sales;


-- 18. How many unique payment methods does the data have?

select count(distinct payment) as unique_cust_types from walmart_sales;


-- 19. What is the gender distribution per branch?

SELECT branch,
SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS Male,
SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS Female
FROM walmart_sales
GROUP BY branch
order by branch;


-- 20. Which time of the day do customers give most ratings?

select time_of_day, count(rating) as rating_count
from walmart_sales
group by time_of_day
order by rating_count desc
limit 1;


-- 21. Which time of the day do customers give most ratings per branch?

with a as ( 
select branch, time_of_day, count(rating) as rating_count,
rank() over(partition by branch order by count(rating) desc) as rnk
from walmart_sales
group by branch, time_of_day
)
select branch, time_of_day, rating_count
from a 
where rnk = 1;


-- 22. Which day of the week has the best avg ratings?

select day_name, avg(rating) as avg_rating
from walmart_sales
group by day_name
order by avg(rating) desc
limit 1;

-- 23. Which day of the week has the best average ratings per branch?

with a as (
select branch, day_name, avg(rating) as ratings,
rank() over(partition by day_name order by avg(rating) desc) as rnk
from walmart_sales
group by branch, day_name
)
select branch, day_name
from a where a.rnk = 1;










