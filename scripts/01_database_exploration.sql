 DATA BASE EXPLORATION

--EXPLORE ALL OBJECTS IN THE DATABASE
SELECT * FROM INFORMATION_SCHEMA.TABLES

--EXPLORE ALL COLUMN IN THE DATABASE

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
