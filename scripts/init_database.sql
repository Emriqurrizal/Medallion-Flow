--Create a new database called DataWarehouse and three schemas: bronze, silver, and gold.

USE master;
GO

--create db
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
