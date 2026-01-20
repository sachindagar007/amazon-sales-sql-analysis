create database amazon_project;
use  amazon_project;

describe amazon;
alter table amazon
add time_of_day varchar(15) not null;

UPDATE amazon 
SET 
    time_of_day = CASE
        WHEN HOUR(time) BETWEEN 06 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;


alter table amazon
add day_name varchar(10) not null;

UPDATE amazon 
SET 
    day_name = (SELECT DAYNAME(date));

alter table amazon
add month_name varchar(10) not null;

UPDATE amazon 
SET 
    month_name = (SELECT MONTHNAME(date)); 


CREATE TABLE amazon_sales (
    invoice_id VARCHAR(30) PRIMARY KEY NOT NULL,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10 , 2 ) NOT NULL,
    quantity INT NOT NULL,
    vat FLOAT NOT NULL,
    total DECIMAL(10 , 2 ) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    cogs DECIMAL(10 , 2 ) NOT NULL,
    gross_margin_percentage FLOAT NOT NULL,
    gross_income DECIMAL(10 , 2 ) NOT NULL,
    rating DECIMAL(3 , 1 ) NOT NULL,
    time_of_day VARCHAR(15) NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    month_name VARCHAR(10) NOT NULL
);

insert into amazon_sales
(select * from amazon);

SELECT 
    COUNT(*) AS total_columns
FROM
    information_schema.columns
WHERE
    table_name = 'amazon_sales';

SELECT 
    COUNT(*) AS total_rows
FROM
    amazon_sales;

SELECT 
    COUNT(*) AS null_values
FROM
    amazon_sales
WHERE
    NULL;
    
    
    
CREATE VIEW count_unique_values AS
    (SELECT 
        COUNT(DISTINCT invoice_id) invoice_id,
        COUNT(DISTINCT branch) branch,
        COUNT(DISTINCT city) city,
        COUNT(DISTINCT customer_type) customertype,
        COUNT(DISTINCT gender) gender,
        COUNT(DISTINCT product_line) product_line,
        COUNT(DISTINCT unit_price) unit_price,
        COUNT(DISTINCT quantity) quantity,
        COUNT(DISTINCT vat) vat,
        COUNT(DISTINCT total) total,
        COUNT(DISTINCT date) date,
        COUNT(DISTINCT time) time,
        COUNT(DISTINCT payment_method) payment_method,
        COUNT(DISTINCT cogs) cogs,
        COUNT(DISTINCT gross_margin_percentage) gross_margin_percentage,
        COUNT(DISTINCT gross_income) gross_income,
        COUNT(DISTINCT rating) rating,
        COUNT(DISTINCT time_of_day) time_of_day,
        COUNT(DISTINCT day_name) day_name,
        COUNT(DISTINCT month_name) month_name
    FROM
        amazon_sales);
        
SELECT 
    *
FROM
    count_unique_values; 
    
SELECT DISTINCT
    (branch) branch
FROM
    amazon_sales;
SELECT DISTINCT
    (city) city
FROM
    amazon_sales;
SELECT DISTINCT
    (customer_type) customer_type
FROM
    amazon_sales;
SELECT DISTINCT
    (gender) gender
FROM
    amazon_sales;
SELECT DISTINCT
    (product_line) product_line
FROM
    amazon_sales;
SELECT DISTINCT
    (payment_method) payment_method
FROM
    amazon_sales;
SELECT DISTINCT
    (time_of_day) time_of_day
FROM
    amazon_sales;
SELECT DISTINCT
    (day_name) day_name
FROM
    amazon_sales;
SELECT DISTINCT
    (month_name) month_name
FROM
    amazon_sales;
    
# Problem and Queries

# 1 Problem 1: Total number of transactions (customer purchases)
SELECT 
    COUNT(DISTINCT invoice_id) AS customer_count
FROM
    amazon_sales;


# 2 Problem 2: customer count by city
SELECT 
    city, COUNT(*) AS customer_count
FROM
    amazon_sales
GROUP BY city
ORDER BY customer_count DESC;

# 3 Problem 3: What is the count of distinct product lines in the dataset?
SELECT 
    COUNT(DISTINCT (product_line))
FROM
    amazon_sales;
    
# 4 Problem 4: Which payment method occurs most frequently?

SELECT 
    payment_method, COUNT(*) AS occurence
FROM
    amazon_sales
GROUP BY payment_method
ORDER BY occurence DESC;

# 5 Problem 5: Which product line has the highest sales?
SELECT 
    product_line, SUM(quantity) AS total_unit_sold
FROM
    amazon_sales
GROUP BY product_line
ORDER BY total_unit_sold DESC
LIMIT 1;

# 6 Problem 6: How much revenue is generated each month?

SELECT 
    month_name, ROUND(SUM(total), 2) AS monthly_revenue
FROM
    amazon_sales
GROUP BY month_name
ORDER BY monthly_revenue DESC;

# 7 Problem 7: In which month did the cost of goods sold reach its peak?

SELECT 
    month_name, ROUND(SUM(cogs), 2) AS cogs_peak
FROM
    amazon_sales
GROUP BY month_name
ORDER BY cogs_peak DESC;

# 8 Problem 8:  Which product line generated the highest revenue?

SELECT 
    product_line, SUM(total) AS total_revenues
FROM
    amazon_sales
GROUP BY product_line
ORDER BY total_revenues DESC;


# 9 Problem 9: In which city was the highest revenue recorded?

SELECT 
    city, SUM(total) AS total_revenue
FROM
    amazon_sales
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;


# 10 Problem 10: Which product line incurred the highest Value Added Tax?

SELECT 
    product_line, ROUND(SUM(vat), 2) AS high_vat
FROM
    amazon_sales
GROUP BY product_line
ORDER BY high_vat DESC
LIMIT 1;

# 11 Problem 11: For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SELECT 
    product_line,
    ROUND(SUM(total), 2) AS total_sales,
    CASE
        WHEN
            SUM(total) > (SELECT 
                    AVG(product_revenue)
                FROM
                    (SELECT 
                        SUM(total) AS product_revenue
                    FROM
                        amazon_sales
                    GROUP BY product_line) t)
        THEN
            'Good'
        ELSE 'Bad'
    END AS performance
FROM
    amazon_sales
GROUP BY product_line;

#12 Problem 12: Identify the branch that exceeded the average number of products sold.

SELECT 
    branch, SUM(quantity) AS total_quantity
FROM
    amazon_sales
GROUP BY branch
HAVING total_quantity > (SELECT 
        AVG(branch_quantity)
    FROM
        (SELECT 
            SUM(quantity) AS branch_quantity
        FROM
            amazon_sales
        GROUP BY branch) t);


#13 Problem 13: Which product line is most frequently associated with each gender?

WITH gender_product_count AS (
    SELECT 
        gender, 
        product_line, 
        COUNT(*) AS purchase_count
    FROM amazon_sales
    GROUP BY gender, product_line
),
ranked_products AS (
    SELECT 
        gender, 
        product_line, 
        purchase_count,
        RANK() OVER (
            PARTITION BY gender 
            ORDER BY purchase_count DESC
        ) AS rnk
    FROM gender_product_count
)
SELECT 
    gender, 
    product_line, 
    purchase_count
FROM ranked_products
WHERE rnk = 1;

# 14 Problem 14:  Calculate the average rating for each product line.

SELECT 
    product_line, AVG(rating) AS avg_rating
FROM
    amazon_sales
GROUP BY product_line
ORDER BY avg_rating DESC;

# 15 Problem 15: Count the sales occurrences for each time of day on every weekday.


SELECT 
    day_name, time_of_day, COUNT(invoice_id) AS sales_count
FROM
    amazon_sales
GROUP BY day_name , time_of_day
ORDER BY FIELD(day_name,
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday') , FIELD(time_of_day,
        'Morning',
        'Afternoon',
        'Evening');
        
#17 Problem 17: Determine the city with the highest VAT percentage.

SELECT 
    city, MAX(vat) AS vat_percentage
FROM
    amazon_sales
GROUP BY city
ORDER BY vat_percentage DESC
LIMIT 1;

# 18 Problem 18: Identify the customer type with the highest VAT payments.

SELECT 
    customer_type, MAX(vat) AS vat_percentage
FROM
    amazon_sales
GROUP BY customer_type
ORDER BY vat_percentage DESC;

# 19 Problem 19: What is the count of distinct customer types in the dataset?

SELECT 
    COUNT(DISTINCT customer_type) AS distinct_count
FROM
    amazon_sales;
  
# 20 Problem 20: What is the count of distinct payment methods in the dataset?

SELECT 
    COUNT(DISTINCT payment_method) AS distinct_payment_method
FROM
    amazon_sales;
    
# 21 Problem 21: Which customer type make most purchases?

SELECT 
    customer_type, COUNT(invoice_id) AS invoice_count
FROM
    amazon_sales
GROUP BY customer_type
ORDER BY invoice_count DESC;


# 22 Problem 22: Determine the predominant gender among customers.

SELECT 
    gender, COUNT(*) AS customer_count
FROM
    amazon_sales
GROUP BY gender
ORDER BY customer_count DESC
LIMIT 1;


# 23 Problem 23  Examine the distribution of genders within each branch. 

SELECT 
    branch, gender, COUNT(*) AS customer_count
FROM
    amazon_sales
GROUP BY branch , gender
ORDER BY branch , gender;

# 24 Problem 24: Identify the time of day when customers provide the most ratings.

SELECT 
    time_of_day, COUNT(rating) AS rating_count
FROM
    amazon_sales
GROUP BY time_of_day
ORDER BY rating_count DESC
LIMIT 1;

#25. Determine the time of day with the highest customer ratings for each branch.

WITH avg_ratings AS (
    SELECT 
        branch, 
        time_of_day, 
        AVG(rating) AS avg_rating
    FROM amazon_sales
    GROUP BY branch, time_of_day
),
ranked_ratings AS (
    SELECT 
        branch, 
        time_of_day, 
        avg_rating,
        RANK() OVER (
            PARTITION BY branch 
            ORDER BY avg_rating DESC
        ) AS rnk
    FROM avg_ratings
)
SELECT 
    branch, 
    time_of_day, 
    ROUND(avg_rating, 2) AS highest_avg_rating
FROM ranked_ratings
WHERE rnk = 1
ORDER BY branch;

# 26 Problem 26: Identify the day of the week with the highest average ratings.

SELECT 
    day_name, ROUND(AVG(rating), 2) AS avg_rating
FROM
    amazon_sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;

# 27 Problem 27 . Determine the day of the week with the highest average ratings for each branch

WITH avg_ratings AS (
    SELECT 
        branch, 
        day_name, 
        AVG(rating) AS avg_rating
    FROM amazon_sales
    GROUP BY branch, day_name
),
ranked_days AS (
    SELECT 
        branch, 
        day_name, 
        avg_rating,
        RANK() OVER (
            PARTITION BY branch 
            ORDER BY avg_rating DESC
        ) AS rnk
    FROM avg_ratings
)
SELECT 
    branch, 
    day_name, 
    ROUND(avg_rating, 2) AS highest_avg_rating
FROM ranked_days
WHERE rnk = 1
ORDER BY branch;

# 28 Problem 28: Which product line is the MOST PROFITABLE?

SELECT 
    product_line, ROUND(SUM(total - cogs), 2) AS total_profit
FROM
    amazon_sales
GROUP BY product_line
ORDER BY total_profit DESC
LIMIT 1;


# 29 Problem 29: Profit margin (%) by product line

SELECT 
    product_line,
    ROUND((SUM(total - cogs) / SUM(total)) * 100,
            2) AS profit_margin_percent
FROM
    amazon_sales
GROUP BY product_line
ORDER BY profit_margin_percent DESC;

# 30 Problem 30: Which branch is MOST EFFICIENT (profit per sale)?

SELECT 
    branch,
    ROUND(SUM(total - cogs) / COUNT(invoice_id), 2) AS profit_per_sale
FROM
    amazon_sales
GROUP BY branch
ORDER BY profit_per_sale DESC;

# 31 Problem 31: Does higher rating lead to higher revenue?

SELECT 
    CASE
        WHEN rating >= 4.5 THEN 'Excellent'
        WHEN rating >= 3.5 THEN 'Good'
        ELSE 'Poor'
    END AS rating_bucket,
    ROUND(SUM(total), 2) AS revenue
FROM
    amazon_sales
GROUP BY rating_bucket
ORDER BY revenue DESC; 


# 32 Problem 32: Average basket size (quantity per transaction)

SELECT 
    ROUND(AVG(quantity), 2) AS avg_items_per_purchase
FROM
    amazon_sales;
    
# 33 Problem 33: Which payment method generates the highest revenue?

SELECT 
    payment_method, ROUND(SUM(total), 2) AS total_revenue
FROM
    amazon_sales
GROUP BY payment_method
ORDER BY total_revenue DESC;

# 34 Problem 34: Peak revenue hour 

SELECT 
    HOUR(time) AS hour_of_day, ROUND(SUM(total), 2) AS revenue
FROM
    amazon_sales
GROUP BY hour_of_day
ORDER BY revenue DESC;

# 35 Problem 35: Revenue contribution % by branch

SELECT 
    branch,
    ROUND(SUM(total) * 100 / (SELECT 
                    SUM(total)
                FROM
                    amazon_sales),
            2) AS revenue_pct
FROM
    amazon_sales
GROUP BY branch;


# 36  Problem 36: Top 3 product lines per branch (Advanced Window Function)
WITH ranked_products AS (
    SELECT
        branch,
        product_line,
        SUM(total) AS revenue,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY SUM(total) DESC
        ) AS rnk
    FROM amazon_sales
    GROUP BY branch, product_line
)
SELECT *
FROM ranked_products
WHERE rnk <= 3;

# 37 Problem 37: Month-over-month revenue growth
SELECT
    month_name,
    ROUND(SUM(total), 2) AS revenue,
    ROUND(
        SUM(total) -
        LAG(SUM(total)) OVER (ORDER BY FIELD(month_name,'January','February','March')),
        2
    ) AS revenue_change
FROM amazon_sales
GROUP BY month_name;



