CREATE DATABASE excel_import_practice;
USE excel_import_practice;

SELECT * FROM customers_import;


ALTER TABLE customers_import
RENAME COLUMN ï»¿customer_id TO customer_id;

SELECT customer_id, COUNT(*) AS id_count
FROM customers_import
GROUP BY customer_id;

ALTER TABLE customers_import
MODIFY COLUMN customer_id INT NOT NULL,
ADD PRIMARY KEY (customer_id);

ALTER TABLE customers_import
MODIFY COLUMN first_name VARCHAR (50) NOT NULL;

ALTER TABLE customers_import
MODIFY COLUMN last_name VARCHAR (50) NOT NULL;


ALTER TABLE customers_import
MODIFY COLUMN city VARCHAR (50);

ALTER TABLE customers_import
MODIFY COLUMN country VARCHAR(50);

SELECT email, COUNT(*) AS email_count
FROM customers_import
GROUP BY email
HAVING COUNT(*) > 1;

SELECT *
FROM customers_import
WHERE email IS NULL;

ALTER TABLE customers_import
MODIFY COLUMN email VARCHAR (100) UNIQUE;
-- OR
ALTER TABLE customers_import
ADD CONSTRAINT unique_customer_email
UNIQUE (email);

SELECT COUNT(*) AS total_customers
FROM customers_import;

SELECT *
FROM customers_import
LIMIT 10;

SELECT email, COUNT(*) AS email_count
FROM customers_import
GROUP BY email
HAVING COUNT(*) > 1;

SELECT *
FROM customers_import
WHERE email IS NULL;

SELECT *
FROM customers_import
WHERE first_name IS NULL
   OR last_name IS NULL
   OR age IS NULL
   OR city IS NULL
   OR country IS NULL
   OR email IS NULL;

SELECT *
FROM customers_import
WHERE age < 18
   OR age > 100;
   
SELECT city, COUNT(*) AS customer_count
FROM customers_import
GROUP BY city
ORDER BY customer_count DESC;

SELECT country, COUNT(*) AS customer_count
FROM customers_import
GROUP BY country
ORDER BY customer_count DESC;

SELECT city,
COUNT(*) AS city_count
FROM customers_import
GROUP BY city
HAVING COUNT(*) > 1;

SELECT customer_id, 
COUNT(*) AS customer_count 
FROM customers_import 
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Duplicate emails
# GROUP BY email
# HAVING COUNT(*) > 1

-- Duplicate customer IDs
# GROUP BY customer_id
# HAVING COUNT(*) > 1

-- Cities with multiple customers
# GROUP BY city
# HAVING COUNT(*) > 1



SELECT	first_name,
		last_name,
		email,
        COUNT(*) AS customer_count
FROM customers_import
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;
 
 SELECT email,
       COUNT(*) AS email_count
FROM customers_import
GROUP BY email
HAVING COUNT(*) > 1;

SELECT first_name,
       last_name,
       email
FROM customers_import
WHERE email IN (
    SELECT email
    FROM customers_import
    GROUP BY email
    HAVING COUNT(*) > 1
);

-- Write a query that returns customers who live in any city that has more than one customer.
SELECT first_name,
		last_name
FROM customers_import
WHERE city IN (
	SELECT city
	FROM customers_import
	GROUP BY city
	HAVING COUNT(*) > 1);

SELECT first_name, last_name, age
FROM customers_import
WHERE age > (
    SELECT AVG(age)
    FROM customers_import
);


SELECT first_name, last_name, age
FROM customers_import
WHERE age = (
SELECT MAX(age)
FROM customers_import);


SELECT city,
COUNT(*) AS customer_count
FROM customers_import
GROUP BY city
HAVING COUNT(*) > 1;

-- Write a query that returns the first name, last name, and email for customers whose email appears more than once.
SELECT first_name,
last_name,
email
FROM customers_import
WHERE email IN (SELECT email
FROM customers_import
GROUP BY email
HAVING COUNT(*) > 1);

SELECT AVG(customer_count) AS avg_customers_per_city
FROM (
    SELECT city,
           COUNT(*) AS customer_count
    FROM customers_import
    GROUP BY city
) AS city_summary;


SELECT * FROM
(SELECT city,
           COUNT(*) AS customer_count
    FROM customers_import
    GROUP BY city) AS city_summary;

-- Using the same city_summary subquery, write a query that returns only the cities whose customer count is greater than the average number of customers per city.
-- In plain English: From our city summary, show me cities that have more customers than the average city.
SELECT city,
		customer_count
FROM (
    SELECT AVG(customer_count)
    FROM (
        SELECT city,
               COUNT(*) AS customer_count
        FROM customers_import
        GROUP BY city
    ) AS city_summary) AS city_count;

SELECT city,
       customer_count
FROM (
    SELECT city,
           COUNT(*) AS customer_count
    FROM customers_import
    GROUP BY city
) AS city_summary
WHERE customer_count > (
    SELECT AVG(customer_count)
    FROM (
        SELECT city,
               COUNT(*) AS customer_count
        FROM customers_import
        GROUP BY city
    ) AS city_counts
);



-- CTEs

WITH city_summary AS (
    SELECT city,
           COUNT(*) AS customer_count
    FROM customers_import
    GROUP BY city
)
SELECT *
FROM city_summary;


-- age_summary
-- Inside the CTE, calculate: city, the average age of customers in that city

WITH age_summary AS (
SELECT	city,
		AVG(age) AS avg_age
FROM customers_import
GROUP BY city
)
SELECT * FROM age_summary;


-- Show only cities where the average customer age is greater than 30.
WITH age_summary AS (
SELECT	city,
		AVG(age) AS avg_age
FROM customers_import
GROUP BY city
)
SELECT * FROM age_summary
WHERE avg_age > 30;


-- create a CTE called: city_summary
-- that produces: city | customer_count
WITH city_summary AS (
SELECT city,
		COUNT(*) AS customer_count
FROM customers_import
GROUP BY city
)
SELECT AVG(customer_count)
FROM city_summary;

-- We want to find Cities whose customer count is greater than the average customer count across all cities.
-- Using CTE
WITH city_summary AS (
    SELECT city,
           COUNT(*) AS customer_count
    FROM customers_import
    GROUP BY city
)
SELECT city, customer_count
FROM city_summary
WHERE customer_count > (SELECT AVG(customer_count) FROM city_summary
);

-- We want to find Cities whose customer count is greater than the average customer count across all cities.
-- Using Subquery
SELECT city,
       customer_count
FROM (
    SELECT city,
           COUNT(*) AS customer_count
    FROM customers_import
    GROUP BY city
) AS city_summary
WHERE customer_count > (
    SELECT AVG(customer_count)
    FROM (
        SELECT COUNT(*) AS customer_count
        FROM customers_import
        GROUP BY city
    ) AS city_counts
);

-- Find the city (or cities) whose customer count is equal to the highest customer count among all cities.
WITH city_summary AS (
SELECT 	city,
		COUNT(*) AS customer_count
FROM customers_import
GROUP BY city)
SELECT	city, customer_count
FROM city_summary
WHERE customer_count = (SELECT MAX(customer_count) FROM city_summary);

-- Find all customers whose age is greater than the average age of all customers.
-- CTE
WITH age_summary AS (
    SELECT * FROM customers_import
)
SELECT *
FROM age_summary
WHERE age > (SELECT AVG(age) FROM age_summary);

-- Find all customers whose age is greater than the average age of all customers.
-- Subquery
SELECT *
FROM customers_import
WHERE age > (SELECT 
AVG(age) AS avg_age
FROM customers_import
);


-- Find the customers who live in a city whose average customer age is greater than 30.
WITH city_summary AS (
SELECT 	city,
		AVG(age) AS avg_age
FROM customers_import
GROUP BY city
HAVING avg_age > 30)
SELECT *
FROM customers_import
WHERE city IN (SELECT city FROM city_summary);

WITH city_summary AS (
    SELECT city
    FROM customers_import
    GROUP BY city
    HAVING AVG(age) > 30
)
SELECT *
FROM customers_import
WHERE city IN (SELECT city FROM city_summary);


-- Find the city (or cities) whose average customer age is higher than the overall average customer age.
WITH city_summary AS (
SELECT	city,
		AVG(age) AS avg_age
FROM customers_import
GROUP BY city
)
SELECT 	city,
		avg_age
FROM city_summary
WHERE avg_age > (SELECT AVG(age)
FROM customers_import);


-- Find the customer(s) who are older than the average age of their own city.
-- Return: first_name, last_name, city, age
WITH customer_summary AS (
SELECT	city,
		AVG(age) AS avg_age
FROM customers_import
GROUP BY city)
SELECT first_name, last_name, ci.city, age
FROM customers_import ci
JOIN customer_summary cs
ON ci.city = cs.city
WHERE ci.age > cs.avg_age;

-- Find the city/cities whose average age is higher than the average age of all cities.
-- Return: city, avg_age
WITH city_summary AS (
SELECT city, AVG(age) AS avg_age
FROM customers_import
GROUP BY city)
SELECT city, avg_age
FROM city_summary
WHERE avg_age > (SELECT AVG(age)
FROM customers_import);


-- creating TEMP TABLES
-- Create a temporary table called: city_summary
-- It should contain: city, customer_count
-- And it should store the number of customers in each city.

CREATE TEMPORARY TABLE city_summary (
	SELECT 	city,
			COUNT(*) AS customer_count
	FROM customers_import
    GROUP BY city
);


DROP TABLE IF EXISTS city_summary;
CREATE TEMPORARY TABLE city_summary AS
	SELECT 	city,
			COUNT(*) AS customer_count
FROM customers_import
GROUP BY city;

SELECT * FROM city_summary;
SELECT AVG(customer_count) FROM city_summary;

DROP TABLE IF EXISTS avg_count;
CREATE TEMPORARY TABLE avg_count AS
SELECT AVG(customer_count) AS avg_count FROM city_summary;

-- write a new query that finds: Cities whose customer count is greater than the average customer count across all cities.
SELECT city, customer_count
FROM city_summary cs
CROSS JOIN avg_count ac
WHERE cs.customer_count > ac.avg_count; 

-- "Create a temporary table containing customers who are older than 30. 
-- Then, using that temporary table, find how many of those customers live in each city."

DROP TABLE IF EXISTS customers_above_30;
CREATE TEMPORARY TABLE customers_above_30 AS 
SELECT * FROM customers_import
WHERE age > 30;

-- Using only that temporary table, produce: city | customer_count
SELECT	city,
		COUNT(*) AS customer_count
FROM customers_above_30
GROUP BY city;

SELECT * FROM customers_above_30;

-- "Create a temporary table containing customers from Nigeria who are aged 25 or older. 
-- Then use that temporary table to find the average age for each city."
DROP TABLE IF EXISTS customers_filtered;
CREATE TEMPORARY TABLE customers_filtered AS
SELECT city, age
FROM customers_import
WHERE country = 'Nigeria' AND 
age >= 25;

SELECT city,
		AVG(age) AS avg_age
FROM customers_filtered
GROUP BY city;


-- Create a temporary table called: customers_cleaned
-- It should contain: customer_id, first_name, last_name, email
-- But use TRIM() to remove leading/trailing spaces from the names.

DROP TABLE IF EXISTS customers_cleaned;
CREATE TEMPORARY TABLE customers_cleaned AS
SELECT	customer_id,
		TRIM(first_name) AS first_name,
        TRIM(last_name) AS last_name,
        email
FROM customers_import;

SELECT * FROM customers_cleaned;

-- Create a temporary table called: customers_final
-- It should contain: customer_id, first_name, last_name, email
DROP TABLE IF EXISTS customers_final;
CREATE TEMPORARY TABLE customers_final AS
SELECT	customer_id,
		TRIM(first_name) AS first_name,
        TRIM(last_name) AS last_name,
        NULLIF(TRIM(email), 'NULL') AS email
FROM customers_import;

SELECT * FROM customers_final;



-- Write a query that tests these three values: 'NULL', ' John ', ' NULL '
-- and uses TRIM() + NULLIF() to turn the two NULL-text variations into actual NULL.
SELECT NULLIF(TRIM('NULL'), 'NULL');

SELECT NULLIF(TRIM(' John '), 'NULL');

SELECT NULLIF(TRIM(' NULL '), 'NULL');




-- Customers whose age is greater than the overall average age.
CREATE TEMPORARY TABLE customers_avg_age AS
SELECT AVG(age) AS overall_avg_age
FROM customers_import;

SELECT c.* FROM customers_import ci
CROSS JOIN customer_avg_age ca
ON ci.age > ca.overall_avg_age;


-- "Find the cities whose average customer age is higher than the overall average customer age."
# SELECT city
# FROM customers_import
# WHERE 


-- CASE — Exercise #1
-- Using customers_import, write a query that displays: first_name, last_name, age
-- a new column called age_group
SELECT	first_name,
		last_name,
        age,
CASE 
	WHEN age < 25
    THEN 'Young'
    WHEN age BETWEEN 25 AND 35
    THEN 'Adult'
    WHEN age > 35
    THEN 'Senior'
END AS age_group
FROM customers_import;

-- Create a new calculated column called: customer_status
-- based on age:
-- Under 25 → Junior
-- 25–35 → Regular
-- Over 35 → Senior
-- Return: first_name, last_name, age, customer_status
SELECT first_name, last_name, age,
CASE
	WHEN age < 25 THEN 'Junior'
    WHEN age BETWEEN 25 AND 35 THEN 'Regular'
    WHEN age > 35 THEN 'Senior'
END AS customer_status
FROM customers_import;


-- 

-- Create a new calculated column called: customer_status
-- based on age:
-- Under 25 → Junior
-- 25–35 → Regular
-- Over 35 → Senior
-- Else 
-- Return: first_name, last_name, age, customer_status
SELECT first_name, last_name, age,
CASE
	WHEN age < 25 THEN 'Junior'
    WHEN age BETWEEN 25 AND 35 THEN 'Regular'
    WHEN age > 35 THEN 'Senior'
    ELSE 'Unknown'
END AS customer_status
FROM customers_import;


-- CASE Exercise #4 — Now we're getting practical
-- Write a query returning: first_name ,last_name ,email ,email_status
-- Rules:
-- If email IS NULL → 'Missing'
-- If email contains '@' → 'Valid'
-- Otherwise → 'Invalid'
SELECT first_name, last_name, email,
CASE 
	WHEN email IS NULL THEN 'Missing'
    WHEN email LIKE '%@%' THEN 'Valid'
    ELSE 'Invalid'
END AS email_status
FROM customers_import;


-- CASE Exercise #5 — Combining conditions
-- We want to classify each customer based on both age AND email quality.
-- Return: first_name, last_name, age, email, customer_category
-- Rules: Condition	Category
-- Age < 25 AND email exists	Young - Contactable
-- Age < 25 AND email is missing	Young - No Contact
-- Age >= 25 AND email exists	Adult - Contactable
-- Age >= 25 AND email is missing	Adult - No Contact
SELECT first_name, last_name, age, email,
CASE
	WHEN age < 25 AND email IS NOT NULL THEN 'Young - Contactable'
    WHEN age < 25 AND email IS NULL THEN 'Young - No Contact'
    WHEN age >= 25 AND email IS NOT NULL THEN 'Adult - Contactable'
    WHEN age >= 25 AND email IS NULL THEN 'Adult - No Contact'
    ELSE 'Unknown'
END AS customer_category
FROM customers_import;


-- CASE Challenge #6 — Real data-cleaning scenario
-- Imagine an imported customer file has an age column where some values might be: NULL, under 18, 18–64, 65+
-- Create: age_status
-- with:
# NULL → Missing Age
# < 18 → Underage
# 18–64 → Working Age
# 65+ → Senior
-- Return: first_name, last_name, age,age_status
SELECT	 first_name, last_name, age,
CASE
	WHEN age IS NULL THEN 'Missing Age'
    WHEN age < 18 THEN 'Underage'
    WHEN age BETWEEN 18 AND 64 THEN 'Working Age'
    WHEN age >= 65 THEN 'Senior'
	ELSE 'Unknown'
END AS age_status
FROM customers_import;


-- Challenge #7
-- We want to know how many customers fall into each age group.
-- Return: age_status | customer_count
-- Use the same age rules:
-- < 25 → Young
-- 25–35 → Adult
-- > 35 → Senior
SELECT age_status, COUNT(*) AS customer_count
FROM (
SELECT first_name, last_name, age, city,
CASE
	WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 35 THEN 'Adult'
    WHEN age > 35 THEN 'Senior'
    ELSE 'Unknown'
END AS age_status
FROM customers_import) AS classified_customers
GROUP BY age_status;


-- Challenge #8 — Let's see if you can do this without a subquery.
-- Show the total number of customers in each age group, but this time use a CTE.
-- Same categories:
-- < 25 → Young
-- 25–35 → Adult
-- > 35 → Senior
WITH classified_customers AS (
SELECT first_name, last_name, age, city,
CASE
	WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 35 THEN 'Adult'
    WHEN age > 35 THEN 'Senior'
    ELSE 'Unknown'
END AS age_status
FROM customers_import)
SELECT age_status, COUNT(*) AS customer_count
FROM classified_customers
GROUP BY age_status;


-- CASE Challenge #9 — A real-world validation question
-- Let's combine several things you've learned.
-- We want to know how many customers are contactable in each age group.
-- Rules:
# < 25 → Young
# 25–35 → Adult
# > 35 → Senior
-- A customer is contactable if: email IS NOT NULL
-- Return: age_status | contactable_count
WITH classified_customers AS (
SELECT first_name, last_name, age, city, email,
CASE
	WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 35 THEN 'Adult'
    WHEN age > 35 THEN 'Senior'
    ELSE 'Unknown'
END AS age_status
FROM customers_import)
SELECT age_status, COUNT(*) AS contactable_count
FROM classified_customers
WHERE email IS NOT NULL
GROUP BY age_status;

-- hallenge #10 — Same data, more information
-- Now return: age_status | contactable_count | non_contactable_count
WITH classified_customers AS (
SELECT first_name, last_name, age, city, email,
CASE
	WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 35 THEN 'Adult'
    WHEN age > 35 THEN 'Senior'
    ELSE 'Unknown'
END AS age_status
FROM customers_import)
SELECT age_status,
SUM(CASE
        WHEN email IS NOT NULL THEN 1
        ELSE 0
    END) AS contactable_count,
SUM(CASE
        WHEN email IS NULL THEN 1
        ELSE 0
    END) AS non_contactable_count
FROM classified_customers
GROUP BY age_status;


-- Challenge #11 — CASE + GROUP BY + HAVING
-- Find the number of customers in each age group, but only return age groups that have more than 1 customer.
WITH classified_customers AS (
SELECT first_name, last_name, age, city, email,
CASE
	WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 35 THEN 'Adult'
    WHEN age > 35 THEN 'Senior'
    ELSE 'Unknown'
END AS age_status
FROM customers_import)
SELECT age_status, COUNT(*) AS customer_count
FROM classified_customers
GROUP BY age_status
HAVING customer_count > 1;


-- Challenge #12 — CASE + HAVING
-- Find the age group whose average age is greater than 30.
-- Return: age_status | average_age
WITH classified_customers AS (
SELECT first_name, last_name, age, city, email,
CASE
	WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 35 THEN 'Adult'
    WHEN age > 35 THEN 'Senior'
    ELSE 'Unknown'
END AS age_status
FROM customers_import)
SELECT age_status,
		AVG(age) AS avg_age
FROM classified_customers
GROUP BY age_status
HAVING avg_age > 30;


-- Challenge #13 — we're combining what you've learned
-- Find the number of contactable customers in each age group, and return only age groups where the contactable count is greater than 1.
-- Return: age_status | contactable_count
WITH classified_customers AS (
 SELECT first_name, last_name, age, city, email,
 CASE
	WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 35 THEN 'Adult'
    WHEN age > 35 THEN 'Senior'
    ELSE 'Unknown'
END AS age_status
FROM customers_import)
SELECT age_status,
SUM(CASE
        WHEN email IS NOT NULL THEN 1
        ELSE 0
    END) AS contactable_count
FROM classified_customers
GROUP BY age_status
HAVING contactable_count > 1;


-- Challenge #14 — final CASE workout 😈
-- For each city, return: city | contactable_count | non_contactable_count
SELECT city,
SUM(CASE
		WHEN email IS NOT NULL THEN 1
        ELSE 0
	END) AS contactable_count,
SUM(CASE
		WHEN email IS NULL THEN 1
        ELSE 0
	END) AS non_contactable_count
FROM customers_import
GROUP BY city
ORDER BY city;



USE excel_import_practice;

DROP TABLE IF EXISTS orders_import;

CREATE TABLE orders_import (
	order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers_import (customer_id)
);

INSERT INTO orders_import (order_id, customer_id, order_date, amount)
VALUES (1001, 1, '2026-01-10', 150000.00),
		(1002, 1, '2026-02-15', 75000.00),
        (1003, 2, '2026-01-20', 200000.00),
        (1004, 3, '2026-03-05', 50000.00),
        (1005, 4, '2026-01-25', 300000.00),
        (1006, 4, '2026-02-28', 125000.00),
        (1007, 5, '2026-03-10', 80000.00);




-- Challenge #1
-- Show each customer's name and their total amount spent.
-- Return: first_name | last_name | total_spent
SELECT	ci.first_name,
		ci.last_name,
        SUM(oi.amount) AS total_spent
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id;


-- Advanced JOIN Challenge #2
-- Show only customers whose total spending is greater than ₦200,000.
-- Return: first_name | last_name | total_spent
SELECT	first_name,
		last_name,
        SUM(oi.amount) AS total_spent
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id
HAVING total_spent > 200000;


-- Advanced JOIN Challenge #3
-- Show each city and the total amount spent by customers in that city.
-- Return: city | total_spent
SELECT 	ci.city,
		SUM(oi.amount) AS total_spent
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.city;


-- Advanced JOIN Challenge #4
-- Let's add another aggregate.
-- For each city, show: city | order_count | total_spent | average_order
SELECT	ci.city,
		COUNT(*) AS order_count,
        SUM(oi.amount) AS total_spent,
        AVG(oi.amount) AS average_order
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.city
ORDER BY city;


-- Challenge #5 — The real test
-- Show each city's total spending, but return only cities whose total spending is greater than ₦100,000, ordered from highest spending to lowest.
-- Return: city | total_spent
SELECT	ci.city,
		SUM(oi.amount) AS total_spent
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY city
HAVING total_spent > 100000
ORDER BY total_spent DESC;


-- Advanced JOIN Challenge #6 — Customer-level analysis
-- Find the top 3 customers by total spending.
-- Return: first_name | last_name | total_spent
SELECT	first_name,
		last_name,
        SUM(oi.amount) AS total_spent
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id
ORDER BY total_spent DESC
LIMIT 3;


-- Challenge #7 — Now we make it interesting
-- Which customers have placed more than one order?
-- Return: first_name | last_name | order_count
SELECT	first_name,
		last_name,
        COUNT(*) AS order_count
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id
HAVING order_count > 1;


-- Challenge #8 — Customer spending + order count
-- Show customers who have placed more than one order AND whose total spending exceeds ₦200,000.
-- Return: first_name | last_name | order_count | total_spent
SELECT	first_name,
		last_name,
        COUNT(*) AS order_count,
        SUM(oi.amount) AS total_spent
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id
HAVING order_count > 1
AND total_spent > 200000;


-- Challenge #9 — A small twist
-- For each customer, find their average order amount, but only show customers whose average order amount is greater than ₦100,000.
-- Return: first_name | last_name | average_order
SELECT	first_name,
		last_name,
        AVG(oi.amount) AS average_order
FROM customers_import ci
JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id
HAVING average_order > 100000;


-- Challenge #10 — Let's introduce a subtle JOIN issue
-- Show ALL customers, including customers who have placed no orders, and show their total spending.
-- Return: first_name | last_name | total_spent
SELECT	first_name,
		last_name,
        coalesce(SUM(oi.amount), 0) total_spent
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id;


-- Advanced JOIN — Challenge #11
-- Which customers have NOT placed any orders?
-- Return: first_name | last_name
SELECT	first_name,
		last_name
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
WHERE order_id IS NULL;


-- Challenge #12 — Let's make it slightly harder
-- Show every customer and the number of orders they have placed, including customers with zero orders.
-- Return: first_name | last_name | order_count
SELECT	first_name,
		last_name,
        (COUNT(oi.order_id), 0) order_count
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id;


-- Challenge #13
-- Show every customer, their number of orders, and their total spending — including customers with zero orders.
-- Return: first_name | last_name | order_count | total_spent
SELECT	first_name,
		last_name,
        COUNT(oi.order_id) AS order_count,
        coalesce(SUM(oi.amount), 0) AS total_spent
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id;


-- Challenge #14 — Now let's make the question more interesting
-- Show every customer who has placed at least one order, but only if their total spending is greater than 100,000.
-- Return: first_name | last_name | total_spent
SELECT	first_name,
		last_name,
        SUM(oi.amount) AS total_spent
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id
HAVING total_spent > 100000;


-- Challenge #15
-- Show each city and the total amount spent by customers in that city, but include cities even if they have no orders.
-- Return: city | total_spent
SELECT	city,
		coalesce(SUM(oi.amount), 0) AS total_spent
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY city;


-- Challenge #16 — Let's introduce a useful twist
-- Show each city, the number of customers in that city, and the total amount spent by customers in that city.
-- Return: city | customer_count | total_spent
SELECT 	city,
		COUNT(DISTINCT ci.customer_id) AS customer_count,
		coalesce(SUM(oi.amount), 0) AS total_spent
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.city;


-- Challenge #17 — Let's raise the difficulty
-- Show cities that have at least 2 customers AND whose customers have spent more than 300,000 in total.
-- Return: city | customer_count | total_spent
SELECT city,
		COUNT(DISTINCT ci.customer_id) AS customer_count,
        coalesce(SUM(oi.amount), 0) AS total_spent
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY city
HAVING customer_count >= 2
AND total_spent > 300000;

-- Challenge #18 — Customer-level filtering
-- Show customers who have placed at least 2 orders AND whose average order amount is greater than 100,000.
-- Return: first_name | last_name | order_count | average_order
SELECT	first_name,
		last_name,
        COUNT(oi.order_id) AS order_count,
        AVG(oi.amount) AS average_order
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
GROUP BY ci.customer_id
HAVING order_count >= 2
AND average_order > 100000;


-- Challenge #19
-- Show all customers and their total spending, but only count orders of 100,000 or more.
-- Return: first_name | last_name | total_spent
SELECT	first_name,
		last_name,
        coalesce(sum(oi.amount), 0) AS total_spent
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
AND oi.amount > 100000
GROUP BY ci.customer_id;


-- Challenge #20 — Final one for this JOIN pattern
-- Show every customer, the number of their orders worth at least 100,000, and the total value of those orders.
-- Return: first_name | last_name | qualifying_orders | qualifying_spend
SELECT	first_name,
		last_name,
        COUNT(oi.order_id) AS qualifying_orders,
        coalesce(sum(oi.amount), 0) AS qualifying_spend
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
AND oi.amount >= 100000
GROUP BY ci.customer_id;


-- Next: Challenge #21
-- Show every customer and their total spending on orders placed in January 2026.
-- Return: first_name | last_name | january_spend
SELECT	first_name,
		last_name,
        COALESCE(SUM(oi.amount), 0) AS january_spend
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
AND oi.order_date BETWEEN '2026-01-01' AND '2026-01-31'
GROUP BY ci.customer_id;



-- Challenge #22 — Let's combine two conditions
-- Show every customer and their total spending on orders of at least 100,000 placed in January 2026.
-- Return: first_name | last_name | january_qualifying_spend
SELECT	first_name,
		last_name,
        coalesce(SUM(oi.amount), 0) AS january_qualifying_spend
FROM customers_import ci
LEFT JOIN orders_import oi
ON ci.customer_id = oi.customer_id
AND oi.amount >= 100000
AND oi.order_date BETWEEN '2026-01-01' AND '2026-01-31'
GROUP BY ci.customer_id;







































SELECT * FROM orders_import;
SELECT * FROM customers_import;
DESCRIBE customers_import;
SHOW CREATE TABLE customers_import;