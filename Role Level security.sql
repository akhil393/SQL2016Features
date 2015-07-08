-- Goal restrict users to only see the sales they contributed

Use AdventureWorks2014

alter table [Person].[Person] drop column [login]

alter table [Person].[Person] add login  AS (left([FirstName],(1))+middleName+[LastName])

SELECT  distinct BusinessEntityID ,login
,'CREATE USER '+login+' WITHOUT LOGIN;'+  'grant select on [Sales].[SalesReason] to '+login as sql
  FROM [AdventureWorks2014].[Person].[Person] 
  where login is not null and login  in ('JHGoldberg',
										'DAMiller',
										'DLMargheim',
										'GNMatthew',
										'OVCracium')

order by login 


Go
CREATE SCHEMA Security;
GO
Create FUNCTION Security.fn_securitypredicate(@BusEntId int )
    RETURNS table
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result  from [Sales].[SalesPerson] 
WHERE exists  (SELECT  1 FROM [Person].[Person] where login = USER_NAME()
and @BusEntId = BusinessEntityID)
or IS_SRVROLEMEMBER ('sysadmin') = 1
GO
CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE Security.fn_securitypredicate([BusinessEntityID]) 
ON [Sales].[SalesPerson] 
WITH (STATE = ON);
Go

drop SECURITY POLICY SalesFilter

GO
CREATE USER DAMiller WITHOUT LOGIN;grant select on [Sales].[SalesPerson] to DAMiller
CREATE USER DLMargheim WITHOUT LOGIN;grant select on [Sales].[SalesPerson] to DLMargheim
CREATE USER GNMatthew WITHOUT LOGIN;grant select on [Sales].[SalesPerson] to GNMatthew
CREATE USER JHGoldberg WITHOUT LOGIN;grant select on [Sales].[SalesPerson] to JHGoldberg
CREATE USER OVCracium WITHOUT LOGIN;grant select on [Sales].[SalesPerson] to OVCracium
GO

EXECUTE AS USER = 'DAMiller';
select USER_NAME()
SELECT * FROM [Sales].[SalesPerson]; 
REVERT;




ALTER SECURITY POLICY SalesFilter
WITH (STATE = OFF);




select CONTEXT_INFO()

declare @cinfo varbinary(5) = (select convert(varbinary(5),'akhil'))
set context_info @cinfo

select convert(varchar,context_info())
