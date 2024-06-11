--1. List the orders placed by employees who have sold more than $1 million worth of products.

--Using Subquery
SELECT 
    sh.SalesOrderID,
    sh.SalesPersonID AS EmployeeID,
    sh.OrderDate,
    sh.CustomerID
FROM Sales.SalesOrderHeader sh
WHERE sh.SalesPersonID IN (
    SELECT 
        SalesPersonID
    FROM Sales.SalesOrderHeader soh_inner
    INNER JOIN Sales.SalesOrderDetail sd ON soh_inner.SalesOrderID = sd.SalesOrderID
    GROUP BY SalesPersonID
    HAVING SUM(sd.LineTotal) > 1000000)
		ORDER BY sh.SalesOrderID;


--2. Find the top 5 products with the highest average order quantity.

SELECT TOP 5
    P.ProductID,
    P.Name,
    AVG(sd.OrderQty) AS AverageOrderQty
FROM
    Sales.SalesOrderDetail sd
    INNER JOIN Production.Product P ON sd.ProductID = P.ProductID
GROUP BY
    P.ProductID,
    P.Name
ORDER BY
    AverageOrderQty DESC;

--3. Get the list of customers who have placed orders with a total value exceeding $10,000.
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    SUM(sh.TotalDue) AS TotalOrderValue
FROM 
    Sales.SalesOrderHeader AS sh
    INNER JOIN Sales.Customer AS c
        ON sh.CustomerID = c.CustomerID
		JOIN Person.Person p ON c.CustomerID = p.BusinessEntityID
GROUP BY 
    c.CustomerID,
    p.FirstName,
    p.LastName
HAVING 
    SUM(sh.TotalDue) > 10000
ORDER BY 
    TotalOrderValue DESC;

SELECT * FROM Person.Person;
--4. Retrieve the names of employees who have sold products to more than 50 different customers.

SELECT p.FirstName, p.LastName
	FROM Sales.SalesOrderHeader sh
		JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID
		JOIN Sales.SalesPerson sp ON sh.SalesPersonID = sp.BusinessEntityID
		JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
	GROUP BY p.FirstName, p.LastName
	HAVING COUNT(DISTINCT sh.CustomerID) > 50;

--5. List the products that are subcomponents of other products.

SELECT DISTINCT
    p.ProductID,
    p.Name AS ProductName
FROM
    Production.Product p
	JOIN
    Production.BillOfMaterials b ON
    p.ProductID = b.ComponentID
ORDER BY
    p.ProductID;

--6. Find the total sales amount for each region.

SELECT DISTINCT cr.CountryRegionCode,
				cr.Name AS CountryName, 
				SUM(st.SalesYTD) AS TotalSales
	FROM Person.CountryRegion cr
		JOIN Sales.SalesTerritory st ON 
		cr.CountryRegionCode = st.CountryRegionCode
	GROUP BY cr.CountryRegionCode,cr.Name;

--7. Get the list of customers who have not placed any orders.

SELECT c.CustomerID,
		p.FirstName, 
		p.LastName, 
		e.EmailAddress
	FROM Sales.Customer c
		JOIN Person.Person p ON c.CustomerID = p.BusinessEntityID
		JOIN Person.EmailAddress e ON e.BusinessEntityID = p.BusinessEntityID
		LEFT JOIN Sales.SalesOrderHeader sh ON sh.CustomerID = c.CustomerID
	WHERE sh.SalesOrderID IS NULL;

--8. Retrieve the names of employees who have sold products in the 'Clothing' category.

SELECT DISTINCT
    pp.FirstName,
    pp.LastName
FROM
    Sales.SalesOrderHeader sh
    INNER JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID
    INNER JOIN Production.Product p ON sd.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory pc ON pc.ProductCategoryID = pc.ProductCategoryID
    INNER JOIN Sales.SalesPerson sp ON sh.SalesPersonID = sp.BusinessEntityID
    INNER JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
	JOIN Person.Person pp ON pp.BusinessEntityID = e.BusinessEntityID
WHERE
    pc.Name = 'Clothing';


--9. List the orders with a total value greater than the average order value.

WITH OrderTotals AS (
    SELECT
        sh.SalesOrderID,
        SUM(sd.OrderQty * sd.UnitPrice) AS TotalOrderValue
    FROM
        Sales.SalesOrderHeader sh
    INNER JOIN
        Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID
    GROUP BY
        sh.SalesOrderID
),
AverageOrderValue AS (
    SELECT
        AVG(TotalOrderValue) AS AvgOrderValue
    FROM
        OrderTotals
)
SELECT
    ot.SalesOrderID,
    ot.TotalOrderValue
FROM
    OrderTotals ot,
    AverageOrderValue aov
WHERE
    ot.TotalOrderValue > aov.AvgOrderValue
ORDER BY
    ot.TotalOrderValue DESC;

--10. Find the top 3 customers with the highest total order value.

SELECT TOP 3 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    SUM(sh.TotalDue) AS TotalOrderValue
FROM 
    Sales.SalesOrderHeader sh
	JOIN Sales.Customer c ON sh.CustomerID = c.CustomerID
	JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
GROUP BY  c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalOrderValue DESC;

--11. Get the list of products that are not associated with any orders.

SELECT p.ProductID, p.Name
	FROM Production.Product p
	LEFT JOIN Sales.SalesOrderDetail sd ON p.ProductID = sd.ProductID
		WHERE sd.ProductID IS NULL;

--12. Retrieve the names of employees who have sold products to customers in the 'United States' region.
SELECT DISTINCT
    p.FirstName,
    p.LastName
FROM
    Sales.SalesOrderHeader sh
    JOIN Sales.Customer c ON sh.CustomerID = c.CustomerID
    JOIN Sales.SalesPerson sp ON sh.SalesPersonID = sp.BusinessEntityID
    JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    JOIN Person.Address a ON sh.BillToAddressID = a.AddressID
    JOIN Person.StateProvince spr ON a.StateProvinceID = spr.StateProvinceID
    JOIN Person.CountryRegion cr ON spr.CountryRegionCode = cr.CountryRegionCode
WHERE
    cr.Name = 'United States';

--13. List the orders placed by customers who have also placed orders for products in the 'Accessories' category.

SELECT DISTINCT o1.*
FROM Sales.SalesOrderHeader o1
JOIN Sales.SalesOrderDetail d1 ON o1.SalesOrderID = d1.SalesOrderID
JOIN Production.Product p1 ON d1.ProductID = p1.ProductID
WHERE o1.CustomerID IN (
    SELECT DISTINCT o2.CustomerID
    FROM Sales.SalesOrderHeader o2
    JOIN Sales.SalesOrderDetail d2 ON o2.SalesOrderID = d2.SalesOrderID
    JOIN Production.Product p2 ON d2.ProductID = p2.ProductID
    JOIN Production.ProductSubcategory ps2 ON p2.ProductSubcategoryID = ps2.ProductSubcategoryID
    JOIN Production.ProductCategory pc2 ON ps2.ProductCategoryID = pc2.ProductCategoryID
    WHERE pc2.Name = 'Accessories'
);

--14. Find the total sales amount for each product category.

SELECT 
    pc.Name AS Category_Name,
    SUM(sd.LineTotal) AS Total_Sales_Amount
FROM 
    Sales.SalesOrderDetail sd
    JOIN Sales.SalesOrderHeader soh ON sd.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product p ON sd.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
	ORDER BY SUM(sd.LineTotal);


--15. Get the list of employees who have sold products with a total value exceeding $50,000 in the 'Clothing' category.

SELECT 
    pp.BusinessEntityID,
    pp.FirstName,
    pp.LastName,
    SUM(sod.LineTotal) AS TotalSales
FROM 
    Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Person.Person pp ON soh.SalesPersonID = pp.BusinessEntityID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
	WHERE pc.Name = 'Clothing'
	GROUP BY pp.BusinessEntityID, pp.FirstName, pp.LastName
	HAVING SUM(sod.LineTotal) > 50000
	ORDER BY TotalSales DESC;

