create database amazon;
use amazon;
select * from amazon.customers;
select * from amazon.order_details;
select * from amazon.products;
select*from amazon.suppliers;	
select Name from amazon.customers;
select customerid from amazon.customers;

select productid,count(*) from amazon.order_details group by ProductID having count(*)>1;

-- task3 Write a query to:
-- Retrieve all customers from a specific city.
select * from amazon.customers where city="meganfort";
-- Fetch all products under the "Fruits" category.
select productname from amazon.products where category="fruits";

-- task 4 Write DDL statements to recreate the Customers table with the following constraints:
-- Ensure Age cannot be null and must be greater than 18.
alter table amazon.customers modify age INT not null;
alter table amazon.customers add constraint che_age check(age>=18);

-- task 5 Insert 3 new rows into the Products table using INSERT statements.
insert into amazon.products (productid,productname,category,subcategory,priceperunit,stockquantity,supplierid) values("0006853c-74cb-44a2-91ed-699aa31c5b5b","Recently Baker","Bakery","sub-Baker-2",678,79,"833a86e4-88c3-42cb-a39d-8c71ce831569");
insert into amazon.products (productid,productname,category,subcategory,priceperunit,stockquantity,supplierid) values("0006853v-74cb-44a2-91ed-699aa31c5b5c","whose Baker","Bakery","sub-Baker-3",694,790,"833a86f4-88c3-42cb-a39d-8c71ce831567");
insert into amazon.products (productid,productname,category,subcategory,priceperunit,stockquantity,supplierid) values("0006853v-74cb-44a2-91ed-699aa31c5b6b"," word fruits","fruits","sub-fruits-4",64,70,"833a86l4-88c3-42cb-a39d-8c71ce8315635");

-- task 6 Update the stock quantity of a product where ProductID matches a specific ID.
update amazon.products set stockquantity=400 where productid="0006853b-74cb-44a2-91ed-699aa31c5b5b";

-- task 7 Delete a supplier from the Suppliers table where their city matches a specific value
delete from amazon.suppliers where city="south ana";
set sql_safe_updates=1;

-- task 8- 1- Add a CHECK constraint to ensure that ratings in the Reviews table are between 1 and 5.
alter table amazon.reviews
add constraint chk_rating
check(rating between 1 and 5);

-- 2- Add a DEFAULT constraint for the PrimeMember column in the Customers table (default value: "No").
alter table amazon.customers
modify primemember varchar(10)
default "no";

-- task 9 Write queries using:
-- 1 WHERE clause to find orders placed after 2024-01-01.
select * from amazon.orders where OrderDate>2024-01-01;
-- 2 HAVING clause to list products with average ratings greater than 4.
select productID,avg(rating) as avgrating from amazon.reviews 
group by ProductID
having avg(rating)>4; 
-- 3 GROUP BY and ORDER BY clauses to rank products by total sales.

-- task 10
-- 1 Calculate each customer's total spending.
select c.customerid,c.name,sum(o.orderamount) as totalspending
from amazon.customers c
join amazon.orders o
on c.customerid=o.CustomerID
group by c.customerid,c.name;

-- 2. Rank customers based on their spending.
select c.customerid,c.name,sum(o.orderamount) as totalspent,
rank() over(order by sum(o.orderamount) desc) as customerrank
from amazon.customers c
join amazon.orders o
on c.customerid=o.CustomerID
group by c.customerid,c.name;

-- 3. Identify customers who have spent more than ₹5,000
select c.customerid,c.name,sum(o.orderamount) as totalspent
from amazon.customers c
join amazon.orders o
on c.customerid=o.CustomerID
group by c.customerid,c.name
having sum(o.orderamount)>5000;

-- Task 11: Use SQL to:
-- 1 Join the Orders and OrderDetails tables to calculate total revenue per order.
select o.orderid,sum(c.Quantity*c.UnitPrice) as totalrevenue
from amazon.orders o
join amazon.order_details c
on o.OrderID=c.orderid
group by o.OrderID;
-- 2 Identify customers who placed the most orders in a specific time period.
select c.customerid,c.name,count(o.orderid) as totalorders
from customers c
join orders o
on c.customerid=o.customerid
where o.orderdate between '2024-21-03' and '2025-11-31'
group by c.customerid,c.name
order by totalorders desc
limit 1;
-- 3 Find the supplier with the most products in stock.
select s.supplierid,s.suppliername,max(p.stockquantity) as totalstock
from amazon.suppliers s
join amazon.products p
on s.supplierid=p.supplierid
group by s.supplierid,s.suppliername
order by totalstock desc;

-- Task 12: Normalize the Products table to 3NF:
 -- Separate product categories and subcategories into a new table.
-- Create foreign keys to maintain relationships.
create table sql_categoriesN(
    categoryid int auto_increment primary key,
    category varchar(100),
    subcategory varchar(100)
);
insert into sql_categoriesN(category, subcategory)
select distinct category, subcategory
from products;

alter table products
add categoryid int;

set sql_safe_updates=0;

update products p
join sql_categoriesN c
on p.category = c.category
and p.subcategory = c.subcategory
set p.categoryid = c.categoryid;

alter table products
add constraint fk_products_category
foreign key (categoryid)
references sql_categoriesN(categoryid);

select*from amazon.sql_categoriesN;

-- Task 13: Write a subquery to:
-- 1 Identify the top 3 products based on sales revenue.
select productid,sum(Quantity*UnitPrice) as SR
from amazon.order_details
group by productid
order by SR  desc limit 3;

-- 2 Find customers who haven’t placed any orders yet.
select name,customerid from customers where customerid 
not in ( select customerid from orders);

-- Task 14: Provide actionable insights:
-- Which cities have the highest concentration of Prime members?
select City,COUNT(*) AS PrimeMembers
from amazon.Customers
where PrimeMember = 'Yes'
GROUP BY City
ORDER BY PrimeMembers DESC;
-- What are the top 3 most frequently ordered categories?
select p.Category,SUM(od.Quantity) AS TotalOrders
from Products p
join Order_Details od
on p.ProductID = od.ProductID
group by p.Category
order by TotalOrders DESC
limit 3;