-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
    date_trunc(week,REGISTRATION_DATE) + 4 AS "week beginning",
    count(*)
FROM
    RUNNERS
GROUP BY
    "week beginning";


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pick up the order?

SELECT 
    AVG(datediff(minute,CO.ORDER_TIME,RO.PICKUP_TIME))
FROM
    RUNNER_ORDERS RO
    JOIN CUSTOMER_ORDERS CO
    ON RO.ORDER_ID = CO.ORDER_ID
WHERE
    RO.PICKUP_TIME != 'null';

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH CTE AS
(SELECT 
    CO.ORDER_ID,
    count(CO.PIZZA_ID) AS "pizzas",
    avg(datediff(minute,CO.ORDER_TIME,RO.PICKUP_TIME)) as "time"
FROM
    RUNNER_ORDERS RO
    JOIN CUSTOMER_ORDERS CO
    ON RO.ORDER_ID = CO.ORDER_ID
WHERE
    RO.PICKUP_TIME != 'null'
GROUP BY
    CO.ORDER_ID
ORDER BY 
    "time" desc)
SELECT 
    "pizzas",
    avg("time")
FROM
    CTE
GROUP BY
    "pizzas";

-- 4. What was the average distance travelled for each customer?

SELECT
    CO.CUSTOMER_ID,
    AVG(TRIM(RO.DISTANCE, 'km')::numeric(3,0)) AS "distance"
FROM
    RUNNER_ORDERS RO
    JOIN CUSTOMER_ORDERS CO
    ON RO.ORDER_ID = CO.ORDER_ID
WHERE
    RO.DISTANCE != 'null'
GROUP BY
    CO.CUSTOMER_ID;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MAX(TRIM(DURATION, 'minutes ')::integer) - MIN(TRIM(DURATION, 'minutes ')::integer) AS "delivery diff"
FROM
    RUNNER_ORDERS
WHERE
    DISTANCE != 'null';

   
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT
    RO.RUNNER_ID,
    CO.ORDER_ID,
    SUM(TRIM(RO.DISTANCE, 'km')::numeric(3,0))/SUM(TRIM(RO.DURATION, 'minutes ')::numeric(3,0)) AS "AVG_SPEED"
FROM
    RUNNER_ORDERS RO
    JOIN CUSTOMER_ORDERS CO
    ON RO.ORDER_ID = CO.ORDER_ID
WHERE 
    DISTANCE != 'null'
GROUP BY 
    RO.RUNNER_ID,
    CO.ORDER_ID
ORDER BY
    "AVG_SPEED" DESC;


-- 7. What is the successful delivery percentage for each runner?

SELECT
    RUNNER_ID,
    sum(CASE WHEN DISTANCE != 'null' THEN 1 ELSE 0 END)/count(DISTINCT(ORDER_ID)) AS "success%"
FROM
    RUNNER_ORDERS
GROUP BY
    RUNNER_ID;