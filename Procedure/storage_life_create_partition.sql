EXEC create_procedure_if_is_not_created 'storage_life_create_partition'
GO
--создаёт секции схему секционирования и таблицу storage_life
ALTER PROCEDURE [dbo].[storage_life_create_partition]
(
  @date_from DATE,
  @date_to DATE
)AS
BEGIN

  DECLARE
    @part_number INT = 3,
    @cursor cursor,
    @date_c DATE,
    @sql_create_PF NVARCHAR (MAX),
    @sql_create_table NVARCHAR (MAX),
    @dates NVARCHAR (MAX)


  SET @date_from = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_from, -1)), 1)
  SET @date_to   = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_to)), 1)

  SET @cursor  = CURSOR SCROLL FOR
    SELECT date_value
    FROM dim_date
    WHERE month_day_number  =   1 
      AND date_value        >=  @date_from 
      AND date_value        <   @date_to

  SELECT 
    @dates = ISNULL(@dates + ', ' ,'') + CONCAT('''', CONVERT(NVARCHAR(MAX), date_value, 23), '''')
  FROM dbo.dim_date
  WHERE month_day_number  =   1
    AND date_value        >=  @date_from AND
    date_value            <   @date_to

  EXEC sp_rename 'dbo.storage_life', 'storage_life_from'

  CREATE PARTITION FUNCTION PF_stronge_life_date_range(DATE) AS
  RANGE RIGHT FOR VALUES (@date_from)

  CREATE PARTITION SCHEME PS_stronge_life_date AS
  PARTITION PF_stronge_life_date_range 
  ALL TO ([PRIMARY])

 CREATE TABLE [dbo].[storage_life]
  (
    id              INT   NOT NULL IDENTITY(1,1),
    date_commit     DATE  NOT NULL,
    id_part         INT   NOT NULL,
    id_guds_unit    INT   NOT NULL,
  ) ON PS_stronge_life_date(date_commit)


  ALTER TABLE storage_life_from SWITCH TO storage_life PARTITION 2

  OPEN @cursor
  FETCH NEXT FROM @cursor INTO @date_c
  FETCH NEXT FROM @cursor INTO @date_c

  WHILE @@FETCH_STATUS = 0
  BEGIN
  ALTER PARTITION FUNCTION PF_stronge_life_date_range() 
  SPLIT RANGE (@date_c)

  ALTER PARTITION SCHEME PS_stronge_life_date
  NEXT USED [PRIMARY]

  FETCH NEXT FROM @cursor INTO @date_c

  END
  DROP TABLE storage_life_from

END
/*
DROP TABLE storage_life
DROP PARTITION SCHEME PS_stronge_life_date
DROP PARTITION FUNCTION PF_stronge_life_date_range

EXEC storage_life_create            '2018-01-12', '2019-05-12'
EXEC period_fill_in_table           '2018-01-12', '2019-05-12','storage_life'
EXEC storage_life_create_partition  '2018-01-12', '2019-05-12'


SELECT o.name objectname,i.name indexname, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id=p.object_id
INNER JOIN sys.indexes i ON i.object_id=p.object_id and p.index_id=i.index_id
WHERE o.name LIKE '%storage_life%'
ORDER BY ( partition_number)
*/

