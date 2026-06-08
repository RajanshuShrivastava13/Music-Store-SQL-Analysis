-- ====================================================================
-- SQL PROJECT: MUSIC STORE DATA ANALYSIS (ALL QUERY SOLUTIONS)
-- Platform: PostgreSQL / OneCompiler
-- ====================================================================

-----------------------------------------------------------------------
-- QUESTION SET 1 - EASY
-----------------------------------------------------------------------

-- Q1: Who is the senior most employee based on job title?[cite: 1]
SELECT EmployeeId, FirstName, LastName, Title, HireDate 
FROM Employee 
ORDER BY ReportsTo ASC NULLS FIRST, HireDate ASC 
LIMIT 1;


-- Q2: Which countries have the most Invoices?[cite: 1]
SELECT BillingCountry, COUNT(InvoiceId) AS Total_Invoices
FROM Invoice
GROUP BY BillingCountry
ORDER BY Total_Invoices DESC;


-- Q3: What are top 3 values of total invoice?[cite: 1]
SELECT Total 
FROM Invoice 
ORDER BY Total DESC 
LIMIT 3;


-- Q4: Which city has the best customers? Return both the city name & sum of all invoice totals.[cite: 1]
SELECT BillingCity, SUM(Total) AS Invoice_Subtotal
FROM Invoice
GROUP BY BillingCity
ORDER BY Invoice_Subtotal DESC
LIMIT 1;


-- Q5: Who is the best customer? The customer who has spent the most money.[cite: 1]
SELECT c.CustomerId, c.FirstName, c.LastName, SUM(i.Total) AS Total_Spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY Total_Spent DESC
LIMIT 1;


-----------------------------------------------------------------------
-- QUESTION SET 2 - MODERATE
-----------------------------------------------------------------------

-- Q1: Return the email, first name, last name, & Genre of all Rock Music listeners. Ordered alphabetically by email starting with A.[cite: 1]
SELECT DISTINCT c.Email, c.FirstName, c.LastName, g.Name AS Genre
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
ORDER BY c.Email ASC;


-- Q2: Invite the artists who have written the most rock music. Return Artist name and total track count of top 10 rock bands.[cite: 1]
SELECT a.Name AS Artist_Name, COUNT(t.TrackId) AS Total_Track_Count
FROM Artist a
JOIN Album al ON a.ArtistId = al.ArtistId
JOIN Track t ON al.AlbumId = t.AlbumId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
GROUP BY a.ArtistId, a.Name
ORDER BY Total_Track_Count DESC
LIMIT 10;


-- Q3: Return all the track names that have a song length longer than the average song length. Order by longest first.[cite: 1]
SELECT Name, Milliseconds
FROM Track
WHERE Milliseconds > (SELECT AVG(Milliseconds) FROM Track)
ORDER BY Milliseconds DESC;


-----------------------------------------------------------------------
-- QUESTION SET 3 - ADVANCE
-----------------------------------------------------------------------

-- Q1: Find how much amount spent by each customer on artists? Return customer name, artist name and total spent.[cite: 1]
SELECT c.FirstName || ' ' || c.LastName AS Customer_Name, 
       a.Name AS Artist_Name, 
       SUM(il.UnitPrice * il.Quantity) AS Total_Spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist a ON al.ArtistId = a.ArtistId
GROUP BY c.CustomerId, Customer_Name, a.ArtistId, Artist_Name
ORDER BY Total_Spent DESC;


-- Q2: Find out the most popular music Genre for each country (highest purchases). Shared maximums return all.[cite: 1]
WITH Genre_Popularity AS (
    SELECT i.BillingCountry AS Country, 
           g.Name AS Genre_Name, 
           COUNT(il.InvoiceLineId) AS Purchases,
           RANK() OVER(PARTITION BY i.BillingCountry ORDER BY COUNT(il.InvoiceLineId) DESC) AS Row_No
    FROM InvoiceLine il
    JOIN Invoice i ON il.InvoiceId = i.InvoiceId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY i.BillingCountry, g.GenreId, g.Name
)
SELECT Country, Genre_Name, Purchases
FROM Genre_Popularity
WHERE Row_No = 1
ORDER BY Country ASC;


-- Q3: Determine the customer that has spent the most on music for each country. Shared maximums provide all.[cite: 1]
WITH Customer_Country_Spending AS (
    SELECT c.CustomerId, 
           c.FirstName, 
           c.LastName, 
           i.BillingCountry AS Country, 
           SUM(i.Total) AS Total_Spent,
           RANK() OVER(PARTITION BY i.BillingCountry ORDER BY SUM(i.Total) DESC) AS Row_No
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName, i.BillingCountry
)
SELECT Country, FirstName, LastName, Total_Spent
FROM Customer_Country_Spending
WHERE Row_No = 1
ORDER BY Country ASC;

-- ====================================================================
-- END OF SCRIPT
-- ====================================================================