-- Retail Sales Performance Analysis SQL Project
create database retail_project;
use retail_project;
-- 1. Create Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    state VARCHAR(50),
    registration_date DATE
);

-- insert data in customers table
BULK INSERT CUSTOMERS
FROM 'D:\New folder\jupyter folder\customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	)
SELECT * FROM customers;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    supplier_id INT
);

BULK INSERT products
FROM 'D:\New folder\jupyter folder\products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	)

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    name VARCHAR(100),
    contact_email VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(10)
);

BULK INSERT SUPPLIERS
FROM 'D:\New folder\jupyter folder\suppliers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);

SELECT * FROM SUPPLIERS;

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50)
);

BULK INSERT STORES
FROM 'D:\New folder\jupyter folder\stores.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    store_id INT,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

BULK INSERT ORDERS
FROM 'D:\New folder\jupyter folder\orders.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

BULK INSERT ORDER_ITEMS
FROM 'D:\New folder\jupyter folder\order_items.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);

-- a. Monthly Sales Trend
SELECT 
    FORMAT(order_date, 'yyyy-MM') AS month, 
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY month;

-- b. Top 5 Best-Selling Products
SELECT TOP 5 
    p.name, 
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name
ORDER BY total_sold DESC;

-- c. Customer Lifetime Value
SELECT 
    customer_id, 
    SUM(total_amount) AS lifetime_value
FROM orders
GROUP BY customer_id
ORDER BY lifetime_value DESC;

-- d. Store Performance by Revenue
SELECT 
    s.store_name, 
    SUM(o.total_amount) AS revenue
FROM orders o
JOIN stores s ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY revenue DESC;

-- e. Product Profit Margin
SELECT 
    name, 
    (price - cost) AS margin
FROM products
ORDER BY margin DESC;

-- f. Create View for Monthly KPI
CREATE VIEW monthly_kpi AS
SELECT 
    FORMAT(order_date, 'yyyy-MM') AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY FORMAT(order_date, 'yyyy-MM');

-- g. Use Window Function: Rank Top Customers
SELECT 
    customer_id,
    SUM(total_amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS rank
FROM orders
GROUP BY customer_id;

-- End of Project

