-- Enable connectivity

EXEC sp_configure 'hadoop connectivity', 5; 
GO 
RECONFIGURE; 
GO 
---create external data source

CREATE EXTERNAL DATA SOURCE HTDP WITH 
( 
    TYPE = HADOOP, 
    LOCATION = 'hdfs://WIN-J1MJU5GE1B3:8020' 
)

--data source with resouce manager
CREATE EXTERNAL DATA SOURCE YHTDP WITH 
( 
    TYPE = HADOOP, 
	LOCATION = 'hdfs://WIN-J1MJU5GE1B3:8020', 
	RESOURCE_MANAGER_LOCATION = 'WIN-J1MJU5GE1B3:8050' 
)
CREATE EXTERNAL DATA SOURCE TESTHDP WITH 
( 
    TYPE = HADOOP, 
	LOCATION = 'hdfs://WIN-J1MJU5GE1B3:8020', 
	RESOURCE_MANAGER_LOCATION = 'WIN-J1MJU5GE1B3:8050' 
)




--- Create external file format 
CREATE EXTERNAL FILE FORMAT CDCSV 
WITH ( 
    FORMAT_TYPE = DELIMITEDTEXT, 
    FORMAT_OPTIONS ( 
        FIELD_TERMINATOR = ',', 
        DATE_FORMAT = 'yyyy-MM-dd HH:mm:ss' ,
		 USE_TYPE_DEFAULT = TRUE 
    ) 
)



-- with out resource manager
create external table AdventureWorksSalesy
( 
    [OrderDate] [datetime] ,
	[CustomerID] [int]  ,
	[SalesPersonID] [int] ,
	[TerritoryID] [int],
	[ShipToAddressID] [int] ,
	[SubTotal] [money],
	[TaxAmt] [money] ,
	[Freight] [money] ,
	[TotalDue]  [money] 
) 
WITH 
( 
    LOCATION = '/sample/AdventureWorksSales.csv', 
    DATA_SOURCE = YHTDP, 
    FILE_FORMAT = CDCSV
	
) 

-- With yarn
create external table AdventureWorksSalesy
( 
    [OrderDate] [datetime] ,
	[CustomerID] [int]  ,
	[SalesPersonID] [int] ,
	[TerritoryID] [int],
	[ShipToAddressID] [int] ,
	[SubTotal] [money],
	[TaxAmt] [money] ,
	[Freight] [money] ,
	[TotalDue]  [money] 
) 
WITH 
( 
    LOCATION = '/sample/AdventureWorksSales.csv', 
    DATA_SOURCE = YHTDP, 
    FILE_FORMAT = CDCSV
	
) 

--- large data set

create external table AdventureWorksSalesybig
( 
    [OrderDate] [datetime] ,
	[CustomerID] [int]  ,
	[SalesPersonID] [int] ,
	[TerritoryID] [int],
	[ShipToAddressID] [int] ,
	[SubTotal] [money],
	[TaxAmt] [money] ,
	[Freight] [money] ,
	[TotalDue]  [money] 
) 
WITH 
( 
    LOCATION = '/sample/AdventureWorksSaleslarge.csv', 
    DATA_SOURCE = YHTDP, 
    FILE_FORMAT = CDCSV
	
) 


create external table AdventureWorksSalesybigtest
( 
    [OrderDate] [datetime] ,
	[CustomerID] [int]  ,
	[SalesPersonID] [int] ,
	[TerritoryID] [int],
	[ShipToAddressID] [int] ,
	[SubTotal] [money],
	[TaxAmt] [money] ,
	[Freight] [money] ,
	[TotalDue]  [money] 
) 
WITH 
( 
    LOCATION = '/sample/AdventureWorksSaleslarge.csv', 
    DATA_SOURCE = TESTHDP, 
    FILE_FORMAT = CDCSV
	
) 


select * from  AdventureWorksSalesy a 
inner join [Person].[Person] p on a.[SalesPersonID] = p.[BusinessEntityID]
where  [TotalDue] > 1000


select customerid ,sum(subtotal)  from  AdventureWorksSalesy 

group by customerid


select * from AdventureWorksSalesybig 
where  customerid=26091
