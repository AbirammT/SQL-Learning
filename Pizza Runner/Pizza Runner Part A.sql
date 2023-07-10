-- 1. How many pizzas were ordered?

SELECT
    count(PIZZA_ID)
FROM 
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS;


-- 2. How many unique customer orders were made?

SELECT
    count(distinct(ORDER_ID)) AS "unique-orders"
FROM 
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS;


-- 3. How many successful orders were delivered by each runner? 

SELECT
    RUNNER_ID,
    count(distinct(ORDER_ID)) AS "Orders"
FROM 
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.RUNNER_ORDERS
WHERE
    PICKUP_TIME != 'null'
GROUP BY
    RUNNER_ID;
    

-- 4. How many of each type of pizza was delivered?*/

SELECT
    CO.PIZZA_ID, count(CO.PIZZA_ID) as "count"
FROM 
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.RUNNER_ORDERS RO
    INNER JOIN TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS CO
    ON RO.ORDER_ID = CO.ORDER_ID
WHERE
    RO.PICKUP_TIME != 'null'
GROUP BY
    CO.PIZZA_ID;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
    CO.CUSTOMER_ID,
    PN.PIZZA_NAME,
    count(CO.PIZZA_ID) AS "count"
FROM 
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.PIZZA_NAMES PN
    INNER JOIN TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS CO
    ON PN.PIZZA_ID = CO.PIZZA_ID
GROUP BY
    CO.CUSTOMER_ID,
    PN.PIZZA_NAME; 

-- 6. What was the maximum number of pizzas delivered in a single order?*/

SELECT
    CO.ORDER_ID, 
    count(CO.PIZZA_ID) AS "pizzas"
FROM 
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.RUNNER_ORDERS RO
    INNER JOIN TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS CO
    ON RO.ORDER_ID = CO.ORDER_ID
WHERE
    RO.PICKUP_TIME != 'null'
GROUP BY
    CO.ORDER_ID
ORDER BY 
    "pizzas" desc
LIMIT 1;
    
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
    CO.CUSTOMER_ID,
    CASE
        WHEN CO.EXCLUSIONS != 'null' and length(CO.EXCLUSIONS) > 0 then 'Change'
        WHEN CO.EXTRAS != 'null' and length(CO.EXTRAS) > 0 then 'Change'
        ELSE 'No Change'
        END AS "Change",
        count(CO.PIZZA_ID) AS "Pizzas"
FROM
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.RUNNER_ORDERS RO
    INNER JOIN TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS CO
    ON RO.ORDER_ID = CO.ORDER_ID
WHERE
    RO.PICKUP_TIME != 'null'
GROUP BY 
    CO.CUSTOMER_ID,
    "Change"; 

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT
    count(*) AS "changed pizza"
FROM
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.RUNNER_ORDERS RO
    INNER JOIN TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS CO
    ON RO.ORDER_ID = CO.ORDER_ID
WHERE
    RO.PICKUP_TIME != 'null' AND
    CO.EXCLUSIONS != 'null' and length(CO.EXCLUSIONS) > 0 AND
    CO.EXTRAS != 'null' and length(CO.EXTRAS) > 0;
    
    

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
    hour(ORDER_TIME) AS "hour",
    count(PIZZA_ID)
FROM 
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS
GROUP BY
    "hour";
    

-- 10. What was the volume of orders for each day of the week?

SELECT 
    dayname(ORDER_TIME) AS "day",
    count(PIZZA_ID)
FROM 
    TIL_PLAYGROUND.CS2_PIZZA_RUNNER.CUSTOMER_ORDERS
GROUP BY
    "day";
