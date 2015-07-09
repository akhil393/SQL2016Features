enable remote data archive (stredcdb) at instance level

EXEC sp_configure 'remote data archive' , '1';
RECONFIGURE;

enable strech db at database level 
setup (azure remote database and credentials)

enable strech table ( reveiew the requitements and limitations for strechdb)
https://msdn.microsoft.com/en-us/library/dn935016.aspx

---

insert sample data

--- 

view the status of migration using select * from sys.dm_db_rda_migration_status

-- remote database and tables 
select * from  sys.remote_data_archive_databases

 select * from sys.remote_data_archive_tables 
----

check table properties will 0 becuase data is being uploaded to remote azure

--- pause migration on table

insert sample data 

check table properties will show rows that are stored on databse 


---

when queried the table sql server concatinates result from azure(remote query) and table 
----------------


---backup restore 

backup as regular, 

once restore check num of rows in table will be same when the migration is paused 
to setup the link 
run the proc 
declare @azureuser nvarchar(100)='akhil393'
declare @azurepass nvarchar(100)='Vshakunthala1'
EXEC sp_reauthorize_remote_data_archive @azureuser , @azurepass
azure_password
--restore database will have the strech configuration moved 
at this point a new rempote database is created -- so any changed made to this streched table only effects the new remote database
 
