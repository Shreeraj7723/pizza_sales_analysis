--Pizzahut Sales Analysis
--1 Retrieve the total number of orders placed.
SELECT Count(order_id) as total_orders FROM orders;
--2 Calculate the total revenue generated from pizza sales.
SELECT 
sum(order_details.quantity * pizzas.price) as total_sales
FROM order_details JOIN pizzas
ON pizzas.pizza_id=order_details.pizza_id;

--3 Identify the highest-priced pizza.
SELECT pizza_types.name,pizzas.price
FROM pizza_types JOIN pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc limit 1;

--4 Identify the most common pizza size ordered.

SELECT pizzas.size, count(order_details.order_details_id) as common_order
FROM pizzas JOIN order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by common_order desc limit 1;

--5 List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,
sum(order_details.quantity) as sum_ordered
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details 
ON order_details.pizza_id=pizzas.pizza_id 
GROUP BY pizza_types.name order by sum_ordered desc limit 5; 

--6 Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category,
SUM(order_details.quantity) as quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details 
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category order by quantity desc;

--7 Determine the distribution of orders by hour of the day.
SELECT EXTRACT(hour from time) as time, count(order_id) as order_count from orders
GROUP BY EXTRACT(hour from time) order by order_count desc;

--8 Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, count(name) from pizza_types
GROUP By category;

--9 Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT Round(avg(quantity),0) as avg_pizzas_ordered_per_day from 
(SELECT orders.date,
sum(order_details.quantity)as quantity
FROM orders JOIN order_details
ON orders.order_id= order_details.order_id
GROUP BY  orders.date) as order_quantity;

--10 Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id= pizzas.pizza_id
GROUP BY pizza_types.name order by revenue desc limit 3;

--11 Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
   round( (SUM(order_details.quantity * pizzas.price)::NUMERIC / 
        (SELECT SUM(order_details.quantity * pizzas.price):: NUMERIC 
         FROM order_details 
         JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)
    ) * 100,2) AS revenue
FROM 
    pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    revenue DESC;

--12 Analyze the cumulative revenue generated over time.
SELECT date,
sum(revenue) over(order by date) as cum_revenue
FROM
(SELECT orders.date,
SUM(order_details.quantity * pizzas.price) as revenue
FROM order_details JOIN pizzas
on order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.date) as sales;

--13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue, category
FROM
(SELECT category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM(order_details.quantity * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) as a) as b
where rn<=3;
