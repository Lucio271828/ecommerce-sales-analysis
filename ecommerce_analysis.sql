#Creating the database.
CREATE DATABASE IF NOT EXISTS ecommerce_analysis; 
USE ecommerce_analysis;
SELECT DATABASE();
#Creating the table where the data from python will be importing.
CREATE TABLE ecommerce_sales (
    ID INT,
    Customer_Name VARCHAR(100),
    Order_ID VARCHAR(20),
    Order_Date DATE,
    Product VARCHAR(100),
    Category VARCHAR(50),
    Quantity INT,
    Price DECIMAL(10,2),
    Payment_Method VARCHAR(50),
    Status VARCHAR(30),
    Total DECIMAL(10,2)
);
#Checking if the number of rows shows in MySql is the same in Python.
select count(*) from ecommerce_sales; 
#The result is 102 rows. So, it's all right.
select * from ecommerce_sales;
#Which categories generate the most revenue, and what percentage of the total revenue do they represent?
select Category, sum(total) as Revenue, round(sum(total)*100/(select sum(total) from ecommerce_sales),2) as Percentage_of_total
from ecommerce_sales
group by Category
order by Revenue desc;
#What are the 10 products that generate the highest revenue, and how do they compare to the average revenue per product?
WITH product_Revenue as (
	select 
		   product,
		   sum(total) as Revenue
	from ecommerce_sales
    group by Product
),
average_revenue as(
select avg(Revenue) as Avg_Revenue
from product_Revenue
)
select 
	pr.Product,
    pr.Revenue,
    round(ar.Avg_Revenue, 2) as Avg_Revenue_Product,
    round(pr.Revenue - ar.Avg_Revenue, 2) as Difference
from product_Revenue as pr
cross JOIN average_revenue as ar
order by pr.Revenue desc
limit 10;
#Which customers fall into the top 20% in terms of revenue generated?
with customer_revenue as(
Select Customer_Name,
	   sum(total) as Revenue,
       ntile(5) OVER (order by sum(total) desc) as Revenue_Group
from ecommerce_sales
group by Customer_Name
)
select *
from customer_revenue
where Revenue_Group = 1
order by Revenue desc;
#How did monthly revenue evolve, and which months saw the highest growth compared to the previous month?
with month_revenue as(
	select date_format(Order_Date, '%Y-%m') as Month_column,
		   sum(total) as revenue
	from ecommerce_sales
    group by Month_column
    
),
month_before as(
	select Month_column,
		   Revenue,
		   lag(Revenue) over(order by Month_column) as Previous_Revenue
    from month_revenue
)
select Month_column,
	   Revenue,
       Previous_Revenue,
       round(100*((Revenue-Previous_Revenue)/NULLIF(Previous_Revenue, 0)), 2) as Growth
from month_before
order by Growth desc;
#What percentage of revenue corresponds to each status, and what percentage of order value was returned or cancelled?
With Revenue_per_status as(
	select Status,
	       sum(total) as Revenue
	from ecommerce_sales
    group by Status
),
status_total as(
	select sum(Revenue) as Revenue_total
    from Revenue_per_status
)
select rs.Status,
	   rs.Revenue,	
	   round(100 * (rs.Revenue/st.Revenue_total),2) as Percentage_of_Revenue_total_Per_Status
from Revenue_per_status as rs
CROSS JOIN Status_total as st
order by Revenue desc;    
#What are the three products that generate the most revenue within each category?
with category_revenue as(
	select Category,
		   Product,
           sum(total) as Revenue
	from ecommerce_sales
    group by Category, Product
),
category_Ranking as(
select Category,
	   Product,
       Revenue,
       row_number() over (partition by Category order by Revenue desc) as Ranking
from category_revenue
)
Select Category,
       Product,
       Revenue,
       Ranking
from Category_Ranking
where Ranking <= 3;
#What is the average ticket value by category, and which categories have an average ticket value higher than the overall average?
with ticket_category as(
	select Category,
           sum(total)/count(distinct Order_ID) as Avg_ticket
	from ecommerce_sales
    group by Category
),
ticket_general as (
	select Category,
           avg_ticket,
           (select sum(total)/count(distinct Order_ID) from ecommerce_sales) as Avg_ticket_general
	from ticket_category
)
select Category,
	   Avg_ticket,
       Avg_ticket_general,
       case
		when avg_ticket>avg_ticket_general then 'Si'
        else 'No'
	   end as Exceeds_the_average
from ticket_general;
#Which customers made purchases in more than one year, and how did their spending change from one year to the next?
with customer as (
	select Customer_Name,
		   date_format(Order_Date, '%Y') as Year_date,
           sum(total) as Revenue
	from ecommerce_sales
    group by Customer_Name, Year_date
),
previous_year as (
	select Customer_Name,
		   Revenue,
           Year_date,
		   lag(Revenue) over(partition by Customer_Name order by Year_date) as Previous_Revenue
	from customer
)
Select Customer_Name,
	   Year_date,
       Revenue, 
       Previous_Revenue,
       round(100*(Revenue-Previous_Revenue)/nullif(Previous_Revenue,0), 2) as Growth
from previous_year
where previous_Revenue is not null;
#Which customers have a total spend above the customer average, placed at least two orders, and also have a high proportion of delivered orders?
with customer as (
	select Customer_Name,
           sum(total) as Revenue,
           count(distinct Order_ID) as Order_quantity,
           sum(
			case 
				when Status='Delivered' then 1
                else 0
			end ) as Delivered_orders
	from ecommerce_sales
    group by Customer_Name
), 
percentage_order as (
	select Customer_Name,
		   Revenue,
           Order_quantity,
           Delivered_orders,
           round(100*(Delivered_orders/nullif(Order_quantity, 0)), 2) as Percentage_Delivered_Orders,
		   (SELECT AVG(Revenue) FROM customer) AS Avg_revenue
		from customer
)
select Customer_Name,
       Revenue,
       Order_quantity,
       Delivered_orders,
       Percentage_Delivered_Orders
from percentage_order
WHERE Revenue > Avg_revenue
  AND Order_quantity >= 2
  AND Percentage_Delivered_Orders >= 70;

#Classify customers as High Value, Medium Value, and Low Value based on their total spend, number of orders, and average order value.
with customer_metric as(
	select Customer_Name,
		   sum(total) as Total_Revenue,
           count(distinct Order_ID) as Order_count,
           sum(total)/nullif(count(distinct Order_ID), 0) as Avg_ticket
	from ecommerce_sales
    group by Customer_Name
),
revenue_group as(
	select Customer_Name,
           Total_Revenue,
           Order_count,
           Avg_Ticket,
           ntile(3) over(order by Total_Revenue desc) as Revenue_group
	from customer_metric
)
Select Customer_Name,
       Total_Revenue,
       Order_count,
       Avg_ticket,
       Case
		when Revenue_group = 1 then 'High Value'
        when Revenue_group = 2 then 'Medium Value'
        else 'Low Value'
        end as Customer_Segment
from revenue_group













	


