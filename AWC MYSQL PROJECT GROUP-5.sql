create database AdventureWorkCycles;
use AdventureWorkCycles;

select * from dimcustomern;
select * from dimdaten;
select * from dimproductfinaln;
select * from dimsalesterritoryn;
select * from factsalesn;

select count(*) from dimsalesterritoryn;

ALTER TABLE factsalesn ADD COLUMN ProfitMargin DECIMAL(10,4);
UPDATE factsalesn SET ProfitMargin = (Profit / SalesAmount);


CREATE VIEW View_AdventureWorkscycle_project AS
SELECT 
    f.SalesOrderNumber,f.SalesAmount,f.OrderQuantity,
    p.EnglishProductName,p.EnglishProductCategoryName AS Category,
    c.CustomerFullName,t.SalesTerritoryRegion AS Region,
    d.FullDateAlternateKey AS OrderDate,d.CalendarYear,d.EnglishMonthName
FROM FactSalesn f
LEFT JOIN DimProductfinaln p ON f.ProductKey = p.ProductKey
LEFT JOIN DimCustomern c ON f.CustomerKey = c.CustomerKey
LEFT JOIN DimDaten d ON f.OrderDateKey = d.DateKey
LEFT JOIN DimSalesTerritoryn t ON f.SalesTerritoryKey = t.SalesTerritoryKey;

select * from View_AdventureWorkscycle_project;

/*  (Filled Map,Tree Map,Bubble Chart,Histogram,scatter plot,waterfall chart)
Top 5 ModelName by sales
ProductCategory - sales Amount - Tax Amount
ProductCategory - Production Cost - Tax Amount

Top N customers by sales		X Top 5 customers by YearlyIncome
country wise profit margin -filled map 
Gender Wise Sales - KPI
Merged Product - Tree Map */

# 1.Top 5 ModelName by sales
select p.ModelName as Model, round(sum(f.SalesAmount)) as TotalSales
from factsalesn f
join dimproductfinaln p on f.ProductKey = p.ProductKey
group by p.ModelName order by TotalSales desc limit 5 ;


# 2.ProductCategory - sales Amount - Tax Amount
select p.EnglishProductCategoryName as ProductCategory, round(sum(f.salesamount)) as SalesAmount , round(sum(f.taxamt)) as TaxAmount
from factsalesn f
join dimproductfinaln p on f.ProductKey = p.ProductKey
group by p.EnglishProductCategoryName ;


# 3.ProductCategory - Production Cost - Tax Amount
select p.EnglishProductCategoryName as ProductCategory, round(sum(f.ProductionCost)) as ProductionCost , round(sum(f.taxamt)) as TaxAmount
from factsalesn f
join dimproductfinaln p on f.ProductKey = p.ProductKey
group by p.EnglishProductCategoryName ;

/* # 4.Top 5 products - DateFirstPurchase
select p.EnglishProductCategoryName as ProductCategory, c.DateFirstPurchase 
from dimcustomern c
join dimproductfinaln p on (No common column)
*/

# 4. Top 5 customers by YearlyIncome
select CustomerFullName , sum(YearlyIncome) as YearlyIncome from dimcustomern 
group by CustomerFullName order by YearlyIncome desc limit 5;


# 5.country wise profit margin 
select s.SalesTerritoryCountry as Country, round(sum(f.ProfitMargin)) as ProfitMargin from factsalesn f 
join dimsalesterritoryn s on f.SalesTerritoryKey = s.SalesTerritoryKey
group by SalesTerritoryCountry ;


# 6.Gender Wise Sales
select c.Gender, round(sum(f.salesamount)) as TotalSales from factsalesn f 
join dimcustomern c on f.customerkey = c.customerkey
group by Gender ;


# Top 5 Sales by Sizerange
select p.SizeRange , round(sum(f.salesamount)) as TotalSales from factsalesn f 
join dimproductfinaln p on f.productkey = p.productkey 
group by p.sizerange order by totalsales desc limit 5;


# Colorwise Sales
select p.Color , round(sum(f.salesamount)) as Totalsales from factsalesn f 
join dimproductfinaln p on f.productkey = p.productkey 
group by p.color order by Totalsales desc ;


/* 
Occupation - product - sales
yearwise sales , quarterwise sales 
MaritalStatus - ProductSubCategory - Sales 
Age Wise - Sales
*/


 # Occupation - product - sales
select c.EnglishOccupation as Occupation , p.EnglishProductName as ProductName , round(sum(salesamount)) as Totalsales 
from factsalesn f join dimcustomern c on f.customerkey = c.customerkey 
join dimproductfinaln p on f.productkey = p.productkey 
group by ProductName , Occupation order by totalsales desc limit 5 ;

 
 # yearwise sales & quarterwise sales 
 select d.year , round(sum(f.salesamount)) as TotalSales from factSalesn f 
 join dimdaten d on f.orderdatekey = d.datekey 
 group by d.year order by d.Year ;
 
 

SELECT TIMESTAMPDIFF(
           YEAR, 
           STR_TO_DATE(birthdate, '%Y-%m-%d'), 
           CURDATE()
       ) AS age
FROM dimcustomern;

UPDATE dimcustomern
SET age = TIMESTAMPDIFF(
              YEAR, 
              STR_TO_DATE(birthdate, '%Y-%m-%d'), 
              CURDATE()
          );
          
          
      UPDATE dimcustomern
SET age = TIMESTAMPDIFF(
    YEAR,
    STR_TO_DATE(birthdate, '%d-%m-%Y'),
    CURDATE()
);    

select * from dimcustomern;
          
     
 # Agewise Sales     
select c.Age ,round(sum(f.salesamount)) as TotalSales from Factsalesn f 
join dimcustomern c on f.customerkey = c.customerkey 
group by c.Age order by c.Age asc;
          
          
# MaritalStatus - ProductSubCategory - Sales 
select  p.EnglishProductSubCategoryName as ProductSubCategory, c.MaritalStatus ,
round(sum(salesamount)) as TotalSales from factsalesn f 
join dimproductfinaln p on f.productkey = p.productkey 
join dimcustomern c on f.customerkey = c.customerkey 
group by c.MaritalStatus, ProductSubCategory order by TotalSales desc ;
          
          
 # Ranking Products by Profit
SELECT  p.EnglishProductCategoryName, p.EnglishProductName, round(sum(f.Profit)) as Profit,
    DENSE_RANK() OVER (PARTITION BY EnglishProductCategoryName ORDER BY sum(f.Profit) desc) AS Profit_Rank
FROM factsalesn f join dimproductfinaln p on p.productkey = f.productkey group by p.EnglishProductName, p.EnglishProductCategoryName ;
         
          
/* KPI'S 
Total Revenue
Total Profit
Total Production Cost
TaxAmt
*/

/* CHARTS 
Combo 				- ProductCategory vs sales Amount vs Tax Amount
Funnel 				- Agewise Sales
Tree Map			- ProductCategory & ProductName With Sales
*Donut Chart			- Genderwise Sales
*Bubble Chart		- Countrywise
					- Colorwise Sales
*Bar Chart			- ModelName 
*Line Chart			- Yearwise Sales
*Column Chart		- TotalSales vs TotalCost vs TaxAmt
*/

select * from factsalesn;
select count(*) from factsalesn;





SELECT OrderDate, SalesOrderNumber, ProductstandardCost, sum(ProductstandardCost) OVER (ORDER BY OrderDate) AS RunningTotal FROM FactSalesn;

SELECT ProductKey, SalesAmount, RANK() OVER (ORDER BY SalesAmount DESC) as ProductRank FROM FactSalesn;


# Ranking Products by Profit
SELECT  p.EnglishProductCategoryName, p.EnglishProductName, round(sum(f.Profit)) as Profit,
    DENSE_RANK() OVER (PARTITION BY EnglishProductCategoryName ORDER BY sum(f.Profit) desc) AS Profit_Rank
FROM factsalesn f join dimproductfinaln p on p.productkey = f.productkey group by p.EnglishProductName, p.EnglishProductCategoryName ;


DELIMITER $$
CREATE PROCEDURE CountryPerformance(IN Country VARCHAR(50))
BEGIN
    SELECT
        c.SalesTerritoryCountry,
        round(SUM(f.SalesAmount)) AS TotalSales,
        round(SUM(f.Profit)) AS TotalProfit
    FROM factsalesn f
    JOIN dimsalesterritoryn c
        ON f.SalesTerritoryKey = c.SalesTerritoryKey
    WHERE c.SalesTerritoryCountry = Country
    GROUP BY c.SalesTerritoryCountry;
END $$
DELIMITER ;

CALL CountryPerformance('United States');

/*
CREATE PROCEDURE GetCountryPerformance
    @CountryName VARCHAR(50)
AS
BEGIN
    SELECT 
        c.SalesTerritoryCountry, 
        SUM(f.SalesAmount) AS TotalSales, 
        SUM(f.Profit) AS TotalProfit
    FROM Factsalesn f
    JOIN dimsalesterritoryn c ON f.SalesTerritoryKey = c.SalesTerritoryKey
    WHERE c.SalesTerritoryCountry = @CountryName
    GROUP BY c.SalesTerritoryCountry;
END;
*/
