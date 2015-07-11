
 
EXEC sp_configure 'remote data archive' , '1';
RECONFIGURE;
-- 

USE [StrechDB]
GO

/****** Object:  Table [dbo].[StrechTable]    Script Date: 7/2/2015 12:09:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[StrechTable](
	[name] [sysname] NOT NULL,
	[object_id] [int] NOT NULL,
	[principal_id] [int] NULL,
	[schema_id] [int] NOT NULL,
	[parent_object_id] [int] NOT NULL,
	[type] [char](2) NULL,
	[type_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NOT NULL,
	[modify_date] [datetime] NOT NULL,
	[is_ms_shipped] [bit] NOT NULL,
	[is_published] [bit] NOT NULL,
	[is_schema_published] [bit] NOT NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[created_on] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


INSERT INTO [dbo].[StrechTable]
           ([name]
           ,[object_id]
           ,[principal_id]
           ,[schema_id]
           ,[parent_object_id]
           ,[type]
           ,[type_desc]
           ,[create_date]
           ,[modify_date]
           ,[is_ms_shipped]
           ,[is_published]
           ,[is_schema_published]
		   ,created_on)
select s.*,Getdate() 
 from sys.objects s  cross join sys.objects so
 go 10

 
select count(*) from strechtable 

sp_spaceused 'strechtable'


select * from sys.allocation_units
 where container_id in(
select hobt_id from sys.partitions where object_id =OBJECT_ID('strechtable'))
 
 --enable strech table ( reveiew the requitements and limitations for strechdb)
 --Current only inserts 
--https://msdn.microsoft.com/en-us/library/dn935016.aspx

-- Enable strech database using GUI 
-- Creates a database server and database on azure 

-- Migration DMv's

 select * from sys.tables 
 where is_remote_data_archive_enabled =1 


 select * from sys.databases 
where is_remote_data_archive_enabled =1 


--
-- about remote databases and tables 

select * from  sys.remote_data_archive_databases

 select * from sys.remote_data_archive_tables 

 -- migration rows status 

select * from sys.dm_db_rda_migration_status



sp_spaceused 'strechtable'


sp_spaceused 'strechtable' ,@mode='local_only'


sp_spaceused 'strechtable' ,@mode='remote_only'


-- Run queries 
---when queried the table sql server concatinates result from azure(remote query) and table 

select * from StrechTable

-- pause strech db 


ALTER TABLE strechtable
    ENABLE REMOTE_DATA_ARCHIVE WITH ( MIGRATION_STATE = OFF );



--- Inser some data 

-- Run queries 


select * from StrechTable

--- Check plan 


dbcc checktable ('strechtable')



-- Alter table -- changes to table
--Current there is no functionality 
--Disable Stretch for a table
	--To disable Stretch for a table
	--Pause data migration on the Stretch-enabled table. For more info, see Pause and resume Stretch.
	--Create a new local table with the same schema as the Stretch-enabled table.
	--Copy the data from the Stretch-enabled table into the new table by using an INSERT INTO … SELECT FROM statement.
	--Drop the Stretch-enabled table.
	--Rename the new table with the name of the Stretch-enabled table that you dropped.

-- Db backup 
--check no of rows in table local and remote

--restore 
--check no of rows in table local and remote
-- we have to re authorize the connection which will recreate a new database 
-- run on restored database

declare @azureuser nvarchar(100)=''
declare @azurepass nvarchar(100)=''
EXEC sp_reauthorize_remote_data_archive @azureuser , @azurepass

select count(*) from strechtable 




ALTER TABLE strechtable
    disable REMOTE_DATA_ARCHIVE WITH ( MIGRATION_STATE = ON );



