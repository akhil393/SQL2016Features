-- Temporal tables
-- Only updates and deletes are moved to history table, Inserted data stays in the current table
alter table [Sales].[SalesOrderHeader] 
ADD PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime), 
SysStartTime datetime2 GENERATED ALWAYS AS ROW START  NOT NULL DEFAULT GETUTCDATE(), 
SysEndTime datetime2 GENERATED ALWAYS AS ROW END  NOT NULL DEFAULT CONVERT(DATETIME2, '9999.12.31');


-- trun on versioning and add a history table
--restrictions
---No computed columns in 2.0
--SysStartTime and SysEndTime values must be defined with a datatype of datetime2.
--By default, the history table is PAGE compressed.
--If current table is partitioned, the history table is created on default file group because partitioning configuration is not replicated automatically from the current table to the history table.
-- when using gui to alter table it disables the system versioning but does not enable
--TRUNCATE TABLE is not supported while SYSTEM_VERSIONING is ON
--INSTEAD OF triggers are not permitted on either the current or the history table to avoid invalidating the DML logic. 

alter table disable trigger all 

alter table  [Sales].[SalesOrderHeader] set (system_versioning = ON (HISTORY_TABLE= dbo.SalesOrderHeader_Hist))

update [Sales].[SalesOrderHeader]  set taxamt = 197 
where salesorderid =43659 

select * from [Sales].[SalesOrderHeader] 
for system_time as of '2015-07-08 15:27:30.7930000' 
			--BETWEEN
			--FROM
			--CONTAINED IN		
where salesorderid =43659

--- To disable versioning 
alter table  [Sales].[SalesOrderHeader] set (system_versioning = OFF)
-- to trun versioning back on 
alter table  [Sales].[SalesOrderHeader] set (system_versioning = ON (HISTORY_TABLE= dbo.SalesOrderHeader_Hist, DATA_CONSISTENCY_CHECK = ON))

-- to drop period 
alter table [Sales].[SalesOrderHeader] drop PERIOD FOR SYSTEM_TIME

