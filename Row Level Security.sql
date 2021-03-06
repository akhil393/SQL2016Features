/****** Script for SelectTopNRows command from SSMS  ******/
Use AdventureWorks2014

---Logic we need inorder to restrict the data to user
---Create a in line table valued function
---create a security 


drop SECURITY POLICY SalesFilter 
go
drop function Security.fn_securitypredicate
go
drop schema security 
go
drop user DAMiller

--alter table [Person].[Person] drop column [login]

--alter table [Person].[Person] add login  AS (left([FirstName],(1))+middleName+[LastName]) persisted 

--SELECT  distinct BusinessEntityID ,[login]
--  FROM [AdventureWorks2014].[Person].[Person] WHERE [LOGIN] IS NOT NULL 
 
--- 
GO

-- Lets look at the data
select * from [Person].[Person]  where login ='DAMiller'

select * from Sales.SalesPerson where BusinessEntityID in (select BusinessEntityID from [Person].[Person]  where login ='DAMiller')

go
drop view vW_Sales_By_User
go

create  VIEW vW_Sales_By_User
as 
SELECT *
      FROM [AdventureWorks2014].[Sales].[SalesPerson] SP 
  WHERE  exists ( select 1 from [Person].[Person] P 
					 where SP.BusinessEntityID = P.BusinessEntityID  
					and ( [LOGIN] = USER_NAME() or  IS_SRVROLEMEMBER ('sysadmin') = 1))

go



CREATE USER DAMiller WITHOUT LOGIN;
grant select on vW_Sales_By_User to DAMiller  

-- I can view all the data becuase I am sys admin
select IS_SRVROLEMEMBER('sysadmin')
Select * from vW_Sales_By_User


EXECUTE AS USER = 'DAMiller';
select * from vW_Sales_By_User

Revert;


GO

CREATE SCHEMA Security;  --optional 
GO


Create FUNCTION Security.fn_securitypredicate(@BusEntId int )
    RETURNS table
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result 
WHERE exists  (SELECT  1 FROM [Person].[Person] where login = USER_NAME() and @BusEntId = BusinessEntityID)
or IS_SRVROLEMEMBER ('sysadmin') = 1
GO



CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE Security.fn_securitypredicate([BusinessEntityID]) 
ON [Sales].[SalesPerson] 
WITH (STATE = ON);
Go

grant select on [Sales].[SalesPerson] to DAMiller
GO


EXECUTE AS USER = 'DAMiller';
select USER_NAME()
SELECT * FROM [Sales].[SalesPerson]; 
REVERT;



ALTER SECURITY POLICY SalesFilter
WITH (STATE = OFF);

select * from sys.security_policies

select * From sys.security_predicates


--Limitation only one predication policy on a table 


--Comparison of RLS and Views,Functions 


revert;
  grant showplan to damiller
  grant select on Security.fn_securitypredicate to damiller

ALTER SECURITY POLICY SalesFilter
WITH (STATE = OFF);

EXECUTE AS USER = 'DAMiller';
--Using Views
select * from vW_Sales_By_User
--Using Functions
select * from sales.SalesPerson p cross apply  Security.fn_securitypredicate(p.BusinessEntityID) cs

revert;

	ALTER SECURITY POLICY SalesFilter	WITH (STATE = ON);
--Using ROw level security
 EXECUTE AS USER = 'DAMiller';

	select * from Sales.SalesPerson

REVERT;




----Middle tier applications/ where application has its own security interface 
--can leverage usiug context 

--
select CONTEXT_INFO()

declare @cinfo varbinary(5) = (select convert(varbinary(5),'DAMiller'))
set context_info @cinfo

select convert(varchar,context_info())
--resolve id using person table

