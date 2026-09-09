----------- explore bronze.crm_cust_info -----------
--check nulls or dupes in the pk 
SELECT cst_id, COUNT(*) AS cnt
from bronze.crm_cust_info
group by cst_id
having COUNT(*) > 1 or cst_id is null

select * from bronze.crm_cust_info
where cst_id = 29466

--check for unwanted spaces
select cst_firstname --change to all columns required 
from bronze.crm_cust_info
where  cst_firstname != trim(cst_firstname)

-- check for data standardization and consistency
select distinct cst_gndr
from bronze.crm_cust_info

select distinct cst_marital_status
from bronze.crm_cust_info

----------- explore bronze.crm_prd_info -----------
--check nulls or dupes in the pk 
SELECT prd_id, COUNT(*) AS cnt
from bronze.crm_prd_info
group by prd_id
having COUNT(*) > 1 or prd_id is null

--check for unwanted spaces
select prd_nm --change to all columns required 
from bronze.crm_prd_info
where  prd_nm != trim(prd_nm)

-- check for data standardization and consistency
select distinct prd_line
from bronze.crm_prd_info
-- (M, R, S, T: Mountain, Road, Sport, Touring)

--check for nulls in prd_cost
select prd_cost
from bronze.crm_prd_info
where prd_cost is null

--check for invalid date orders
select *
from bronze.crm_prd_info
where prd_start_dt > prd_end_dt

----------- explore bronze.crm_sales_details -----------
--check for invalid date orders
select *
from bronze.crm_sales_details
where sls_ord_dt > sls_ship_dt or sls_ord_dt > sls_due_dt or sls_ship_dt > sls_due_dt
--check for invalid data types
select nullif(sls_ord_dt, 0) sls_ord_dt
from bronze.crm_sales_details
where sls_ord_dt <= 0 
or len(sls_ord_dt) != 8 

select nullif(sls_ship_dt, 0) sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt <= 0 
or len(sls_ship_dt) != 8

select nullif(sls_due_dt, 0) sls_due_dt
from bronze.crm_sales_details
where sls_due_dt <= 0 
or len(sls_due_dt) != 8

--check business rules (sales = price * quantity), where sales, price, and quantity are all non-null and non-zero
select distinct
sls_sales, sls_quantity, sls_price
from bronze.crm_sales_details
where sls_sales != sls_price * sls_quantity
or sls_sales is null or sls_price is null or sls_quantity is null
or sls_sales <= 0 or sls_price <= 0 or sls_quantity <= 0
order by sls_sales, sls_quantity, sls_price
/*rules for fixing:
if sales is negative, zero, or null, then set sales = price * quantity
if price is zero or null, then set price = sales / quantity
if price is negative, then set price = abs(price)*/ 
select distinct
sls_sales as old_sls_sales,
sls_quantity, 
sls_price as old_sls_price,
case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) 
        then sls_quantity * abs(sls_price) 
    else sls_sales 
end as sls_sales,
case when sls_price is null or sls_price <= 0 
        then sls_sales / sls_quantity
    else sls_price 
end as sls_price
from bronze.crm_sales_details
where sls_sales != sls_price * sls_quantity
or sls_sales is null or sls_price is null or sls_quantity is null
or sls_sales <= 0 or sls_price <= 0 or sls_quantity <= 0
order by sls_sales, sls_quantity, sls_price

----------- explore bronze.erp_cust_az12 -----------
select distinct bdate
from bronze.erp_cust_az12
where bdate < '1924-01-01' or bdate > getdate() -- check for invalid birth dates (before 1924 or after today)

select distinct gen
from bronze.erp_cust_az12

----------- explore bronze.erp_loc_a101-----------
select * from bronze.erp_loc_a101

select distinct cntry
from bronze.erp_loc_a101

----------- explore bronze.erp_px_cat_g1v2-----------
select id, count(*) as cnt
from bronze.erp_px_cat_g1v2
group by id
having count(*) > 1 or id is null

select id 
from bronze.erp_px_cat_g1v2
where  id != trim(id)

select distinct id
from bronze.erp_px_cat_g1v2

select * from silver.crm_prd_info

----------- explore bronze.erp_px_cat_g1v2 -----------
select * from bronze.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance)

select distinct maintenance
from bronze.erp_px_cat_g1v2 --all good from the bronze data, no need to clean or transform