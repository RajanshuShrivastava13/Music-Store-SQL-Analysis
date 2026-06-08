-- 1. टेबल्स को साफ़ करना (यदि पहले से मौजूद हों)
DROP TABLE IF EXISTS PlaylistTrack CASCADE;
DROP TABLE IF EXISTS InvoiceLine CASCADE;
DROP TABLE IF EXISTS Invoice CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Employee CASCADE;
DROP TABLE IF EXISTS Playlist CASCADE;
DROP TABLE IF EXISTS Track CASCADE;
DROP TABLE IF EXISTS MediaType CASCADE;
DROP TABLE IF EXISTS Genre CASCADE;
DROP TABLE IF EXISTS Album CASCADE;
DROP TABLE IF EXISTS Artist CASCADE;

-- 2. टेबल्स का निर्माण (Schema Creation)
CREATE TABLE Artist (
    ArtistId INT PRIMARY KEY,
    Name VARCHAR(255)
);

CREATE TABLE Album (
    AlbumId INT PRIMARY KEY,
    Title VARCHAR(255),
    ArtistId INT REFERENCES Artist(ArtistId)
);

CREATE TABLE Genre (
    GenreId INT PRIMARY KEY,
    Name VARCHAR(255)
);

CREATE TABLE MediaType (
    MediaTypeId INT PRIMARY KEY,
    Name VARCHAR(255)
);

CREATE TABLE Track (
    TrackId INT PRIMARY KEY,
    Name VARCHAR(255),
    AlbumId INT REFERENCES Album(AlbumId),
    MediaTypeId INT REFERENCES MediaType(MediaTypeId),
    GenreId INT REFERENCES Genre(GenreId),
    Composer VARCHAR(255),
    Milliseconds INT,
    Bytes INT,
    UnitPrice NUMERIC(10,2)
);

CREATE TABLE Playlist (
    PlaylistId INT PRIMARY KEY,
    Name VARCHAR(255)
);

CREATE TABLE PlaylistTrack (
    PlaylistId INT REFERENCES Playlist(PlaylistId),
    TrackId INT REFERENCES Track(TrackId),
    PRIMARY KEY (PlaylistId, TrackId)
);

CREATE TABLE Employee (
    EmployeeId INT PRIMARY KEY,
    LastName VARCHAR(255),
    FirstName VARCHAR(255),
    Title VARCHAR(255),
    ReportsTo INT REFERENCES Employee(EmployeeId),
    BirthDate TIMESTAMP,
    HireDate TIMESTAMP,
    Address VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    PostalCode VARCHAR(255),
    Phone VARCHAR(255),
    Fax VARCHAR(255),
    Email VARCHAR(255)
);

CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Company VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    PostalCode VARCHAR(255),
    Phone VARCHAR(255),
    Fax VARCHAR(255),
    Email VARCHAR(255),
    SupportRepId INT REFERENCES Employee(EmployeeId)
);

CREATE TABLE Invoice (
    InvoiceId INT PRIMARY KEY,
    CustomerId INT REFERENCES Customer(CustomerId),
    InvoiceDate TIMESTAMP,
    BillingAddress VARCHAR(255),
    BillingCity VARCHAR(255),
    BillingState VARCHAR(255),
    BillingCountry VARCHAR(255),
    BillingPostalCode VARCHAR(255),
    Total NUMERIC(10,2)
);

CREATE TABLE InvoiceLine (
    InvoiceLineId INT PRIMARY KEY,
    InvoiceId INT REFERENCES Invoice(InvoiceId),
    TrackId INT REFERENCES Track(TrackId),
    UnitPrice NUMERIC(10,2),
    Quantity INT
);

-- 3. 50-50 रोज़ का डमी डेटा इंसर्ट करना (Data Insertion)

-- Artist (50 Rows)
INSERT INTO Artist (ArtistId, Name) 
SELECT i, 'Artist ' || i FROM generate_series(1, 50) i;

-- Album (50 Rows)
INSERT INTO Album (AlbumId, Title, ArtistId) 
SELECT i, 'Album ' || i, (i % 50) + 1 FROM generate_series(1, 50) i;

-- Genre (50 Rows - Ensuring 'Rock' is present for queries)
INSERT INTO Genre (GenreId, Name) VALUES (1, 'Rock');
INSERT INTO Genre (GenreId, Name) 
SELECT i, 'Genre ' || i FROM generate_series(2, 50) i;

-- MediaType (50 Rows)
INSERT INTO MediaType (MediaTypeId, Name) 
SELECT i, 'Media Type ' || i FROM generate_series(1, 50) i;

-- Track (50 Rows - Normal distributed lengths around 250000ms)
INSERT INTO Track (TrackId, Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) 
SELECT i, 'Track ' || i, (i % 50) + 1, (i % 50) + 1, CASE WHEN i <= 25 THEN 1 ELSE (i % 50) + 1 END, 'Composer ' || i, 200000 + (i * 2000), 1000000 + (i * 5000), 0.99 FROM generate_series(1, 50) i;

-- Playlist (50 Rows)
INSERT INTO Playlist (PlaylistId, Name) 
SELECT i, 'Playlist ' || i FROM generate_series(1, 50) i;

-- PlaylistTrack (50 Rows)
INSERT INTO PlaylistTrack (PlaylistId, TrackId) 
SELECT i, i FROM generate_series(1, 50) i;

-- Employee (50 Rows - Hierarchy built using ReportsTo)
INSERT INTO Employee (EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate, HireDate, City, Country, Email) VALUES 
(1, 'Shrivastava', 'Rajanshu', 'General Manager', NULL, '1988-07-13', '2015-01-15', 'Bhopal', 'India', 'rajanshu@musicstore.com');
INSERT INTO Employee (EmployeeId, LastName, FirstName, Title, ReportsTo, BirthDate, HireDate, City, Country, Email) 
SELECT i, 'LName ' || i, 'FName ' || i, 'Sales Support', 1, '1990-05-05', '2020-06-01', 'City ' || i, 'Country ' || (i % 5 + 1), 'emp' || i || '@musicstore.com' FROM generate_series(2, 50) i;

-- Customer (50 Rows)
INSERT INTO Customer (CustomerId, FirstName, LastName, City, Country, Email, SupportRepId) 
SELECT i, 'CustFN ' || i, 'CustLN ' || i, CASE WHEN i <= 10 THEN 'Bhopal' ELSE 'City ' || i END, CASE WHEN i <= 15 THEN 'India' WHEN i <= 30 THEN 'USA' ELSE 'UK' END, CHR(65 + (i % 26)) || i || 'customer@gmail.com', (i % 49) + 2 FROM generate_series(1, 50) i;

-- Invoice (50 Rows - Varying totals for ranking queries)
INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, BillingCity, BillingCountry, Total) 
SELECT i, (i % 50) + 1, '2026-01-01'::TIMESTAMP + (i || ' days')::INTERVAL, CASE WHEN i <= 10 THEN 'Bhopal' ELSE 'City ' || i END, CASE WHEN i <= 15 THEN 'India' WHEN i <= 30 THEN 'USA' ELSE 'UK' END, (i * 5.50) FROM generate_series(1, 50) i;

-- InvoiceLine (50 Rows)
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) 
SELECT i, (i % 50) + 1, (i % 50) + 1, 0.99, 1 FROM generate_series(1, 50) i;

-- डेटा इन्सर्शन की सफलता जांचने के लिए टेस्ट प्रिंट
SELECT 'Database Created Successfully with 50 rows in each table!' AS Status;