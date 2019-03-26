--EXEC create_procedure_if_is_not_created 'storage_life_create_partition'
--GO
----создаёт секции схему секционирования и таблицу storage_life
--ALTER PROCEDURE [dbo].[storage_life_create_partition]
--(
DECLARE
@date_from DATE,
@date_to DATE


SELECT @date_from = '2000-01-01', @date_to = '3000-01-01' 

--)AS
--BEGIN

  DECLARE
    @sql_сommand NVARCHAR (MAX),
    @dates NVARCHAR (MAX)

  SET @date_from  = DATEADD(DAY,datediff(day, 0, EOMONTH(@date_from,-1)),1)
  SET @date_to    = EOMONTH(@date_to)
  SET @date_to    = DATEADD(DAY,datediff(day, 0, @date_to),1)

  SELECT 
    @dates = ISNULL(@dates + ', ' ,'') + CONCAT('''', CONVERT(NVARCHAR(MAX), date_value, 23), '''')
  FROM dbo.dim_date
  WHERE month_day_number  =   1
    AND date_value        >=  @date_from AND
    date_value            <   @date_to

    

  SET @sql_сommand = '
  CREATE PARTITION FUNCTION PF_stronge_life_date_range(DATE) AS
  RANGE RIGHT FOR VALUES (##date_range##)
'
  SET @sql_сommand = REPLACE(@sql_сommand, '##date_range##', @dates)
  EXECUTE SP_EXECUTESQL @sql_сommand
  --PRINT @sql_сommand
 
  
  CREATE PARTITION SCHEME PS_stronge_life_date AS
  PARTITION PF_stronge_life_date_range
  ALL TO ( [PRIMARY] )

  
  --ALTER TABLE dbo.storage_life DROP CONSTRAINT PK_storage_life

  ----ALTER TABLE dbo.storage_life ADD CONSTRAINT PK_storage_life PRIMARY KEY CLUSTERED (id)
  ----WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
  ----ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

  --CREATE INDEX IX_storage_life_date_commit ON dbo.storage_life (date_commit)
  --WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
  --  ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
  --ON PS_stronge_life_date(date_commit)

--END

/*
ALTER TABLE dbo.storage_life DROP CONSTRAINT PK_storage_life
--DROP TABLE storage_life
DROP PARTITION SCHEME PS_stronge_life_date
DROP PARTITION FUNCTION PF_stronge_life_date_range


EXEC storage_life_create
EXEC storage_life_fill  '2018-01-12', '2019-08-12'
EXEC storage_life_create_partition '2018-01-12', '2019-08-12'


SELECT o.name objectname,i.name indexname, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id=p.object_id
INNER JOIN sys.indexes i ON i.object_id=p.object_id and p.index_id=i.index_id
WHERE o.name LIKE '%storage_life%'
*/