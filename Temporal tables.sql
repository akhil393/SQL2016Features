https://en.wikipedia.org/wiki/SQL:2011
https://msdn.microsoft.com/en-us/library/Dn935015.aspx


-- Temporal tables
-- Only updates and deletes are moved to history table, Inserted data stays in the current table

  
select name,temporal_type,temporal_type_desc,history_table_id from sys.tables where temporal_type  !=0

select top 10 *  from  [Production].[Product]

sp_help '[Production].[Product]'


alter table [Production].[Product]
ADD PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime), 
SysStartTime datetime2 GENERATED ALWAYS AS ROW START  NOT NULL CONSTRAINT DEFAULT_SYSSTART_TIME DEFAULT GETUTCDATE(), 
SysEndTime datetime2 GENERATED ALWAYS AS ROW END  NOT NULL CONSTRAINT DEFAULT_SYSEND_TIME DEFAULT CONVERT(DATETIME2, '9999.12.31');

select  top 10 *   from  [Production].[Product] where ListPrice=150 > 0

-- Turn on versioning and add a history table
--Restrictions
---No computed columns in 2.0
---SysStartTime and SysEndTime values must be defined with a datatype of datetime2.
---By default, the history table is PAGE compressed.
---If current table is partitioned, the history table is created on default file group because partitioning configuration is not replicated automatically from the current table to the history table.
---when using gui to alter table it disables the system versioning but does not enable
---TRUNCATE TABLE is not supported while SYSTEM_VERSIONING is ON
---INSTEAD OF triggers are not permitted on either the current or the history table to avoid invalidating the DML logic. 

alter table  [Production].[Product] set (system_versioning = ON (HISTORY_TABLE= [Production].[Product_History]))

sp_help '[Production].[Product_History]'

select * from [Production].[Product_History]


select  top 10 *   from  [Production].[Product] where ListPrice=150 > 0


select  *   from  [Production].[Product]
where ProductID = 514

update  [Production].[Product] 
set ListPrice = 150
where ProductID = 514

select * from [Production].[Product_History] 

delete [Production].[Product]
where ProductID = 514


--- To disable versioning 
alter table  [Production].[Product] set (system_versioning = OFF)
-- to trun versioning back on 
alter table  [Production].[Product] set (system_versioning = ON (HISTORY_TABLE= [Production].[Product_History], DATA_CONSISTENCY_CHECK = ON))

-- To Disable Syste versioning 
--Turn of system versioning
alter table  [Production].[Product] set (system_versioning = OFF)
alter table  [Production].[Product] drop PERIOD FOR SYSTEM_TIME
truncate table [Production].[Product_History]
alter table  [Production].[Product] drop constraint DEFAULT_SYSSTART_TIME
alter table  [Production].[Product] drop constraint DEFAULT_SYSEND_TIME
alter table  [Production].[Product] drop column sysstarttime
alter table  [Production].[Product] drop column sysendtime 
drop table [Production].[Product_History]





create function period (@sysstartime datetime2,@sysendtime datetime2)
returns int
as
begin
declare @diff int;
set @diff = DATEDIFF(ss,@sysstartime, case when @sysendtime = '9999-12-31 00:00:00.0000000' 
			then @sysstartime else @sysendtime end)
return(@diff)
end;






---Prouct          -- Temporal Table
---Product_history -- History Table 


---Query Temporal Table 
--For Systemtime
				--AS OF	
				--BETWEEN
				--FROM
				--CONTAINED IN		
 

select name,temporal_type,temporal_type_desc,history_table_id 
from sys.tables 
where temporal_type  !=0

--Lets look at a transaction
select top 10 *  
from  [Production].[Product] 
where ListPrice > 0

--Actual data
select productid,listprice,sysstarttime,sysendtime  
from  [Production].[Product]  
where productid = 515
--History data
select productid,listprice,sysstarttime,sysendtime
from [Production].[product_history]


begin tran 
select GETUTCDATE() 
update [Production].[Product]  
set ListPrice=130 
where productid = 515
commit tran 
waitfor delay '00:00:03'

begin tran 
select GETUTCDATE() 
update [Production].[Product]  
set ListPrice=140 
where productid = 515
commit tran 

waitfor delay '00:00:03'
begin tran 
select GETUTCDATE() 
update [Production].[Product]  
set ListPrice=150 
where productid = 515
commit tran 
--2015-08-07 11:14:28.587




---Check the current table
select productid,listprice,sysstarttime,sysendtime ,dbo.period(sysstarttime,SysEndTime) as record_validity 
	from  [Production].[Product] where productid = 515
--Check the temporal history table
select productid,listprice,sysstarttime,sysendtime ,dbo.period(sysstarttime,SysEndTime) as record_validity 
 from [Production].[Product_History]


-- AS of will give us state of the record at the point of time one unique record for each row.. either active record or history record
-- How temporal queries work
declare @date_time datetime2 = '2015-08-10 10:46:24.0779411'
select productid,listprice,sysstarttime,sysendtime ,dbo.period(sysstarttime,SysEndTime) as record_validity 
from  [Production].[Product]
for system_time as of @date_time
--[SysEndTime]>[@date_time] and SysStartTime <= [@date_time]
where productid = 515

--declare @date_time datetime2 = '2015-08-10 10:46:24.0779411'
Select productid,listprice,sysstarttime,sysendtime  from production.product 
where sysstarttime <= @date_time
and sysendtime > @date_time
and productid = 515
union 
Select productid,listprice,sysstarttime,sysendtime  from production.product_history 
where sysstarttime <= @date_time 
and sysendtime >@date_time
and productid = 515




---Check the current table
select productid,listprice,sysstarttime,sysendtime  from  [Production].[Product] where productid = 515
--Check the temporal history table
select productid,listprice,sysstarttime,sysendtime,dbo.period(sysstarttime,SysEndTime) as record_validity  
 from [Production].[Product_History]


begin tran 
select GETUTCDATE()  

update [Production].[Product]  set  ListPrice=120 
where productid = 515
commit tran 
--2015-08-07 11:22:38.080

---Check the current table
select * from  [Production].[Product] where productid = 515
--Check the temporal history table
select *,DATEDIFF(ss,sysstarttime, case when SysEndTime = '9999-12-31 00:00:00.0000000' 
			then sysstarttime else SysEndTime end) as record_validity 
 from [Production].[Product_History]



-- From give us all the records during the time specified including the active record if it falls in the range of query 
--SysStartTime < end_date_time AND SysEndTime > start_date_time
Declare @lower datetime2 = '2015-08-07 11:32:27.8942358'
declare @upper datetime2 = '2015-08-10 10:46:24.0779411'

select *,dbo.period(sysstarttime,SysEndTime) as record_validity 
from  [Production].[Product]
for system_time from  @lower to @upper
where productid = 515
order by sysstarttime asc 

-- Between give us all the records during the time specified and including the active record if it falls in the range of query 
--SysStartTime <= end_date_time AND SysEndTime > start_date_time

select *,dbo.period(sysstarttime,SysEndTime) as record_validity 
from  [Production].[Product]
for system_time between  @lower and @upper
where productid = 515
order by sysstarttime asc 


-- Contained give us all the records during the time specified and including the active record if it falls in the range of query 
---SysStartTime >= start_date_time AND SysEndTime <= end_date_time
select *,dbo.period(sysstarttime,SysEndTime) as record_validity 
from  [Production].[Product]
for system_time CONTAINED IN (@lower ,  @upper)
where productid = 515
order by sysstarttime asc 



 
AS OF <date_time>									SysStartTime <= date_time AND SysEndTime > date_time
FROM <start_date_time> TO <end_date_time>			SysStartTime < end_date_time AND SysEndTime > start_date_time
BETWEEN <start_date_time> AND <end_date_time>		SysStartTime <= end_date_time AND SysEndTime > start_date_time
CONTAINED IN (<start_date_time> , <end_date_time>)	SysStartTime >= start_date_time AND SysEndTime <= end_date_time



delete from production.product where productid = 515 

-- Product's that were deleted from product catalog
select * from production.product_history ph  left outer join production.product p
on ph.productid = p.productid 
where p.productid is null 


--- Get all rows and custom queries 
declare @productid int = 515


select  * ,dbo.period(sysstarttime,SysEndTime) as record_validity 
 from [Production].[Product] 
where productid = @productid
union 
select *,dbo.period(sysstarttime,SysEndTime) as record_validity  
			 from [Production].[Product_History] pTH
where productid = @productid














-- Performance and Limitations

--Minimal impact on insert
/*Update and delete takes twice 
the amount of time it takes to update with out temporal tables
*/
  
select name,temporal_type,temporal_type_desc,history_table_id 
from sys.tables where temporal_type  !=0


checkpoint 
dbcc dropcleanbuffers

update production.product
set makeflag = 1 
go 50


alter table  [Production].[Product] set (system_versioning = OFF)

alter table  [Production].[Product] set (system_versioning = ON (HISTORY_TABLE= [Production].[Product_History], DATA_CONSISTENCY_CHECK = ON))

--check temportal status 
  
select name,temporal_type,temporal_type_desc,history_table_id 
from sys.tables where temporal_type  !=0


-- limitations
 --
 https://msdn.microsoft.com/en-us/library/Dn935015.aspx


BEGIN TRAN 

        /* Takes schema lock on both tables */
ALTER TABLE [Production].[Product]
SET (SYSTEM_VERSIONING = OFF)

/* add column to current table */
ALTER TABLE [Production].[Product]
ADD test INT NULL;
        /* add column to history table */
ALTER TABLE [Production].[Product_History]
ADD test INT NULL;


        /* Re-establish versioning agin
        Given that this operation is under strict control (other transactions are blocked), 
        DBA chooses to ignore data consistency check in order to make it fast
        */
ALTER TABLE [Production].[Product]
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[Production].[Product_History], DATA_CONSISTENCY_CHECK = ON));

COMMIT;
GO

select GETUTCDATE()

select * from sys.periods

select object_name(object_id),column_id,generated_always_type,generated_always_type_desc 
from sys.columns
where generated_always_type !=0














with cte as 
(

select top 500000 *  from [Production].[Product]
order by TransactionID desc 

)

delete from cte 