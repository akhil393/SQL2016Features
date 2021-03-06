
--To Enable Dynamic data masking in SQL 16 ctp 2.0/2.1

DBCC TRACEON(209,219,-1)


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [BusinessEntityID]
      ,[EmailAddressID]
      ,[EmailAddress]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [AdventureWorks2014].[Person].[EmailAddress]


  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [CreditCardID]
      ,[CardType]
      ,[CardNumber]
      ,[ExpMonth]
      ,[ExpYear]
      ,[ModifiedDate]
  FROM [AdventureWorks2014].[Sales].[CreditCard]


  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[AdditionalContactInfo]
      ,[Demographics]
      ,[rowguid]
      ,[ModifiedDate]
      ,[login]
  FROM [AdventureWorks2014].[Person].[Person]



alter table person.person add SSN varchar(11) 

Declare @busid int = (select max(BusinessEntityID)  from person.person)
while(@busid >0)
begin
update person.person 
set ssn = Convert(varchar,Convert(int,rand() * 1000000000))
where BusinessEntityID = @busid
set @busid = @busid -1 
end 


select * from person.person 
 

 -- Three Masking functions 
 /*
 Default - Default()

 Email - Email()

 Partial - Partial(Starting Character or int, 'Masking Values',Ending character or int)
 */
 --




 ALTER TABLE person.person ALTER COLUMN [SSN] ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XX-",4)')
  
  
  ALTER TABLE person.person ALTER COLUMN SSN DROP MASKED;


 CREATE USER TestUser WITHOUT LOGIN;
GRANT SELECT ON person.person TO TestUser;

EXECUTE AS USER = 'TestUser';
SELECT * FROM person.person;
REVERT;


 select * from person.person 

 -- default()


alter table [Sales].[CreditCard] alter column cardnumber add masked with (function = 'default()')



GRANT SELECT ON  [Sales].[CreditCard] TO TestUser;
EXECUTE AS USER = 'TestUser';
select * from [Sales].[CreditCard]
REVERT;


alter table [Sales].[CreditCard] alter column Expmonth add masked with (function = 'default()')


EXECUTE AS USER = 'TestUser';
select * from [Sales].[CreditCard]
REVERT;



--Email()




/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [BusinessEntityID]
      ,[EmailAddressID]
      ,[EmailAddress]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Person].[EmailAddress]


alter table [Person].[EmailAddress] alter column [EmailAddress] add masked with (function ='email()')

grant select on [Person].[EmailAddress] to TestUser
EXECUTE AS USER = 'TestUser';
select * from [Person].[EmailAddress]
REVERT;


 Alter table person.person drop column ssn 


 ALTER TABLE PERSON.PERSON  ALTER COLUMN SSN DROP MASKED;

ALTER TABLE [SALES].[CREDITCARD] ALTER COLUMN CARDNUMBER DROP MASKED

ALTER TABLE [SALES].[CREDITCARD] ALTER COLUMN EXPMONTH DROP MASKED 

ALTER TABLE [PERSON].[EMAILADDRESS] ALTER COLUMN [EmailAddress] DROP MASKED;