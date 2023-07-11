-- 1. What are the standard ingredients for each pizza?

SELECT
    PT.TOPPING_NAME,
    count(DISTINCT PR.PIZZA_ID) as "Pizzas"
FROM
    PIZZA_RECIPES PR
    LEFT JOIN LATERAL split_to_table(TOPPINGS, ',') SPR
    INNER JOIN PIZZA_TOPPINGS PT
    ON SPR.VALUE = PT.TOPPING_ID
GROUP BY
    PT.TOPPING_NAME
HAVING
 "Pizzas" > 1;

    
-- 2. What was the most commonly added extra?

SELECT
    PT.TOPPING_NAME,
    COUNT(PT.TOPPING_ID) AS "count"
FROM
    CUSTOMER_ORDERS CO
    LEFT JOIN LATERAL split_to_table(EXTRAS, ', ') SCO
    INNER JOIN PIZZA_TOPPINGS PT
    ON SCO.VALUE = PT.TOPPING_ID
WHERE
    CO.EXTRAS != 'null' and length(CO.EXTRAS) >= 1
GROUP BY 
    PT.TOPPING_NAME
ORDER BY
    COUNT(PT.TOPPING_ID) DESC
LIMIT 1;
    

-- 3. What was the most common exclusion?

SELECT
    PT.TOPPING_NAME,
    COUNT(PT.TOPPING_ID) AS "count"
FROM
    CUSTOMER_ORDERS CO
    LEFT JOIN LATERAL split_to_table(EXCLUSIONS, ', ') SCO
    INNER JOIN PIZZA_TOPPINGS PT
    ON SCO.VALUE = PT.TOPPING_ID
WHERE
    CO.EXCLUSIONS != 'null' and length(CO.EXCLUSIONS) >= 1
GROUP BY 
    PT.TOPPING_NAME
ORDER BY
    COUNT(PT.TOPPING_ID) DESC
LIMIT 1;


/*4. Generate an order item for each record in the customers_orders table in the format of one of the following:

- Meat Lovers

- Meat Lovers - Exclude Beef

- Meat Lovers - Extra Bacon

- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */


WITH EXTRAS AS( 
SELECT
    CO.ORDER_ID, CO.PIZZA_ID, listagg(PT.TOPPING_NAME, ', ') AS EXTRA, listagg(SPR.VALUE, ',') AS EXTRA_N
FROM 
    CUSTOMER_ORDERS CO
    LEFT JOIN LATERAL split_to_table(EXTRAS, ',') SPR
    INNER JOIN PIZZA_TOPPINGS PT
    ON SPR.VALUE = PT.TOPPING_ID
WHERE 
    CO.EXTRAS != 'null' and length(CO.EXTRAS) >= 1
GROUP BY
    ORDER_ID, PIZZA_ID
    ),

EXCLUSIONS AS(
SELECT
    ORDER_ID, 
    PIZZA_ID, 
    listagg(DISTINCT PT.TOPPING_NAME, ', ') AS EXCLUSION, 
    listagg(DISTINCT SPR.VALUE, ',') AS EXCLUSION_N
FROM 
    CUSTOMER_ORDERS CO
    LEFT JOIN LATERAL split_to_table(EXCLUSIONS, ',') SPR
    INNER JOIN PIZZA_TOPPINGS PT
    ON SPR.VALUE = PT.TOPPING_ID
WHERE 
    CO.EXCLUSIONS != 'null' and length(CO.EXCLUSIONS) >= 1 
GROUP BY
    ORDER_ID, PIZZA_ID) 

SELECT
    CONCAT(
        CASE
            WHEN CO.PIZZA_ID = 1 THEN 'Meat Lovers' 
            WHEN CO.PIZZA_ID = 2 THEN 'Vegetarian'
            END,
        ' ',
        CASE
            WHEN length(EXCLUSIONS.EXCLUSION) > 1 THEN '-Exclude ' || EXCLUSIONS.EXCLUSION || ' '
            ELSE ''
            END,
        CASE
            WHEN length(EXTRAS.EXTRA) > 1 THEN '-Extra ' || EXTRAS.EXTRA || ' '
            ELSE ''
            END) AS TICKET
FROM
    CUSTOMER_ORDERS CO
    LEFT JOIN EXTRAS ON CO.EXTRAS = EXTRA_N
    LEFT JOIN EXCLUSIONS ON CO.EXCLUSIONS = EXCLUSION_N;
    
/*5. Generate an alphabetically ordered comma-separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"*/

WITH EXTRAS AS 
(SELECT
    ORDER_ID,
    PIZZA_ID,
    TOPPING_NAME,
    EXCLUSIONS,
    EXTRAS
FROM 
    CUSTOMER_ORDERS CO
    LEFT JOIN LATERAL split_to_table(EXTRAS, ',') SPR
    INNER JOIN PIZZA_TOPPINGS PT
    ON SPR.VALUE = PT.TOPPING_ID
WHERE 
    CO.EXTRAS != 'null' and length(CO.EXTRAS) >= 1)
    ,
    
EXCLUSIONS AS (
   (SELECT
    ORDER_ID,
    PIZZA_ID,
    EXCLUSIONS,
    TOPPING_NAME
FROM 
    CUSTOMER_ORDERS CO
    LEFT JOIN LATERAL split_to_table(EXCLUSIONS, ',') SPR
    INNER JOIN PIZZA_TOPPINGS PT
    ON SPR.VALUE = PT.TOPPING_ID
WHERE 
    CO.EXCLUSIONS != 'null' and length(CO.EXCLUSIONS) >= 1)),
    

ORDERS AS 
    (SELECT
    ORDER_ID,
    CO.PIZZA_ID,
    TOPPING_ID,
    TOPPING_NAME,
    EXCLUSIONS,
    EXTRAS
FROM
    PIZZA_RECIPES PR
    LEFT JOIN LATERAL split_to_table(TOPPINGS, ',') SPR
    INNER JOIN PIZZA_TOPPINGS PT
    ON SPR.VALUE = PT.TOPPING_ID
    INNER JOIN CUSTOMER_ORDERS CO
    ON CO.PIZZA_ID = PR.PIZZA_ID)

,

ORDERS_AND_EXTRAS AS (
SELECT 
    ORDERS.ORDER_ID,
    ORDERS.PIZZA_ID,
    ORDERS.TOPPING_NAME,
    ORDERS.EXCLUSIONS,
    ORDERS.EXTRAS
FROM 
    ORDERS 
    LEFT JOIN EXCLUSIONS
    ON ORDERS.EXCLUSIONS = EXCLUSIONS.EXCLUSIONS  
    and ORDERS.PIZZA_ID = EXCLUSIONS.PIZZA_ID 
    and ORDERS.ORDER_ID = EXCLUSIONS.ORDER_ID 
    and ORDERS.TOPPING_NAME = EXCLUSIONS.TOPPING_NAME
WHERE
    EXCLUSIONS.TOPPING_NAME IS NULL

UNION ALL

SELECT
    *
FROM
    EXTRAS)
,

INGREDIENTS AS(
SELECT
    ORDER_ID,
    CASE
        WHEN PIZZA_ID = 1 THEN 'Meat Lovers' 
        WHEN PIZZA_ID = 2 THEN 'Vegetarian'
        END AS PIZZA_NAME,
    CONCAT(count(TOPPING_NAME), 'x ', TOPPING_NAME) AS ITEM,
    EXCLUSIONS,
    EXTRAS
FROM
    ORDERS_AND_EXTRAS
GROUP BY
    ORDER_ID,
    PIZZA_ID,
    TOPPING_NAME,
    EXCLUSIONS,
    EXTRAS)

SELECT
    ORDER_ID,
    PIZZA_NAME,
    listagg(ITEM, ', ') AS TICKET
FROM
    INGREDIENTS
GROUP BY
    ORDER_ID,
    PIZZA_NAME,
    EXCLUSIONS,
    EXTRAS;