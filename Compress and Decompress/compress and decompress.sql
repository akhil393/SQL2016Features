/****** Script for SelectTopNRows command from SSMS  ******/

--New SQL 2016 database engine feature COMPRESS and DECOMPRESS 


 declare @vbtest varbinary(max)
declare @vctest varchar(max) = replicate('a',4000)
select  DATALENGTH(@vctest)  as uncompressed
set @vbtest = compress(@vctest)
select  DATALENGTH(@vbtest)  as compressed
select  100- DATALENGTH(@vbtest)/(DATALENGTH(@vctest) * 1.0) as CompressionRatio


--Create two tables with just one column and insert some data 
--One table we will insert raw data in Varchar(max) and inother table we use compress 
--function to insert compressed data
-- create database compress 
 create table [dbo].[uncompressed] (test varchar(max))
 create table [dbo].[compressed](test varbinary(max))
 --Uncompressed
 insert into [dbo].[uncompressed]
 select replicate('a',10000000)
 from sys.objects a
 cross join sys.objects b 
 cross join sys.objects b1 
--Compressed using compress function 
 insert into compressed
 select compress(test) from uncompress


  sp_spaceused 'uncompressed'
 go
  sp_spaceused 'compressed'

  select 100-42264/(6297976 * 1.0) as compressionRatio


  --IO and Speed test
  set statistics time on 
  set statistics io on 
  select top 1000 test from uncompressed
  go 
  select top 1000 convert(varchar,decompress(test)) from compressed
  set statistics io off 
  set statistics time off 



  --Adding page and row compression on top of column compression feature. 

Datatype(varchar(max))
					compressed  uncompressed
COMPRESS()Feature		Yes			No	
No of Rows				787152      787152           
Size					41.2 MB		6150.36 MB
Avgtime elapsed
(1000 Rows Select)		200 ms		300 ms
RowCompressionSize      38.9 MB		6149.64 MB
PageCompressionSize		8.5 MB		6149.64           






--Row compression test over GZIP Column function

	ALTER TABLE [dbo].[compressed] REBUILD PARTITION = ALL
		WITH 
		(DATA_COMPRESSION = ROW)

	ALTER TABLE [dbo].[uncompressed]REBUILD PARTITION = ALL
		WITH 
		(DATA_COMPRESSION =ROW)
--Check row compression savings 		
	sp_spaceused 'compressed'
	go
	sp_spaceused 'uncompressed'

--page compression test

	ALTER TABLE [dbo].[compressed] REBUILD PARTITION = ALL
		WITH 
		(DATA_COMPRESSION = PAGE)


		ALTER TABLE [dbo].[uncompressed]REBUILD PARTITION = ALL
		WITH 
		(DATA_COMPRESSION =PAGE)
--Check space usage

	sp_spaceused 'compressed'
	go
	sp_spaceused 'uncompressed'


--Check page allocations 

	  SELECT
     OBJECT_NAME(sp.object_id) AS [ObjectName]
     ,si.name AS IndexName
     ,sps.in_row_data_page_count as In_Row
     ,sps.row_overflow_used_page_count AS Row_Over_Flow
     ,sps.lob_reserved_page_count AS LOB_Data
FROM
     sys.dm_db_partition_stats sps
     JOIN sys.partitions sp
           ON sps.partition_id=sp.partition_id
     JOIN sys.indexes si
           ON sp.index_id=si.index_id AND sp.object_id = si.object_id
WHERE
     OBJECTPROPERTY(sp.object_id,'IsUserTable') =1
order by sps.in_row_data_page_count desc


--- repeat same test for fixed length varchar 



drop table [dbo].[uncompressed]
drop table [dbo].[compressed]
 create table [dbo].[uncompressed] (test varchar(8000))
 create table [dbo].[compressed](test varbinary(max))
 --Uncompressed
 insert into [dbo].[uncompressed]
 select replicate('a',8000)
 from sys.objects a
 cross join sys.objects b 
 cross join sys.objects b1 
--Compressed using compress function 
 insert into compressed
 select compress(test) from uncompressed


 	sp_spaceused 'compressed'
	go
	sp_spaceused 'uncompressed'

Datatype(varchar(8000))
					compressed  uncompressed
COMPRESS()Feature		Yes			No	
No of Rows				804357     804357                         
Size					42.17 MB	6284.03 MB
Avgtime elapsed
(1000 Rows Select)		250 ms		250 ms
RowCompressionSize      40.02 MB	6284.04 MB
PageCompressionSize		8.8 MB		6284.04 MB          


---Check avg row size 
	
declare @table nvarchar(128)
declare @idcol nvarchar(128)
declare @sql nvarchar(max)

--initialize those two values
set @table = 'uncompressed'
set @idcol = '1'

set @sql = 'select ' + @idcol +' , (0'

select @sql = @sql + ' + isnull(datalength(' + name + '), 1)' 
        from sys.columns where object_id = object_id(@table)
set @sql = @sql + ') as rowsize from ' + @table + ' order by rowsize desc'

PRINT @sql

exec (@sql)

