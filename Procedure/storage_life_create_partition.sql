EXEC create_procedure_if_is_not_created 'storage_life_create_partition'
GO

--создаёт секции схемы секционирования и таблицу storage_life
ALTER PROCEDURE [dbo].[storage_life_create_partition]
(
  @date_from  DATE,
  @date_to    DATE
)AS
BEGIN

  DECLARE
    @cursor                 CURSOR,
    @date_c                 DATE,
    @create_constraint_sql  NVARCHAR (MAX)

 --выравнивание даты
  SET @date_from = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_from, -1)), 1)
  SET @date_to   = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_to)), 1)

  EXEC sp_rename 'dbo.storage_life', 'storage_life_from' -- переименовываем исходную таблицу

  CREATE PARTITION FUNCTION PF_stronge_life_date_commit(DATE) AS -- создаём функцию секционирования
  RANGE RIGHT FOR VALUES (@date_from)

  CREATE PARTITION SCHEME PS_stronge_life_date_commit AS -- создаём схему секционирования
  PARTITION PF_stronge_life_date_commit 
  ALL TO ([PRIMARY])

  CREATE TABLE [dbo].[storage_life]
  (
    id              INT   NOT NULL IDENTITY(1,1),
    date_commit     DATE  NOT NULL,
    id_part         INT   NOT NULL,
    id_guds_unit    INT   NOT NULL,
  ) ON PS_stronge_life_date_commit(date_commit)

  SET @create_constraint_sql='
  ALTER TABLE storage_life_from 
    ADD CONSTRAINT check_stronge_life_date_commit 
      CHECK
      (
            date_commit >= ''##@date_from##''
        AND date_commit <  ''##@date_to##''
      )
      '
      -- выравниваем период на начало и конец месяца (+1 день)
  SET @create_constraint_sql = REPLACE(@create_constraint_sql, '##@date_from##',  CONVERT(NVARCHAR(MAX), @date_from, 23))
  SET @create_constraint_sql = REPLACE(@create_constraint_sql, '##@date_to##',    CONVERT(NVARCHAR(MAX), @date_to, 23))


   EXECUTE SP_EXECUTESQL @create_constraint_sql --добавляем в исходную таблицу ограничения

  ALTER TABLE storage_life_from SWITCH TO storage_life PARTITION 2 -- меняем секцию 2 на исходную таблицу

  SET @cursor = CURSOR SCROLL FOR
  SELECT
    date_value
  FROM dim_date
  WHERE month_day_number  = 1
    AND date_value        > @date_from
    AND date_value        < @date_to

  OPEN @cursor
  FETCH NEXT FROM @cursor INTO @date_c
  WHILE @@FETCH_STATUS = 0
  BEGIN
    BEGIN TRANSACTION

    ALTER PARTITION FUNCTION PF_stronge_life_date_commit() --разбиваем раздел на ещё одну секцию
    SPLIT RANGE (@date_c)

    ALTER PARTITION SCHEME PS_stronge_life_date_commit --следующая партица будет создана в PRIMARY
    NEXT USED [PRIMARY]
    COMMIT

    FETCH NEXT FROM @cursor INTO @date_c
  END

  DROP TABLE storage_life_from --удаление ненужной таблицыб так как данные уже в секционированной таблице storage_life

END

/*
DROP TABLE storage_life
DROP PARTITION SCHEME PS_stronge_life_date_commit
DROP PARTITION FUNCTION PF_stronge_life_date_commit

EXEC storage_life_create
EXEC storage_life_fill               '2014-01-01', '2019-03-12'
EXEC storage_life_create_partition   '2014-01-01', '2029-12-31'
SELECT * FROM storage_life ORDER BY (date_commit)

SELECT o.name objectname,i.name indexname, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id=p.object_id
INNER JOIN sys.indexes i ON i.object_id=p.object_id and p.index_id=i.index_id
WHERE o.name LIKE '%storage_life%'
ORDER BY (partition_number)

*/
