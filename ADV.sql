Create database adventure_work_cycles;
use adventure_work_cycles;

select * from dimcustomer;
Select * from dimdate;
select * from dimproduct;
select * from dimproductcategory;
select * from dimproductsubcategory;
select * from dimsalesterritory;
select * from factinternetsales;
select * from fact_internet_sales_new;

-- converted all the date columns into date type

update dimcustomer
set birthdate=str_to_date(Birthdate,"%d-%m-%Y");
SELECT distinct(YEAR(BIRTHDATE)) FROM dimcustomer;

update dimcustomer
set DateFirstPurchase=str_to_date(DateFirstPurchase,"%d-%m-%Y");
SELECT distinct(YEAR(DateFirstPurchase)) FROM dimcustomer;

update dimdate
set FullDateAlternateKey="31-12-2014"
WHERE FullDateAlternateKey=42004;

update dimdate
set FullDateAlternateKey=str_to_date(FullDateAlternateKey,"%d-%m-%Y");

update dimproduct
set StartDate=str_to_date(StartDate,"%d-%m-%Y");  

update dimproduct
set EndDate=null
where EndDate="";

update dimproduct
set EndDate=str_to_date(EndDate,"%d-%m-%Y"); 


alter table fact_internet_sales_new2 rename  fact_internet_sales_new;

update factinternetsales
set OrderDateKeyProper=str_to_date(OrderDateKeyProper,"%d-%m-%Y");

select distinct(year(OrderDateKeyProper)) from factinternetsales;

update fact_internet_sales_new
set OrderDateKeyProper=str_to_date(OrderDateKeyProper,"%d-%m-%Y");   
select distinct(year(OrderDateKeyProper)) from fact_internet_sales_new;

-- Appended factinternetsales and fact_internet_sales_new

CREATE VIEW sales AS
select * from factinternetsales
union
select * from fact_internet_sales_new;

select * from sales;

-- 1st Kpi
select s.*,p.EnglishProductName
from dimproduct as p
join sales as s
on p.ProductKey=s.productkey;

-- 2nd kpi
select s.*,concat(c.FirstName," ",c.LastName) as FullName,p.Unitprice
from dimcustomer as c
join sales as s
on c.CustomerKey=s.CustomerKey
join dimproduct as p
on s.Productkey=p.ProductKey;

-- 3rd Kpi
update factinternetsales
set OrderDateKeyProper=str_to_date(OrderDateKeyProper,"%d-%m-%Y");
update fact_internet_sales_new
set OrderDateKeyProper=str_to_date(OrderDateKeyProper,"%d-%m-%Y");   
-- A
select Year(orderdatekey) AS Years from sales;
-- B
select month(OrderDateKey) As Months from sales;
-- C 
select monthname(OrderDateKey) as MonthNames from sales;
-- D
select concat("Q",quarter(OrderDateKey)) AS Quarters from sales;
-- E 
select concat(Year(OrderDateKey),"-",monthname(OrderDateKey)) as Yr_Mnt from sales;
-- F 
select weekday(OrderDateKey) as weekno from sales;
-- G 
select  weekday(OrderDateKey), dayname(Orderdatekey) from sales;
-- H 
select month(OrderDateKey),
case 
     when month(orderDateKeY)>9 then month(orderdatekey)-9
      else month(orderdatekey)+3 end as financial_month
 from sales;
 -- I
 select month(orderDateKeY),case
 when month(orderDateKeY)<=3 then "Q2"
WHEN month(orderDateKeY)<=6 then "Q3"
WHEN month(orderDateKeY)<=9 then "Q4"
ELSE "Q1" end as financial_Quarter
from sales;

-- 4th Kpi
select sum(round((orderQuantity*UnitPrice)-(orderQuantity*UnitPriceDiscountPct),0)) as Sales from sales;

-- 5th kpi
select sum(round((TotalProductCost*OrderQuantity),0)) as Production_Cost from sales;

-- 6th kpi
select sum(round((orderQuantity*UnitPrice)-(orderQuantity*UnitPriceDiscountPct),0))
-sum(round((ProductStandardcost*OrderQuantity),0)) as profit from sales;

-- 7th Kpi
select 
MontHname(orderDateKey) as months, 
round(Sum(salesAmount),0) as sales
from sales 
where year(orderdatekey)=2011
group by monthname(orderDateKey);

-- 8th Kpi
select year(OrderDateKey) as years, Round(sum(salesAmount),0)as sales
from sales
group by Year(orderdatekey);

-- 9th Kpi
select 
MontHname(orderDateKey) as months, 
round(Sum(salesAmount),0) as sales
from sales 
group by monthname(orderDateKey);

-- 10th Kpi
select concat("Q",quarter(Orderdatekey)) as quarters,
Round(sum(salesAmount),0) as sales
from sales
group by quarters;

-- 11th Kpi
select Year(orderdatekey) as years,Round(sum(salesamount),0) as sales,Round(sum(Totalproductcost),0) as Total_cost
from sales
group by years;

select * from sales;
select * from dimproduct;
select * from dimproductcategory;
select * from dimproductsubcategory;

-- Top category wise subcategory sales

select englishproductcategoryname,round(sum(salesamount),0) from dimproductcategory as d1
join dimproductsubcategory as ds
on d1.ProductCategoryKey=ds.ProductCategoryKey
join dimproduct  as p
on ds.ProductSubcategoryKey=p.ProductSubcategoryKey
join sales as s
on s.productkey=p.productkey
group by 1;


with main1 as (
with main as (
select EnglishProductCategoryName,EnglishProductSubcategoryName,round(sum(salesamount),0) as total from dimproductcategory as d1
join dimproductsubcategory as ds
on d1.ProductCategoryKey=ds.ProductCategoryKey
join dimproduct  as p
on ds.ProductSubcategoryKey=p.ProductSubcategoryKey
join sales as s
on s.productkey=p.productkey
group by 1,2)

select *,row_number()over(partition by englishproductcategoryname order by total desc) as rn
from main)

select * from main1
where rn =1
order by total desc
-- limit 1
;