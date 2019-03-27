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
  PRINT(@sql_сommand)
  EXECUTE SP_EXECUTESQL @sql_сommand
  
  SET @sql_сommand = '
  CREATE PARTITION FUNCTION PF_stronge_life_date_range(DATE) AS
  RANGE RIGHT FOR VALUES (##date_range##)

  CREATE PARTITION SCHEME PS_stronge_life_date AS
  PARTITION PF_stronge_life_date_range
  ALL TO ([PRIMARY])

  CREATE TABLE [dbo].[storage_life_partition]
  (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [date_commit] [date] NOT NULL
      CONSTRAINT OrdersRangeYear
        CHECK ([date_commit]  >= ##date_from##
        AND [date_commit]     < ##date_to##),
    [id_part] [int] NOT NULL,
    [id_guds_unit] [int] NOT NULL
  ) ON PS_stronge_life_date (date_commit)'

  SELECT @sql_сommand = REPLACE(@sql_сommand, '##date_range##', @dates)
  SELECT @sql_сommand = REPLACE(@sql_сommand, '##date_from##',   ''''+CONVERT(NVARCHAR(MAX), @date_from, 23)+'''')
  SELECT @sql_сommand = REPLACE(@sql_сommand, '##date_to##',     ''''+CONVERT(NVARCHAR(MAX), @date_to,   23)+'''')

  EXECUTE SP_EXECUTESQL @sql_сommand
END
/*

DROP TABLE storage_life
DROP PARTITION SCHEME PS_stronge_life_date
DROP PARTITION FUNCTION PF_stronge_life_date_range

EXEC storage_life_create
EXEC storage_life_fill  '2018-01-12', '2019-05-12'
EXEC storage_life_create_partition '2018-01-12', '2019-05-12'


SELECT o.name objectname,i.name indexname, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id=p.object_id
INNER JOIN sys.indexes i ON i.object_id=p.object_id and p.index_id=i.index_id
WHERE o.name LIKE '%storage_life%'
*/