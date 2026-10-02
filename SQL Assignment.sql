SELECT * FROM dim_campaigns
SELECT * FROM dim_products
SELECT * FROM dim_stores
SELECT * FROM fact_events

--SQL PRACTICE SET – RETAIL EVENTS DATASET
--20 QUESTIONS | EASY → MEDIUM → HARD

/*DATASET OVERVIEW
================

This practice set uses the retail_events_db database.

Main tables:

1. dim_campaigns
   - campaign_id
   - campaign_name
   - start_date
   - end_date

2. dim_products
   - product_code
   - product_name
   - category

3. dim_stores
   - store_id
   - city

4. fact_events
   - event_id
   - store_id
   - campaign_id
   - product_code
   - base_price
   - promo_type
   - quantity_sold(before_promo)
   - quantity_sold(after_promo)

The fact_events table stores product-level promotional event information.
Use the dimension tables to obtain campaign, product and store details.

IMPORTANT:
- Use MySQL syntax.
- Column names containing parentheses may need backticks.
  Example:
  `quantity_sold(before_promo)`
  `quantity_sold(after_promo)`
- Do not modify the data.
- Write a separate SQL query for each question.
- Questions are arranged from easy to hard.
- Focus especially on JOINs, GROUP BY, HAVING, CASE, CTEs and window functions.*/

============================================================
--EASY QUESTIONS
============================================================

/*Q1. Basic Filtering – High-Value Products
Find all event records where the base_price is greater than 1,000.

Display:
- event_id
- store_id
- product_code
- base_price
- promo_type

Concepts:
SELECT, WHERE, comparison operators.*/

SELECT event_id, store_id, product_code, base_price, promo_type
FROM fact_events

------------------------------------------------------------

/*Q2. Sorting Promotional Events
Display all events where quantity sold after the promotion was greater than 100.

Display:
- event_id
- product_code
- promo_type
- quantity_sold(before_promo)
- quantity_sold(after_promo)

Sort by quantity_sold(after_promo) in descending order.

Concepts:
WHERE, ORDER BY, DESC.*/

SELECT event_id, product_code, promo_type, [quantity_sold(before_promo)], [quantity_sold(after_promo)]
FROM fact_events 
ORDER BY [quantity_sold(after_promo)] DESC;

------------------------------------------------------------

/*Q3. DISTINCT Promotion Types
Find all unique promotion types used in the dataset.

Display only the unique promo_type values.

Concepts:
DISTINCT.*/

SELECT DISTINCT promo_type
FROM fact_events;

------------------------------------------------------------

/*Q4. Basic Aggregation
Calculate the following for the complete fact_events table:

- Total number of events
- Total quantity sold before promotion
- Total quantity sold after promotion
- Average base price
- Maximum base price
- Minimum base price

Return all metrics in one row.

Concepts:
COUNT, SUM, AVG, MAX, MIN.*/

SELECT COUNT(*) AS [Total number of events],
SUM([quantity_sold(before_promo)]) AS [Total quantity sold before promotion],
SUM([quantity_sold(after_promo)]) AS [Total quantity sold after promotion],
AVG(base_price) AS [Average base price], MAX(base_price) AS [Maximum base price], MIN(base_price) AS [Minimum base price]
FROM fact_events;

============================================================
--MEDIUM QUESTIONS
============================================================

/*Q5. Sales Volume by Promotion Type
For each promo_type, calculate:

- Number of events
- Total quantity sold before promotion
- Total quantity sold after promotion

Sort by total quantity sold after promotion in descending order.

Concepts:
GROUP BY, COUNT, SUM, ORDER BY.*/

SELECT promo_type, COUNT(*) AS [Number of events], SUM([quantity_sold(before_promo)]) AS [Total quantity sold before promotion],
SUM([quantity_sold(after_promo)]) AS [Total quantity sold after promotion]
FROM fact_events
GROUP BY promo_type
ORDER BY [Total quantity sold after promotion] DESC;

------------------------------------------------------------

/*Q6. Promotion Uplift
For every promotion type, calculate:

- Total quantity before promotion
- Total quantity after promotion
- Quantity increase/decrease

Use:

Quantity Change = After Promo Quantity - Before Promo Quantity

Display:
- promo_type
- total_before
- total_after
- quantity_change

Sort by quantity_change descending.

Concepts:
GROUP BY, SUM, arithmetic calculations, aliases.*/

SELECT promo_type, SUM([quantity_sold(before_promo)]) AS [total_before], SUM([quantity_sold(after_promo)]) AS [total_after],
SUM([quantity_sold(after_promo)])-SUM([quantity_sold(before_promo)]) AS [quantity_change]
FROM fact_events
GROUP BY promo_type
ORDER BY [quantity_change] DESC;

------------------------------------------------------------

/*Q7. Product Performance
Using fact_events and dim_products, calculate total quantity sold after promotion for every product.

Display:
- product_code
- product_name
- category
- total quantity after promotion

Sort by total quantity after promotion descending.

Concepts:
INNER JOIN, GROUP BY, SUM, ORDER BY.*/

SELECT p.product_code, p.product_name, p.category, SUM(e.[quantity_sold(after_promo)]) AS [total quantity after promotion]
FROM fact_events e INNER JOIN dim_products p
ON e.product_code = p.product_code
GROUP BY p.product_code, p.product_name, p.category
ORDER BY [total quantity after promotion] DESC;

------------------------------------------------------------

/*Q8. Category-Level Performance
Using fact_events and dim_products, calculate for every product category:

- Number of events
- Total quantity before promotion
- Total quantity after promotion
- Quantity change

Sort categories by total quantity after promotion descending.

Concepts:
JOIN, GROUP BY, SUM, COUNT, arithmetic calculations.*/

SELECT p.category, COUNT(e.event_id) AS [Number of events], 
SUM(e.[quantity_sold(before_promo)]) AS [Total quantity before promotion], 
SUM(e.[quantity_sold(after_promo)]) AS [Total quantity after promotion],
SUM(e.[quantity_sold(after_promo)])-SUM(e.[quantity_sold(before_promo)]) AS [Quantity_change]
FROM fact_events e INNER JOIN dim_products p
ON e.product_code = p.product_code
GROUP BY p.category
ORDER BY [Total quantity after promotion] DESC;

------------------------------------------------------------

/*Q9. Store Performance
Using fact_events and dim_stores, calculate for every city:

- Number of promotional events
- Total quantity before promotion
- Total quantity after promotion

Display:
- city
- event_count
- total_before
- total_after

Sort cities by total_after descending.

Concepts:
JOIN, GROUP BY, aggregation, ORDER BY.*/

SELECT s.city, COUNT(e.event_id) AS [event_count], 
SUM(e.[quantity_sold(before_promo)]) AS [total_before], 
SUM(e.[quantity_sold(after_promo)]) AS [total_after]
FROM dim_stores s INNER JOIN fact_events e
ON s.store_id = e.store_id
GROUP BY s.city
ORDER BY [total_after] DESC;

------------------------------------------------------------

/*Q10. Campaign Performance
Using fact_events and dim_campaigns, calculate for each campaign:

- Campaign name
- Start date
- End date
- Number of events
- Total quantity before promotion
- Total quantity after promotion

Sort by total quantity after promotion descending.

Concepts:
JOIN, GROUP BY, date columns, aggregation.*/

SELECT c.campaign_name, c.start_date, c.end_date, COUNT(e.event_id) AS [Number of events], 
SUM(e.[quantity_sold(before_promo)]) AS [Total quantity before promotion], 
SUM(e.[quantity_sold(after_promo)]) AS [Total quantity after promotion]
FROM dim_campaigns c INNER JOIN fact_events e
ON c.campaign_id = e.campaign_id
GROUP BY c.campaign_name, c.start_date, c.end_date
ORDER BY [Total quantity after promotion] DESC;

------------------------------------------------------------

/*Q11. Product Category with HAVING
Find product categories where the total quantity sold after promotion is greater than 1,000.

Display:
- category
- total quantity after promotion
- average base price

Sort by total quantity after promotion descending.

Concepts:
JOIN, GROUP BY, HAVING, AVG, SUM.*/

SELECT p.category, SUM(e.[quantity_sold(after_promo)]) AS [Total quantity after promotion], 
AVG(base_price) AS [average base price]
FROM fact_events e INNER JOIN dim_products p
ON e.product_code = p.product_code
GROUP BY p.category
HAVING SUM(e.[quantity_sold(after_promo)]) > 1000
ORDER BY [Total quantity after promotion] DESC;
------------------------------------------------------------

/*Q12. Store + Category Analysis
Using fact_events, dim_stores and dim_products, calculate total quantity sold after promotion for every combination of:

- City
- Product category

Display:
- city
- category
- total quantity after promotion

Sort first by city and then by total quantity descending.

Concepts:
Multiple JOINs, GROUP BY, ORDER BY.*/

SELECT s.city, p.category, SUM(e.[quantity_sold(after_promo)]) AS [Total quantity after promotion]
FROM fact_events e INNER JOIN dim_products p
ON e.product_code = p.product_code
INNER JOIN dim_stores s ON s.store_id = e.store_id
GROUP BY s.city, p.category
ORDER BY [Total quantity after promotion] DESC;

------------------------------------------------------------

/*Q13. Promotion Effectiveness by Product
For each product, calculate:

- Product name
- Category
- Total quantity before promotion
- Total quantity after promotion
- Quantity change
- Percentage change

Use:

Percentage Change =
((After Promo - Before Promo) / Before Promo) * 100

Handle division by zero appropriately.

Sort by percentage change descending.

Concepts:
JOIN, GROUP BY, arithmetic calculations, NULLIF, percentage calculations.*/

SELECT p.product_name, p.category, 
SUM(e.[quantity_sold(before_promo)]) AS [Total quantity before promotion], 
SUM(e.[quantity_sold(after_promo)]) AS [Total quantity after promotion],
SUM(e.[quantity_sold(after_promo)])-SUM(e.[quantity_sold(before_promo)]) AS [Quantity_change],
((SUM(e.[quantity_sold(after_promo)])- SUM(e.[quantity_sold(before_promo)])) * 100/ NULLIF(SUM(e.[quantity_sold(before_promo)]),0)) AS [Percentage change]
FROM fact_events e INNER JOIN dim_products p
ON e.product_code = p.product_code
GROUP BY p.product_name, p.category
ORDER BY [Percentage change] DESC;

------------------------------------------------------------

/*Q14. Campaign and Promotion Type Analysis
For each campaign and promo_type combination, calculate:

- Number of events
- Total quantity before promotion
- Total quantity after promotion
- Quantity change

Display:
- campaign_name
- promo_type
- event_count
- total_before
- total_after
- quantity_change

Sort by campaign_name and quantity_change descending.

Concepts:
Multiple GROUP BY columns, JOIN, aggregation, ORDER BY.*/

SELECT c.campaign_name, e.promo_type, COUNT(e.event_id) AS [event_count],  
SUM(e.[quantity_sold(before_promo)]) AS [total_before], 
SUM(e.[quantity_sold(after_promo)]) AS [total_after],
SUM(e.[quantity_sold(after_promo)])-SUM(e.[quantity_sold(before_promo)]) AS [Quantity_change]
FROM dim_campaigns c INNER JOIN fact_events e
ON c.campaign_id = e.campaign_id
GROUP BY c.campaign_name, e.promo_type
ORDER BY c.campaign_name ASC, [Quantity_change] DESC;

------------------------------------------------------------

/*Q15. Product Revenue Before and After Promotion
For each product, calculate:

1. Revenue before promotion =
   base_price × quantity_sold(before_promo)

2. Revenue after promotion =
   base_price × quantity_sold(after_promo)

3. Revenue difference =
   Revenue after - Revenue before

Display:
- product_name
- category
- revenue_before
- revenue_after
- revenue_difference

Sort by revenue_difference descending.

Concepts:
JOIN, GROUP BY, SUM, arithmetic calculations, aliases.*/

SELECT p.product_name, p.category, 
SUM(e.base_price*e.[quantity_sold(before_promo)]) AS [revenue_before],
SUM(e.base_price*e.[quantity_sold(after_promo)]) AS [revenue_after],
SUM(e.base_price*e.[quantity_sold(after_promo)]) - SUM(e.base_price*e.[quantity_sold(before_promo)]) AS [revenue_difference]
FROM fact_events e INNER JOIN dim_products p
ON e.product_code = p.product_code
GROUP BY p.product_name, p.category
ORDER BY [revenue_difference] DESC;

------------------------------------------------------------

/*Q16. Classify Promotion Performance
For every promotion type, calculate total quantity before and after promotion.

Then classify the promotion using CASE:

- Percentage change >= 50% → "High Impact"
- Percentage change >= 20% → "Medium Impact"
- Percentage change < 20% → "Low Impact"

Display:
- promo_type
- total_before
- total_after
- percentage_change
- performance_category

Sort by percentage_change descending.

Concepts:
GROUP BY, CASE, arithmetic calculations, NULLIF, aliases.*/

WITH temp AS (
SELECT promo_type, 
SUM([quantity_sold(before_promo)]) AS [total_before], 
SUM([quantity_sold(after_promo)]) AS [total_after],
((SUM([quantity_sold(after_promo)])- SUM([quantity_sold(before_promo)])) * 100/ NULLIF(SUM([quantity_sold(before_promo)]),0)) AS [percentage_change]
FROM fact_events
GROUP BY promo_type
)
SELECT promo_type, [total_before], [total_after], [percentage_change], 
CASE
	WHEN [percentage_change] >= 50 THEN 'High Impact'
	WHEN [percentage_change] >= 20 THEN 'Medium Impact'
	ELSE 'No Impact'
END AS [performance_category]
FROM temp
ORDER BY [percentage_change] DESC;


============================================================
HARD QUESTIONS
============================================================

/*Q17. Top Products Within Each Category
Using a CTE:

1. Calculate total quantity sold after promotion for every product.
2. Rank products within each category based on total quantity sold after promotion.
3. Return only the top 2 products from every category.

Display:
- category
- product_name
- total_quantity_after
- category_rank

Concepts:
CTE, JOIN, GROUP BY, DENSE_RANK/ROW_NUMBER,
PARTITION BY, window functions.*/

WITH temp AS (
SELECT  p.category, p.product_name, 
SUM(e.[quantity_sold(after_promo)]) AS [total_quantity_after],
RANK() OVER (PARTITION BY p.category ORDER BY SUM(e.[quantity_sold(after_promo)]) DESC) AS [category_rank]
FROM fact_events e INNER JOIN dim_products p
ON e.product_code = p.product_code
GROUP BY p.category, p.product_name
)
SELECT category, product_name, total_quantity_after, category_rank
FROM temp 
WHERE category_rank <= 2;

------------------------------------------------------------

/*Q18. Best-Performing Stores Within Each City
Calculate total quantity sold after promotion for each store.

Join dim_stores to obtain the city.

Then rank stores within each city based on total quantity sold after promotion.

Return the top 2 stores from each city.

Display:
- city
- store_id
- total_quantity_after
- city_rank

Concepts:
JOIN, CTE, GROUP BY, window functions,
PARTITION BY, RANK/DENSE_RANK.*/

WITH temp AS (
SELECT s.city, s.store_id, SUM(e.[quantity_sold(after_promo)]) AS [total_quantity_after],
RANK() OVER (PARTITION BY s.city ORDER BY SUM(e.[quantity_sold(after_promo)]) DESC) AS [city_rank],
FROM dim_stores s INNER JOIN fact_events e
ON s.store_id = e.store_id
GROUP BY s.city, s.store_id
)
SELECT city, store_id, [total_quantity_after], [city_rank]
FROM temp
WHERE [city_rank] <= 2;

------------------------------------------------------------

/*Q19. Campaign-Level Product Performance
For every campaign and product:

Calculate:
- Total quantity before promotion
- Total quantity after promotion
- Quantity change
- Percentage change

Then rank products within each campaign based on percentage change.

Return the top 3 products for every campaign.

Display:
- campaign_name
- product_name
- total_before
- total_after
- quantity_change
- percentage_change
- campaign_rank

Concepts:
Multiple JOINs, CTE, GROUP BY, arithmetic calculations,
NULLIF, window functions, PARTITION BY, ranking.*/

WITH temp1 AS (
SELECT c.campaign_name, p.product_name, 
SUM(e.[quantity_sold(before_promo)]) AS [total_before], 
SUM(e.[quantity_sold(after_promo)]) AS [total_after],
SUM(e.[quantity_sold(after_promo)])-SUM(e.[quantity_sold(before_promo)]) AS [Quantity_change],
((SUM(e.[quantity_sold(after_promo)])- SUM(e.[quantity_sold(before_promo)])) * 100/ NULLIF(SUM(e.[quantity_sold(before_promo)]),0)) AS [percentage_change]
FROM dim_campaigns c INNER JOIN fact_events e ON c.campaign_id = e.campaign_id
INNER JOIN dim_products p ON p.product_code = e.product_code
GROUP BY c.campaign_name, p.product_name
),
temp2 AS (
SELECT campaign_name, product_name, total_before, total_after, quantity_change, percentage_change,
DENSE_RANK() OVER (PARTITION BY campaign_name ORDER BY percentage_change DESC) AS campaign_rank
FROM temp1
)
SELECT campaign_name, product_name, total_before, total_after, quantity_change, percentage_change, campaign_rank
FROM temp2
WHERE campaign_rank <=3;


------------------------------------------------------------

/*Q20. Complete Promotional Performance Analysis
Create a complete analytical report at the product-category level.

For every product, calculate:

- Product name
- Category
- Number of promotional events
- Total quantity before promotion
- Total quantity after promotion
- Quantity change
- Percentage change
- Revenue before promotion
- Revenue after promotion
- Revenue change
- Average base price
- Product rank within its category

Use:

Quantity Change =
Total After - Total Before

Percentage Change =
((Total After - Total Before) / Total Before) * 100

Revenue Before =
SUM(base_price × quantity_before)

Revenue After =
SUM(base_price × quantity_after)

Revenue Change =
Revenue After - Revenue Before

Then:

1. Rank products within each category by Revenue Change.
2. Return only the top 2 products from each category.
3. Use appropriate handling for division by zero.

Concepts:
- Multiple JOINs
- CTEs
- GROUP BY
- COUNT
- SUM
- AVG
- CASE
- NULLIF
- Arithmetic calculations
- Percentage calculations
- Window functions
- PARTITION BY
- DENSE_RANK / ROW_NUMBER
- Filtering ranked results
- Business analysis*/

WITH temp AS (
SELECT p.product_name, p.category, COUNT(e.promo_type) AS [Number of promotional events], 
SUM(e.[quantity_sold(before_promo)]) AS [Total quantity before promotion], 
SUM(e.[quantity_sold(after_promo)]) AS [Total quantity after promotion],
SUM(e.[quantity_sold(after_promo)]) - SUM(e.[quantity_sold(before_promo)]) AS [Quantity change],
((SUM(e.[quantity_sold(after_promo)])- SUM(e.[quantity_sold(before_promo)])) * 100/ NULLIF(SUM(e.[quantity_sold(before_promo)]),0)) AS [percentage_change],
SUM(e.base_price*e.[quantity_sold(before_promo)]) AS [Revenue before promotion],
SUM(e.base_price*e.[quantity_sold(after_promo)]) AS [Revenue after promotion],
SUM(e.base_price*e.[quantity_sold(after_promo)]) - SUM(e.base_price*e.[quantity_sold(before_promo)]) AS [Revenue Change],
DENSE_RANK() OVER (PARTITION BY p.category 
ORDER BY (SUM(e.base_price*e.[quantity_sold(after_promo)]) - SUM(e.base_price*e.[quantity_sold(before_promo)])) DESC) AS [Product Rank]
FROM dim_products p INNER JOIN fact_events e
ON p.product_code = e.product_code
GROUP BY p.product_name, p.category
)
SELECT product_name, category, [Number of promotional events], [Total quantity before promotion], [Total quantity after promotion],
[Quantity change], [percentage_change], [Revenue before promotion], [Revenue after promotion], [Revenue Change], [Product Rank]
FROM temp
WHERE [Product Rank] <= 2;

============================================================
--CONCEPT COVERAGE
============================================================
/*
SELECT                  Q1-Q20
WHERE                   Q1-Q3
DISTINCT                Q3
ORDER BY                Q2-Q20
COUNT                   Q4-Q20
SUM                     Q4-Q20
AVG                     Q4, Q11, Q16, Q20
MIN / MAX               Q4
GROUP BY                Q5-Q20
HAVING                  Q11
INNER JOIN              Q7-Q20
Multiple JOINs          Q12, Q14, Q17-Q20
Arithmetic              Q6, Q13, Q15-Q20
NULLIF                  Q13, Q16, Q19, Q20
CASE                    Q16, Q20
CTE                     Q17-Q20
Window Functions        Q17-Q20
PARTITION BY            Q17-Q20
RANK/DENSE_RANK         Q17-Q20
Business Analysis       Q13-Q20
*/
============================================================
--RECOMMENDED LEARNING FLOW
============================================================
/*
Q1-Q4:
SQL fundamentals, filtering and aggregation.

Q5-Q10:
GROUP BY, JOINs and basic business analysis.

Q11-Q16:
HAVING, multiple JOINs, calculations, percentages and CASE.

Q17-Q20:
CTEs, window functions, ranking and advanced business analysis.*/

============================================================
--IMPORTANT BUSINESS QUESTIONS LEARNERS SHOULD THINK ABOUT
============================================================

--While solving the questions, learners should think about:

1. Which promotion types generate the highest increase in quantity?
2. Which products respond most strongly to promotions?
3. Which categories perform best after promotions?
4. Which cities/stores have the highest promotional volume?
5. Which campaigns generate the strongest product performance?
6. Does a higher quantity increase necessarily mean higher revenue?
7. Which products have the highest revenue improvement after promotion?
8. Which products should be investigated for weak promotional performance?

Do not answer these questions separately. Use SQL queries to derive the answers.
