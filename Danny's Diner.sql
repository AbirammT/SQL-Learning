-- 1. What is the total amount each customer spent at the restaurant?

select S.CUSTOMER_ID, sum(M.PRICE)
from TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY S.CUSTOMER_ID;


-- 2. How many days has each customer visited the restaurant?

SELECT CUSTOMER_ID, count(distinct(ORDER_DATE))
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES
GROUP BY CUSTOMER_ID; 


-- 3. What was the first item from the menu purchased by each customer?

WITH CTE AS
(SELECT S.CUSTOMER_ID, S.ORDER_DATE, M.PRODUCT_NAME,
RANK() 
    OVER(PARTITION BY S.CUSTOMER_ID
    ORDER BY S.ORDER_DATE ASC) as "rnk"
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU M on S.PRODUCT_ID = M.PRODUCT_ID)
SELECT * FROM CTE
WHERE "rnk" = 1;

-- (Note: you can choose to return all items for their first order or pick 1 of the items from their first order, I'll accept either)


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT M.PRODUCT_NAME, count(S.PRODUCT_ID) AS "count"
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU M on S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY M.PRODUCT_NAME
ORDER BY "count" DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer? 

WITH CTE AS (
SELECT M.PRODUCT_NAME, count(S.PRODUCT_ID) AS "count", S.CUSTOMER_ID,
rank() over(PARTITION BY S.CUSTOMER_ID ORDER BY "count" desc) AS "rnk"
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU M on S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY M.PRODUCT_NAME, S.CUSTOMER_ID
ORDER BY "count" DESC)
SELECT * FROM CTE
WHERE "rnk" = 1;


/* 6. Which item was purchased first by the customer after they became a member?

(Note: you can choose to return all or 1 of the items that meet this condition, I'll accept either) */

WITH CTE AS (
SELECT Mem.CUSTOMER_ID, Mem.JOIN_DATE, S.ORDER_DATE, Men.PRODUCT_NAME, datediff(day,Mem.JOIN_DATE,S.ORDER_DATE) AS "time/days",
RANK() OVER (PARTITION BY Mem.CUSTOMER_ID ORDER BY "time/days" ASC) AS "rnk"
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU Men ON S.PRODUCT_ID = Men.PRODUCT_ID
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MEMBERS Mem ON S.CUSTOMER_ID = Mem.CUSTOMER_ID
WHERE "time/days" >= 0)
SELECT CUSTOMER_ID, PRODUCT_NAME FROM CTE 
WHERE "rnk" = 1;


-- 7. Which item was purchased just before the customer became a member?

WITH CTE AS (
SELECT Mem.CUSTOMER_ID, Mem.JOIN_DATE, S.ORDER_DATE, Men.PRODUCT_NAME, datediff(day,Mem.JOIN_DATE,S.ORDER_DATE) AS "time/days",
RANK() OVER (PARTITION BY Mem.CUSTOMER_ID ORDER BY "time/days" DESC) AS "rnk"
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU Men ON S.PRODUCT_ID = Men.PRODUCT_ID
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MEMBERS Mem ON S.CUSTOMER_ID = Mem.CUSTOMER_ID
WHERE "time/days" < 0)
SELECT * FROM CTE ;

-- (Note: you can choose to return all or 1 of the items that meet this condition, I'll accept either)

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT Mem.CUSTOMER_ID,count(S.PRODUCT_ID) ,sum(Men.PRICE)
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU Men ON S.PRODUCT_ID = Men.PRODUCT_ID
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MEMBERS Mem ON S.CUSTOMER_ID = Mem.CUSTOMER_ID
WHERE datediff(day,Mem.JOIN_DATE,S.ORDER_DATE) < 0
GROUP BY Mem.CUSTOMER_ID;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT S.CUSTOMER_ID,
SUM((CASE
    WHEN PRODUCT_NAME = 'sushi' then 20
    ELSE 10 END)*PRICE) AS "POINTS"
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU Men ON S.PRODUCT_ID = Men.PRODUCT_ID
GROUP BY S.CUSTOMER_ID;



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customers A and B have at the end of January?

SELECT S.CUSTOMER_ID, sum((CASE
    WHEN PRODUCT_NAME = 'sushi' then 20
    WHEN datediff(day,Mem.JOIN_DATE,S.ORDER_DATE) BETWEEN 0 AND 7 then 20
    ELSE 10 END*Men.PRICE)) AS "POINTS"
FROM TIL_PLAYGROUND.CS1_DANNYS_DINER.SALES S
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MENU Men ON S.PRODUCT_ID = Men.PRODUCT_ID
    JOIN TIL_PLAYGROUND.CS1_DANNYS_DINER.MEMBERS Mem ON S.CUSTOMER_ID = Mem.CUSTOMER_ID
WHERE month(S.ORDER_DATE) = 1
GROUP BY S.CUSTOMER_ID;