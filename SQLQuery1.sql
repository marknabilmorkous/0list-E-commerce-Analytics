CREATE DATABASE Olist_Analytics;
USE Olist_Analytics
USE Olist_Analytics;

CREATE TABLE Customers
(
    customer_id VARCHAR(32) NOT NULL,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INT NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state VARCHAR(2) NOT NULL,

    CONSTRAINT PK_Customers
        PRIMARY KEY (customer_id)
);
INSERT INTO Customers
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM Customers_Staging;
---------------------------------order table
SELECT COUNT(*) AS total_rows
FROM Orders_Staging;

CREATE TABLE Orders
(
    order_id VARCHAR(32) NOT NULL,
    customer_id VARCHAR(32) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NOT NULL,

    CONSTRAINT PK_Orders PRIMARY KEY (order_id)
);

SELECT 
    order_id,
    COUNT(*) AS duplicate_count
FROM Orders_Staging
GROUP BY order_id
HAVING COUNT(*) > 1;

INSERT INTO Orders
(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
SELECT
    order_id,
    customer_id,
    order_status,
    TRY_CONVERT(DATETIME, order_purchase_timestamp, 103),
    TRY_CONVERT(DATETIME, NULLIF(order_approved_at, ''), 103),
    TRY_CONVERT(DATETIME, NULLIF(order_delivered_carrier_date, ''), 103),
    TRY_CONVERT(DATETIME, NULLIF(order_delivered_customer_date, ''), 103),
    TRY_CONVERT(DATETIME, order_estimated_delivery_date, 103)
FROM Orders_Staging;

SELECT COUNT(*) AS total_rows
FROM Orders;

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_count,
    COUNT(customer_id) AS customer_id_count,
    COUNT(order_status) AS status_count,
    COUNT(order_purchase_timestamp) AS purchase_date_count,
    COUNT(order_approved_at) AS approved_date_count,
    COUNT(order_delivered_carrier_date) AS carrier_date_count,
    COUNT(order_delivered_customer_date) AS customer_date_count,
    COUNT(order_estimated_delivery_date) AS estimated_date_count
FROM Orders;

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS unmatched_customers
FROM Orders o
LEFT JOIN Customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

DROP TABLE Orders_Staging;
-- --------------------------------- Order_Items
SELECT COUNT(*) AS total_rows
FROM Order_Items_Staging;

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM Order_Items_Staging
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_count,
    COUNT(order_item_id) AS item_id_count,
    COUNT(product_id) AS product_id_count,
    COUNT(seller_id) AS seller_id_count,
    COUNT(shipping_limit_date) AS shipping_date_count,
    COUNT(price) AS price_count,
    COUNT(freight_value) AS freight_count
FROM Order_Items_Staging;

CREATE TABLE Order_Items
(
    order_id VARCHAR(32) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(32) NOT NULL,
    seller_id VARCHAR(32) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    freight_value DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Order_Items
        PRIMARY KEY (order_id, order_item_id)
);

SELECT COUNT(*) AS total_rows
FROM Order_Items;

SELECT COUNT(*) AS Staging_Rows
FROM Order_Items_Staging;

SELECT COUNT(*) AS Order_Items_Rows
FROM Order_Items;

SELECT COUNT(*) AS Null_Shipping_Dates
FROM Order_Items
WHERE shipping_limit_date IS NULL;

SELECT TOP 10 *
FROM Order_Items;

SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT order_id) AS Unique_Orders,
    COUNT(DISTINCT product_id) AS Unique_Products
FROM Order_Items;

DROP TABLE Order_Items_Staging; 
---------------------------------prodact

SELECT COUNT(*) AS Total_Rows
FROM Products_Staging;

SELECT TOP 10 *
FROM Products_Staging;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(product_id) AS Product_ID_Not_Null,
    COUNT(product_weight_g) AS Weight_Not_Null,
    COUNT(product_length_cm) AS Length_Not_Null,
    COUNT(product_height_cm) AS Height_Not_Null,
    COUNT(product_width_cm) AS Width_Not_Null
FROM Products_Staging;

CREATE TABLE Products (
    product_id VARCHAR(32) NOT NULL,
    product_category_name NVARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT NULL,
    product_length_cm INT NULL,
    product_height_cm INT NULL,
    product_width_cm INT NULL,

    CONSTRAINT PK_Products PRIMARY KEY (product_id)

);

INSERT INTO Products (
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM Products_Staging;

SELECT COUNT(*) AS Products_Rows
FROM Products;

SELECT
    (SELECT COUNT(*) FROM Products_Staging) AS Staging_Rows,
    (SELECT COUNT(*) FROM Products) AS Products_Rows;

    DROP TABLE Products_Staging;

    SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
---------------------------------------------------Sellers
SELECT COUNT(*) AS Total_Rows
FROM Sellers_Staging;

SELECT TOP 10 *
FROM Sellers_Staging;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(seller_id) AS Seller_ID_Not_Null,
    COUNT(seller_zip_code_prefix) AS Zip_Not_Null,
    COUNT(seller_city) AS City_Not_Null,
    COUNT(seller_state) AS State_Not_Null
FROM Sellers_Staging;

CREATE TABLE Sellers (
    seller_id VARCHAR(32) NOT NULL,
    seller_zip_code_prefix VARCHAR(5) NOT NULL,
    seller_city NVARCHAR(100) NOT NULL,
    seller_state VARCHAR(2) NOT NULL,

    CONSTRAINT PK_Sellers PRIMARY KEY (seller_id)
);

INSERT INTO Sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM Sellers_Staging;

SELECT COUNT(*) AS Total_Rows
FROM Sellers;
SELECT

DROP TABLE Sellers_Staging;
----------------------------------Order_Payments
SELECT COUNT(*) AS Total_Rows
FROM Order_Payments_Staging;

SELECT TOP 10 *
FROM Order_Payments_Staging;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(order_id) AS Order_ID_Not_Null,
    COUNT(payment_sequential) AS Sequential_Not_Null,
    COUNT(payment_type) AS Payment_Type_Not_Null,
    COUNT(payment_installments) AS Installments_Not_Null,
    COUNT(payment_value) AS Payment_Value_Not_Null
FROM Order_Payments_Staging;

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS Duplicate_Count
FROM Order_Payments_Staging
GROUP BY
    order_id,
    payment_sequential
HAVING COUNT(*) > 1;

CREATE TABLE Order_Payments (
    order_id VARCHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(18,2) NOT NULL,

    CONSTRAINT PK_Order_Payments 
        PRIMARY KEY (order_id, payment_sequential)
);

INSERT INTO Order_Payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM Order_Payments_Staging;

SELECT COUNT(*) AS Total_Rows
FROM Order_Payments;

DROP TABLE Order_Payments_Staging;
------------------------------------Order_Reviews
SELECT COUNT(*) AS Total_Rows
FROM Order_Reviews_Staging;

SELECT TOP 10 *
FROM Order_Reviews_Staging;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(review_id) AS Review_ID_Not_Null,
    COUNT(order_id) AS Order_ID_Not_Null,
    COUNT(review_score) AS Score_Not_Null,
    COUNT(review_comment_title) AS Title_Not_Null,
    COUNT(review_comment_message) AS Message_Not_Null,
    COUNT(review_creation_date) AS Creation_Date_Not_Null,
    COUNT(review_answer_timestamp) AS Answer_Date_Not_Null
FROM Order_Reviews_Staging;

SELECT
    review_id,
    COUNT(*) AS Duplicate_Count
FROM Order_Reviews_Staging
GROUP BY review_id
HAVING COUNT(*) > 1;

SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM Order_Reviews_Staging
WHERE review_id IN (
    SELECT review_id
    FROM Order_Reviews_Staging
    GROUP BY review_id
    HAVING COUNT(*) > 1
)
ORDER BY review_id;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT review_id) AS Unique_Reviews,
    COUNT(DISTINCT order_id) AS Unique_Orders
FROM Order_Reviews_Staging;

SELECT
    COUNT(*) AS Duplicate_Review_Rows
FROM Order_Reviews_Staging
WHERE review_id IN (
    SELECT review_id
    FROM Order_Reviews_Staging
    GROUP BY review_id
    HAVING COUNT(*) > 1
);

SELECT
    review_id,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT order_id) AS Order_Count
FROM Order_Reviews_Staging
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY Order_Count DESC;

SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM Order_Reviews_Staging
WHERE review_id = '08528f70f579f0c830189efc523d2182';

SELECT
    review_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    COUNT(*) AS Duplicate_Count
FROM Order_Reviews_Staging
GROUP BY
    review_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;
select top 10 *
FROM Order_Reviews_Staging;


SELECT
    order_id,
    COUNT(*) AS Review_Count
FROM dbo.Order_Reviews_Staging
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY Review_Count DESC;

SELECT *
FROM dbo.Order_Reviews_Staging
WHERE order_id IN (
    SELECT order_id
    FROM dbo.Order_Reviews_Staging
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
ORDER BY order_id;

CREATE TABLE dbo.Order_Reviews
(
    review_id VARCHAR(32) NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title NVARCHAR(255) NULL,
    review_comment_message NVARCHAR(MAX) NULL,
    review_creation_date DATETIME NULL,
    review_answer_timestamp DATETIME NULL,

    CONSTRAINT PK_Order_Reviews
        PRIMARY KEY (review_id)
);

INSERT INTO dbo.Order_Reviews
(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM
(
    SELECT *,
        ROW_NUMBER() OVER
        (
            PARTITION BY review_id
            ORDER BY review_answer_timestamp DESC
        ) AS rn
    FROM dbo.Order_Reviews_Staging
) AS x
WHERE rn = 1;

SELECT COUNT(*) AS Total_Rows
FROM dbo.Order_Reviews;

SELECT review_id, COUNT(*) AS Duplicate_Count
FROM dbo.Order_Reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT review_id) AS Unique_Reviews,
    COUNT(DISTINCT order_id) AS Unique_Orders
FROM dbo.Order_Reviews;
--------------------------------------------------Olist_Geolocation

SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CONCAT(
        geolocation_zip_code_prefix, '|',
        geolocation_lat, '|',
        geolocation_lng, '|',
        geolocation_city, '|',
        geolocation_state
    )) AS Unique_Rows
FROM dbo.Olist_Geolocation_Raw;

SELECT TOP 20 *
FROM dbo.Olist_Geolocation_Raw;

CREATE TABLE dbo.Olist_Geolocation
(
    geolocation_id INT IDENTITY(1,1) NOT NULL,
    geolocation_zip_code_prefix INT NOT NULL,
    geolocation_lat DECIMAL(12,8) NOT NULL,
    geolocation_lng DECIMAL(12,8) NOT NULL,
    geolocation_city NVARCHAR(100) NULL,
    geolocation_state VARCHAR(2) NULL,

    CONSTRAINT PK_Olist_Geolocation_Final
        PRIMARY KEY (geolocation_id)
);

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Olist_Geolocation_Raw'
ORDER BY ORDINAL_POSITION;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS Null_Zip,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS Null_Lat,
    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS Null_Lng,
    SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS Null_City,
    SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS Null_State
FROM Olist_Geolocation_Raw;

INSERT INTO dbo.Olist_Geolocation
(
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM dbo.Olist_Geolocation_Raw;

SELECT COUNT(*) AS Final_Row_Count
FROM dbo.Olist_Geolocation;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS Distinct_Zip_Prefix,
    COUNT(DISTINCT geolocation_city) AS Distinct_Cities,
    COUNT(DISTINCT geolocation_state) AS Distinct_States
FROM dbo.Olist_Geolocation;

DROP TABLE dbo.Olist_Geolocation_Raw;

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Product_Category_Translation_Raw'
ORDER BY ORDINAL_POSITION;

SELECT
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS Null_Category_Name,
    SUM(CASE WHEN product_category_name2 IS NULL THEN 1 ELSE 0 END) AS Null_Category_Name2
FROM Product_Category_Translation_Raw;

CREATE TABLE dbo.Product_Category_Translation
(
    product_category_name VARCHAR(50) NOT NULL,
    product_category_name2 VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Product_Category_Translation
        PRIMARY KEY (product_category_name)
);

INSERT INTO dbo.Product_Category_Translation
(
    product_category_name,
    product_category_name2
)
SELECT
    product_category_name,
    product_category_name2
FROM dbo.Product_Category_Translation_Raw;

SELECT COUNT(*) AS Final_Row_Count
FROM dbo.Product_Category_Translation;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT product_category_name) AS Distinct_Portuguese,
    COUNT(DISTINCT product_category_name2) AS Distinct_English
FROM dbo.Product_Category_Translation;

SELECT TOP 5 *
FROM dbo.Products ;

ALTER TABLE dbo.Products
ADD product_category_name_en VARCHAR(50);

UPDATE P
SET P.product_category_name_en = T.product_category_name2
FROM dbo.Products AS P
LEFT JOIN dbo.Product_Category_Translation AS T
    ON P.product_category_name = T.product_category_name;

SELECT
    product_category_name,
    product_category_name_en
FROM dbo.Products
WHERE product_category_name IS NOT NULL;
----------------------------------------------
SELECT 
    t.name AS Table_Name,
    SUM(p.rows) AS Row_Count
FROM sys.tables t
INNER JOIN sys.partitions p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
GROUP BY t.name
ORDER BY t.name;

USE Olist_Analytics;
GO

-- 1. Orders → Customers
SELECT COUNT(*) AS Orphan_Orders_Customers
FROM dbo.Orders o
LEFT JOIN dbo.Customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

ALTER TABLE dbo.Orders
ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (customer_id)
REFERENCES dbo.Customers(customer_id);

SELECT COUNT(*) AS Orphan_Order_Items
FROM dbo.Order_Items oi
LEFT JOIN dbo.Orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

ALTER TABLE dbo.Order_Items
ADD CONSTRAINT FK_Order_Items_Orders
FOREIGN KEY (order_id)
REFERENCES dbo.Orders(order_id);

SELECT COUNT(*) AS Orphan_Order_Items_Products
FROM dbo.Order_Items oi
LEFT JOIN dbo.Products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

ALTER TABLE dbo.Order_Items
ADD CONSTRAINT FK_Order_Items_Products
FOREIGN KEY (product_id)
REFERENCES dbo.Products(product_id);

SELECT COUNT(*) AS Orphan_Order_Items_Sellers
FROM dbo.Order_Items oi
LEFT JOIN dbo.Sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

ALTER TABLE dbo.Order_Items
ADD CONSTRAINT FK_Order_Items_Sellers
FOREIGN KEY (seller_id)
REFERENCES dbo.Sellers(seller_id);
-----------------------------------Order_Payments → Orders

SELECT COUNT(*) AS Orphan_Order_Payments
FROM dbo.Order_Payments op
LEFT JOIN dbo.Orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

ALTER TABLE dbo.Order_Payments
ADD CONSTRAINT FK_Order_Payments_Orders
FOREIGN KEY (order_id)
REFERENCES dbo.Orders(order_id);
---Order_Reviews → Orders

SELECT COUNT(*) AS Orphan_Order_Reviews
FROM dbo.Order_Reviews r
LEFT JOIN dbo.Orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

ALTER TABLE dbo.Order_Reviews
ADD CONSTRAINT FK_Order_Reviews_Orders
FOREIGN KEY (order_id)
REFERENCES dbo.Orders(order_id);

SELECT 
    fk.name AS Foreign_Key,
    OBJECT_NAME(fk.parent_object_id) AS Child_Table,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS Child_Column,
    OBJECT_NAME(fk.referenced_object_id) AS Parent_Table,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS Parent_Column
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
ORDER BY Child_Table, Foreign_Key;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE CONSTRAINT_NAME IN (
    SELECT CONSTRAINT_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_TYPE = 'PRIMARY KEY'
)
ORDER BY TABLE_NAME;

SELECT
    fk.name AS Foreign_Key,
    OBJECT_NAME(fk.parent_object_id) AS Child_Table,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS Child_Column,
    OBJECT_NAME(fk.referenced_object_id) AS Parent_Table,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS Parent_Column
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
ORDER BY Child_Table, Foreign_Key;


-- 1. Order_Items → Orders
SELECT COUNT(*) AS Orphan_Order_Items_Orders
FROM dbo.Order_Items oi
LEFT JOIN dbo.Orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 2. Order_Items → Products
SELECT COUNT(*) AS Orphan_Order_Items_Products
FROM dbo.Order_Items oi
LEFT JOIN dbo.Products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- 3. Order_Items → Sellers
SELECT COUNT(*) AS Orphan_Order_Items_Sellers
FROM dbo.Order_Items oi
LEFT JOIN dbo.Sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- 4. Order_Payments → Orders
SELECT COUNT(*) AS Orphan_Order_Payments_Orders
FROM dbo.Order_Payments op
LEFT JOIN dbo.Orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 5. Order_Reviews → Orders
SELECT COUNT(*) AS Orphan_Order_Reviews_Orders
FROM dbo.Order_Reviews r
LEFT JOIN dbo.Orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 6. Orders → Customers
SELECT COUNT(*) AS Orphan_Orders_Customers
FROM dbo.Orders o
LEFT JOIN dbo.Customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

CREATE VIEW dbo.vw_Sales_Analysis
AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.shipping_limit_date,
    oi.price,
    oi.freight_value,

    p.product_category_name_en,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state

FROM dbo.Order_Items AS oi

INNER JOIN dbo.Orders AS o
    ON oi.order_id = o.order_id

LEFT JOIN dbo.Products AS p
    ON oi.product_id = p.product_id

LEFT JOIN dbo.Sellers AS s
    ON oi.seller_id = s.seller_id;
GO

CREATE VIEW dbo.vw_Payment_Analysis
AS
SELECT
    op.order_id,
    op.payment_sequential,
    op.payment_type,
    op.payment_installments,
    op.payment_value,

    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date

FROM dbo.Order_Payments AS op

INNER JOIN dbo.Orders AS o
    ON op.order_id = o.order_id;
GO

CREATE VIEW dbo.vw_Review_Analysis
AS
SELECT
    r.review_id,
    r.order_id,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message,
    r.review_creation_date,
    r.review_answer_timestamp,

    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date

FROM dbo.Order_Reviews AS r

INNER JOIN dbo.Orders AS o
    ON r.order_id = o.order_id;
GO

CREATE VIEW dbo.vw_Customer_Analysis
AS
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state
FROM dbo.Customers AS c;
GO

CREATE VIEW dbo.vw_Product_Analysis
AS
SELECT
    p.product_id,
    p.product_category_name_en,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM dbo.Products AS p;
GO

CREATE VIEW dbo.vw_Seller_Analysis
AS
SELECT
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state
FROM dbo.Sellers AS s;
GO

CREATE VIEW dbo.vw_Geolocation_Analysis
AS
SELECT
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) AS latitude,
    AVG(geolocation_lng) AS longitude,
    MAX(geolocation_city) AS city,
    MAX(geolocation_state) AS state
FROM dbo.Olist_Geolocation
GROUP BY
    geolocation_zip_code_prefix;
GO

SELECT COUNT(*) AS View_Rows
FROM dbo.vw_Geolocation_Analysis;


CREATE OR ALTER VIEW dbo.vw_Customer_Analysis
AS
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    g.latitude,
    g.longitude
FROM dbo.Customers AS c
LEFT JOIN dbo.vw_Geolocation_Analysis AS g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;
GO

CREATE OR ALTER VIEW dbo.vw_Seller_Analysis
AS
SELECT
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,
    g.latitude,
    g.longitude
FROM dbo.Sellers AS s
LEFT JOIN dbo.vw_Geolocation_Analysis AS g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix;
GO

CREATE OR ALTER VIEW dbo.vw_Sales_Analysis
AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.shipping_limit_date,
    oi.price,
    oi.freight_value,

    p.product_category_name_en,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,
    s.latitude,
    s.longitude

FROM dbo.Order_Items AS oi

INNER JOIN dbo.Orders AS o
    ON oi.order_id = o.order_id

LEFT JOIN dbo.Products AS p
    ON oi.product_id = p.product_id

LEFT JOIN dbo.vw_Seller_Analysis AS s
    ON oi.seller_id = s.seller_id;
GO
