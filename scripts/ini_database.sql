

/* 
=======================================================================================================
CREATE DATABASE AND SCHEMA
=======================================================================================================
script objective:
The scripts create a new Database named 'DataWharehouse'. The scripts will check if the Database does exist. if the Database exist, the script will dropped the database and recreate it.
Futhermore, the script set up addtional script for three schema namely, 'bronze', 'silver', and 'gold'.

WARNING
Proceed with caution and make sure you have proper backups before running the scripts.
Because the scripts has the power to drop the entire 'DataWarehouse' if the database exists.
All data in the database will be permanetly be deleted.
*/
USE master;
GO
-- Drop and Recreate 'DataWarehouse' database
  IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
  BEGIN
       ALTER DATABASE DataWarehouse SET SINGLE_USER ROLLBACK IMMEDIATE;
   END;
   GO

--- Create the'DataWarehouse' Database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO
--- Create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
