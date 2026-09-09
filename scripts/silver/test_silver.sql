-- testing for silver.crm_cust_info
--check nulls or dupes in the pk 
SELECT cst_id, COUNT(*) AS cnt
from silver.crm_cust_info
group by cst_id
having COUNT(*) > 1 or cst_id is null

select * from silver.crm_cust_info
where cst_id = 29366

--check for unwanted spaces
select cst_firstname --change to all columns required 
from silver.crm_cust_info
where  cst_firstname != trim(cst_firstname)

-- check for data standardization and consistency
select distinct cst_gndr
from silver.crm_cust_info

select distinct cst_marital_status
from silver.crm_cust_info

--check all data
select * from silver.crm_cust_info

----------- test silver.crm_prd_info -----------
--check nulls or dupes in the pk 
SELECT prd_id, COUNT(*) AS cnt
from silver.crm_prd_info
group by prd_id
having COUNT(*) > 1 or prd_id is null

--check for unwanted spaces
select prd_nm --change to all columns required 
from silver.crm_prd_info
where  prd_nm != trim(prd_nm)

-- check for data standardization and consistency
select distinct prd_line
from silver.crm_prd_info
-- (M, R, S, T: Mountain, Road, Sport, Touring)

--check for nulls in prd_cost
select prd_cost
from silver.crm_prd_info
where prd_cost is null

--check for invalid date orders
select *
from silver.crm_prd_info
where prd_start_dt > prd_end_dt

----------- test silver.crm_sales_details -----------
--check for invalid date orders
select *
from silver.crm_sales_details
where sls_ord_dt > sls_ship_dt or sls_ord_dt > sls_due_dt or sls_ship_dt > sls_due_dt

--check business rules (sales = price * quantity), where sales, price, and quantity are all non-null and non-zero
select distinct
sls_sales, sls_quantity, sls_price
from silver.crm_sales_details
where sls_sales != sls_price * sls_quantity
or sls_sales is null or sls_price is null or sls_quantity is null
or sls_sales <= 0 or sls_price <= 0 or sls_quantity <= 0
order by sls_sales, sls_quantity, sls_price

----------- test silver.erp_cust_az12 -----------
select distinct bdate
from silver.erp_cust_az12
where bdate < '1924-01-01' or bdate > getdate() -- check for invalid birth dates (before 1924 or after today)

select distinct gen
from silver.erp_cust_az12

----------- test silver.erp_loc_a101 -----------
select distinct cntry
from silver.erp_loc_a101

select * from silver.erp_loc_a101

----------- test silver.erp_px_cat_g1v2 -----------
select * from silver.erp_px_cat_g1v2
