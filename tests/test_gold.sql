select * from gold.dim_customers
select * from gold.dim_products
select * from gold.fact_sales

select * from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
where c.customer_key is null