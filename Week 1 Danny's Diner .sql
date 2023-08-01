/* 1. What is the Total Amount Each Customer Spent */

SELECT s.Customer_id, SUM(m.price) AS total_amount_spent
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.Customer_id;

/* 2. How many days has each customer visited the restaurant?  */

SELECT s.Customer_id, COUNT(DISTINCT DATE(s.Order_date)) AS days_visited
FROM Sales s
GROUP BY s.Customer_id;

/* 3. What was the first item from the menu purchased by each customer?  */

SELECT s.Customer_id, m.product_name AS first_purchased_item
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
WHERE (s.Customer_id, s.Order_date) IN (
    SELECT Customer_id, MIN(Order_date)
    FROM Sales
    GROUP BY Customer_id
);

/* 4. What is the most purchased item on the menu and how many times was it purchased by all customers? */

SELECT m.product_name AS most_purchased_item, COUNT(*) AS no_of_times_purchased
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY no_of_times_purchased DESC 
LIMIT 1;


/* 5. Which item was the most popular for each customer? */

SELECT  s.Customer_id, m.product_name AS most_popular_item, (COUNT(*)) AS purchase_count
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.Customer_id, s.product_id, m.product_name
ORDER BY purchase_count DESC;

/* 6. Which item was purchased first by the customer after they became a member? */

SELECT ANY_VALUE(m.product_name) AS first_purchased_item, s.Customer_id, MIN(s.Order_date) AS first_purchase_date
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
JOIN Members mem ON s.Customer_id = mem.customer_id
WHERE s.Order_date >= mem.join_date
GROUP BY s.Customer_id;

/* 7. Which item was purchased last by the customer before they became a member? */

SELECT m.product_name AS last_purchased_item, s.Customer_id, s.Order_date AS last_purchase_date
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
JOIN Members mem ON s.Customer_id = mem.customer_id
WHERE (s.Customer_id, s.Order_date) IN (
    SELECT Customer_id, MAX(Order_date)
    FROM Sales
    WHERE Order_date < mem.join_date
    GROUP BY Customer_id
);

/* 8. What is the total items and amount spent for each member before they became a member? */
SELECT s.Customer_id, mem.join_date, 
       COUNT(s.product_id) AS total_items_purchased,
       SUM(m.price) AS total_amount_spent
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
JOIN Members mem ON s.Customer_id = mem.customer_id
WHERE s.Order_date < mem.join_date
GROUP BY s.Customer_id, mem.join_date;


/* 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? */

SELECT s.Customer_id,
       SUM(CASE WHEN m.product_name = 'sushi' THEN 2 * m.price ELSE m.price END) * 10 AS total_points
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.Customer_id;


/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? */

SELECT s.Customer_id, 
       10 * SUM(CASE 
                  WHEN s.Order_date <= DATE_ADD(mem.join_date, INTERVAL 1 WEEK) THEN 2 * m.price 
                  ELSE m.price 
               END) AS total_points
FROM Sales s
JOIN menu m ON s.product_id = m.product_id
JOIN Members mem ON s.Customer_id = mem.customer_id
WHERE s.Order_date <= '2023-01-31'
GROUP BY s.Customer_id;



