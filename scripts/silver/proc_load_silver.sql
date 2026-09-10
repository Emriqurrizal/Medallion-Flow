exec silver.load_silver;
go

--refers to the explore_bronze.sql file to check for problems
create or alter procedure silver.load_silver as
begin
     begin try
          print '--------------------------------'
          PRINT 'Loading data into silver layer'
          print '--------------------------------'

          print '--------------------------------'
          PRINT 'Loading CRM tables:'
          print '--------------------------------'

          -- Cleaning and transforming data from bronze.crm_cust_info to silver.crm_cust_info
          print'Truncating silver.crm_cust_info table'
          truncate table silver.crm_cust_info;
          print'Inserting data into silver.crm_cust_info table'
          insert into silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
          select 
          cst_id,
          cst_key,
          trim(cst_firstname) as cst_firstname, -- remove unwanted spaces
          trim(cst_lastname) as cst_lastname, -- remove unwanted spaces
          case when upper(trim(cst_marital_status)) = 'S' then 'Single' -- standardize gender values and avoid unwanted spaces
               when upper(trim(cst_marital_status)) = 'M' then 'Married'   -- standardize gender values and avoid unwanted spaces
               else 'Unknown'
          end cst_marital_status,
          case when upper(trim(cst_gndr)) = 'F' then 'Female' -- standardize gender values and avoid unwanted spaces
               when upper(trim(cst_gndr)) = 'M' then 'Male'   -- standardize gender values and avoid unwanted spaces
               else 'Unknown'
          end cst_gndr_std,  
          cst_create_date
          from(
               -- picking the latest record for each customer based on cst_create_date (avoid id dupes and nulls)
               select 
               *,
               row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
               from bronze.crm_cust_info
               where cst_id is not null
          )t where flag_last = 1;

          -- Cleaning and transforming data from bronze.crm_prd_info to silver.crm_prd_info
          print'Truncating silver.crm_prd_info table'
          truncate table silver.crm_prd_info;
          print'Inserting data into silver.crm_prd_info table'
          insert into silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
          select
          prd_id,
          replace(substring(prd_key, 1, 5), '-', '_') as cat_id, --splitting 5 first characters from prd_key to as category id and replace - to _ to make it joinable with erp table
          substring(prd_key, 7, len(prd_key)) as prd_key,
          prd_nm,
          isnull(prd_cost, 0) as prd_cost, -- replace nulls in prd_cost with 0
          case upper(trim(prd_line))
               when 'M' then 'Mountain' -- standardize product line values and avoid unwanted spaces
               when 'R' then 'Road'     -- standardize product line values and avoid unwanted spaces
               when 'S' then 'Others'    -- standardize product line values and avoid unwanted spaces
               when 'T' then 'Touring'  -- standardize product line values and avoid unwanted spaces
               else 'Unknown'
          end prd_line,
          cast (prd_start_dt as DATE) as prd_start_dt, --cast removes time from the original datetime field and keeps only the date part
          cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt -- set prd_end_dt to the next prd_start_dt for the same prd_id
          from bronze.crm_prd_info;

          -- Cleaning and transforming data from bronze.crm_prd_info to silver.crm_sales_details
          print'Truncating silver.crm_sales_details table'
          truncate table silver.crm_sales_details;
          print'Inserting data into silver.crm_sales_details table'
          insert into silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_ord_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
          select
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,
          case when sls_ord_dt = 0 or len(sls_ord_dt) != 8 then null -- set invalid dates to null
               else cast(cast(sls_ord_dt as varchar) as date) -- convert int to date (cant directly cast int to date)
          end as sls_ord_dt,
          case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null -- set invalid dates to null
               else cast(cast(sls_ship_dt as varchar) as date) -- convert int to date (cant directly cast int to date)
          end as sls_ship_dt,
          case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null -- set invalid dates to null
               else cast(cast(sls_due_dt as varchar) as date) -- convert int to date (cant directly cast int to date)
          end as sls_due_dt,
          case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) 
               then sls_quantity * abs(sls_price) 
          else sls_sales 
          end as sls_sales, --fix business rule (refer to explore_bronze.sql for the business rule)
          sls_quantity,
          case when sls_price is null or sls_price <= 0 
               then sls_sales / nullif(sls_quantity, 0)
          else sls_price 
          end as sls_price --fix business rule (refer to explore_bronze.sql for the business rule)
          from bronze.crm_sales_details;

          print '--------------------------------'
          PRINT 'Loading ERP tables'
          print '--------------------------------'

          -- Cleaning and transforming data from bronze.erp_cust_az12 to silver.erp_cust_az12
          print'Truncating silver.erp_cust_az12 table'
          truncate table silver.erp_cust_az12;
          print'Inserting data into silver.erp_cust_az12 table'
          insert into silver.erp_cust_az12 (cid, bdate, gen)
          select 
          case when cid like 'NAS%' then substring(cid, 4, len(cid)) -- remove 'NAS' prefix from cid
               else cid
          end as cid,
          case when bdate > getdate() then null
               else bdate
          end as bdate,
          case when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
               when upper(trim(gen)) IN ('M', 'MALE') then 'Male'
               else 'Unknown'
          end as gen
          from bronze.erp_cust_az12

          -- Cleaning and transforming data from bronze.erp_loc_a101 to silver.erp_loc_a101
          print'Truncating silver.erp_loc_a101 table'
          truncate table silver.erp_loc_a101;
          print'Inserting data into silver.erp_loc_a101 table'
          insert into silver.erp_loc_a101 (cid, cntry)
          select 
          replace(cid, '-', '') as cid, -- remove '-' from cid
          case when upper(trim(cntry)) in ('US', 'USA') then 'United States' -- standardize country values and avoid unwanted spaces
               when upper(trim(cntry)) in ('DE', 'GERMANY') then 'Germany'
               when upper(trim(cntry)) = '' or cntry is null then 'Unknown'
               else cntry
          end as cntry
          from bronze.erp_loc_a101;

          -- cleaning and transforming data from bronze.erp_px_cat_g1v2 to silver.erp_px_cat_g1v2
          print'Truncating silver.erp_px_cat_g1v2 table'
          truncate table silver.erp_px_cat_g1v2;
          print'Inserting data into silver.erp_px_cat_g1v2 table'
          insert into silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
          select 
          id,
          cat,
          subcat,
          maintenance
          from bronze.erp_px_cat_g1v2;
     end try
     BEGIN CATCH
        PRINT 'Error occurred while loading data into silver layer:'
        PRINT ERROR_MESSAGE()
     END CATCH
end
go

